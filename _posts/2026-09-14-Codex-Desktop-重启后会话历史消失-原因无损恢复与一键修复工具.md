---
layout: single
title: "Codex Desktop 重启后会话历史消失：原因、无损恢复与一键修复工具"
excerpt: "记录 Codex Desktop 切换会话或重启后历史只剩第一条消息的问题，解释 expected ordinal / token_count 投影异常，并提供默认 Dry Run、自动备份、可批量恢复的 PowerShell 7 工具。"
categories: 技术 Codex
tags: [OpenAI Codex, PowerShell, SQLite, Windows, 故障排查]
hidden: false
---

## 前言

最近遇到一个比较隐蔽的 Codex Desktop 问题：**会话进行中一切正常，但切换会话或重新打开 App 后，聊天历史只剩第一条或前几条消息。**

第一反应很容易是“聊天记录丢了”。实际排查后发现，在这一类故障中，原始会话通常仍完整保存在本地 `rollout-*.jsonl` 中，真正出问题的是 Desktop 用来恢复历史的**派生索引 / 历史投影状态**。

恢复原则很简单：

> **不修改原始会话 JSONL，只修复损坏的历史投影游标，再让 Codex runtime 重新刷新线程。**

我把这次排障过程整理成了一个 PowerShell 7 工具，方便以后再次遇到同类问题时直接检查和恢复。

工具目录：

