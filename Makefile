.PHONY: generate test serve

generate:
	@go mod tidy
	@go generate ./...
	@echo "[OK] Generate all completed!"

security:
	@gosec ./...
	@echo "[OK] Go security check was completed!"

gitTime=$(shell date +%Y%m%d_%H%M%S)
gitCID=$(shell git rev-parse --short HEAD)
# gitTime=$(git log -1 --format=%at | xargs -I{} date -d @{} +%Y%m%d_%H%M%S)
# 去除 符号信息 和 调试信息  -ldflags="-s -w"
build: generate
	@cd cmd;go build -ldflags "-s -w -X main.build=${gitTime}_${gitCID}" -o "../bin/mini_transfer"
	@echo "[OK] App binary was created!"

buildcross: generate
	@cd cmd;CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -ldflags "-s -w -X main.build=${gitTime}.${gitCID}" -o "../bin/mini_transfer.amd64"
	@cp ./bin/mini_transfer.amd64 ./bin/mini_transfer.x86_64
	@echo "[OK] App amd64 binary was created!"
	@cd cmd;CGO_ENABLED=0 GOARCH=arm64 GOOS=linux go build -ldflags "-s -w -X main.build=${gitTime}.${gitCID}" -o "../bin/mini_transfer.arm64"
	@cp ./bin/mini_transfer.arm64 ./bin/mini_transfer.aarch64
	@echo "[OK] App arm64 binary was created!"
	@cd cmd;CGO_ENABLED=0 GOARCH=mips64le GOOS=linux go build -ldflags "-s -w -X main.build=${gitTime}.${gitCID}" -o "../bin/mini_transfer.mips64le"
	@echo "[OK] App mips64le binary was created!"

# 另有 https://golang.org/doc/install/gccgo 压缩方式
# 使用 upx 压缩 体积 `pacman -S upx`
compress:
	@upx -9 ./bin/mini_transfer

run:
	@./bin/mini_transfer

test:
	go test -v ./...

serve: build run