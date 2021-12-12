PROJECT_NAME=chamber-client
GOPATH=$(shell go env GOPATH)

VERSION=$(shell $(GOPATH)/bin/semver get release)
BUILD_TIME=$(shell TZ=UTC date -u '+%Y-%m-%d_%I:%M:%S%p')

STRESS_DURATION=1m
STRESS_QPS=100 

all: clean init build

build: build-darwin build-linux

test:
	go test .

init:
	go get -u \
		github.com/maykonlf/semver-cli/cmd/semver \
	  github.com/securego/gosec/v2/cmd/gosec \
		github.com/rakyll/hey

stress:
	hey -z $(STRESS_DURATION) -q $(STRESS_QPS) -m GET http://localhost:5000

compose-up:
	docker-compose up -d

compose-down:
	docker-compose down

gosec:
	$(GOPATH)/bin/gosec . -tests

upver:
	$(GOPATH)/bin/semver up release

build-windows:
	go mod tidy
	GOOS=windows GOARCH=amd64 go build -o "build/windows/$(PROJECT_NAME)" -ldflags "-X main.Version=$(VERSION) -X main.BuildTime=$(BUILD_TIME)"

build-darwin:
	go mod tidy
	GOOS=darwin  GOARCH=amd64 go build -o "build/darwin/$(PROJECT_NAME)" -ldflags "-X main.Version=$(VERSION) -X main.BuildTime=$(BUILD_TIME)"

build-linux:
	go mod tidy
	GOOS=linux   GOARCH=amd64 go build -o "build/linux/$(PROJECT_NAME)" -ldflags "-X main.Version=$(VERSION) -X main.BuildTime=$(BUILD_TIME)"

clean:
	rm -rf ./build || true
