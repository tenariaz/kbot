APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=ghcr.io/tenariaz
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS?=$(shell go env GOOS)
TARGETARCH?=$(shell go env GOARCH)

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) go build -v -o kbot -ldflags "-X=github.com/tenariaz/kbot/cmd.appVersion=$(VERSION)"

linux:
	make build TARGETOS=linux TARGETARCH=amd64

linux-arm:
	make build TARGETOS=linux TARGETARCH=arm64

darwin:
	make build TARGETOS=darwin TARGETARCH=amd64

darwin-arm:
	make build TARGETOS=darwin TARGETARCH=arm64

windows:
	make build TARGETOS=windows TARGETARCH=amd64
	mv kbot kbot.exe

image:
	docker build --build-arg TARGETOS=$(TARGETOS) --build-arg TARGETARCH=$(TARGETARCH) -t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH) .

push:
	docker push $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

clean:
	rm -rf kbot kbot.exe
