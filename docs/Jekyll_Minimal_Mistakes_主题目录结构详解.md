# Jekyll Minimal Mistakes 主题目录结构说明

> 本文以 **Minimal Mistakes** 主题为例，解释 Jekyll 主题中的 `_includes`、`_layouts`、`_sass`、`assets`、`_data` 等目录分别做什么，以及一篇 Markdown 文章最终是如何组合成网页的。
>
> 适合当前这种使用方式：**通过 Gem/Remote Theme 使用 Minimal Mistakes，只在自己项目中覆盖少量文件，以降低后续维护成本。**
>
> 说明：Minimal Mistakes 不同版本的具体文件数量可能有差异，本文按当前 4.x 系列和官方仓库结构说明。

---

# 1. 先回答：`include` 是什么意思？

`include` 可以理解成：

> **可复用的 HTML / Liquid 小组件。**

例如一个完整网页可能包含：

```text
顶部导航栏
作者侧边栏
文章正文
文章日期
分享按钮
上一篇 / 下一篇
评论区
页脚
```

如果把所有代码都写进 `single.html`，文件会非常长，也很难维护。

所以 Jekyll 会把这些独立功能拆成很多小文件，放到：

```text
_includes/
```

然后在布局中通过：

```liquid
{% include 文件名.html %}
```

插进去。

例如：

```liquid
{% include social-share.html %}
```

意思就是：

```text
把 _includes/social-share.html
的内容插到当前位置
```

---

# 2. 用你刚才修改的分享按钮理解 include

Minimal Mistakes 的：

```text
_layouts/single.html
```

中有类似：

```liquid
{% if page.share %}
  {% include social-share.html locale=locale %}
{% endif %}

{% include post_pagination.html locale=locale %}
```

可以理解成：

```text
single.html
│
├── 文章正文
│
├── 日期
│
├── social-share.html
│      └── X / LinkedIn / Reddit / 微博 / 复制链接
│
└── post_pagination.html
       └── 上一篇 / 下一篇
```

所以我们之前没有修改整个 `single.html`。

我们只创建：

```text
_includes/social-share.html
_includes/post_pagination.html
```

Jekyll 就会优先使用你的版本。

这就是为什么这种方式维护量很小。

---

# 3. `layout` 和 `include` 的区别

这是理解 Jekyll 主题最重要的一点。

## 3.1 Layout：页面骨架

目录：

```text
_layouts/
```

Layout 是一个**完整页面的大结构**。

例如：

```text
default.html
single.html
archive.html
search.html
splash.html
```

可以把它理解成：

```text
Layout = 页面模板 / 页面骨架
```

---

## 3.2 Include：页面零件

目录：

```text
_includes/
```

例如：

```text
masthead.html
sidebar.html
social-share.html
post_pagination.html
footer.html
breadcrumbs.html
page__meta.html
```

可以理解成：

```text
Include = 可重复使用的小组件
```

---

## 3.3 一个类比

可以把一个网页理解成一台电脑：

```text
_layouts/default.html
        =
机箱

_layouts/single.html
        =
整机结构

_includes/masthead.html
        =
顶部导航模块

_includes/sidebar.html
        =
侧边栏模块

_includes/social-share.html
        =
分享按钮模块

_includes/post_pagination.html
        =
文章导航模块

_sass/
        =
所有模块的外观样式

assets/
        =
CSS / JavaScript / 静态资源
```

---

# 4. 一篇文章到底是怎么生成网页的？

假设你写：

```text
_posts/2026-08-29-jekyll-guide.md
```

内容：

```yaml
---
title: "Jekyll 使用教程"
layout: single
share: true
---

这里是文章正文。
```

Jekyll 会经历大致这样的过程：

```text
2026-08-29-jekyll-guide.md
          │
          │ Front Matter 指定
          │ layout: single
          ↓
_layouts/single.html
          │
          │ single.html 自己又指定
          │ layout: default
          ↓
_layouts/default.html
          │
          ├── head.html
          ├── masthead.html
          ├── footer.html
          ├── scripts.html
          │
          └── {{ content }}
                 ↑
                 │
           single.html 内容
                 │
                 ├── sidebar.html
                 ├── page__meta.html
                 ├── 文章正文
                 ├── page__date.html
                 ├── social-share.html
                 └── post_pagination.html
```

最后生成：

```text
_site/...
```

