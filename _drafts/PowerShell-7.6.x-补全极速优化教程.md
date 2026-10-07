---
layout: single
title: "PowerShell 7.6.x 补全极速优化教程"
slug: "powershell-7-6-completion-optimization"
excerpt: "针对 PowerShell 7+ 的 Tab 菜单补全、PSReadLine 命令预测、第三方 CLI 补全与性能调优配置记录。"
categories: 技术 Windows PowerShell
tags: [PowerShell, PowerShell 7, PSReadLine, PSCompletions, Windows Terminal, 命令行, 补全]
hidden: false
---

本教程针对 **PowerShell 7+（pwsh.exe）**，不适用于 Windows 自带的 PowerShell 5.1。全程操作约 5 分钟，完成后补全体验可明显改善。

> 当前为草稿，后续实际测试后再根据结果修订并发布。

---

## 一、前置准备（必做）

### 1. 确认版本

打开 PowerShell 7，执行命令确认版本 ≥ 7.2：

~~~powershell
$PSVersionTable.PSVersion
~~~

### 2. 设置脚本执行策略

默认策略可能会阻止加载本地配置脚本。执行以下命令，将执行策略设置为仅对当前用户生效：

~~~powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
~~~

提示输入时按 `Y` 确认即可。

### 3. 升级核心模块 PSReadLine

PowerShell 自带的 PSReadLine 版本可能较旧，可以先升级到最新稳定版，这是后续补全功能的基础：

~~~powershell
Install-Module PSReadLine -Force -SkipPublisherCheck -Scope CurrentUser
~~~

如果提示安装 NuGet 提供者，按 `Y` 确认即可。

---

## 二、基础优化：3 项核心配置

这一步主要解决「按 Tab 只循环候选项、不显示菜单」的问题，同时开启命令自动预测。

### 1. 打开永久配置文件

执行以下命令，自动创建并打开个人配置文件：

