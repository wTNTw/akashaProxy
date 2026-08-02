## akashaProxy

中文 | [English](./readme.md)

### 使用须知

1. 拥有自主判断/分析能力
2. 知道如何使用搜索引擎
3. 拥有阅读官方文档的能力
4. 拥有基础的Linux知识
4. 乐于折腾
5. akashaProxy是基于Magsik运行的非商业性质工具，只提供Mihomo的配置管理、运行控制等功能
6. 本软件基于The GNU General Public License v3.0 (GPL-3.0) 开源协议进行开放源代码
7. 使用akashaProxy需遵循当地相关法律法规，任何因使用akashaProxy而产生的任何后果开发者/贡献者不承担任何责任
8. akashaProxy不保证通过本模块获得的信息内容 (包括但不限于调用的第三方内容) 的合法性、真实性、准确性、有效性，开发者/贡献者不对使用者做出的任何行为的结果承担任何责任

> 否则不建议您使用本模块


akashaProxy 是 mihomo 的Magisk/KernelSU模块 

名字来源于[mihomo文档](https://wiki.metacubex.one)的虚空终端修改而来

~~中文名应该叫`虚空代理`~~

---

**此模块99%的问题基本上都来自mihomo配置错误或插件配置错误**

**请善用搜索引擎和日志**

## 配置：

**工作路径：/data/adb/akashaProxy/**

`clash.config` : 模块启动配置

`config.yaml.` ：mihomo配置文件

`packages.list` : 进行代理的黑/白名单列表

yacd管理面板：127.0.0.1:9090/ui（默认）

> 将config.yaml.example重命名为config.yaml后填写配置文件，或者使用你自己的配置文件

clash教程：
https://wiki.metacubex.one
https://clash-meta.wiki

## 启动和停止

开始：
````
/data/adb/akashaProxy/scripts/clash.service -s && /data/adb/akashaProxy/scripts/clash.iptables -s
````

停止：
````
/data/adb/akashaProxy/scripts/clash.service -k && /data/adb/akashaProxy/scripts/clash.iptables -k
````

您还可以使用/data/adb/modules/akashaProxy/config/tools下的脚本管理启停或者使用KernelSU webUI

## 模块

[模块文档](./docs/zh/module-zh.md)

## 编译

执行 `make` 编译并打包模块
````
make
````
> 默认构建android平台下armeabi-v7a架构和arm64-v8a架构

## 发布

[Telegram](https://t.me/akashaProxyci)

[Github工作流(需要解压)](https://github.com/akashaProxy/akashaProxy/actions)

[Github releases](https://github.com/akashaProxy/akashaProxy/releases)