中的静态 HTML。

---

# 5. Minimal Mistakes 的整体结构

官方主题仓库的核心结构可以概括为：

```text
minimal-mistakes/
│
├── _data/
│
├── _includes/
│
├── _layouts/
│
├── _sass/
│
├── assets/
│
├── docs/
│
├── test/
│
├── _config.yml
├── Gemfile
├── minimal-mistakes-jekyll.gemspec
├── package.json
├── Rakefile
└── index.html
```

但对于你自己的博客来说，真正经常接触的是：

```text
_data/
_includes/
_layouts/
_sass/
assets/
_config.yml
_posts/
_drafts/
```

下面逐个介绍。

---

# 6. `_layouts`：页面骨架

目录：

```text
_layouts/
```

这是 Jekyll 最核心的主题目录之一。

当前 Minimal Mistakes 主要包含类似：

```text
_layouts/
├── default.html
├── single.html
├── archive.html
├── archive-taxonomy.html
├── categories.html
├── category.html
├── collection.html
├── home.html
├── posts.html
├── search.html
├── splash.html
├── tag.html
└── tags.html
```

---

## 6.1 `default.html`

这是最基础的页面骨架。

可以理解为：

```text
<html>
  <head>
  </head>

  <body>

    顶部导航

    {{ content }}

    footer

    JavaScript

  </body>
</html>
```

Minimal Mistakes 中大致关系是：

```text
default.html
│
├── head.html
├── masthead.html
├── {{ content }}
├── footer.html
└── scripts.html
```

很多其他 layout 最终都会套在它里面。

---

## 6.2 `single.html`

这是你当前博客文章最重要的 Layout。

典型文章：

```yaml
---
layout: single
title: "..."
---
```

就会使用它。

它负责：

```text
文章标题
作者侧边栏
文章元信息
TOC
正文
分类
标签
更新时间
分享按钮
上一篇 / 下一篇
评论
相关文章
```

而它自己顶部又有：

```yaml
---
layout: default
---
```

所以实际结构是：

```text
default.html
    ↓
single.html
    ↓
你的 Markdown 正文
```

---

## 6.3 `archive.html`

用于文章归档列表。

比如：

```text
所有文章
按年份显示文章
```

---

## 6.4 `categories.html`

用于分类归档。

例如：

```text
Python
Jekyll
强化学习
AnyLogic
```

---

## 6.5 `tags.html`

用于标签归档。

---

## 6.6 `search.html`

搜索页面布局。

---

## 6.7 `splash.html`

一种更自由的大页面布局。

适合：

```text
首页
项目展示
Landing Page
Portfolio
```

---

# 7. `_includes`：可复用组件

这是你这次修改最多的目录。

官方当前 `_includes` 中有很多组件，例如：

```text
_includes/
│
├── analytics-providers/
├── comments-providers/
├── footer/
├── head/
├── search/
│
├── after-content.html
├── analytics.html
├── archive-single.html
├── author-profile.html
├── breadcrumbs.html
├── comments.html
├── footer.html
├── head.html
├── masthead.html
├── page__date.html
├── page__hero.html
├── page__meta.html
├── page__related.html
├── page__taxonomy.html
├── post_pagination.html
├── scripts.html
├── seo.html
├── sidebar.html
├── social-share.html
├── toc.html
└── ...
```

不需要全部记住。

对于个人博客，最值得理解的是下面这些。

---

# 8. `_includes/masthead.html`

作用：

```text
网站最顶部导航栏
```

一般对应：

```text
网站名称    首页    文章    分类    标签    关于
```

它的数据通常来自：

```text
_data/navigation.yml
```

所以：

```text
navigation.yml
    ↓
masthead.html
    ↓
顶部导航栏
```

---

# 9. `_includes/sidebar.html`

作用：

```text
控制文章页面左侧边栏
```

你截图左边的：

```text
头像
名字
个人介绍
所在地
GitHub
邮箱
知乎
```

就主要和：

```text
sidebar.html
author-profile.html
```

有关。

---

# 10. `_includes/author-profile.html`

专门负责作者信息区域。

大致显示：

```text
头像
作者名字
简介
地点
链接
```

数据通常来自 `_config.yml`：

