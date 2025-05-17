FROM golang:1.24.1 AS builder

WORKDIR /go/src/app
COPY . .
# RUN go get - перенести в мейкфайл
RUN make build
FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot"]