.PHONY: clean init generate test serve dev

generate:
	@go mod tidy
	@go generate ./...
	@echo "[OK] Generate all completed!"

security:
	@gosec ./...
	@echo "[OK] Go security check was completed!"

gitTime=$(shell date +00%y%m%d%H%M%S)
gitCID=$(shell git rev-parse HEAD)
# gitTime=$(git log -1 --format=%at | xargs -I{} date -d @{} +%Y%m%d_%H%M%S)
# 去除 符号信息 和 调试信息  -ldflags="-s -w"
build: generate
	@cd cmd; go build -ldflags "-s -w -X main.build=${gitTime}.${gitCID}" -o "../bin/mini_transfer"
	@echo "[OK] App binary was created!"

init: .git/hooks/pre-push .air

buildcross: generate
	@cd cmd; CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -ldflags "-s -w -X main.build=${gitTime}.${gitCID}" -o "../bin/mini_transfer.amd64"
	@cp ../bin/mini_transfer.amd64 ../bin/mini_transfer.x86_64
	@echo "[OK] App amd64 binary was created!"
	@cd cmd; CGO_ENABLED=0 GOARCH=arm64 GOOS=linux go build -ldflags "-s -w -X main.build=${gitTime}.${gitCID}" -o "../bin/mini_transfer.arm64"
	@cp ../bin/mini_transfer.arm64 ../bin/mini_transfer.aarch64
	@echo "[OK] App arm64 binary was created!"
	@cd cmd; CGO_ENABLED=0 GOARCH=mips64le GOOS=linux go build -ldflags "-s -w -X main.build=${gitTime}.${gitCID}" -o "../bin/mini_transfer.mips64le"
	@echo "[OK] App mips64le binary was created!"

# 另有 https://golang.org/doc/install/gccgo 压缩方式
# 使用 upx 压缩 体积 `pacman -S upx`
compress:
	@upx -9 ../bin/mini_transfer

run:
	@./bin/mini_transfer

#sh -c "ulimit -n 20000; go test ./..."
test:
	go test -v ./...

serve: build run


.git/hooks/pre-push:makefile
	@echo "#!/usr/bin/env bash" > $@
	@echo "set -e" >> $@
	@echo "make test" >> $@
	@echo "cd web && npm run lint" >> $@
	@chmod a+x $@


.air:
	go get -u github.com/cosmtrek/air
	touch .air

dev: p1="air"
dev: p2=["sh", "-c", "cd web && exec npm run serve"]
dev: .air test_data
	@echo 'import subprocess; [p.wait() for p in subprocess.Popen(${p1}),subprocess.Popen(${p2})]' | python2

test_data:
	mkdir test_data
