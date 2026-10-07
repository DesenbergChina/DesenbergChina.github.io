---
layout: single
title: "Windows 下 Codex 登录失败：failed to start login server（os error 10013）排查与修复"
slug : "codex-login-server-os-error-10013-windows"
excerpt: "记录一次 Windows 下 Codex 登录时报 failed to start login server / os error 10013 的排查过程：检查本地回调端口、Windows 排除端口范围与 WinNAT，并给出可复用的修复步骤。"
categories: 技术 Codex Windows
tags: [OpenAI Codex, Codex CLI, Windows, PowerShell, OAuth, WinNAT, 网络排障]
hidden: false
---

## 前言

在 Windows 上登录 Codex 时，我遇到了下面这个错误：

~~~text
failed to start login server:
以一种访问权限不允许的方式做了一个访问套接字的尝试。
(os error 10013)
~~~

一开始看起来像是“登录失败”或者“网络访问失败”，但这个错误实际上发生在本机登录回调服务启动阶段。

最终问题成功解决。这里把完整排查过程整理下来，方便以后再次遇到相同问题时快速定位。

---

## 1. 这个错误是什么意思？

os error 10013 是 Windows Socket 错误，核心含义是：

> 某个程序尝试创建或监听一个网络套接字，但 Windows 因权限、端口占用或端口保留等原因拒绝了这个操作。

Codex 使用浏览器进行登录时，需要在本机启动一个临时的 OAuth 回调服务。

简单理解就是：

~~~text
Codex
  ↓
启动本地登录服务器
  ↓
浏览器打开 OpenAI 登录页面
  ↓
登录完成后跳回 localhost
  ↓
Codex 接收登录结果
~~~

如果 Codex 无法监听本地回调端口，就可能出现：

~~~text
failed to start login server
os error 10013
~~~

所以这个问题与“OpenAI 账号密码错误”并不是一回事。

---

## 2. 第一件事：检查端口是否被 Windows 保留

本次排障时，Codex 登录回调涉及本机端口 1455。

以管理员身份打开 PowerShell，然后执行：

~~~powershell
netsh interface ipv4 show excludedportrange protocol=tcp
~~~

这个命令用于查看 Windows 当前保留的 TCP 端口范围。

例如可能看到：

~~~text
Protocol tcp Port Exclusion Ranges

Start Port    End Port
----------    --------
1359          1458
...
~~~

如果某个范围覆盖了 1455，那么即使没有普通程序正在使用这个端口，Codex 也可能无法监听它。

也就是说：

~~~text
netstat 看起来没人占用
        ≠
这个端口一定可以使用
~~~

Windows 的排除端口范围也可能阻止程序绑定端口。

> 注意：不同版本的 Codex 后续可能调整登录回调端口。如果实际错误日志显示了其他端口，应以当前版本实际使用的端口为准。

---

## 3. 第二步：检查是否真的有进程占用了端口

继续执行：

~~~powershell
netstat -ano | findstr :1455
~~~

### 情况 A：没有任何输出

如果 netstat 没有输出，但是：

~~~powershell
netsh interface ipv4 show excludedportrange protocol=tcp
~~~

显示某个排除范围包含 1455，那么问题很可能不是普通进程占用，而是 Windows 端口保留。

这种情况重点检查 WinNAT、WSL、Hyper-V、Docker 或 VPN/代理软件对网络栈的影响。

### 情况 B：有输出

例如：

~~~text
TCP    127.0.0.1:1455    0.0.0.0:0    LISTENING    12345
~~~

最后一列 12345 就是 PID。

可以继续查是谁占用了端口：

~~~powershell
tasklist /FI "PID eq 12345"
~~~

如果确认是可以关闭的普通程序，关闭该程序后重新登录 Codex。

不要看到 PID 后就直接结束系统进程，先确认它是什么。

---

## 4. 本次最关键的修复：重新启动 WinNAT

如果端口没有被普通进程占用，却落在 Windows 的排除端口范围中，可以尝试重新启动 WinNAT。

管理员 PowerShell：

~~~powershell
net stop winnat
net start winnat
~~~

然后再次检查：

~~~powershell
netsh interface ipv4 show excludedportrange protocol=tcp
~~~

观察原来覆盖登录端口的排除范围是否已经变化。

接着：

1. 完全退出 Codex。
2. 重新启动 Codex。
3. 再次执行登录。

本次登录失败问题在完成相关端口排查与网络服务处理后成功解决。

### 为什么重启 WinNAT 可能有效？

