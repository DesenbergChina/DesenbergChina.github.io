---
layout: single
title: "使用 GoatCounter 为 Jekyll + GitHub Pages 显示网站累计访问量与文章阅读量"
excerpt: "记录在 Minimal Mistakes 主题中接入 GoatCounter 的完整实践：不覆盖核心 layout，通过 custom analytics、footer/custom.html 和首页 include 显示全站累计访问量与单篇文章阅读量。"
categories: 技术 Jekyll
tags: [Jekyll, GitHub Pages, Minimal Mistakes, GoatCounter, 网站统计, 阅读量]
hidden: false
toc: true
toc_sticky: true
---

对于部署在 GitHub Pages 上的 Jekyll 静态博客，一个很常见的需求是：

- 在首页显示**网站累计访问量**；
- 在每篇文章标题下显示**文章阅读量**；
- 不为了统计功能自己维护后端和数据库；
- 尽量不覆盖 Minimal Mistakes 的 `single.html`、`home.html`、`page__meta.html` 等主题文件，降低后续升级主题的维护成本。

本文记录一套基于 **GoatCounter + Minimal Mistakes 官方扩展点**的实现方案。

最终效果类似：

```text
首页：
📈 本站累计访问 128 次

文章页：
◷ 7 minute read · 👁 18 次阅读
```

整个方案只使用一套 GoatCounter 服务，同时完成全站访问统计和单篇文章阅读统计。

---

## 一、为什么选择 GoatCounter？

静态网站本身没有数据库，因此无法像动态网站一样直接在服务器端给浏览量加一。最简单的做法是接入第三方统计服务。

对于个人技术博客，GoatCounter 的优势比较明显：

- 接入简单，只需要一段 JavaScript；
- 不需要自己部署数据库；
- 可以查看后台统计；
- 可以通过公开 Counter API 获取某个页面的访问次数；
- 可以通过特殊路径 `TOTAL` 获取整个站点的累计统计；
- 默认使用 session 去重，反复刷新页面不会简单地不断增加阅读量。

本文的核心思路是：

```text
                     GoatCounter
                         │
                ┌────────┴────────┐
                │                 │
                ▼                 ▼
         TOTAL.json        当前文章 path.json
                │                 │
                ▼                 ▼
          全站累计访问         文章阅读量
                │                 │
                ▼                 ▼
        index.markdown      footer/custom.html
```

---

## 二、最终文件结构

推荐保持下面的结构：

```text
项目根目录/
│
├── _config.yml
├── index.markdown
│
└── _includes/
    ├── analytics-providers/
    │   └── custom.html
    │
    ├── footer/
    │   └── custom.html
    │
    └── site-stats.html
```

这套结构有一个很重要的特点：

```text
_layouts/single.html      不覆盖
_layouts/home.html        不覆盖
_includes/page__meta.html 不覆盖
主题 Gem                  不修改
```

也就是说，绝大多数 Minimal Mistakes 主题更新仍然可以直接继承。

---

## 三、创建并配置 GoatCounter

进入 GoatCounter 创建站点后，会得到一个站点 Code。

例如：

```text
desenbergchina
```

那么统计地址就是：

```text
https://desenbergchina.goatcounter.com
```

这里最容易犯的错误就是把 Code 写错。

例如真实 Code 是：

```text
desenbergchina
```

但代码里却写成：

```text
desenberg
```

那么统计脚本即使成功加载，也不会访问到正确的 GoatCounter 站点。

### 推荐的后台配置

在 GoatCounter `Settings` 中，个人博客可以保持类似下面的配置：

```text
Your site:
desenbergchina.github.io

Code:
desenbergchina

Allow adding visitor counts on your website:
✓

Custom domain:
留空

Dashboard:
Only logged in users

Data retention:
0

Individual pageviews:
✗

Sessions:
✓

Referrer:
✓

User-Agent:
✓
```

其中最关键的是：

```text
Allow adding visitor counts on your website
```

必须开启，否则公开 Counter 无法正常用于网页显示访问数字。

另外建议保留：

```text
Sessions ✓
```

这样同一用户短时间内反复刷新同一个页面时，不会把每一次刷新都简单算成新的阅读。

---

## 四、让 Minimal Mistakes 加载 GoatCounter