```yaml
author:
  name: "你的名字"
  avatar: "/assets/images/avatar.jpg"
  bio: "全栈开发者 / 技术博主"
  location: "杭州，中国"

  links:
    - label: "GitHub"
      icon: "fab fa-fw fa-github"
      url: "..."

    - label: "邮箱"
      icon: "fas fa-fw fa-envelope"
      url: "..."
```

关系是：

```text
_config.yml
    ↓
author-profile.html
    ↓
左侧作者资料
```

---

# 11. `_includes/page__meta.html`

负责文章标题下的一部分元信息。

例如可能包含：

```text
阅读时间
发布时间
更新时间
```

具体显示取决于主题配置和页面参数。

---

# 12. `_includes/page__date.html`

负责文章日期区域。

你截图中的：

```text
Updated: August 29, 2026
```

主要来自这里。

如果你以后想修改：

```text
Updated:
```

变成：

```text
最后更新：
```

除了修改模板，更推荐先查看：

```text
_data/ui-text.yml
```

因为这些 UI 文字通常来自语言配置。

---

# 13. `_includes/social-share.html`

就是我们刚才修改的分享组件。

原本主题负责：

```text
X
Facebook
LinkedIn
Bluesky
```

你自己的版本可以变成：

```text
X
LinkedIn
Reddit
Telegram
微博
邮件
复制链接
```

single.html 中：

```liquid
{% if page.share %}
  {% include social-share.html locale=locale %}
{% endif %}
```

所以文章中：

```yaml
share: true
```

时才显示。

---

# 14. `_includes/post_pagination.html`

负责：

```text
上一篇
下一篇
```

我们之前把：

```text
Previous              Next
```

改成：

```text
← 上一篇               下一篇 →
文章标题               文章标题
```

这是典型的：

```text
改 include，而不是改 single layout
```

---

# 15. `_includes/breadcrumbs.html`

负责面包屑导航。

例如：

```text
首页 > Jekyll > Jekyll 安装教程
```

是否显示一般由：

```yaml
breadcrumbs: true
```

控制。

---

# 16. `_includes/toc.html`

负责生成文章目录：

```text
目录
├── 第一章
├── 第二章
│   ├── 2.1
│   └── 2.2
└── 第三章
```

文章 Front Matter 例如：

```yaml
toc: true
toc_sticky: true
```

---

# 17. `_includes/page__taxonomy.html`

负责：

```text
Categories
Tags
```

例如：

```text
Categories: Jekyll
Tags: GitHub, Blog, Ruby
```

---

# 18. `_includes/comments.html`

评论系统入口。

根据：

```text
Disqus
utterances
giscus
...
```

配置选择不同实现。

真正不同评论平台的模板通常放在：

```text
_includes/comments-providers/
```

---

# 19. `_includes/head.html`

控制：

```html
<head>
```

区域。

包括：

```text
字符编码
viewport
SEO
CSS
favicon
meta
Open Graph
```

通常不建议直接大改。

Minimal Mistakes 还提供：

```text
_includes/head/custom.html
```

这种专门的扩展点。

如果只是增加：

```text
favicon
额外 meta
额外 head script
```

优先改：

```text
head/custom.html
```

而不是整个 `head.html`。

这和我们修改分享按钮的思想一样：

> 尽量覆盖最小组件。

---

# 20. `_includes/footer.html`

负责网站页脚。

例如：

```text
© 2026
Powered by Jekyll
Follow
```

Minimal Mistakes 也提供：

```text
_includes/footer/custom.html
```

供你额外插入内容。

---

# 21. `_includes/scripts.html`

负责页面底部 JavaScript。

通常是在：

```html
</body>
```

之前加载：

```text
主题 JS
搜索 JS
评论 JS
统计 JS
自定义 JS
```

一般不要为了增加一小段 JS 就复制整个文件。

如果主题有现成自定义脚本配置，优先使用配置。

---

# 22. `_data`：结构化配置数据

目录：

```text
_data/
```

里面一般是：

```text
YAML
JSON
CSV
```

Jekyll 会自动读取。

Minimal Mistakes 最典型的是：

```text
_data/
├── navigation.yml
└── ui-text.yml
```

---

# 23. `_data/navigation.yml`

负责导航数据。

例如：

```yaml
main:
  - title: "首页"
    url: /

  - title: "文章"
    url: /posts/

  - title: "分类"
    url: /categories/

  - title: "标签"
    url: /tags/
```

然后：

```text
navigation.yml
      ↓
masthead.html
      ↓
顶部菜单
```

