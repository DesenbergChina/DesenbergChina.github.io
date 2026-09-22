---
layout: single
title: "Windows 自定义 D 盘安装并升级 Claude Code：从 Native 迁移到 npm-global 的完整实践"
slug: "Customize the D drive for installation and then upgrade of Claude Code"
excerpt: "记录一次 Windows 下 Claude Code 从自定义 Native 安装迁移到 D 盘 npm-global 管理的完整过程，涵盖安装位置冲突、网络下载失败、旧版本清理、诊断验证与后续一条命令升级。"
categories: 技术 AI工具
tags: [Claude Code, Anthropic, Windows, PowerShell, npm, 开发工具]
hidden: false
---

## 前言

Claude Code 官方当前推荐的安装方式是 Native Install。在 Windows PowerShell 中，常见安装命令是：

```powershell
irm https://claude.ai/install.ps1 | iex
```

对于大多数用户，这种方式最省事：安装简单，并且 Native 安装支持后台自动更新。

但如果你和我一样，有一个额外要求：

> **不希望把程序安装到 C 盘，而是希望统一把开发工具放到自定义目录，例如 `D:\APPz\claudeCode`。**

那么官方 Native Installer 的默认目录就不一定适合你。

本文记录一次完整实践：将原本位于 D 盘的 Claude Code Native 可执行文件，迁移为 **npm-global 管理，同时继续把 Claude Code 程序文件保留在 D 盘**。

最终效果如下：

```text
Running: npm-global (2.1.272)
Path: D:\APPz\claudeCode\node_modules\@anthropic-ai\claude-code\bin\claude.exe
```

后续升级只需要一条命令：

```powershell
npm install -g --prefix "D:\APPz\claudeCode" @anthropic-ai/claude-code@latest
```

---

## 1. 先理解 Claude Code 的几种安装方式

Claude Code 当前常见的 Windows 安装方式主要有：

- Native Installer
- WinGet
- npm global package

其中官方推荐 Native Install：

```powershell
irm https://claude.ai/install.ps1 | iex
```

Native 安装可以自动检查和后台安装更新，也可以手动执行：

```powershell
claude update
```

但是，如果你严格要求程序文件安装到自定义 D 盘目录，npm 的 `--prefix` 会更容易控制安装位置。

值得注意的是，现在通过 npm 安装 Claude Code，并不代表运行一个旧的 JavaScript CLI。

官方文档说明：

> npm 包安装的是和 standalone installer 相同的 native binary。

也就是说，npm 在这里主要承担的是：

```text
下载
  ↓
版本管理
  ↓
安装路径管理
```

真正运行的 `claude.exe` 仍然是 Native Binary。

---

## 2. 我的初始状态

一开始，我的 Claude Code 位于：

```text
D:\APPz\claudeCode\claude.exe
```

查看实际命令位置：

```powershell
where.exe claude
```

输出：

```text
D:\APPz\claudeCode\claude.exe
```

进一步执行：

```powershell
claude doctor
```

可以看到：

```text
Currently running: native (2.1.169)
Path: D:\APPz\claudeCode\claude.exe
Config install method: native
```

说明当时实际运行的是：

```text
安装方式：Native
版本：2.1.169
程序位置：D:\APPz\claudeCode\claude.exe
```

---

## 3. 为什么直接运行 Native Installer 会出现问题

我尝试直接执行官方安装命令：

```powershell
irm https://claude.ai/install.ps1 | iex
```

安装过程中出现：

```text
Failed to fetch version from
https://downloads.claude.ai/claude-code-releases/latest

connect ECONNREFUSED ...:443
```

这个错误表示：

```text
claude.ai/install.ps1        可以访问
        ↓
安装脚本成功启动
        ↓
downloads.claude.ai         无法建立 HTTPS 连接
        ↓
真正的 Claude Code Binary 下载失败
```

也就是说，这不是 PowerShell 语法错误，而是网络路径问题。

可以通过下面几条命令检查：

```powershell
Resolve-DnsName downloads.claude.ai

Test-NetConnection downloads.claude.ai -Port 443

curl.exe -I https://downloads.claude.ai/claude-code-releases/latest
```

如果使用 Clash、Mihomo、v2rayN 等代理，可以在当前 PowerShell 会话中设置：

```powershell
$env:HTTPS_PROXY="http://127.0.0.1:7890"
$env:HTTP_PROXY="http://127.0.0.1:7890"
```

其中 `7890` 应替换为自己的 HTTP 或 Mixed Port。

然后重新测试：

```powershell
curl.exe -I https://downloads.claude.ai/claude-code-releases/latest
```

---

## 4. 更重要的问题：安装位置不符合我的需求

即使网络问题解决，Native Installer 的默认管理目录仍然位于用户目录下。

Windows Native 安装的典型目录包括：