~~~powershell
if (!(Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }
notepad $PROFILE
~~~

### 2. 粘贴基础配置

在打开的记事本中，粘贴以下配置：

~~~powershell
# ========== PSReadLine 核心补全配置 ==========
Import-Module PSReadLine

# 1. Tab 键改为菜单式补全
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# 2. 开启命令预测（历史记录 + 插件）
Set-PSReadLineOption -PredictionSource HistoryAndPlugin

# 3. 预测样式：行内提示
# 也可以改为 ListView
Set-PSReadLineOption -PredictionViewStyle InlineView

# 4. 补全时显示参数说明 / 工具提示
Set-PSReadLineOption -ShowToolTips

# 可选：关闭错误提示音
Set-PSReadLineOption -BellStyle None
~~~

### 3. 生效配置

保存配置文件后关闭记事本，然后重启 PowerShell。

也可以执行：

~~~powershell
. $PROFILE
~~~

重新加载配置。

### 基础效果验证

- 输入 `Get-Ch` 后按 `Tab`，观察是否出现菜单式候选列表。
- 输入以前使用过的命令前缀，例如 `cd`，观察是否出现历史命令预测。
- 出现行内预测后，可使用右方向键接受预测内容。

---

## 三、进阶增强：第三方命令补全

PowerShell 原生 cmdlet 补全能力较强，但 `git`、`docker`、`npm`、`python` 等外部 CLI 的补全能力通常依赖额外的 completer。

这里计划使用社区模块 **PSCompletions**。

### 1. 安装 PSCompletions

~~~powershell
Install-Module PSCompletions -Scope CurrentUser -Force
~~~

### 2. 加入配置文件

在 `$PROFILE` 中追加：

~~~powershell
# ========== 第三方命令增强补全 ==========
Import-Module PSCompletions
~~~

### 计划验证的常用工具

后续实际测试以下命令的补全效果：

- git
- docker
- kubectl
- npm / node
- python / pip
- cargo
- go
- java
- winget
- choco

---

## 四、性能调优：解决补全卡顿

如果遇到按 Tab 卡顿、预测延迟较高，可以尝试在配置中追加以下选项：

~~~powershell
# 预测延迟（毫秒），避免输入过程中频繁触发预测
Set-PSReadLineOption -PredictionDelay 150

# 限制历史记录最大条数
Set-PSReadLineOption -MaximumHistoryCount 2000

# 历史记录自动去重
Set-PSReadLineOption -HistoryNoDuplicates
~~~

> 这些选项需要结合实际安装的 PSReadLine 版本验证。若某个参数不存在，应先通过 `Get-Help Set-PSReadLineOption -Full` 检查当前版本支持的参数。

---

## 五、完整配置参考

以下是一份整合后的配置草稿：

~~~powershell
# ========== 执行策略（已设置过可忽略） ==========
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -ErrorAction SilentlyContinue

# ========== PSReadLine 核心补全与交互 ==========
Import-Module PSReadLine

# Tab 键 = 菜单式补全
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Shift+Tab = 反向选择补全项
Set-PSReadLineKeyHandler -Key Shift+Tab -Function TabCompletePrevious

# 命令预测：历史 + 插件
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -PredictionDelay 150

# 补全显示工具提示
Set-PSReadLineOption -ShowToolTips

# 上下箭头 = 前缀匹配历史搜索
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# 关闭错误提示音
Set-PSReadLineOption -BellStyle None

# 历史记录去重
Set-PSReadLineOption -HistoryNoDuplicates

# ========== 第三方命令增强补全 ==========
if (Get-Module -ListAvailable -Name PSCompletions) {
    Import-Module PSCompletions
}
~~~

---

## 六、常见问题排查

### 1. 安装模块提示「找不到匹配的项」

先更新 NuGet 包提供者：

~~~powershell
Install-PackageProvider NuGet -Force -Scope CurrentUser
~~~

然后重新执行模块安装命令。

### 2. 按 Tab 还是循环切换，没有菜单

依次检查：

- 确认当前运行的是 **PowerShell 7（pwsh.exe）**，而不是 Windows PowerShell 5.1。
- 执行 `Get-Module PSReadLine` 查看实际加载的版本。
- 重新启动终端，或者执行 `. $PROFILE` 重新加载配置。

### 3. 行内预测不显示

- Windows Terminal 和 VS Code 集成终端通常支持现代终端渲染能力。
- 执行：

~~~powershell
Get-PSReadLineOption | Select-Object PredictionSource
~~~

确认 `PredictionSource` 是否为 `HistoryAndPlugin`。

### 4. 某个特定命令没有补全

如果第三方补全模块未覆盖某个命令，可以：

1. 搜索该 CLI 是否提供官方 PowerShell completer。
2. 搜索独立的 PowerShell 补全模块。
3. 使用 `Register-ArgumentCompleter` 手动注册。

---

## 效果目标

完成并验证以上配置后，希望达到：

- Tab 键使用菜单式补全。
- 命令、参数、参数值和文件路径均可快速补全。
- 输入命令时出现历史记录或插件预测。
- git、docker、npm 等常用第三方 CLI 获得更好的补全能力。
- 尽量降低补全与预测带来的输入延迟。

---

## 后续测试清单

正式发布前计划重点验证：

- [ ] PowerShell 7.6.x 下所有 PSReadLine 参数是否仍然有效。
- [ ] `PredictionDelay` 是否为当前 PSReadLine 稳定版支持的参数。
- [ ] `HistoryNoDuplicates` 的实际行为及是否仍推荐使用。
- [ ] PSCompletions 的安装源、当前维护状态和实际支持的 CLI 列表。
- [ ] `HistoryAndPlugin` 在未安装 prediction plugin 时的实际表现。
- [ ] MenuComplete 在 Windows Terminal 和 VS Code Terminal 中的显示效果。
- [ ] 配置对 PowerShell 启动速度的影响。