[Codex History Recovery](https://github.com/DesenbergChina/DesenbergChina.github.io/tree/main/tool/Codex-Desktop-重启后会话历史消失-原因无损恢复与一键修复工具)

---

## 1. 典型现象

这类问题通常表现为：

- 当前会话聊天正常；
- 切换会话或重启 Desktop 后，历史明显变短；
- `~/.codex/sessions/` 下的 rollout 文件仍然存在；
- 日志中出现 `expected ordinal` 或 `invalid type: map, expected f64`。

典型日志：

```text
invalid type: map, expected f64
```

随后出现：

```text
thread history projection ... expected ordinal N, got N+1
```

例如：

```text
expected ordinal 17, got 18
```

---

## 2. 为什么历史看起来“消失”了

Codex 本地历史可以粗略理解为：

```text
~/.codex/sessions/.../rollout-*.jsonl
        │
        │ 原始会话记录
        ▼
thread history projector
        │
        ▼
~/.codex/thread_history_1.sqlite
        │
        ▼
Codex Desktop UI
```

我遇到的故障点是一条 `event_msg / token_count`。某些版本的历史 projector 没有正确解析其中的结构化 `rate_limits`，于是把 ordinal `N` 跳过，但 byte offset 已经前进到 `N+1`。

最终形成：

```text
SQLite:
next_rollout_ordinal = N

但：
next_rollout_byte_offset -> JSONL ordinal N+1
```

下一次投影就会得到：

```text
expected ordinal N, got N+1
```

因此，**正在聊天时记录可能仍能看到，但一旦 Desktop 重新从本地历史索引加载，就只剩投影失败之前的部分。**

---

## 3. 先不要做什么

遇到这种情况时，不建议第一时间：

```text
Reset Codex
删除 ~/.codex
删除 sessions
删除 rollout JSONL
手工重写 JSONL ordinal
```

尤其不要直接删除 `~/.codex/sessions/`，因为完整聊天往往就在这些 rollout 文件中。

更稳妥的思路是：

```text
保护原始 rollout
        +
修复派生索引
        +
重新刷新历史
```

---

## 4. 一键恢复工具

工具目录中提供：

```text
codex-history-recovery.ps1
```

它只自动处理本文实际验证过的模式：

```text
SQLite expected ordinal = N
上一条 JSONL           = ordinal N
上一条 payload         = event_msg / token_count
当前 byte offset       = ordinal N+1
```

安全设计：

- 默认只做 Dry Run；
- 自动执行 SQLite `integrity_check`；
- 修改前备份 `thread_history_1.sqlite` 和相关 rollout；
- **从不修改原始 rollout JSONL**；
- 只修严格匹配的 `N -> N+1` cursor mismatch；
- duplicate ordinal、regressed ordinal、未知 schema 等情况一律停止自动修改；
- 修复后通过 Codex `thread/resume` 批量刷新历史。

### 环境要求

```text
Windows 10 / 11
PowerShell 7+
Python 3
Node.js + npm / npx
Codex Desktop
```

脚本支持 `CODEX_HOME`，不会写死 Windows 用户目录；备份目录通过系统 API 获取真实 Desktop，因此也适用于 OneDrive 或桌面重定向。

本文默认使用本次实际验证成功的 Codex CLI `0.154.0`。如需使用其他版本，可通过 `-CodexVersion` 覆盖。

---

## 5. 使用方法

### Step 1：下载脚本

从工具目录下载：

```text
codex-history-recovery.ps1
```

放到任意目录，例如：

```text
D:\Tools\CodexHistoryRecovery\codex-history-recovery.ps1
```

这里的路径只是示例，不包含任何固定用户名或本机目录要求。

### Step 2：先做 Dry Run

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass `
  -File "D:\Tools\CodexHistoryRecovery\codex-history-recovery.ps1"
```

脚本只检查，不修改文件。

如果命中本文故障模式，会看到类似：

```text
SAFE REPAIR CANDIDATES

[1] <THREAD_ID>
    ordinal : 17 -> 18
    skipped : event_msg / token_count

Safe candidates: 1
Suspicious states: 0
```

最关键的是：

```text
ordinal : N -> N+1
skipped : event_msg / token_count
```

### Step 3：完全退出 Codex Desktop

真正修改前，完全关闭 Codex Desktop，避免 Desktop 与脚本同时写 `thread_history_1.sqlite`。

### Step 4：一键修复并刷新

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass `
  -File "D:\Tools\CodexHistoryRecovery\codex-history-recovery.ps1" `
  -Apply
```

脚本会自动完成：

```text
integrity_check
      ↓
识别安全候选
      ↓
备份 SQLite + rollout
      ↓
修正 next_rollout_ordinal
      ↓
再次 integrity_check
      ↓
thread/resume
      ↓
重新物化完整历史
```

最后重新打开 Codex Desktop 即可。

---

## 6. `Safe candidates: 0`，但某个线程仍不完整

有时 cursor 已经恢复正常，但 Desktop 还没有重新物化完整历史。这时不要继续修改 SQLite，只刷新指定线程：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass `
  -File ".\codex-history-recovery.ps1" `
  -RefreshOnly `
  -ThreadIds "<THREAD_ID>"
```

`<THREAD_ID>` 可以从：

```text
codex://threads/<THREAD_ID>
```

中取出。

也可以直接用 Codex CLI 验证：

```powershell
npx -y @openai/codex@0.154.0 resume <THREAD_ID>
```

如果 `resume` 后完整历史重新出现，通常说明原始 rollout 一直都在，问题只发生在本地历史投影层。

---

## 7. 备份在哪里

执行 `-Apply` 后，脚本会在当前 Windows 用户的真实 Desktop 目录创建：

```text
codex-history-recovery-YYYYMMDD-HHMMSS/
├── thread_history_1.sqlite
├── repair-plan.json
└── rollouts/
```

也可以指定其他位置：

```powershell
-BackupRoot "D:\Backup\Codex"
```

---

## 8. 为什么脚本不会“什么都自动修”

这是刻意设计的。

如果发现：

```text
duplicate ordinal
regressed ordinal
JSONL 真正损坏
未知数据库 schema
其他 ordinal 跳变
```

脚本会输出：

```text
Suspicious states were NOT modified
```

而不是猜测数据库应该被改成什么值。

对于恢复工具来说，**知道什么时候停止自动修改，比“尽量多修”更重要。**

---

## 9. 最简恢复流程

以后再次遇到“Codex 重启后聊天历史只剩第一条”，只需要记住两步。

先检查：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass `
  -File ".\codex-history-recovery.ps1"
```

确认候选都是：

```text
ordinal : N -> N+1
skipped : event_msg / token_count
```

完全退出 Codex Desktop，然后：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass `
  -File ".\codex-history-recovery.ps1" `
  -Apply
```

这套方法的本质不是“重建聊天内容”，而是：

```text
保留 canonical rollout
+
修复损坏的历史索引
+
让 Codex runtime 重新物化历史
```

相比 Reset、删除 `.codex` 或直接修改 JSONL，这种恢复方式更保守，也更容易回滚。

> 本文工具针对一次实际出现并验证过的 Codex Desktop 本地历史投影故障。Codex 的本地数据库结构和 app-server 协议未来可能变化；如果脚本报告未知 schema 或 `Suspicious state`，应停止自动修改并重新分析。