```text
%USERPROFILE%\.local\bin\claude.exe
%USERPROFILE%\.local\share\claude\
```

而我的要求是：

```text
D:\APPz\claudeCode
```

因此我没有继续让 Native Installer 管理安装，而是选择：

> **使用 npm 管理 Claude Code，但通过 `--prefix` 把 Claude Code 单独安装到 D 盘。**

这样既不需要修改系统整体 npm prefix，也不会把其他 npm 全局工具一起迁移到 D 盘。

---

## 5. 先检查系统中到底有几套 Claude Code

迁移之前，先执行：

```powershell
where.exe claude
```

我的系统当时出现：

```text
D:\APPz\claudeCode\claude.exe
C:\Users\dengj\AppData\Roaming\npm\claude
C:\Users\dengj\AppData\Roaming\npm\claude.cmd
```

这说明系统里实际上存在两套来源：

```text
D:\APPz\claudeCode\claude.exe
        ↓
当前正在使用的 Native 版本

C:\Users\dengj\AppData\Roaming\npm\...
        ↓
以前遗留的 npm global 版本
```

再执行：

```powershell
Get-Command claude -All
```

可以进一步确认 PATH 中不同 Claude 命令的优先级。

---

## 6. 清理旧 npm-global 残留

如果 `claude doctor` 提示类似：

```text
Leftover npm global installation
```

可以执行：

```powershell
npm uninstall -g @anthropic-ai/claude-code
```

然后再次检查：

```powershell
where.exe claude
```

理想情况下，此时只剩当前准备迁移的 Claude Code。

---

## 7. 检查 Node.js 版本

官方文档目前说明，从 Claude Code `v2.1.198` 开始，npm 包要求：

```text
Node.js 22+
```

因此先执行：

```powershell
node -v
```

建议至少看到：

```text
v22.x.x
```

虽然 Claude Code 最终运行的是 native binary，但 npm 仍然负责安装过程，因此应满足 npm 包要求。

---

## 8. 备份原来的 Native 可执行文件

为了方便回滚，我没有直接删除原来的：

```text
D:\APPz\claudeCode\claude.exe
```

而是先执行：

```powershell
Rename-Item `
  "D:\APPz\claudeCode\claude.exe" `
  "claude.exe.backup"
```

这样即使后续安装失败，也可以恢复原版本。

---

## 9. 把 Claude Code 安装到指定 D 盘目录

核心命令如下：

```powershell
npm install -g --prefix "D:\APPz\claudeCode" @anthropic-ai/claude-code@latest
```

这里最重要的是：

```text
--prefix "D:\APPz\claudeCode"
```

它的意义是：

> 只让这一次全局安装使用指定目录，而不是修改整个 npm 的全局 prefix。

因此，不需要执行：

```powershell
npm config set prefix "D:\APPz\claudeCode"
```

我的系统原来的 npm prefix 仍然可以保持：

```text
C:\Users\dengj\AppData\Roaming\npm
```

这样更加干净，也不会影响其他 npm 工具。

---

## 10. 安装后的目录结构

安装完成后，Claude Code 会位于类似：

```text
D:\APPz\claudeCode\
│
├── claude.cmd
├── claude.ps1
│
└── node_modules\
    └── @anthropic-ai\
        └── claude-code\
            └── bin\
                └── claude.exe
```

实际诊断结果：

```text
Running: npm-global (2.1.272)
Commit: 013cad548b76
Platform: win32-x64
Path: D:\APPz\claudeCode\node_modules\@anthropic-ai\claude-code\bin\claude.exe
```

说明迁移成功。

---

## 11. 验证是否真的使用了 D 盘版本

安装完成后，至少执行以下三个命令。

### 11.1 查看命令位置

```powershell
where.exe claude
```

确认优先命中的路径来自：

```text
D:\APPz\claudeCode
```

### 11.2 查看版本

```powershell
claude --version
```

本次迁移结果从：

```text
2.1.169
```

升级到了：

```text
2.1.272
```

### 11.3 查看完整诊断

```powershell
claude doctor
```

最终关键输出：

```text
Running: npm-global (2.1.272)
Path: D:\APPz\claudeCode\node_modules\@anthropic-ai\claude-code\bin\claude.exe
```

这里最关键的是两个字段：

```text
Running: npm-global
Path: D:\APPz\...
```

它们共同说明：

> Claude Code 已经由 npm-global 管理，而且实际运行的程序位于 D 盘。

---

## 12. 为什么 `Config install method: native` 还可能存在

迁移后，`claude doctor` 有时仍可能出现：

```text
Config install method: native
```

但同时又显示：

```text
Running: npm-global
Path: D:\APPz\claudeCode\node_modules\...
```

这种情况下，判断当前实际运行方式应该优先看：

```text
Running
Path
```