Minimal Mistakes 已经提供了自定义 Analytics 的扩展点，因此没有必要修改主题 layout。

在 `_config.yml` 中加入：

```yaml
analytics:
  provider: "custom"
```

然后创建：

```text
_includes/analytics-providers/custom.html
```

内容如下：

```html
<script
  data-goatcounter="https://desenbergchina.goatcounter.com/count"
  async
  src="https://gc.zgo.at/count.js">
</script>
```

如果使用自己的站点，请把：

```text
desenbergchina
```

替换成自己的 GoatCounter Code。

这一段代码负责真正把页面访问发送到 GoatCounter。

---

## 五、文章页显示阅读量：不要覆盖 `page__meta.html`

最开始很容易想到：

> Minimal Mistakes 的阅读时间就在 `page__meta.html` 中，那我直接覆盖这个文件，再把浏览量写进去不就行了吗？

技术上当然可以，但这会增加主题升级时的维护成本，而且还有一个容易忽略的问题。

Minimal Mistakes 不仅文章正文会调用 `page__meta.html`，相关文章卡片等位置也可能调用它。如果在这个 include 中直接加入浏览量组件，就可能出现：

```text
Views for this page: 0
Views for this page: 0
Views for this page: 0
```

甚至多个元素使用相同 `id`，最终全部插入文章顶部。

更干净的方案是利用主题提供的：

```text
_includes/footer/custom.html
```

在文章页面加载完成后，用 JavaScript 精确找到标题下面的 `.page__meta`，动态插入阅读量。

### 创建 `footer/custom.html`

创建：

```text
_includes/footer/custom.html
```

写入：

```liquid
{% if page.collection == "posts" %}
<script>
(function () {
  const meta = document.querySelector(
    ".page__inner-wrap > header > .page__meta"
  );

  if (!meta || document.getElementById("gc-pageviews")) {
    return;
  }

  const separator = document.createElement("span");
  separator.className = "page__meta-sep";

  const views = document.createElement("span");
  views.className = "page__meta-item page__views";
  views.innerHTML =
    '<i class="fas fa-fw fa-eye" aria-hidden="true"></i>' +
    '<span id="gc-pageviews">--</span> 次阅读';

  meta.appendChild(separator);
  meta.appendChild(views);

  const path =
    window.goatcounter && window.goatcounter.get_data
      ? window.goatcounter.get_data().p
      : window.location.pathname;

  fetch(
    "https://desenbergchina.goatcounter.com/counter/" +
    encodeURIComponent(path) +
    ".json"
  )
    .then(function (response) {
      if (response.status === 404) {
        return { count: "0" };
      }

      if (!response.ok) {
        throw new Error("GoatCounter request failed");
      }

      return response.json();
    })
    .then(function (data) {
      document.getElementById("gc-pageviews").textContent =
        data.count || "0";
    })
    .catch(function () {
      document.getElementById("gc-pageviews").textContent = "--";
    });
})();
</script>
{% endif %}
```

同样，如果是自己的 GoatCounter 站点，需要替换：

```text
desenbergchina
```

### 为什么使用 `page.collection == "posts"`？

这可以把脚本限制在博客文章中，而不是所有 `single` layout 页面。

因此：

```text
博客文章     → 显示阅读量
关于我       → 不显示
分类页       → 不显示
标签页       → 不显示
首页         → 不显示
```

### 为什么选择器写得这么具体？

这里使用：

```js
document.querySelector(
  ".page__inner-wrap > header > .page__meta"
);
```

而不是简单写：

```js
document.querySelector(".page__meta");
```

原因是 Minimal Mistakes 页面里可能不止一个 `.page__meta`。

我们真正需要的是：

```text
.page__inner-wrap
       │
       └── header
              │
              └── .page__meta
```

也就是**文章标题正下方的元信息区域**。

最终页面效果类似：

```text
◷ 7 minute read · 👁 18 次阅读
```

---

## 六、为什么不用 `goatcounter.visit_count()`？

GoatCounter 官方确实提供：

```js
window.goatcounter.visit_count({
  append: "#gc-pageviews",
  no_branding: true
});
```

但是这个函数的用途是插入一个完整的访客计数组件，而不是只返回数字。

默认效果类似：

```text
┌─────────────────────────┐
│ Views for this page:    │
│            18           │
└─────────────────────────┘
```

