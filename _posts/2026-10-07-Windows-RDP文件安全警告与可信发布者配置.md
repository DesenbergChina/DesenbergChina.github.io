---

layout: single # 使用单页布局模板

title: "Windows 11：如何安全消除 RDP 文件反复弹出的安全警告" # 文章标题

excerpt: "2026 年 Windows 更新后，双击自己保存的 .rdp 文件也会出现新的安全警告。本文介绍如何通过代码签名证书、RDP 文件签名与受信任发布者策略，只信任自己的 RDP 文件，而不是全局关闭安全机制。" # 文章摘要

categories: 技术 Windows # 文章分类

tags: [Windows 11, RDP, 远程桌面, 数字签名, 证书, Group Policy] # 文章标签

hidden: false # 公开显示

---

## 前言

从 2026 年 4 月 Windows 安全更新开始，`mstsc.exe` 在通过 `.rdp` 文件发起远程桌面连接时，会显示新的安全提示。

即使这个 RDP 文件是自己在“远程桌面连接”里保存出来的，也可能继续提示“未知发布者”或要求确认连接安全设置。

这不是系统认为文件一定有病毒，而是因为：

> **“这个文件是我自己保存的”并不等于“这个文件由 Windows 信任的发布者签名”。**

RDP 文件除了保存目标地址，还可以请求剪贴板、磁盘、摄像头、打印机等本地资源重定向。微软加强这类文件的安全提示，主要是为了降低恶意 RDP 文件被用于钓鱼和本地资源窃取的风险。

本文介绍一种更合理的解决方案：

> **不给所有 RDP 文件关闭安全警告，只让自己明确签名并信任的 RDP 文件免除该警告。**

---

## 一、整体思路

完整流程可以概括为：

```text
创建代码签名证书
        ↓
使用证书签署 .rdp 文件
        ↓
让 Windows 信任该证书
        ↓
把证书 SHA-256 指纹加入
“受信任的 .rdp 发布者”组策略
        ↓
双击该 .rdp 文件时不再显示对应安全警告
```

这里有两个概念必须分开：

### 1. 文件“已签名”

数字签名可以证明：

- 文件由某个证书持有者签署；
- 文件签名后没有被修改。

### 2. 发布者“已受信任”

Windows 还需要知道：

- 这个签名证书是否可信；
- 是否明确允许这个证书作为受信任的 RDP 发布者。

因此：

> **仅给 RDP 文件加签名，并不一定会自动消除安全提示。**

---

## 二、创建一个用于 RDP 签名的证书

Windows PowerShell 自带 `New-SelfSignedCertificate`，可以创建一个个人使用的代码签名证书。

下面使用完全通用的示例信息，不包含任何真实个人数据：

```powershell
$cert = New-SelfSignedCertificate `
    -Type CodeSigningCert `
    -Subject "CN=Personal RDP Publisher" `
    -FriendlyName "Personal RDP Signing" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -NotAfter (Get-Date).AddYears(5) `
    -HashAlgorithm SHA256 `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -KeyUsage DigitalSignature `
    -KeyExportPolicy Exportable
```

几个关键参数：

| 参数 | 作用 |
| --- | --- |
| `CodeSigningCert` | 创建代码签名用途证书 |
| `CurrentUser\My` | 保存到当前用户个人证书库 |
| `SHA256` | 使用 SHA-256 |
| `RSA 2048` | 对个人 RDP 签名已足够 |
| `DigitalSignature` | 仅用于数字签名 |
| `Exportable` | 允许以后导出 PFX 做备份 |

如果只是本机使用，`CurrentUser\My` 通常比 `LocalMachine\My` 更合适，也不需要给所有 Windows 用户共享私钥。

---

## 三、让 Windows 信任这个自签名证书

自签名证书没有公共 CA 为它建立信任链，因此仅存在于“个人”证书库还不够。

先导出公钥证书：

```powershell
Export-Certificate `
    -Cert $cert `
    -FilePath "$env:TEMP\PersonalRdpPublisher.cer"
```

