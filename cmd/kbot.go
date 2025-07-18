package cmd

import (
	"context"
	"fmt"
	"os"
	"time"

	"github.com/hirosassa/zerodriver"
	"github.com/spf13/cobra"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetricgrpc"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.12.0"
	"go.opentelemetry.io/otel/trace"
	telebot "gopkg.in/telebot.v3"
)

var (
	TeleToken   = os.Getenv("TELE_TOKEN")
	MetricsHost = os.Getenv("METRICS_HOST")
	tracer      trace.Tracer
)

func initTelemetry(ctx context.Context) {
	if MetricsHost == "" {
		MetricsHost = "localhost:4317"
	}

	// Metrics
	metricExporter, err := otlpmetricgrpc.New(
		ctx,
		otlpmetricgrpc.WithEndpoint(MetricsHost),
		otlpmetricgrpc.WithInsecure(),
	)
	if err != nil {
		fmt.Printf("Failed to create metric exporter: %v\n", err)
		return
	}

	// Traces
	traceExporter, err := otlptracegrpc.New(
		ctx,
		otlptracegrpc.WithEndpoint(MetricsHost),
		otlptracegrpc.WithInsecure(),
	)
	if err != nil {
		fmt.Printf("Failed to create trace exporter: %v\n", err)
		return
	}

	resource := resource.NewWithAttributes(
		semconv.SchemaURL,
		semconv.ServiceNameKey.String("kbot"),
		semconv.ServiceVersionKey.String(appVersion),
	)

	mp := sdkmetric.NewMeterProvider(
		sdkmetric.WithResource(resource),
		sdkmetric.WithReader(
			sdkmetric.NewPeriodicReader(metricExporter, sdkmetric.WithInterval(10*time.Second)),
		),
	)

	tp := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(traceExporter),
		sdktrace.WithResource(resource),
	)

	otel.SetMeterProvider(mp)
	otel.SetTracerProvider(tp)
	tracer = otel.Tracer("kbot")
}

func pmetrics(ctx context.Context, payload string) {
	meter := otel.GetMeterProvider().Meter("kbot_light_signal_counter")
	counter, _ := meter.Int64Counter(fmt.Sprintf("kbot_light_signal_%s", payload))
	counter.Add(ctx, 1)
}

var kbotCmd = &cobra.Command{
	Use:     "kbot",
	Aliases: []string{"start"},
	Short:   "A brief description of your command",
	Run: func(cmd *cobra.Command, args []string) {
		ctx := context.Background()
		initTelemetry(ctx)

		logger := zerodriver.NewProductionLogger()

		kbot, err := telebot.NewBot(telebot.Settings{
			URL:    "",
			Token:  TeleToken,
			Poller: &telebot.LongPoller{Timeout: 10 * time.Second},
		})

		if err != nil {
			logger.Fatal().Str("Error", err.Error()).Msg("Please check TELE_TOKEN")
			return
		} else {
			logger.Info().Str("Version", appVersion).Msg("kbot started")
		}

		kbot.Handle(telebot.OnText, func(m telebot.Context) error {
			ctx, span := tracer.Start(ctx, "handle_message")
			defer span.End()

			traceID := span.SpanContext().TraceID().String()

			logger.Info().
				Str("trace_id", traceID).
				Str("payload", m.Text()).
				Str("user", m.Sender().Username).
				Msg("Processing message")

			payload := m.Message().Payload
			pmetrics(ctx, payload)

			switch payload {
			case "hello":
				err = m.Send(fmt.Sprintf("Hello I'm Kbot %s! TraceID: %s", appVersion, traceID))
			}

			return err
		})

		kbot.Start()
	},
}

func init() {
	rootCmd.AddCommand(kbotCmd)
}
