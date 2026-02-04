## akashaProxy

English | [中文](./readme_zh.md)


### Usage Notes

1. Be able to make independent judgments and analyses.
2. Know how to use search engines.
3. Be able to read official documentation.
4. Have basic Linux knowledge.
5. Enjoy tinkering.
6. akashaProxy is a non-commercial tool that runs on Magisk, providing only Mihomo configuration management and runtime control features.
7. This software is released under the GNU General Public License v3.0 (GPL-3.0).
8. You must follow local laws and regulations when using akashaProxy; the developers and contributors are not responsible for any consequences arising from its use.
9. akashaProxy does not guarantee the legality, authenticity, accuracy, or validity of information obtained through the module (including third-party content); developers and contributors assume no responsibility for how you use it.

> Otherwise, we do not recommend that you use this module.

akashaProxy is a Magisk/KernelSU module for Mihomo.

The name is adapted from the Void Terminal described in the [Mihomo documentation](https://wiki.metacubex.one).

---

**99% of issues with this module originate from incorrect Mihomo configurations or plugin configurations.**

**Please make good use of search engines and logs.**

## Configuration

**Working directory: /data/adb/modules/akashaProxy/config/**

`clash.config`: Module startup configuration.

`config.yaml`: Mihomo configuration file.

`packages.list`: Allowlist/denylist for traffic routed through the proxy.

yacd dashboard: 127.0.0.1:9090/ui (default)

> Rename config.yaml.example to config.yaml and fill in the configuration, or use your own configuration file.

Clash tutorials:
https://wiki.metacubex.one
https://clash-meta.wiki

## Start and Stop

Start:
````
/data/adb/modules/akashaProxy/config/scripts/clash.service -s && /data/adb/modules/akashaProxy/config/scripts/clash.iptables -s
````

Stop:
````
/data/adb/modules/akashaProxy/config/scripts/clash.service -k && /data/adb/modules/akashaProxy/config/scripts/clash.iptables -k
````

You can also manage start and stop with the scripts under /data/adb/modules/akashaProxy/config/tools or via the KernelSU web UI.

## Module

See [docs/module.md](docs/module.md) for the module documentation.

## Build

Run `make` to build and package the module:
````
make
````
> By default, the Android armeabi-v7a and arm64-v8a architectures are built.

## Release

[Telegram](https://t.me/akashaProxyci)

[GitHub Actions (requires extraction)](https://github.com/akashaProxy/akashaProxy/actions)

[GitHub releases](https://github.com/akashaProxy/akashaProxy/releases)