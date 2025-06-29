FROM quay.io/projectquay/golang:1.24 AS builder


ARG TARGETOS=linux
ARG TARGETARCH=amd64

WORKDIR /go/src/app
COPY . .
RUN make build TARGETOS=${TARGETOS} TARGETARCH=${TARGETARCH}

FROM quay.io/projectquay/golang:1.24 AS test
WORKDIR /go/src/app
COPY . .
RUN make get
RUN make test

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot", "start"]