这是一种很好的设计：

```text
数据和 HTML 分离
```

你只修改导航数据，不需要改导航模板。

---

# 24. `_data/ui-text.yml`

保存主题各种 UI 文案的多语言文本。

比如：

```text
Previous
Next
Updated
Follow
Share on
Read more
```

不同语言会有不同配置。

所以如果你只是希望：

```text
Previous → 上一篇
Next → 下一篇
```

在某些情况下，可以优先考虑语言配置，而不是修改 HTML。

但如果像我们之前那样：

```text
加入文章标题
改变 HTML 结构
```

就应该覆盖：

```text
post_pagination.html
```

---

# 25. `_sass`：主题 SCSS 源码

目录：

```text
_sass/
```

负责页面视觉样式。

Minimal Mistakes 当前大致：

```text
_sass/
│
├── minimal-mistakes.scss
│
└── minimal-mistakes/
    │
    ├── skins/
    ├── vendor/
    │
    ├── _animations.scss
    ├── _archive.scss
    ├── _base.scss
    ├── _buttons.scss
    ├── _footer.scss
    ├── _forms.scss
    ├── _masthead.scss
    ├── _mixins.scss
    ├── _navigation.scss
    ├── _notices.scss
    ├── _page.scss
    ├── _print.scss
    ├── _reset.scss
    ├── _search.scss
    ├── _sidebar.scss
    ├── _syntax.scss
    ├── _tables.scss
    ├── _utilities.scss
    └── _variables.scss
```

---

# 26. `_sass/minimal-mistakes/_page.scss`

负责文章页面相关样式。

例如：

```text
文章正文
page__content
page__meta
page__share
标题
图片
```

你截图里的：

```text
SHARE ON
```

区域默认样式就和 `_page.scss` 有关系。

---

# 27. `_sass/minimal-mistakes/_navigation.scss`

负责：

```text
导航
分页
Previous / Next
```

默认：

```text
.pagination
.pagination--pager
```

主要来自这里。

---

# 28. `_sass/minimal-mistakes/_buttons.scss`

负责：

```text
.btn
.btn--primary
各种按钮
```

分享按钮本身会使用 `.btn`，所以也会受到这里影响。

---

# 29. `_sass/minimal-mistakes/_sidebar.scss`

负责左侧作者区域、侧边栏相关样式。

如果以后想调整：

```text
头像尺寸
作者资料字体
侧边栏宽度
```

通常要关注这里对应的 CSS selector。

---

# 30. `_sass/minimal-mistakes/_masthead.scss`

负责顶部导航栏样式。

---

# 31. `_sass/minimal-mistakes/_variables.scss`

包含大量 Sass 变量。

例如：

```text
字体
断点
颜色
宽度
间距
```

属于主题内部基础变量。

---

# 32. `_sass/minimal-mistakes/skins/`

主题皮肤。

Minimal Mistakes 支持：

```text
default
air
aqua
contrast
dark
dirt
mint
neon
plum
sunrise
...
```

你在 `_config.yml` 中例如：

```yaml
minimal_mistakes_skin: default
```

就会选择对应皮肤。

---

# 33. 为什么我不建议你直接修改 `_sass/minimal-mistakes/*`

因为如果你使用 Gem：

```text
bundle update
```

以后主题源码可能更新。

如果你直接修改 Gem 目录中的：

```text
_sass/minimal-mistakes/_page.scss
```

下一次 Gem 更新：

```text
你的修改可能消失
```

而如果你创建自己的：

```text
assets/css/main.scss
```

并在主题 import 后增加：

```scss
.layout--single .custom-share {
  ...
}
```

主题更新时就不会直接覆盖你的代码。

---

# 34. `assets`：真正输出给浏览器的资源

目录：

```text
assets/
```

Minimal Mistakes 官方核心主要有：

```text
assets/
├── css/
└── js/
```

你自己的项目还可以加：

```text
assets/
├── css/
├── js/
├── images/
├── fonts/
└── files/
```

---

# 35. `assets/css/main.scss`

这是非常重要的文件。

典型内容：

```scss
---
search: false
---

@charset "utf-8";

@import "minimal-mistakes/skins/{{ site.minimal_mistakes_skin | default: 'default' }}";
@import "minimal-mistakes";

/* 你的样式 */
```

流程是：

