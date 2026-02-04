NAME=akashaProxy
CC ?= clang
.PHONY: all pack download-dashboard download-mihomo build-webui clean check-deps build-tools default download build-ruleconverter download-geodata
all: default

default: check-deps clean pack

check-deps:
	@command -v curl >/dev/null 2>&1 || { echo >&2 "[ERROR] curl is not installed. Please install curl."; exit 1; }
	@command -v unzip >/dev/null 2>&1 || { echo >&2 "[ERROR] unzip is not installed. Please install unzip."; exit 1; }
	@command -v pnpm >/dev/null 2>&1 || { echo >&2 "[ERROR] pnpm is not installed. Please install pnpm."; exit 1; }
	@command -v go >/dev/null 2>&1 || { echo >&2 "[ERROR] go is not installed. Please install go."; exit 1; }
	@command -v upx >/dev/null 2>&1 || { echo >&2 "[ERROR] upx is not installed. Please install upx."; exit 1; }

download: download-mihomo download-dashboard download-geodata
build: build-tools build-webui build-ruleconverter

init:
	mkdir tmp
	cp -r module/* tmp/

pack: init download build
	echo "id=akashaProxy\nname=akashaProxy\nversion="$(shell git rev-parse --short HEAD)"\nversionCode="$(shell git log -1 --format=%ct)"\nauthor=akashaProxy developer\ndescription=akasha terminal transparent proxy module that supports tproxy and tun and adds many easy-to-use features. Compatible with Magisk/KernelSU">tmp/module.prop
	cd tmp && zip -r ../$(NAME).zip *
	@echo "module pack successfully"
	rm -rf tmp

download-geodata:
	curl --connect-timeout 5 --progress-bar -L -o tmp/config/GeoSite.dat \
	"https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
	curl --connect-timeout 5 --progress-bar -L -o tmp/config/GeoIP.dat \
	"https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"

download-mihomo:
	@[ ! -f tmp/config/bin ] && mkdir -p tmp/bin
	remote_mihomo_ver=$$(curl --connect-timeout 5 -L "https://github.com/MetaCubeX/mihomo/releases/latest/download/version.txt") && \
	curl --connect-timeout 5 --progress-bar -L -o tmp/bin/mihomo-android-arm64-v8.gz \
	"https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-android-arm64-v8-$${remote_mihomo_ver}.gz"
	@echo "mihomo download successfully"

download-dashboard:
	@[ ! -f tmp/config/bin ] && mkdir -p tmp/config/zashboard
	curl --connect-timeout 5 --progress-bar -L -o tmp/config/zashboard/dist-no-fonts.zip \
	"https://github.com/Zephyruso/zashboard/releases/latest/download/dist-no-fonts.zip"
	unzip -o tmp/config/zashboard/dist-no-fonts.zip -d tmp/config/zashboard/
	mv -f tmp/config/zashboard/dist/* tmp/config/zashboard/
	rm -rf tmp/config/zashboard/dist
	rm -rf tmp/config/zashboard/dist-no-fonts.zip
	@echo "dashboard download successfully"

build-webui:
	cd webui && pnpm i
	cd webui && pnpm build
	mv -f ./webui/out ./tmp/webroot
	@echo "webui build successfully"

build-tools:
	cd yamlcli && go mod tidy
	cd yamlcli && CGO_ENABLED=0 GOOS=android GOARCH=arm64 go build -trimpath -ldflags="-s -w" -buildvcs=false -o ../tmp/config/bin/yamlcli
	upx tmp/config/bin/yamlcli
	@echo "yamlcli build successfully"

build-ruleconverter:
	cd plugins/ruleconverter && go mod tidy
	cd plugins/ruleconverter && CGO_ENABLED=0 GOOS=android GOARCH=arm64 go build -trimpath -ldflags="-s -w" -buildvcs=false -o ../../tmp/config/plugins/ruleconverter/bin/ruleconverter
	upx tmp/config/plugins/ruleconverter/bin/ruleconverter
	@echo "ruleconverter build successfully"

clean:
	rm -rf tmp
	rm -rf $(NAME).zip