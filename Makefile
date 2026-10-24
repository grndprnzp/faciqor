.PHONY: proto build-cli build-cli-freebsd dev-backend codegen-mobile test-all

proto:
	buf lint
	buf generate

build-cli:
	cd cli && go build -o ../bin/faciqor ./cmd/faciqor

build-cli-freebsd:
	cd cli && GOOS=freebsd GOARCH=amd64 CGO_ENABLED=0 go build -ldflags="-s -w" -o ../bin/faciqor-freebsd-amd64 ./cmd/faciqor

dev-backend:
	cd backend && mix phx.server

codegen-mobile:
	cd mobile && dart run build_runner build --delete-conflicting-outputs

test-all:
	cd backend && mix test
	cd cli && go test ./...