即使设置：

```js
no_branding: true
```

也只是隐藏 GoatCounter 品牌，并不会只留下数字。

对于已经有完整视觉样式的博客，更适合直接使用 GoatCounter 的 JSON Counter：

```text
https://YOURCODE.goatcounter.com/counter/[PATH].json
```

它会返回类似：

```json
{
  "count": "18"
}
```

然后我们只把：

```text
18
```

写进页面，这样最终显示样式完全由 Minimal Mistakes 控制。

---

## 七、首页显示网站累计访问量

GoatCounter 为整个站点提供了一个特殊路径：

```text
TOTAL
```

因此可以通过：

```text
https://YOURCODE.goatcounter.com/counter/TOTAL.json
```

获得全站累计统计。

### 创建首页统计组件

新建：

```text
_includes/site-stats.html
```

内容：

```html
<p class="site-stats">
  <i class="fas fa-chart-line" aria-hidden="true"></i>
  本站累计访问
  <strong id="gc-total-views">--</strong>
  次
</p>

<script>
(function () {
  const counter = document.getElementById("gc-total-views");

  if (!counter) {
    return;
  }

  fetch("https://desenbergchina.goatcounter.com/counter/TOTAL.json")
    .then(function (response) {
      if (response.status === 404) {
        return { count: "0" };
      }

      if (!response.ok) {
        throw new Error("GoatCounter request failed");
      }

      return response.json();
    })
    .then(function (data) {
      counter.textContent = data.count || "0";
    })
    .catch(function () {
      counter.textContent = "--";
    });
})();
</script>
```

---

## 八、在 `index.markdown` 中插入累计访问量

如果主页使用：

```yaml
layout: home
```

完全没有必要覆盖 Minimal Mistakes 的 `home.html`。

只需要在自己的主页 Markdown 中调用 include。

例如：

```markdown
---
layout: home
---

## 欢迎来到我的博客

{% include site-stats.html %}
```

这样首页就会出现：

```text
欢迎来到我的博客

📈 本站累计访问 128 次
```

而下面仍然继续使用主题原生的文章列表。

---

## 九、可选：给首页统计增加一点样式

如果希望统计信息稍微弱化一些，可以在自己的 `assets/css/main.scss` 中增加：

```scss
.site-stats {
  margin: 1rem 0 2rem;
  font-size: 0.9em;
  color: var(--global-text-color-light);

  strong {
    margin: 0 0.2em;
    color: var(--global-text-color);
  }
}
```

这里没有做复杂卡片，而是尽量让它保持和博客正文一致的视觉风格。

---

## 十、本地为什么可能看不到统计？

Minimal Mistakes 默认会在 `development` 环境中禁用 Analytics。

平时本地运行：

```bash
bundle exec jekyll serve --livereload --port 4100
```

通常属于 development 环境，因此 `_includes/analytics-providers/custom.html` 中的 GoatCounter 统计脚本可能不会被主题加载。

如果只是想验证生产环境，可以临时使用：

### PowerShell

```powershell
$env:JEKYLL_ENV="production"
bundle exec jekyll serve --livereload --port 4100
```

### CMD

```cmd
set JEKYLL_ENV=production
bundle exec jekyll serve --livereload --port 4100
```

不过 GoatCounter 本身也默认忽略 localhost，因此真正验证统计时，最可靠的方法仍然是部署到 GitHub Pages 后测试。

---

## 十一、部署后如何排查？

如果 GitHub Pages 已经部署，但数字仍然不显示，可以按下面的顺序检查。

### 1. 检查 GoatCounter Code

首先确认：

```html
data-goatcounter="https://desenbergchina.goatcounter.com/count"
```

中的：

```text
desenbergchina
```

和 GoatCounter 后台的 Code 完全一致。

### 2. 检查 `count.js`

浏览器打开开发者工具：

```text
F12 → Network
```

搜索：

```text
count.js
```

应该能够看到：

```text
https://gc.zgo.at/count.js
```

### 3. 检查 GoatCounter 对象

在 Console 输入：

```js
window.goatcounter
```

正式网站正常加载后，一般应该得到对象，而不是：

```text
undefined
```

### 4. 直接测试 Counter JSON

首页累计访问：

