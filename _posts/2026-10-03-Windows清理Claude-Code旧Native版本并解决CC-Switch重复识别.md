---
layout: single
title: "Windows 清理 Claude Code 旧 Native 版本：解决 CC Switch 重复识别两个 Claude"
excerpt: "记录一次 Windows 下 Claude Code 从 Native 迁移到 npm-global 后，CC Switch 仍识别出两个 Claude Code 的排查与清理过程，包括 where.exe、PATH 优先级、旧 Native binary 删除和最终验证。"
categories: 技术 AI工具
tags: [Claude Code, CC Switch, Windows, PowerShell, npm, PATH, Anthropic]
hidden: false
---

## 前言

前面我已经把 Claude Code 从旧的 Native 安装迁移到了自定义 D 盘的 npm-global 安装，并且后续可以直接使用：

~~~powershell
npm install -g --prefix "D:\APP\ClaudeCode" @anthropic-ai/claude-code@latest
~~~

进行升级。

但之后在使用 **CC Switch** 时，又遇到了一个新的问题：

> CC Switch 提示检测到多处 Claude Code，并且两个位置的版本还不一样。

当时 CC Switch 识别到：

~~~text
D:\APP\ClaudeCode\bin\claude.exe     2.1.169
D:\APP\claudeCode\claude.cmd          2.1.288
~~~

这说明虽然新的 npm-global 版本已经安装成功，但原来的旧 Native 可执行文件仍然残留在系统中。

本文记录完整的排查和清理过程。

---

## 1. 问题现象

在 PowerShell 中执行：

~~~powershell
where.exe claude
~~~

得到：

~~~text
D:\APP\ClaudeCode\bin\claude.exe
D:\APP\claudeCode\claude
D:\APP\claudeCode\claude.cmd
~~~

乍一看似乎出现了两个不同的目录：

~~~text
D:\APP\ClaudeCode
D:\APP\claudeCode
~~~

实际上在默认 Windows 文件系统中，路径通常不区分大小写，所以 ClaudeCode 和 claudeCode 通常指向的是同一个目录。

真正的问题不是目录名大小写，而是存在两个不同的 Claude Code 启动入口：

~~~text
D:\APP\ClaudeCode\bin\claude.exe
                             ↑
                         旧 Native

D:\APP\ClaudeCode\claude.cmd
                             ↑
                       新 npm-global
~~~

因此 CC Switch 会把它们识别为两个不同的 Claude Code 安装。

---

## 2. 为什么会留下两个 Claude Code

我之前的安装结构经历过一次迁移。

旧版本：

~~~text
Native 2.1.169
D:\APP\ClaudeCode\bin\claude.exe
~~~

后来迁移为 npm-global 管理：

~~~text
npm-global 2.1.288
D:\APP\ClaudeCode\claude.cmd
~~~

npm-global 实际管理的 Native Binary 位于类似：

~~~text
D:\APP\ClaudeCode\node_modules\@anthropic-ai\claude-code\bin\claude.exe
~~~

但是旧的：

~~~text
D:\APP\ClaudeCode\bin\claude.exe
~~~

并不会因为安装 npm-global 版本而自动删除。

因此系统最后形成：

~~~text
旧 Native binary
        +
新 npm-global launcher
~~~

这就是 CC Switch 重复识别的根本原因。

---

## 3. 为什么 where.exe claude 很重要

Windows 会根据 PATH 中目录的顺序寻找可执行程序。

执行：

~~~powershell
where.exe claude
~~~

不仅可以看到系统中有哪些 Claude 命令入口，还可以看到它们的搜索优先级。

例如：

~~~text
D:\APP\ClaudeCode\bin\claude.exe
D:\APP\ClaudeCode\claude
D:\APP\ClaudeCode\claude.cmd
~~~

第一条通常意味着：

> 直接输入 claude 时，Windows 很可能优先命中旧的 bin\claude.exe。

因此即使已经成功安装新版，也有可能实际上一直在运行旧版。

---

## 4. 分别确认两个 Claude 的版本

不要只执行：

~~~powershell
claude --version
~~~

最好直接指定两个入口分别检查：

~~~powershell
& "D:\APP\ClaudeCode\bin\claude.exe" --version
& "D:\APP\ClaudeCode\claude.cmd" --version
~~~

我这里对应的是：

~~~text
bin\claude.exe   → 2.1.169
claude.cmd        → 2.1.288
~~~

这样就可以确认：

~~~text
2.1.169 = 应删除的旧 Native
2.1.288 = 当前应保留的 npm-global
~~~

---

## 5. 不要直接删除，先改名备份

为了避免误删后无法启动，我先把旧 Native 可执行文件改名：

~~~powershell
Rename-Item "D:\APP\ClaudeCode\bin\claude.exe" "claude.exe.old"
~~~

此时旧文件仍然存在，但已经不会再被 where.exe claude 识别为 Claude Code 命令。

这种做法比直接删除更稳妥。

---

## 6. 重新验证 Claude Code

关闭当前 PowerShell，再重新打开一个终端。

然后执行：

~~~powershell
where.exe claude
~~~

理想情况下应该只剩：

