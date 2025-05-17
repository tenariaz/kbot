APP=$(shell basename $(git remote get-url origin))
REGISTRY=tenariaz
VERSION=${shell git describe --tags --abbrev=0}-${shell git rev-parse --short HEAD}
TARGETOS=linux
TARGETARCH=arm64

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${shell dpkg --print-architecture} go build -v -o kbot -ldflags "-X="github.com/tenariaz/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/s${APP}:${VERSION}-${TARGETARCH}

push:
	docker push ${REGISTRY}/s${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -rf kbot
