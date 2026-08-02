# dns_redirect_port 自定义 DNS 劫持转发端口 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 `module/src/clash.config` 插件参数区新增 `dns_redirect_port`，非空时让 akashaProxy 劫持系统 DNS（UDP 53）并转发到该端口。

**Architecture:** 复用现有 `dns_port` 基础设施。`dns_redirect_port` 非空时在 `module/src/clash.env` 中将 `dns_port` 覆盖为该值（优先级高于 `adguardhome_iptables`），`redirect.proxy`/`tproxy.proxy` 已使用 `${dns_port}` 无需改动。

**Tech Stack:** Android Shell (sh/bash)，Magisk/KernelSU 模块，iptables REDIRECT。

**依据设计文档:** `docs/superpowers/specs/2026-08-02-dns-redirect-port-design.md`

---

## 文件结构

- Modify: `module/src/clash.config` — 在插件参数区新增 `dns_redirect_port` 参数（约第 68 行 `adguardhome` 区块附近）
- Modify: `module/src/clash.env:112-114` — 将 adguardhome 覆盖 `dns_port` 的逻辑改为 `dns_redirect_port` 优先
- 不改动：`module/src/scripts/redirect.proxy`、`module/src/scripts/tproxy.proxy`、`module/src/scripts/clash.tool`、`webui`

---

### Task 1: 在 clash.config 新增 dns_redirect_port 参数

**Files:**
- Modify: `module/src/clash.config`（插件参数区，`adguardhome_iptables` 之后）

- [ ] **Step 1: 在插件参数区添加参数**

在 [`module/src/clash.config`](../../../module/src/clash.config:73) 的 `adguardhome_iptables` 参数块之后（`adguardhome_config_file` 之前）插入：

```bash
dns_redirect_port=""
# 由akashaproxy劫持系统dns转发到指定端口(留空则不劫持, 优先级高于adguardhome_iptables)

```

即 `module/src/clash.config` 中该区块最终为：

```bash
adguardhome_iptables="false"
# 由akashaproxy劫持系统dns转发到adguardhome

dns_redirect_port=""
# 由akashaproxy劫持系统dns转发到指定端口(留空则不劫持, 优先级高于adguardhome_iptables)

adguardhome_config_file=""
# adguardhome配置文件路径(为空则在/data/adb中搜索AdGuardHome.yaml)
```

- [ ] **Step 2: 验证参数已添加**

Run: `findstr /n "dns_redirect_port" module\src\clash.config`
Expected: 输出 2 行（参数定义行 + 注释行）

- [ ] **Step 3: 提交**

```bash
git add module/src/clash.config
git commit -m "feat: clash.config 新增 dns_redirect_port 自定义DNS劫持转发端口参数"
```

---

### Task 2: 修改 clash.env 的 dns_port 优先级逻辑

**Files:**
- Modify: `module/src/clash.env:112-114`

- [ ] **Step 1: 更新 dns_port 覆盖逻辑**

将 [`module/src/clash.env`](../../../module/src/clash.env:112) 第 112-114 行的 adguardhome 覆盖逻辑：

```bash
if [ "${adguardhome_iptables}" = "true" ] || [ "${adguardhome}" = "true" ]; then
    dns_port="$(yamlcli -f "${adguardhome_config_file}" get 'dns.port')"
fi
```

替换为（`dns_redirect_port` 非空则优先）：

```bash
if [ -n "${dns_redirect_port}" ]; then
    dns_port="${dns_redirect_port}"
elif [ "${adguardhome_iptables}" = "true" ] || [ "${adguardhome}" = "true" ]; then
    dns_port="$(yamlcli -f "${adguardhome_config_file}" get 'dns.port')"
fi
```

- [ ] **Step 2: 语法检查**

Run: `bash -n module/src/clash.env`
Expected: 无输出（退出码 0）

- [ ] **Step 3: 提交**

```bash
git add module/src/clash.env
git commit -m "feat: clash.env 支持 dns_redirect_port 自定义DNS劫持转发端口(优先级高于adguardhome)"
```

---

### Task 3: 验证 dns_port 优先级逻辑

用独立模拟脚本（不依赖 Android 环境）验证 4 种场景。脚本为临时文件，验证后删除，不提交。

**Files:**
- Create (临时): `/tmp/dns_port_test.sh`

- [ ] **Step 1: 编写模拟验证脚本**

创建 `/tmp/dns_port_test.sh`（内容如下，用假 `yamlcli` 替代真实二进制）：

```bash
#!/bin/bash
# 模拟 clash.env 中 dns_port 覆盖逻辑的优先级验证
PASS=0; FAIL=0
check() {
    local desc="$1" expected="$2" actual="$3"
    if [ "$actual" = "$expected" ]; then
        echo "PASS: $desc (got $actual)"
        PASS=$((PASS+1))
    else
        echo "FAIL: $desc (expected $expected, got $actual)"
        FAIL=$((FAIL+1))
    fi
}

# 假 yamlcli：返回固定 adguardhome dns.port
yamlcli() { echo "3000"; }

resolve_dns_port() {
    local dns_redirect_port="$1" adguardhome_iptables="$2" adguardhome="$3"
    local dns_port="1053"  # 模拟来自 config dns.listen
    if [ -n "${dns_redirect_port}" ]; then
        dns_port="${dns_redirect_port}"
    elif [ "${adguardhome_iptables}" = "true" ] || [ "${adguardhome}" = "true" ]; then
        dns_port="$(yamlcli -f x get 'dns.port')"
    fi
    echo "$dns_port"
}

check "仅 dns_redirect_port=5335"        "5335" "$(resolve_dns_port 5335 false false)"
check "仅 adguardhome_iptables=true"     "3000" "$(resolve_dns_port "" true false)"
check "两者同时设置(自定义优先)"         "5335" "$(resolve_dns_port 5335 true false)"
check "两者均未设置(用config的dns.listen)" "1053" "$(resolve_dns_port "" false false)"
check "adguardhome=true 且未设自定义"     "3000" "$(resolve_dns_port "" false true)"

echo "---"
echo "PASS=$PASS FAIL=$FAIL"
[ "$FAIL" = "0" ]
```

- [ ] **Step 2: 运行脚本验证**

Run: `bash /tmp/dns_port_test.sh`
Expected: 5 个 PASS，FAIL=0，退出码 0

- [ ] **Step 3: 清理临时脚本**

Run: `del /f /q /tmp/dns_port_test.sh`（或 `rm -f /tmp/dns_port_test.sh`）
Expected: 无输出

- [ ] **Step 4: 确认整体工作树状态并汇总提交（无新增文件时仅确认干净）**

Run: `git status`
Expected: 仅 Task 1、Task 2 的两个提交，无未跟踪文件残留

---

## 自审记录

- **Spec 覆盖**：设计文档需求全部对应 — 参数新增（Task 1）、优先级逻辑（Task 2）、4 场景验证（Task 3）。✓
- **占位符扫描**：无 TBD/TODO，所有步骤含完整代码与命令。✓
- **类型一致性**：`dns_redirect_port`、`dns_port` 命名在各任务中一致。✓
