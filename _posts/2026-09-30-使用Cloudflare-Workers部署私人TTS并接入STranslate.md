---
layout: single
title: "使用 Cloudflare Workers 部署私人 TTS 服务并接入 STranslate：从一键部署到访问控制的完整实践"
slug: "cloudflare-workers-private-tts-stranslate"
excerpt: "记录一次将基于 Microsoft Edge TTS 的 VoiceCraft 部署到 Cloudflare Workers、增加 PRIVATE_KEY 私人访问认证，并接入 STranslate 的完整过程，同时系统解释 Workers 的 Serverless/边缘计算模型、免费额度、限制与常见排错方法。"
categories: 技术 Cloudflare AI工具
tags: [Cloudflare Workers, Serverless, Edge Computing, TTS, Microsoft Edge TTS, STranslate, JavaScript, API, Cloudflare, 故障排查]
hidden: false
---

## 前言

最近我想给 STranslate 配置一个自己可控的文字转语音服务，最终选择了开源项目 [wangwangit/tts](https://github.com/wangwangit/tts)。

这个项目的特点是：

- 提供完整的 Web TTS 界面；
- TTS 使用 Microsoft Edge TTS；
- 提供 /v1/audio/speech 接口；
- 可以直接部署到 Cloudflare Workers；
- STranslate 的 Microsoft Edge TTS 插件可以配置自定义 API URL。

最终我完成了下面这套结构：

~~~text
浏览器 / STranslate
        |
        v
Cloudflare Workers
        |
        |-- PRIVATE_KEY 认证
        |
        v
Microsoft Edge TTS
        |
        v
MP3 音频
~~~

这次部署本身并不复杂，真正值得记录的是几个容易混淆的问题：

1. Cloudflare Workers 到底是什么？它和 VPS 有什么区别？
2. “一键部署到 Workers”实际上做了什么？
3. Workers 免费版到底有多少请求额度？
4. 为什么部署后的 Worker 默认任何人都可以调用？
5. 如何使用 Cloudflare Secret 给自己的 TTS 加一层私人访问认证？
6. 如何把这个接口配置到 STranslate？
7. 网页能打开但 STranslate 失败时，应该怎样快速定位？

下面按照实际部署过程完整记录。

---

## 1. Cloudflare Workers 到底是什么？

Cloudflare 官方将 Workers 定义为一个用于在 Cloudflare 全球网络上构建、部署和扩展应用的 **Serverless（无服务器）平台**。

官方文档：

- [Cloudflare Workers Overview](https://developers.cloudflare.com/workers/)
- [How Workers works](https://developers.cloudflare.com/workers/reference/how-workers-works/)
- [Serverless computing](https://developers.cloudflare.com/learning-paths/workers/concepts/serverless-computing/)

### 1.1 Serverless 并不是“没有服务器”

“无服务器”这个名字很容易让人误解。

它不是说程序真的不运行在服务器上，而是：

> **服务器的购买、操作系统、扩容、故障恢复、负载均衡等基础设施问题由云平台负责，开发者只需要关心代码。**

传统 VPS 的工作方式通常是：

~~~text
购买 VPS
  ↓
安装 Linux
  ↓
安装 Node.js / Python
  ↓
配置防火墙
  ↓
配置 Nginx
  ↓
配置 HTTPS
  ↓
运行自己的后端程序
  ↓
自己负责更新、重启和维护
~~~

而 Cloudflare Workers 更接近：

~~~text
写 Worker 代码
  ↓
部署
  ↓
Cloudflare 自动运行
~~~

我们不需要拥有或维护一台长期运行的虚拟机。

### 1.2 Workers 是“请求来了才执行”的代码

Worker 最典型的入口是一个 HTTP 请求：

~~~javascript
export default {
    async fetch(request, env, ctx) {
        return new Response("Hello");
    }
};
~~~

当有人访问 Worker URL 时：

~~~text
HTTP Request
      ↓
Cloudflare
      ↓
执行 fetch()
      ↓
返回 Response
~~~

所以 Worker 很适合做：

- API；
- Webhook；
- 反向代理；
- 身份认证；
- URL 重写；
- 轻量 Web 应用；
- Serverless 后端；
- 调用第三方 API；
- 边缘计算逻辑。

### 1.3 Workers 和传统服务器的一个核心区别：V8 Isolates

Cloudflare Workers 的 JavaScript Runtime 基于 V8，也就是 Chromium 和 Node.js 使用的 JavaScript 引擎。

但它并不是为每一个 Worker 启动一整台虚拟机。

Cloudflare 使用的是 **Isolate**。

可以简单理解成：

~~~text
传统虚拟机：

[完整 OS]
[Runtime]
[应用]

Workers：

Cloudflare Runtime
 ├─ Isolate A
 ├─ Isolate B
 ├─ Isolate C
 └─ ...
~~~

Isolate 是一个轻量、相互隔离的执行环境。

这种方式使 Worker 可以快速启动，并在大量请求之间高效切换。

### 1.4 为什么叫“边缘计算”？

普通云服务器通常位于某个固定区域，例如东京、新加坡、香港或美国西部。用户不管从哪里访问，都要连接到那台服务器。

Workers 的思路不同：Worker 代码运行在 Cloudflare 的全球网络上，由 Cloudflare 在靠近请求的位置执行。

因此我们不需要自己维护多个地区的服务器。对于 API、鉴权、代理、轻量 Web 服务，这种模式非常方便。

---

## 2. Workers 在这套 TTS 架构中究竟做了什么？

这里一定要区分：

> **Cloudflare Workers 并没有在 Cloudflare 上运行 Microsoft Edge TTS 模型。**

本次架构实际上是：

~~~text
用户
 |
 | POST /v1/audio/speech
 v
Cloudflare Worker
 |
 | 组织请求 / 鉴权 / 转发
 v
Microsoft Edge TTS
 |
 | 返回语音
 v
Cloudflare Worker
 |
 v
用户
~~~

Worker 的角色更像一个：

> **运行在云端的轻量 API 后端 / 中间层。**

它负责：

- 接收文本；
- 处理 voice、speed、pitch、style 等参数；
- 调用 Microsoft Edge TTS；
- 获取音频；
- 把 MP3 返回给浏览器或 STranslate。

因此这里不是在 Cloudflare GPU 上运行 TTS 大模型，而是 Worker 去调用外部 TTS 服务。

---

## 3. Cloudflare Workers 免费版有多少额度？

以下数据按照我部署时的 Cloudflare 官方文档整理，时间为 **2026-09-30**。以后额度可能调整，建议以官方页面为准：

- [Workers Limits](https://developers.cloudflare.com/workers/platform/limits/)
- [Workers Pricing](https://developers.cloudflare.com/workers/platform/pricing/)

Workers Free 当前主要限制如下：

| 项目 | Workers Free |
| --- | --- |
| Worker 动态请求 | **100,000 次 / 天** |
| 单次 CPU Time | **10 ms** |
| 内存 | **128 MB** |
| 外部 Subrequests | **50 次 / 单次 Worker 调用** |
| 同时向外连接 | **6 个 / 单次请求** |
| Environment Variables | **64 个 / Worker** |
| Cron Triggers | **5 个 / Account** |
| Free Cloudflare 账户请求体上限 | **100 MB** |

### 3.1 100,000 次 / 天是什么意思？

它指进入 Worker 的动态请求。

例如访问网页：

~~~text
GET /
~~~

会执行 Worker。

调用一次 TTS：

~~~text
POST /v1/audio/speech
~~~

也会执行 Worker。

如果一天只有自己使用 STranslate，例如一天调用几百次甚至几千次，对个人用途来说通常距离 100,000 次还有很大余量。

免费额度会在 **UTC 00:00** 重置。

### 3.2 不要把 Workers Free 和 Workers AI 免费额度混淆

Cloudflare 还有一个产品叫 **Workers AI**。

Workers AI 是 Cloudflare 自己提供 GPU 模型推理的产品，它有自己的 Neurons 计费和免费额度。

而本文部署的 Edge TTS 是：

~~~text
Cloudflare Workers
      ↓
Microsoft Edge TTS
~~~

并没有使用 Workers AI。

所以本文应该关注的是：

~~~text
Workers Requests
CPU Time
Subrequests
~~~

而不是 Workers AI Neurons。

### 3.3 Subrequest 是什么？

当 Worker 收到一个外部请求后，它自己又使用 fetch() 请求别的服务，这就是 Subrequest。

例如：

~~~text
STranslate
   |
   | 1 次 Worker Request
   v
Worker
   |
   | Subrequest
   v
Microsoft TTS
~~~

对于长文本，项目可能会把文本切成多个块，然后多次请求 TTS。

因此对于这种项目，除了每天 100,000 次入口请求以外，还应该关注免费计划每次调用最多 **50 个外部 Subrequests** 的限制。

---

## 4. 为什么这个项目适合 Cloudflare Workers？

原项目：

[wangwangit/tts](https://github.com/wangwangit/tts)

项目已经按照 Workers 的形式准备好了：

~~~text
index.js
README.md
wrangler.toml
~~~

其中 wrangler.toml 用来告诉 Cloudflare：

- Worker 名称；
- 入口文件；
- compatibility date；
- compatibility flags；
- 环境变量等部署信息。

例如核心结构类似：

~~~toml
name = "tts-voice-magic"
main = "index.js"
compatibility_date = "2024-01-15"
compatibility_flags = ["nodejs_compat"]
~~~

因此这个项目并不是“普通 Node.js 服务硬塞到 Cloudflare”，它本来就是按 Worker Runtime 设计的。

---

## 5. 一键部署到 Cloudflare Workers 到底做了什么？

项目 README 中提供了 **Deploy to Cloudflare Workers** 按钮。

Cloudflare 官方也专门提供 Deploy Button：

[Deploy to Cloudflare buttons](https://developers.cloudflare.com/workers/platform/deploy-buttons/)

它帮助完成的事情包括：

~~~text
Git 仓库
   ↓
复制 / 克隆源码
   ↓
创建自己的 Git 仓库
   ↓
读取 Workers 配置
   ↓
Cloudflare Build
   ↓
部署 Worker
   ↓
获得 workers.dev 域名
~~~

因此所谓“一键部署”不是下载一个程序到本机，而是在：

> **把 Git 仓库中的应用代码部署到自己的 Cloudflare 账号。**

部署完成后通常会得到类似：

~~~text
https://your-worker.your-subdomain.workers.dev
~~~

以后代码仓库更新后，还可以通过 Cloudflare 的 Git 集成继续构建与部署。

---

## 6. 部署 TTS

最简单的方式是进入原项目 README，点击：

~~~text
Deploy to Cloudflare Workers
~~~

然后：

1. 登录 Cloudflare；
2. 连接 GitHub；
3. 创建自己的项目仓库；
4. 设置 Worker 名称；
5. Deploy。

部署成功之后直接访问：

~~~text
https://your-worker.your-subdomain.workers.dev
~~~

就可以看到 VoiceCraft 页面。

TTS API 地址为：

~~~text
https://your-worker.your-subdomain.workers.dev/v1/audio/speech
~~~

---

## 7. 一个重要问题：默认部署后任何人都可以访问

部署成功后，这个 workers.dev 地址本质上是公网 URL。

如果没有增加认证，只要别人知道：

~~~text
https://your-worker.your-subdomain.workers.dev
~~~

或者：

~~~text
https://your-worker.your-subdomain.workers.dev/v1/audio/speech
~~~

就可以直接调用。

对于公共 Demo 这没有问题。

但我的目的只是：

> **给自己的 STranslate 使用。**

因此我希望：

~~~text
其他人访问 → Unauthorized
我访问 → 正常
STranslate → 正常
~~~

---

## 8. 为什么没有直接使用 Cloudflare Access？

Cloudflare Access 是更完整的身份访问控制方案，例如可以限制只有指定邮箱登录后才能访问。

对于浏览器访问来说，这是非常好的方案。

但是 STranslate 的 Microsoft Edge TTS 插件当前主要配置的是：

- URL；
- Voice；
- Speed；
- Pitch；
- Style。

它并没有直接提供 Cloudflare Access Service Token 所需的多个认证 Header 输入框。

所以如果直接用 Cloudflare Access 把整个 Worker 锁起来：

~~~text
浏览器 → 可以登录
STranslate → 很可能只能拿到登录页面
~~~

为了保持 STranslate 的简单兼容性，我最终使用了一个轻量方案：

> **Cloudflare Secret + PRIVATE_KEY。**

---

## 9. 使用 Cloudflare Secret 保存 PRIVATE_KEY

Cloudflare 官方明确建议 API Key、Token、密码等敏感值使用 Secret，而不是普通明文变量。

官方文档：

[Cloudflare Workers Secrets](https://developers.cloudflare.com/workers/configuration/secrets/)

进入：

~~~text
Cloudflare Dashboard
→ Workers & Pages
→ 选择 Worker
→ Settings
→ Variables and Secrets
→ Add
~~~

创建：

~~~text
Type:
Secret

Variable name:
PRIVATE_KEY

Value:
随机生成的私人密钥
~~~

PowerShell 可以生成一个随机值：

~~~powershell
[guid]::NewGuid().ToString("N") + [guid]::NewGuid().ToString("N")
~~~

注意：

**不要把真正的 PRIVATE_KEY 提交到 GitHub。**

Worker 代码只需要读取：

~~~javascript
env.PRIVATE_KEY
~~~

密钥本身保存在 Cloudflare Secret 中。

---

## 10. 给 Worker 增加私人认证

Worker 的入口原本大致是：

~~~javascript
export default {
    async fetch(request, env, ctx) {
        return handleRequest(request);
    }
};
~~~

修改后将 env 传入：

~~~javascript
export default {
    async fetch(request, env, ctx) {
        return handleRequest(request, env);
    }
};
~~~

然后在路由处理前进行认证。

核心思路：

~~~javascript
const requestUrl = new URL(request.url);

const urlKey = requestUrl.searchParams.get("key") || "";

const authorization = request.headers.get("Authorization") || "";
const bearerKey = authorization.startsWith("Bearer ")
    ? authorization.slice(7).trim()
    : "";

const suppliedKey = bearerKey || urlKey;

if (!env.PRIVATE_KEY || suppliedKey !== env.PRIVATE_KEY) {
    return new Response("Unauthorized", {
        status: 401
    });
}
~~~

这样 API 就可以支持：

~~~text
?key=PRIVATE_KEY
~~~

或者：

~~~http
Authorization: Bearer PRIVATE_KEY
~~~

---

## 11. 浏览器使用 Cookie，避免每次在地址栏里输入 Key

如果网页访问也每次写：

~~~text
https://your-worker.workers.dev/?key=PRIVATE_KEY
~~~

很不方便。

因此我额外加入了一层 Cookie 逻辑。

第一次：

~~~text
/?key=PRIVATE_KEY
~~~

认证成功后 Worker 写入认证 Cookie，并设置：

~~~text
HttpOnly
Secure
SameSite=Strict
Max-Age=2592000
~~~

然后把浏览器重定向回：

~~~text
/
~~~

这样：

~~~text
第一次访问：
/?key=PRIVATE_KEY
        ↓
验证 Key
        ↓
写 Cookie
        ↓
跳转 /

以后访问：
/
        ↓
读取 Cookie
        ↓
正常访问
~~~

Max-Age 为 2,592,000 秒，也就是约 30 天。

---

## 12. Query String Key 的安全注意事项

为了兼容 STranslate，我最终使用：

~~~text
/v1/audio/speech?key=PRIVATE_KEY
~~~

这种方法非常方便，但必须知道：

> Query String 中的 Key 可能出现在浏览器历史、日志、代理记录或截图中。

因此：

- 不要把完整 API URL 提交到 GitHub；
- 不要把带 key 的 URL 放进博客；
- 不要公开截图；
- 一旦怀疑泄露，直接重新生成 PRIVATE_KEY；
- 如果客户端支持 Authorization Header，优先使用 Header。

对于一个仅自己使用的轻量工具，这是一个实用的兼容方案，但不是大型生产系统中最理想的鉴权设计。

---

## 13. 配置到 STranslate

STranslate：

[STranslate GitHub](https://github.com/STranslate/STranslate)

进入：

~~~text
STranslate
→ 设置
→ TTS
→ Microsoft Edge TTS
~~~

填写：

~~~text
API URL:
https://your-worker.your-subdomain.workers.dev/v1/audio/speech?key=PRIVATE_KEY

Voice:
zh-CN-XiaoxiaoNeural

Speed:
1.0

Pitch:
0

Style:
general
~~~

这里最重要的是完整 API URL。

必须包含：

~~~text
/v1/audio/speech
~~~

以及私人认证参数：

~~~text
?key=PRIVATE_KEY
~~~

最终调用链：

~~~text
STranslate
   |
   | POST JSON
   v
Cloudflare Worker
   |
   | PRIVATE_KEY 校验
   v
Microsoft Edge TTS
   |
   v
MP3
   |
   v
STranslate 播放
~~~

---

## 14. 如何在 PowerShell 中验证自己的 API？

如果 STranslate 无法播放，不要第一时间修改 Worker，应该先单独验证 API。

我最终更推荐使用 PowerShell 原生的 Invoke-WebRequest，而不是复杂的 curl 转义。

首先：

~~~powershell
$uri = "https://your-worker.your-subdomain.workers.dev/v1/audio/speech?key=YOUR_PRIVATE_KEY"
~~~

构建 JSON：

~~~powershell
$body = @{
    input = "你好，这是STranslate接口测试"
    voice = "zh-CN-XiaoxiaoNeural"
    speed = 1.0
    pitch = "0"
    style = "general"
} | ConvertTo-Json -Compress
~~~

检查：

~~~powershell
$body
~~~

然后单行发送请求：

~~~powershell
Invoke-WebRequest -Uri $uri -Method POST -ContentType "application/json" -Body $body -OutFile ".\test.mp3"
~~~

播放：

~~~powershell
Start-Process .\test.mp3
~~~

如果 test.mp3 能正常播放，就说明：

~~~text
Worker       OK
PRIVATE_KEY  OK
API          OK
Edge TTS     OK
~~~

这时就应该检查 STranslate 自己的配置，而不是继续修改云端代码。

---

## 15. 这次遇到的几个排错问题

### 15.1 PowerShell 中把 curl 多行参数当成独立命令

曾经出现：

~~~text
-H: 术语 '-H' 不会被识别...
-d: 术语 '-d' 不会被识别...
~~~

原因不是 API，而是后半段参数被 PowerShell 当成了独立命令。

如果必须写多行 curl，需要正确使用 PowerShell 的续行规则；对于 JSON 请求，我后来直接改用 Invoke-WebRequest，反而更加稳定、直观。

### 15.2 Unexpected end of JSON input

还遇到：

~~~json
{
  "error": {
    "message": "Unexpected end of JSON input",
    "code": "edge_tts_error"
  }
}
~~~

这说明：

~~~text
网络连接成功
Worker 路由成功
认证基本成功
JSON Body 解析失败
~~~

也就是说这已经不是“访问不到 Worker”的问题。

最后通过 PowerShell Hashtable + ConvertTo-Json 避免了复杂的字符串转义。

### 15.3 浏览器正常，并不能证明 API 一定正常

浏览器访问：

~~~text
GET /
~~~

和 STranslate：

~~~text
POST /v1/audio/speech
~~~

是两个不同请求。

因此网页正常只能证明 Worker 首页可访问，不能直接证明 TTS POST API 正常。

单独使用 Invoke-WebRequest 测试 API 非常重要。

### 15.4 本次 STranslate 失败的最终原因其实很简单

完成 API 测试后，test.mp3 可以正常播放。

因此服务端链路已经全部排除。

最后重新复制完整 API URL 后，STranslate 立刻恢复正常。

真正的问题是：

> **之前填入 STranslate 的 API URL 写错了。**

正确结构必须是：

~~~text
https://your-worker.your-subdomain.workers.dev/v1/audio/speech?key=PRIVATE_KEY
~~~

这个经历再次说明：

> 在复杂系统里，先逐层验证链路，比一上来修改代码更有效。

---

## 16. 最终架构

最后我的整个私人 TTS 服务是：

~~~text
                     ┌──────────────────────┐
                     │      Browser         │
                     │ 首次 ?key=PRIVATE_KEY │
                     └──────────┬───────────┘
                                │
                                v
                     ┌──────────────────────┐
                     │ Cloudflare Workers   │
                     │                      │
                     │ PRIVATE_KEY Secret   │
                     │ HttpOnly Cookie      │
                     │ API Authentication   │
                     └──────────┬───────────┘
                                │
                                v
                     ┌──────────────────────┐
                     │ Microsoft Edge TTS   │
                     └──────────────────────┘

STranslate
    │
    │ POST /v1/audio/speech?key=...
    │
    └──────────────→ Cloudflare Workers
~~~

我不需要：

- 买 VPS；
- 配 Nginx；
- 配 SSL；
- 长期运行 Node.js 进程；
- 自己维护操作系统；
- 自己处理服务器扩容。

对于这种轻量 API 来说，Workers 的开发和维护成本非常低。

---

## 17. Cloudflare Workers 适合什么，不适合什么？

### 很适合

- API；
- Webhook；
- 身份认证；
- API Gateway；
- 反向代理；
- 请求转换；
- 小型 Web 后端；
- 边缘逻辑；
- 调用第三方服务；
- Serverless 工具；
- 个人在线小应用。

### 不应该把它直接理解成 VPS 替代品

Workers 并不是“一台可以 SSH 登录的 Linux”。

因此如果程序强依赖：

- 长期运行的后台进程；
- 完整 Linux 用户空间；
- 任意系统二进制；
- 固定本地磁盘；
- 自己管理 Docker Daemon；

那么传统 VPS、容器平台或其他计算产品可能更合适。

Workers 更像：

> **一个全球分布、按请求触发、由 Cloudflare 管理基础设施的 Serverless Runtime。**

---

## 18. 免费额度对于个人 TTS 是否够用？

对我的这个场景来说，Workers Free 每天：

~~~text
100,000 requests
~~~

已经非常宽裕。

假设每天使用 STranslate TTS 100 次、500 次或 1000 次，都远低于 100,000。

但要注意，入口请求数并不是唯一限制。

TTS 项目还会请求 Microsoft Edge TTS，因此应该同时关注：

~~~text
CPU Time
Subrequests
第三方 TTS 本身的可用性和限制
~~~

尤其是超长文本被切成大量小块时，比“每天能访问多少次”更容易首先碰到单次请求的资源限制。

---

## 19. 后续可以继续优化什么？

目前这套方案已经足够个人使用。

### 1. 改用 Authorization Header

如果 STranslate 插件增加 API Key / Header 配置，可以从：

~~~text
?key=...
~~~

升级到：

~~~http
Authorization: Bearer ...
~~~

避免 Key 出现在 URL 中。

### 2. 使用 Cloudflare Access

如果客户端可以发送 Service Token Header，可以直接让 Cloudflare Access 负责身份认证。

### 3. 添加 Rate Limit

即使 PRIVATE_KEY 泄露，也可以限制单位时间调用次数。

### 4. 自定义域名

例如：

~~~text
tts.example.com
~~~

比 workers.dev 地址更加容易管理。

### 5. 增加日志和监控

可以利用 Workers 的 Observability 查看请求数量、错误率、CPU Time 和调用日志。

---

## 总结

这次部署最大的收获其实不是“搭好了一个 TTS”，而是通过一个具体的小项目，把 Serverless 和 Cloudflare Workers 的运行模式真正串了起来。

整个过程可以概括成：

~~~text
GitHub 开源项目
      ↓
Deploy to Cloudflare
      ↓
Workers Serverless API
      ↓
配置 PRIVATE_KEY Secret
      ↓
增加私人认证
      ↓
浏览器 Cookie
      ↓
STranslate API URL
      ↓
Microsoft Edge TTS
~~~

如果只看最终结果，它只是一个可以朗读文字的 API。

但从架构上看，它实际上包含了：

- Git 托管；
- CI/CD 部署；
- Serverless；
- 边缘计算；
- Secret 管理；
- API 鉴权；
- 第三方 API 调用；
- 客户端集成；
- HTTP 排错。

而 Cloudflare Workers 的价值也正体现在这里：

> 对于一个不值得专门购买和维护服务器的小型服务，可以用非常低的运维成本把代码直接放到公网运行。

---

## 参考资料

- [Cloudflare Workers Overview](https://developers.cloudflare.com/workers/)
- [How Workers works](https://developers.cloudflare.com/workers/reference/how-workers-works/)
- [Cloudflare Workers Limits](https://developers.cloudflare.com/workers/platform/limits/)
- [Cloudflare Workers Pricing](https://developers.cloudflare.com/workers/platform/pricing/)
- [Deploy to Cloudflare buttons](https://developers.cloudflare.com/workers/platform/deploy-buttons/)
- [Cloudflare Workers Secrets](https://developers.cloudflare.com/workers/configuration/secrets/)
- [wangwangit/tts](https://github.com/wangwangit/tts)
- [STranslate/STranslate](https://github.com/STranslate/STranslate)
