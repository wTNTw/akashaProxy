# 设计：自定义 DNS 劫持转发端口（dns_redirect_port）

日期：2026-08-02
状态：已确认（方案 A）

## 背景与目标

akashaProxy 模块在 tproxy/redirect 模式下会劫持系统 DNS（UDP 53）并 `REDIRECT` 到 `dns_port` 端口。当前 `dns_port` 来源有两个：

1. 配置文件的 `dns.listen` 端口（[`module/src/clash.env`](../../../module/src/clash.env:51)）
2. `adguardhome_iptables` / `adguardhome` 开启时，覆盖为 adguardhome 配置的 `dns.port`（[`module/src/clash.env`](../../../module/src/clash.env:112)）

**目标**：在 [`module/src/clash.config`](../../../module/src/clash.config:60) 的"插件参数"区新增一个自定义参数 `dns_redirect_port`，当填写端口（如 `5335`）时，akashaProxy 将系统 DNS 劫持并转发到该端口。

## 需求

- 新增参数 `dns_redirect_port=""`（留空 = 不劫持/不启用）
- 当 `dns_redirect_port` 非空时，将系统 DNS（端口 53）转发到该端口
- 优先级：`dns_redirect_port` 非空时覆盖 `adguardhome_iptables` / `adguardhome`
- 生效范围与现有 `adguardhome_iptables` 一致：仅 tproxy/redirect 模式（非 socks、非 tun）

## 实现方案（方案 A）

复用现有 `dns_port` 基础设施，仅需改动两个文件，`redirect.proxy` / `tproxy.proxy` 完全无需改动。

### 1. `module/src/clash.config`

在插件参数区（`adguardhome_iptables` 附近）新增：

```bash
dns_redirect_port=""
# 由akashaproxy劫持系统dns转发到指定端口(留空则不劫持, 优先级高于adguardhome_iptables)
```

### 2. `module/src/clash.env`

将现有 adguardhome 覆盖逻辑（[`module/src/clash.env`](../../../module/src/clash.env:112)）改为：

```bash
if [ -n "${dns_redirect_port}" ]; then
    dns_port="${dns_redirect_port}"
elif [ "${adguardhome_iptables}" = "true" ] || [ "${adguardhome}" = "true" ]; then
    dns_port="$(yamlcli -f "${adguardhome_config_file}" get 'dns.port')"
fi
```

### 3. 无需改动

- `module/src/scripts/redirect.proxy`：已使用 `${dns_port}`
- `module/src/scripts/tproxy.proxy`：已使用 `${dns_port}`
- `module/src/scripts/clash.tool`：端口检查已使用 `dns_port`
- `webui`：不渲染插件参数，无需改动

## 数据流

```
clash.config: dns_redirect_port="5335"
        │
        ▼
clash.env: dns_port="5335"  (dns_redirect_port 非空 → 覆盖)
        │
        ▼
redirect.proxy / tproxy.proxy: iptables REDIRECT udp 53 → ${dns_port}
```

## 错误处理

- `dns_redirect_port` 留空：不覆盖，保持原有 `dns.listen` / adguardhome 逻辑
- 用户填写非数字内容：与现有参数一致，不做额外校验（iptables 会报错并记录到日志）

## 测试

1. 对改动的 shell 文件执行 `bash -n` 语法检查
2. 模拟验证 `dns_port` 优先级：
   - 仅 `dns_redirect_port="5335"` → `dns_port=5335`
   - 仅 `adguardhome_iptables="true"` → `dns_port` = adguardhome `dns.port`
   - 两者同时设置 → `dns_port=5335`（自定义优先）
   - 两者均未设置 → `dns_port` = 配置 `dns.listen` 端口