`Config install method` 可能反映的是历史安装配置或已有配置状态，而不是当前 PATH 实际命中的 Claude Code 可执行文件。

---

## 13. Native 安装残留如何检查

可以检查标准 Native 目录是否还存在：

```powershell
Test-Path "$env:USERPROFILE\.local\bin\claude.exe"
Test-Path "$env:USERPROFILE\.local\share\claude"
```

如果都返回：

```text
False
False
```

说明 C 盘并没有实际残留 Native Claude Code 本体。

如果确实存在，并且你已经决定完全使用 npm 版本，可以删除 Native 安装文件：

```powershell
Remove-Item -Path "$env:USERPROFILE\.local\bin\claude.exe" -Force
Remove-Item -Path "$env:USERPROFILE\.local\share\claude" -Recurse -Force
```

但是不要随意删除：

```text
%USERPROFILE%\.claude
%USERPROFILE%\.claude.json
```

这些目录保存 Claude Code 的用户设置、权限、MCP 配置和状态数据。

---

## 14. 以后升级 Claude Code，只需要一条命令

迁移完成后，以后的升级命令固定为：

```powershell
npm install -g --prefix "D:\APPz\claudeCode" @anthropic-ai/claude-code@latest
```

然后检查：

```powershell
claude --version
```

以及：

```powershell
claude doctor
```

这比重新运行：

```powershell
irm https://claude.ai/install.ps1 | iex
```

更适合需要**严格控制安装目录**的 Windows 用户。

---

## 15. 为什么不推荐用 `npm update -g`

Claude Code 官方文档明确建议 npm 安装用户升级时执行：

```powershell
npm install -g @anthropic-ai/claude-code@latest
```

而不是：

```powershell
npm update -g
```

原因是 `npm update -g` 会遵守原安装包的 semver 范围，不一定升级到最新发布版本。

对于自定义安装目录，则对应为：

```powershell
npm install -g --prefix "D:\APPz\claudeCode" @anthropic-ai/claude-code@latest
```

---

## 16. 可选：写一个升级脚本

如果不想每次输入完整命令，可以新建：

```text
D:\APPz\claudeCode\update-claude.ps1
```

内容：

```powershell
$ClaudePrefix = "D:\APPz\claudeCode"

Write-Host "Updating Claude Code..."

npm install -g --prefix $ClaudePrefix @anthropic-ai/claude-code@latest

Write-Host ""
Write-Host "Current Claude Code version:"
claude --version

Write-Host ""
Write-Host "Claude Code path:"
where.exe claude
```

以后执行：

```powershell
& "D:\APPz\claudeCode\update-claude.ps1"
```

即可完成升级和验证。

---

## 17. 一套完整的迁移流程

如果以后需要在另一台 Windows 机器上复现，可以按照下面的顺序操作。

### 第一步：查看当前安装

```powershell
where.exe claude
Get-Command claude -All
claude --version
claude doctor
```

### 第二步：清理旧 npm-global 安装

```powershell
npm uninstall -g @anthropic-ai/claude-code
```

### 第三步：确认 Node.js

```powershell
node -v
```

确保 Node.js 22 或更高。

### 第四步：安装到 D 盘

```powershell
npm install -g --prefix "D:\APPz\claudeCode" @anthropic-ai/claude-code@latest
```

### 第五步：验证

```powershell
where.exe claude
claude --version
claude doctor
```

最终希望看到：

```text
Running: npm-global
Path: D:\APPz\claudeCode\node_modules\@anthropic-ai\claude-code\bin\claude.exe
```

---

## 18. 最终方案总结

对于普通用户，优先使用官方 Native Installer：

```powershell
irm https://claude.ai/install.ps1 | iex
```

然后让 Claude Code 自动更新，或者手动执行：

```powershell
claude update
```

但如果需求是：

- Windows 环境
- 不希望程序安装到 C 盘
- 希望开发工具统一放在 D 盘
- 希望安装目录完全可控
- 希望后续升级足够简单

那么使用 npm `--prefix` 是一个非常实用的方案：

```powershell
npm install -g --prefix "D:\APPz\claudeCode" @anthropic-ai/claude-code@latest
```

我的最终状态是：

```text
Claude Code: 2.1.272
Install type: npm-global
Binary:
D:\APPz\claudeCode\node_modules\@anthropic-ai\claude-code\bin\claude.exe
```

从此以后，升级只需要重复同一条命令即可。

---

## 参考资料

- [Claude Code Advanced setup](https://code.claude.com/docs/en/setup)
- [Claude Code 官方文档](https://code.claude.com/docs/)

> 注：Claude Code 更新较快，版本号和部分安装行为可能随时间变化。本文中的 `2.1.169 → 2.1.272` 为本次实际迁移记录；长期使用时应以 Anthropic 官方最新文档为准。