```text
assets/css/main.scss
        │
        ├── import skin
        │
        └── import _sass/minimal-mistakes
                    ↓
              Jekyll Sass 编译
                    ↓
          _site/assets/css/main.css
```

浏览器真正加载的是：

```text
main.css
```

不是 SCSS。

---

# 36. 为什么 `main.scss` 顶部有 `---`

例如：

```scss
---
search: false
---
```

或者：

```scss
---
---
```

这是 Jekyll 的 Front Matter。

它告诉 Jekyll：

> 这个文件需要经过 Jekyll 处理。

没有 Front Matter 时，某些文件可能不会经过 Liquid / Sass 处理流程。

---

# 37. `assets/js`

存放 JavaScript。

例如：

```text
主题导航
搜索
滚动
图片
复制链接
评论
自定义交互
```

通常最终浏览器加载的会是合并/压缩后的 JS 文件。

---

# 38. `assets/images`

你自己的图片建议放这里：

```text
assets/images/avatar.jpg
assets/images/posts/jekyll.png
```

Markdown 中可以：

```markdown
![图片](/assets/images/posts/jekyll.png)
```

头像也可以：

```yaml
author:
  avatar: "/assets/images/avatar.jpg"
```

---

# 39. `_config.yml`：全站总配置

这是你的 Jekyll 网站最重要的配置文件。

例如：

```yaml
title: "我的博客"

url: "https://example.github.io"

locale: "zh-CN"

minimal_mistakes_skin: default

author:
  name: "你的名字"
  location: "杭州，中国"

search: true
breadcrumbs: true
```

它控制的是：

```text
全局配置
```

和文章 Front Matter 的关系可以理解为：

```text
_config.yml
    =
网站默认设置

文章 Front Matter
    =
当前文章设置
```

---

# 40. `_config.yml` 和单篇文章谁优先？

例如全站设置：

```yaml
defaults:
  - scope:
      path: ""
      type: posts
    values:
      layout: single
      share: true
      toc: true
```

那么所有文章默认：

```text
layout: single
share: true
toc: true
```

某篇文章可以单独覆盖：

```yaml
---
share: false
toc: false
---
```

可以理解成：

```text
全局默认
    ↓
页面局部覆盖
```

---

# 41. `_posts`：正式文章

你的文章目录：

```text
_posts/
```

文件名通常：

```text
YYYY-MM-DD-title.md
```

例如：

```text
_posts/
└── 2026-08-29-jekyll-theme-guide.md
```

文章：

```yaml
---
title: "Jekyll 主题结构说明"
layout: single
categories:
  - Jekyll
tags:
  - Blog
  - GitHub
---

正文...
```

---

# 42. `_drafts`：草稿

草稿目录：

```text
_drafts/
```

文件不要求日期：

```text
_drafts/
└── jekyll-theme-guide.md
```

正常：

```bash
bundle exec jekyll serve
```

不会发布草稿。

预览：

```bash
bundle exec jekyll serve --drafts
```

---

# 43. `_site`：最终网站输出目录

执行：

```bash
bundle exec jekyll build
```

后生成：

```text
_site/
```

里面是：

```text
真正最终的 HTML
CSS
JS
图片
```

例如：

```text
_site/
├── index.html
├── assets/
│   └── css/
│       └── main.css
└── 2026/
    └── 08/
        └── ...
```

这个目录：

> **不要手工修改。**

因为下一次：

```bash
jekyll build
```

会重新生成。

---

# 44. `.jekyll-cache`

Jekyll 构建缓存：

```text
.jekyll-cache/
```

用于加快构建。

如果遇到很奇怪的缓存问题，可以删除后重新构建：

```bash
bundle exec jekyll clean
bundle exec jekyll serve
```

通常：

```text
_site/
.jekyll-cache/
```

都不需要提交 Git。

---

# 45. `Gemfile`

Ruby 依赖配置。

例如：

```ruby
source "https://rubygems.org"

gem "minimal-mistakes-jekyll"
```

以及 Jekyll 插件：

```ruby
gem "jekyll-include-cache"
```

安装：

```bash
bundle install
```

运行：

```bash
bundle exec jekyll serve
```

`bundle exec` 的含义是：

> 使用当前项目 Gemfile 锁定的 Ruby Gem 版本运行 Jekyll。

---

# 46. `Gemfile.lock`

Bundler 实际解析出来的依赖版本。

例如：

