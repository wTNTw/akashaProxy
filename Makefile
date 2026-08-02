NAME=akashaProxy
CC ?= clang
.PHONY: all pack download-dashboard download-mihomo build-webui clean check-deps build-tools default download build-ruleconverter download-geodata
all: default

default: check-deps clean init download pack

check-deps:
	@command -v curl >/dev/null 2>&1 || { echo >&2 "[ERROR] curl is not installed. Please install curl."; exit 1; }
	@command -v unzip >/dev/null 2>&1 || { echo >&2 "[ERROR] unzip is not installed. Please install unzip."; exit 1; }
	@command -v pnpm >/dev/null 2>&1 || { echo >&2 "[ERROR] pnpm is not installed. Please install pnpm."; exit 1; }
	@command -v go >/dev/null 2>&1 || { echo >&2 "[ERROR] go is not installed. Please install go."; exit 1; }
	@command -v upx >/dev/null 2>&1 || { echo >&2 "[ERROR] upx is not installed. Please install upx."; exit 1; }

init:
	@git submodule update --init --recursive
	@mkdir -p tmp
	@cp -rf module/* tmp/
	
download: download-mihomo download-dashboard download-geodata

pack: build-tools build-webui build-ruleconverter
	echo "id=akashaProxy\nname=akashaProxy\nversion="$(shell git rev-parse --short HEAD)"\nversionCode="$(shell git log -1 --format=%ct)"\nauthor=akashaProxy developer\ndescription=akasha terminal transparent proxy module that supports tproxy and tun and adds many easy-to-use features. Compatible with Magisk/KernelSU">tmp/module.prop
	cd tmp && zip -r ../$(NAME).zip *
	@echo "module pack successfully"

download-geodata:
	curl --connect-timeout 5 --progress-bar -L -o tmp/src/GeoSite.dat \
	"https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
	curl --connect-timeout 5 --progress-bar -L -o tmp/src/GeoIP.dat \
	"https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"

download-mihomo:
	@mkdir -p tmp/bin
	remote_mihomo_ver=$$(curl --connect-timeout 5 -L "https://github.com/MetaCubeX/mihomo/releases/latest/download/version.txt") && \
	curl --connect-timeout 5 --progress-bar -L -o tmp/bin/mihomo-android-arm64-v8.gz \
	"https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-android-arm64-v8-$${remote_mihomo_ver}.gz"
	@echo "mihomo download successfully"

download-dashboard:
	@mkdir -p tmp/src/zashboard
	curl --connect-timeout 5 --progress-bar -L -o tmp/src/zashboard/dist-no-fonts.zip \
	"https://github.com/Zephyruso/zashboard/releases/latest/download/dist-no-fonts.zip"
	unzip -o tmp/src/zashboard/dist-no-fonts.zip -d tmp/src/zashboard/
	mv -f tmp/src/zashboard/dist/* tmp/src/zashboard/
	rm -rf tmp/src/zashboard/dist
	rm -rf tmp/src/zashboard/dist-no-fonts.zip
	@echo "dashboard download successfully"

build-webui:
	cd webui && pnpm i
	cd webui && pnpm build
	mv -f ./webui/out ./tmp/webroot
	@echo "webui build successfully"

build-tools:
	cd yamlcli && go mod tidy
	cd yamlcli && CGO_ENABLED=0 GOOS=android GOARCH=arm64 go build -trimpath -ldflags="-s -w" -buildvcs=false -o ../tmp/src/bin/yamlcli
	upx tmp/src/bin/yamlcli
	@echo "yamlcli build successfully"

build-ruleconverter:
	cd plugins/ruleconverter && go mod tidy
	cd plugins/ruleconverter && CGO_ENABLED=0 GOOS=android GOARCH=arm64 go build -trimpath -ldflags="-s -w" -buildvcs=false -o ../../tmp/src/plugins/ruleconverter/bin/ruleconverter
	upx tmp/src/plugins/ruleconverter/bin/ruleconverter
	@echo "ruleconverter build successfully"

clean:
	rm -rf tmp
	rm -rf $(NAME).zip