然后导入到当前用户的“受信任的发布者”：

```powershell
Import-Certificate `
    -FilePath "$env:TEMP\PersonalRdpPublisher.cer" `
    -CertStoreLocation "Cert:\CurrentUser\TrustedPublisher"
```

如果这是你自己创建并完全控制的自签名证书，还可以将它加入当前用户的根证书信任：

```powershell
Import-Certificate `
    -FilePath "$env:TEMP\PersonalRdpPublisher.cer" `
    -CertStoreLocation "Cert:\CurrentUser\Root"
```

> **注意：Root 信任权限很高。**
>
> 不要把来源不明的证书加入“受信任的根证书颁发机构”。只有在你明确知道证书来源、用途和私钥归属时才这样做。

也可以通过：

```text
Win + R
→ certmgr.msc
```

在图形界面中查看、导入和导出证书。

---

## 四、给 RDP 文件签名

Windows 自带 `rdpsign.exe`。

建议先做一次测试：

```powershell
rdpsign.exe /sha256 <证书指纹> /l "C:\RDP\server.rdp"
```

`/l` 表示只测试，不真正修改文件。

确认没有错误后，再正式签名：

```powershell
rdpsign.exe /sha256 <证书指纹> /v "C:\RDP\server.rdp"
```

微软文档说明，签名后的输出会覆盖原 RDP 文件，因此建议先备份。

### 修改 RDP 文件后需要重新签名

数字签名保护的是文件内容。

因此以下操作都可能使原签名失效：

- 修改服务器地址；
- 修改用户名；
- 修改磁盘或剪贴板重定向；
- 在远程桌面连接中重新“另存为”覆盖文件；
- 手工编辑 RDP 配置。

修改后应重新签名。

---

## 五、为什么已经签名了，还是会弹警告？

这是最容易遗漏的一步。

**签名证书必须同时被配置成“受信任的 .rdp 发布者”。**

打开本地组策略编辑器：

```text
Win + R
→ gpedit.msc
```

进入：

```text
计算机配置
→ 管理模板
→ Windows 组件
→ 远程桌面服务
→ 远程桌面连接客户端
```

找到：

```text
指定用于标识受信任的 .rdp 发布者的证书指纹
```

英文名称为：

```text
Specify thumbprints of certificates representing trusted .rdp publishers
```

将它设置为：

```text
已启用
```

然后加入签名证书的指纹。

微软说明：当 RDP 文件由该策略中匹配的可信证书签名时，Remote Desktop Connection 不再显示对应的 RDP 文件安全警告。

---

## 六、2026 年以后应优先使用 SHA-256 指纹

2026 年 7 月 Windows 安全更新之后，这个组策略开始支持 SHA-2 指纹。

微软已经明确建议：

> 不要再把 SHA-1 用于新的证书固定（certificate pinning）配置，应迁移到 SHA-256 或更强算法。

新版组策略的帮助信息会说明当前系统支持的格式。

常见形式类似：

```text
sha256:<64位十六进制SHA256指纹>
```

例如：

```text
sha256:0123456789ABCDEF...（此处仅为示例）
```

实际使用时：

- 不要复制示例值；
- 使用自己证书真实的 SHA-256 指纹；
- 按本机组策略右侧“帮助”中要求的前缀和格式填写；
- 如果系统提供“不允许 SHA-1 指纹”选项，新的配置建议保持启用。

配置后执行：

```powershell
gpupdate /force
```

然后完全关闭已经运行的 `mstsc.exe`，重新双击 RDP 文件测试。

---

## 七、如何获得 SHA-256 证书指纹

Windows 传统证书管理界面经常显示的是 SHA-1 Thumbprint。

如果组策略需要 SHA-256，可以直接根据证书原始 DER 数据计算：