WinNAT 是 Windows 网络地址转换相关服务。

WSL2、Hyper-V、Docker Desktop 以及部分虚拟网络环境都可能与 Windows NAT 和动态端口分配有关。

重新启动 WinNAT 后，Windows 可能重新生成部分动态网络状态和端口保留范围，从而释放原来阻止 Codex 本地回调服务监听的端口。

---

## 5. 重启 WinNAT 前需要注意什么？

执行：

~~~powershell
net stop winnat
net start winnat
~~~

可能短暂影响依赖 Windows NAT 的程序，例如：

- WSL2
- Docker Desktop
- Hyper-V 虚拟网络
- 部分 VPN
- 部分代理软件

因此建议先保存正在进行的工作。

如果 Docker、WSL 或 VPN 在操作后网络异常，可以重新启动相关程序。

---

## 6. 如果仍然失败：继续按这个顺序检查

推荐按照下面的顺序排查，不要一开始就重装 Codex。

### 第一步：查看排除端口

~~~powershell
netsh interface ipv4 show excludedportrange protocol=tcp
~~~

### 第二步：查看端口占用

~~~powershell
netstat -ano | findstr :1455
~~~

### 第三步：如果有 PID，定位进程

~~~powershell
tasklist /FI "PID eq <PID>"
~~~

### 第四步：尝试重启 WinNAT

管理员 PowerShell：

~~~powershell
net stop winnat
net start winnat
~~~

### 第五步：完全退出并重新启动 Codex

不要只关闭当前终端窗口。

如果是 Codex Desktop，也建议确认后台 Codex 进程已经退出后再重新启动。

---

## 7. Codex CLI 的备用登录方式

如果浏览器 OAuth 登录仍然因为本地回调服务无法启动而失败，可以尝试 Codex CLI 的 device authentication：

~~~powershell
codex login --device-auth
~~~

这种方式不依赖传统的 localhost 浏览器回调流程，因此在本地回调端口异常时可以作为备用方案。

如果当前安装的 Codex CLI 版本不识别这个参数，可以先查看：

~~~powershell
codex login --help
~~~

以本机版本实际提供的登录选项为准。

---

## 8. 一个容易误判的点：10013 不等于“端口被普通进程占用”

这次排障最值得记录的一点是：

~~~text
端口无法监听
~~~

并不一定意味着：

~~~text
另一个程序正在 LISTENING
~~~

Windows 还存在 Excluded Port Range（排除端口范围）。

因此下面两个命令需要一起看：

~~~powershell
netsh interface ipv4 show excludedportrange protocol=tcp

netstat -ano | findstr :1455
~~~

可以用下面这个简单判断：

| 现象 | 更可能的原因 |
|---|---|
| netstat 有 LISTENING | 某个进程正在占用端口 |
| netstat 无输出，但 excluded port range 包含端口 | Windows 保留了端口 |
| 两者都没有 | 再检查防火墙、安全软件、Codex 本身或其他网络配置 |

---

## 9. 最短解决流程

以后再遇到：

~~~text
failed to start login server
os error 10013
~~~

我会优先执行下面四步：

~~~powershell
# 1. 检查 Windows 排除端口
netsh interface ipv4 show excludedportrange protocol=tcp

# 2. 检查 Codex 登录端口是否被进程占用
netstat -ano | findstr :1455

# 3. 如果怀疑 WinNAT 动态端口保留异常
net stop winnat
net start winnat

# 4. 再次检查端口范围
netsh interface ipv4 show excludedportrange protocol=tcp
~~~

然后完全退出 Codex，再重新打开并登录。

---

## 总结

这次 Codex 登录错误：

~~~text
failed to start login server
以一种访问权限不允许的方式做了一个访问套接字的尝试。
(os error 10013)
~~~

核心不是 OpenAI 账号认证失败，而是：

> Codex 无法正常启动本机登录回调服务器。

排查时最重要的是区分两种情况：

~~~text
普通进程占用端口
        vs
Windows 保留/排除该端口
~~~

对应的两个关键命令是：

~~~powershell
netstat -ano | findstr :1455
netsh interface ipv4 show excludedportrange protocol=tcp
~~~

如果确认与 Windows NAT 的动态端口保留有关，可以尝试：

~~~powershell
net stop winnat
net start winnat
~~~

相比直接卸载、重装 Codex，这种方法能够更直接地定位问题本身，也更适合作为以后遇到同类 Windows Socket 10013 错误时的通用排障思路。