```text
jekyll 4.x
minimal-mistakes-jekyll 4.x
liquid ...
```

它的作用是：

```text
保证不同电脑安装出尽量一致的依赖版本
```

个人博客通常建议提交 Git。

---

# 47. `index.html` / `index.md`

网站首页入口。

例如：

```yaml
---
layout: home
---
```

或者：

```yaml
---
layout: splash
---
```

首页最终也会套用对应 Layout。

---

# 48. `docs/` 是什么？

你如果查看 Minimal Mistakes 官方仓库，会发现：

```text
docs/
```

这是：

```text
官方文档 + 官方演示站内容
```

它不是你普通个人博客必须有的目录。

你使用 Gem 主题时：

```text
不需要复制 docs/
```

---

# 49. `test/` 是什么？

这是主题开发者测试 Minimal Mistakes 自己用的。

普通用户：

```text
不需要
```

---

# 50. `.github/`

GitHub 仓库配置。

可能包含：

```text
GitHub Actions
Issue template
Dependabot
CI
```

这是开发和仓库自动化，不属于网页主题运行核心。

---

# 51. `package.json`

Node.js / npm 工具配置。

Minimal Mistakes 主题开发者可能用它来：

```text
构建 JavaScript
压缩资源
开发主题
```

如果你只是：

```text
写 Markdown
使用 Gem 主题
自定义少量 SCSS
```

通常不用管它。

---

# 52. `minimal-mistakes-jekyll.gemspec`

这是主题 Gem 自己的描述文件。

定义：

```text
Gem 名称
版本
包含哪些文件
依赖
```

这是：

```text
主题开发者
```

关心的文件。

普通博客用户基本不用修改。

---

# 53. Gem 方式为什么看不到 `_layouts` 和 `_includes`？

这是很多初学者最困惑的地方。

如果 `_config.yml`：

```yaml
theme: minimal-mistakes-jekyll
```

那么：

```text
_layouts
_includes
_sass
部分 assets
```

可能并不在你的博客仓库中。

它们实际上在 Ruby Gem 安装目录中。

可以执行：

```powershell
bundle show minimal-mistakes-jekyll
```

查看主题位置。

例如：

```text
D:/App/RubyGems/gems/minimal-mistakes-jekyll-4.xx.x
```

里面才有完整：

```text
_layouts/
_includes/
_sass/
assets/
```

这是正常现象。

---

# 54. Jekyll 的“本地覆盖主题”机制

这是你现在最值得掌握的机制。

假设 Gem 中有：

```text
Gem/
└── _includes/
    └── social-share.html
```

而你的博客项目中创建：

```text
你的博客/
└── _includes/
    └── social-share.html
```

构建时：

```text
你的博客中的文件
        ↓ 优先级更高
Gem 中主题文件
```

所以最终使用：

```text
你的 social-share.html
```

这就是 Theme Override。

---

# 55. 为什么这种设计维护成本最低？

假设主题有：

```text
150 个模板和样式文件
```

你只希望改：

```text
分享按钮
上一篇 / 下一篇
一点 CSS
```

那么你只维护：

```text
_includes/
├── social-share.html
└── post_pagination.html

assets/css/
└── main.scss
```

主题其他一百多个文件：

```text
继续由 Gem 管理
```

以后：

```bash
bundle update
```

主题可以继续升级。

而你的改动只有三个文件需要检查兼容性。

---

# 56. 不推荐的方式

## 方式 A：复制整个主题

例如把：

```text
_layouts
_includes
_sass
assets
```

全部复制到自己的项目。

缺点：

```text
主题升级后
你本地的旧文件会继续覆盖新主题文件
```

最后会越来越难升级。

---

## 方式 B：直接修改 Gem 目录

例如修改：

```text
D:/RubyGems/.../minimal-mistakes-jekyll/_includes/social-share.html
```

问题：

```text
bundle update
重新安装 Gem
换电脑
```

以后修改都会丢失。

所以不要这样做。

---

# 57. 推荐的个人博客目录结构

对于你这种：

```text
Minimal Mistakes
+
GitHub Pages
+
Markdown 写博客
+
少量自定义
```

我建议保持：