```powershell
$cert = Get-ChildItem Cert:\CurrentUser\My |
    Where-Object Subject -eq "CN=Personal RDP Publisher"

$sha256 = [System.Security.Cryptography.SHA256]::Create()
$hash = $sha256.ComputeHash($cert.RawData)

$thumbprint256 = ($hash | ForEach-Object { $_.ToString("X2") }) -join ""

$thumbprint256
```

输出会类似：

```text
0123456789ABCDEF...
```

用于组策略时，根据本机帮助信息添加对应前缀，例如：

```text
sha256:0123456789ABCDEF...
```

---

## 八、常见问题

### 1. 已经显示发布者名称，但仍然弹安全提示

通常说明：

- 文件签名已经存在；
- 但签名证书还没有加入“受信任的 .rdp 发布者”组策略。

重点检查组策略中的 SHA-256 指纹。

### 2. 仍然显示“未知发布者”

通常检查：

- RDP 文件是否在签名后被修改；
- 是否签错了文件；
- 证书是否仍在证书库中；
- 自签名证书是否建立了本地信任；
- Code Signing EKU 和私钥是否存在。

### 3. `rdpsign` 返回 `2148081668`

十六进制为：

```text
0x80092004
```

常见含义是：

```text
CRYPT_E_NOT_FOUND
```

在 RDP 签名场景中，通常表示 `rdpsign` 没有找到指定证书。

检查：

- 证书是否位于 `CurrentUser\My` 或正确的证书库；
- 指纹是否复制正确；
- 是否包含多余空格；
- 当前 Windows 版本的 `rdpsign` 对 SHA-256 指纹的查找行为。

某些系统版本在证书查找方面存在兼容性差异。如果 SHA-256 指纹无法定位证书，可以先通过 `certmgr.msc` 确认 Windows 标准 Thumbprint，并结合当前系统 `rdpsign /?` 的帮助信息进行测试。

### 4. 提示“无法验证远程计算机的身份”

这和本文讨论的 RDP **文件发布者签名**不是同一层问题。

这里至少存在两套证书概念：

```text
RDP 文件签名证书
→ 验证 .rdp 文件是谁发布的

远程服务器 TLS/RDP 证书
→ 验证正在连接的服务器是谁
```

服务器身份警告需要从远程主机证书、主机名、证书链等方向排查。

---

## 九、为什么不建议直接关闭 RDP 安全警告？

最简单粗暴的方法当然是尝试关闭或回退安全提示。

但这样会把：

```text
“只信任我自己的 RDP 文件”
```

变成：

```text
“降低所有 RDP 文件的安全检查”
```

这两个安全模型完全不同。

更合理的方式是：

```text
自己明确创建的 RDP
        ↓
可信证书签名
        ↓
证书指纹加入白名单
        ↓
无需重复确认

陌生或未签名 RDP
        ↓
继续显示安全警告
```

这样既减少自己日常使用中的重复提示，又保留微软新增安全机制对陌生 RDP 文件的保护。

---

## 十、最终检查清单

完成配置后，可以按下面顺序检查：

- [ ] 已创建包含 Code Signing 用途的签名证书；
- [ ] 证书私钥存在；
- [ ] 自签名证书已按需要加入可信证书库；
- [ ] RDP 文件已经通过 `rdpsign.exe` 成功签名；
- [ ] 签名后没有再次修改 RDP 文件；
- [ ] “受信任的 .rdp 发布者”组策略已经启用；
- [ ] 已配置正确的 SHA-256 指纹；
- [ ] 已执行 `gpupdate /force`；
- [ ] 已关闭并重新启动 `mstsc.exe`。

如果这几项都满足，固定使用的可信 RDP 文件就可以避免重复的文件发布者安全提示，而未知来源的 RDP 文件仍然受到安全机制保护。

---

## 参考资料

- Microsoft Learn — Understanding security warnings when opening Remote Desktop (RDP) files  
  https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/remotepc/understanding-security-warnings

- Microsoft Learn — RDP file security settings in Group Policy  
  https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/remotepc/manage-rdp-file-security-settings-with-group-policy

- Microsoft Learn — rdpsign  
  https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/rdpsign