~~~text
D:\APP\ClaudeCode\claude
D:\APP\ClaudeCode\claude.cmd
~~~

再执行：

~~~powershell
claude --version
~~~

确认版本已经是新的 npm-global 版本，例如：

~~~text
2.1.288 (Claude Code)
~~~

也可以继续运行：

~~~powershell
claude doctor
~~~

确认实际运行路径来自 npm-global。

---

## 7. 检查 PATH 中是否还保留旧的 bin 目录

虽然删除旧的 claude.exe 已经可以解决重复识别，但最好继续检查 PATH。

执行：

~~~powershell
$env:Path -split ';' | Where-Object { $_ -match 'ClaudeCode' }
~~~

如果看到：

~~~text
D:\APP\ClaudeCode\bin
D:\APP\ClaudeCode
~~~

说明旧 Native 的目录仍然留在 PATH 中。

现在 npm-global 的启动入口位于：

~~~text
D:\APP\ClaudeCode\claude.cmd
~~~

因此只需要保留：

~~~text
D:\APP\ClaudeCode
~~~

旧的：

~~~text
D:\APP\ClaudeCode\bin
~~~

可以从 Windows 用户 PATH 中删除。

操作位置：

~~~text
系统属性
  → 高级
    → 环境变量
      → 用户变量
        → Path
~~~

删除：

~~~text
D:\APP\ClaudeCode\bin
~~~

保留：

~~~text
D:\APP\ClaudeCode
~~~

修改 PATH 后重新打开终端。

---

## 8. 确认无误后彻底删除旧 Native

如果新的 npm-global Claude Code 已经正常运行，就可以删除刚才的备份：

~~~powershell
Remove-Item "D:\APP\ClaudeCode\bin\claude.exe.old"
~~~

如果 bin 目录已经完全为空，也可以删除目录：

~~~powershell
Remove-Item "D:\APP\ClaudeCode\bin" -Force
~~~

注意：

> 删除目录之前一定先确认里面没有其他需要保留的文件。

---

## 9. 最终推荐目录结构

清理后，我希望 Claude Code 的目录结构保持为：

~~~text
D:\APP\ClaudeCode\
│
├── claude
├── claude.cmd
├── claude.ps1
│
└── node_modules\
    └── @anthropic-ai\
        └── claude-code\
            └── bin\
                └── claude.exe
~~~

其中：

~~~text
claude.cmd
    ↓
npm-global 启动入口

node_modules\...\bin\claude.exe
    ↓
npm 包实际管理的 Native Binary
~~~

而旧的：

~~~text
D:\APP\ClaudeCode\bin\claude.exe
~~~

已经不再存在。

---

## 10. 为什么 CC Switch 最终只应该识别一个 Claude

CC Switch 会扫描系统中可以找到的 Claude Code 可执行入口。

之前：

~~~text
D:\APP\ClaudeCode\bin\claude.exe
D:\APP\ClaudeCode\claude.cmd
~~~

两个入口都存在，所以 CC Switch 会认为系统存在两套 Claude Code。

清理以后只剩 npm-global：

~~~text
D:\APP\ClaudeCode\claude.cmd
~~~

CC Switch 就不会再把旧 Native 版本列出来。

---

## 11. 以后如何升级

现在 Claude Code 已经统一交给 npm-global 管理，而且安装在自定义 D 盘目录。

以后升级只需要：

~~~powershell
npm install -g --prefix "D:\APP\ClaudeCode" @anthropic-ai/claude-code@latest
~~~

然后验证：

~~~powershell
claude --version
where.exe claude
claude doctor
~~~

这种方式可以避免再次使用 Native Installer 后，在其他位置额外生成一套 Claude Code。

---

## 12. 一套完整的排查模板

以后如果再遇到：

- Claude Code 明明升级了，版本却没有变化
- CC Switch 检测到多个 Claude
- claude doctor 显示的安装方式和预期不一致
- 不知道实际执行的是哪一个 claude.exe

可以依次执行：

~~~powershell
where.exe claude

Get-Command claude -All

claude --version

$env:Path -split ';' | Where-Object { $_ -match 'ClaudeCode' }
~~~

如果存在多个候选，再分别执行：

~~~powershell
& "完整路径\claude.exe" --version
& "完整路径\claude.cmd" --version
~~~

判断哪个是旧版本，哪个才是当前应该保留的版本。

---

## 总结

这次问题并不是 CC Switch 识别错误，而是系统中确实同时存在：

~~~text
旧 Native Claude Code
+
新 npm-global Claude Code
~~~

关键排查命令是：

~~~powershell
where.exe claude
~~~

最终处理流程可以概括为：

~~~text
where.exe claude
        ↓
发现旧 Native + 新 npm-global
        ↓
分别检查版本
        ↓
先 Rename-Item 备份旧 claude.exe
        ↓
验证新版 Claude 正常运行
        ↓
从 PATH 删除旧 bin 目录
        ↓
Remove-Item 删除旧 Native
        ↓
CC Switch 只保留一个 Claude Code
~~~

完成清理后，Claude Code 安装方式就统一为 npm-global，并继续保留在 D 盘自定义目录中。以后升级、诊断和 CC Switch 管理都会更加清晰。