```text
https://desenbergchina.goatcounter.com/counter/TOTAL.json
```

单篇文章则可以根据文章 path 测试：

```text
https://desenbergchina.goatcounter.com/counter/[编码后的文章路径].json
```

### 5. 检查广告拦截器

AdGuard、uBlock 等浏览器扩展有可能拦截统计脚本或第三方统计域名。

因此排查时最好先临时关闭广告拦截器，或者使用无扩展的隐私窗口进行验证。

---

## 十二、统计数字为什么不会立即变化？

GoatCounter 的公开 Visitor Counter 响应会缓存，官方说明最长可能缓存约 **4 小时**。

因此：

```text
当前：18 次阅读
```

访问一次以后，不一定马上变成：

```text
19 次阅读
```

这并不代表统计失败。

调试时应该优先判断：

- 请求是否成功；
- JSON 是否有返回；
- GoatCounter 后台是否记录到了访问；

而不是依靠数字是否立刻加一判断功能是否正常。

---

## 十三、“阅读量”到底是什么？

如果 GoatCounter 后台保持：

```text
Sessions ✓
```

那么 GoatCounter 更接近统计 **visit**，而不是传统意义上每一次页面加载都增加的原始 pageview。

例如：

```text
第一次打开文章  → 1
F5              → 仍然 1
再次 F5         → 仍然 1
```

这对于博客反而比较合理，因为不会因为一个人连续刷新页面就制造大量阅读数。

因此本文在页面上把它显示为：

```text
👁 18 次阅读
```

首页则显示为：

```text
📈 本站累计访问 128 次
```

需要注意，它们并不等价于“128 个绝对唯一访客”。

---

## 十四、最终方案总结

最终只需要维护三个扩展文件和一个首页调用：

```text
_config.yml
    │
    └── analytics.provider = custom

_includes/analytics-providers/custom.html
    │
    └── 负责记录 GoatCounter 访问

_includes/footer/custom.html
    │
    └── 文章页动态插入阅读量

_includes/site-stats.html
    │
    └── 获取 TOTAL.json

index.markdown
    │
    └── {% include site-stats.html %}
```

最终效果：

```text
首页：
📈 本站累计访问 128 次

文章：
◷ 7 minute read · 👁 18 次阅读
```

最重要的是，我们没有为了这个功能去覆盖：

```text
single.html
home.html
page__meta.html
```

这比直接复制并修改主题 layout 更容易维护，也更适合长期使用 Minimal Mistakes 的博客。

---

## 十五、几个实际踩过的坑

最后记录几个实践中最容易遇到的问题：

1. **GoatCounter Code 写错**：例如后台是 `desenbergchina`，代码却写成 `desenberg`，统计自然无法正常工作。
2. **把 `visit_count()` 当成数字接口**：它实际会生成完整的 Visitor Counter UI，所以页面会突然出现紫色或带边框的 `Views for this page` 小组件。
3. **直接覆盖 `page__meta.html`**：相关文章等位置也会调用这个 include，可能造成阅读量组件重复插入。
4. **多个元素使用相同 `id`**：如果相关文章和正文同时产生 `id="gc-pageviews"`，JavaScript 只会找到第一个元素，结果多个计数器可能挤在一起。
5. **本地开发环境看不到统计**：Minimal Mistakes 默认在 development 下关闭 Analytics，GoatCounter 也默认忽略 localhost。
6. **访问一次数字没有马上变化**：公开 Counter 有缓存，最长可能约 4 小时。
7. **浏览器广告拦截器影响统计**：测试第三方统计脚本时，需要排除 AdGuard、uBlock 等扩展的影响。

这些问题都说明了一点：

> 对静态博客做统计，最值得追求的不是“功能堆得多”，而是尽量利用主题已有扩展点，把统计逻辑保持在主题之外。

---

## 参考资料

- [GoatCounter - Visitor counter](https://www.goatcounter.com/help/visitor-counter)
- [GoatCounter - Sessions and visitors](https://www.goatcounter.com/help/sessions)
- [Minimal Mistakes - Configuration / Analytics](https://mmistakes.github.io/minimal-mistakes/docs/configuration/)
- [Minimal Mistakes - Custom head and footer](https://mmistakes.github.io/minimal-mistakes/docs/layouts/#custom-head-and-footer)