```text
你的博客/
│
├── _config.yml
│
├── Gemfile
├── Gemfile.lock
│
├── _data/
│   └── navigation.yml
│
├── _includes/
│   ├── social-share.html
│   └── post_pagination.html
│
├── _posts/
│   ├── 2026-08-29-example.md
│   └── ...
│
├── _drafts/
│   └── future-post.md
│
├── assets/
│   ├── css/
│   │   └── main.scss
│   └── images/
│       ├── avatar.jpg
│       └── posts/
│
├── index.html
│
└── .gitignore
```

不用复制：

```text
_layouts/
_sass/minimal-mistakes/
整个 _includes/
```

除非确实需要修改其中某个文件。

---

# 58. 以后想改网页某个位置，应该先找什么？

可以按这个判断：

| 想修改 | 首先检查 |
|---|---|
| 网站名称、作者、URL | `_config.yml` |
| 顶部菜单项目 | `_data/navigation.yml` |
| UI 中文翻译 | `_data/ui-text.yml` |
| 写文章 | `_posts/` |
| 写草稿 | `_drafts/` |
| 改按钮颜色 | `assets/css/main.scss` |
| 改分享平台 | `_includes/social-share.html` |
| 改上一篇/下一篇 | `_includes/post_pagination.html` |
| 改左侧作者栏 HTML | `_includes/author-profile.html` |
| 改顶部导航 HTML | `_includes/masthead.html` |
| 改 footer HTML | `_includes/footer/custom.html` 或 `footer.html` |
| 改文章整体结构 | `_layouts/single.html` |
| 改整个网页基础框架 | `_layouts/default.html` |

---

# 59. 推荐修改优先级

为了维护成本低，建议始终按：

```text
第 1 级
_config.yml
_data/*.yml
文章 Front Matter
        ↓

第 2 级
assets/css/main.scss
        ↓

第 3 级
覆盖一个 _includes/*.html
        ↓

第 4 级
覆盖一个 _layouts/*.html
        ↓

第 5 级
复制并修改主题 _sass 内部源码
```

越往下：

```text
自定义自由度越高
但未来主题升级维护成本越高
```

---

# 60. 用我们这次修改做一个完整实例

你要修改：

```text
分享按钮
+
上一篇 / 下一篇
```

Minimal Mistakes 原本调用关系：

```text
文章 Markdown
      ↓
single.html
      │
      ├── social-share.html
      └── post_pagination.html
                ↓
           默认主题 CSS
```

我们现在改成：

```text
文章 Markdown
      ↓
Gem 中的 single.html
      │
      ├── 你自己的 social-share.html
      │
      └── 你自己的 post_pagination.html
                ↓
         你自己的 main.scss
```

注意：

```text
single.html 仍然由主题维护
default.html 仍然由主题维护
sidebar.html 仍然由主题维护
head.html 仍然由主题维护
footer.html 仍然由主题维护
```

你只接管：

```text
两个小组件
+
一点样式
```

这就是最适合长期博客维护的方式。

---

# 61. `{{ }}` 和 `{% %}` 又是什么？

这是 Liquid 模板语法。

Jekyll 使用 Liquid 来把：

```text
Markdown
配置
模板
数据
```

组合起来。

---

## 61.1 `{{ ... }}`：输出值

例如：

```liquid
{{ page.title }}
```

输出：

```text
当前文章标题
```

例如：

```liquid
{{ site.title }}
```

输出：

```text
网站标题
```

---

## 61.2 `{% ... %}`：执行逻辑

例如：

```liquid
{% if page.share %}
```

意思：

```text
如果 share == true
```

---

例如：

```liquid
{% include social-share.html %}
```

意思：

```text
插入一个 include
```

---

例如：

```liquid
{% for post in site.posts %}
```

意思：

```text
遍历所有文章
```

---

# 62. `page`、`site`、`layout` 分别是什么？

Liquid 中经常出现：

```text
page
site
layout
```

---

## `page`

当前页面/文章。

例如：

```liquid
{{ page.title }}
{{ page.url }}
{{ page.date }}
{{ page.tags }}
```

---

## `site`

整个网站。

数据来自：

```text
_config.yml
_data
所有文章
```

例如：

```liquid
{{ site.title }}
{{ site.url }}
{{ site.posts }}
```

---

## `layout`

当前 Layout 自己的配置。

一般普通写文章时不常直接用。

---

# 63. `content` 是什么？

你会在 Layout 中看到：

```liquid
{{ content }}
```

这是最重要的变量之一。

含义：

> 把下一级内容插进这里。

例如：

```text
default.html
    ↓
{{ content }}
    ↓
single.html
```

然后：

```text
single.html
    ↓
{{ content }}
    ↓
你的 Markdown 正文
```

所以整个布局是一层套一层。

---

# 64. 最终可以把 Jekyll 理解成 5 层

建议以后脑中保持这个模型：

```text
第 1 层：内容
_posts/*.md

        ↓

第 2 层：页面模板
_layouts/

        ↓

第 3 层：页面组件
_includes/

        ↓

第 4 层：配置与数据
_config.yml
_data/

        ↓

第 5 层：样式和行为
_sass/
assets/css/
assets/js/

        ↓

最终生成
_site/
```

---

# 65. 对你当前博客最需要掌握的 8 个位置

刚开始其实不用记全部主题源码。

只需要重点掌握：

```text
1. _config.yml
   全站配置

2. _posts/
   正式博客文章

3. _drafts/
   草稿

4. _data/navigation.yml
   顶部导航

5. _includes/
   需要覆盖的小组件

6. assets/css/main.scss
   自定义样式

7. assets/images/
   图片

8. _site/
   构建结果，只看不改
```

至于：

```text
_layouts/
_sass/minimal-mistakes/
```

先把它们当作：

```text
主题内部实现
```

只有真正需要改变结构时再覆盖。

---

# 66. 一句话总结每个目录

| 目录/文件 | 一句话理解 |
|---|---|
| `_posts/` | 正式发布的文章 |
| `_drafts/` | 未发布草稿 |
| `_layouts/` | 整个页面的大骨架 |
| `_includes/` | 可重复使用的小组件 |
| `_data/` | 供模板读取的结构化数据 |
| `_sass/` | 主题 SCSS 源代码 |
| `assets/css/` | CSS/SCSS 入口和自定义样式 |
| `assets/js/` | JavaScript |
| `assets/images/` | 图片资源 |
| `_config.yml` | 全站总配置 |
| `Gemfile` | Ruby/Jekyll 依赖 |
| `Gemfile.lock` | 锁定依赖版本 |
| `_site/` | 最终生成的网站 |
| `.jekyll-cache/` | Jekyll 构建缓存 |

---

# 67. 你现在最合适的维护策略

建议继续保持：

```text
主题主体
        ↓
Minimal Mistakes Gem

你的内容
        ↓
_posts/
_drafts/

你的配置
        ↓
_config.yml
_data/navigation.yml

你的图片
        ↓
assets/images/

你的样式
        ↓
assets/css/main.scss

只有确实需要改变 HTML 时
        ↓
创建对应的 _includes/
```

也就是：

> **能配置就不改模板，能改 CSS 就不改 HTML，能覆盖 Include 就不覆盖 Layout。**

这是使用 Jekyll Theme Gem 时最利于长期维护的方式。

---

# 68. 参考资料

Minimal Mistakes 官方：

```text
https://mmistakes.github.io/minimal-mistakes/
```

主题结构说明：

```text
https://mmistakes.github.io/minimal-mistakes/docs/structure/
```

官方 GitHub：

```text
https://github.com/mmistakes/minimal-mistakes
```

Jekyll 官方：

```text
https://jekyllrb.com/docs/
```

Liquid：

```text
https://shopify.github.io/liquid/
```

---

# 69. 最终结构图

```text
                      _config.yml
                           │
                    全站配置 / 作者信息
                           │
                           ↓
_posts/*.md ───────→ _layouts/single.html
 Markdown正文               │
                            ├────→ _includes/sidebar.html
                            │          └─ author-profile.html
                            │
                            ├────→ _includes/page__meta.html
                            │
                            ├────→ {{ content }}
                            │          └─ Markdown 正文
                            │
                            ├────→ _includes/page__date.html
                            │
                            ├────→ _includes/social-share.html
                            │
                            └────→ _includes/post_pagination.html
                                         │
                                         ↓
                               _layouts/default.html
                                         │
                            ┌────────────┼─────────────┐
                            ↓            ↓             ↓
                       head.html    masthead.html   footer.html
                            │
                            ↓
                      assets/css/main.scss
                            │
                       import _sass
                            │
                            ↓
                         Jekyll
                            │
                            ↓
                          _site/
                            │
                            ↓
                      最终静态网页
```

如果理解了这张图，Minimal Mistakes 的大部分自定义逻辑就已经理解了。
