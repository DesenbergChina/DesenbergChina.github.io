# Minimal-Mistakes 的现成样式使用指南

主要可以分为**预设配色皮肤（Skins）**、**页面布局（Layouts）** 和**工具类（Utility Classes）** 三个层面。以下为你详细汇总：

### 🎨 预设配色皮肤 (Skins)

这是最直观的样式切换方式，通过在 `_config.yml` 中修改一行配置就能改变整个网站的颜色主题。Minimal-Mistakes 一共提供了 **9 种** 现成的皮肤。

| 皮肤名称       | 主要特点                 | 主色             | 背景色             |
| :------------- | :----------------------- | :--------------- | :----------------- |
| **`default`**  | 干净、中性的默认配色     | #6f777d (灰色)   | #ffffff (白色)     |
| **`air`**      | 清新、轻盈，带蓝色点缀   | -                | 浅色背景           |
| **`aqua`**     | 水润质感的蓝/绿色调      | -                | -                  |
| **`contrast`** | 高对比度，适合无障碍阅读 | #b60000 (红色)   | #ffffff (白色)     |
| **`dark`**     | 深色背景搭配高亮文字     | #00adb5 (蓝绿色) | #252a34 (近黑色)   |
| **`dirt`**     | 大地色系，棕色和中性色调 | -                | -                  |
| **`mint`**     | 薄荷绿，清新凉爽         | #11999e (蓝绿色) | #f3f6f6 (浅薄荷色) |
| **`neon`**     | 鲜艳的霓虹色，充满活力   | #f21368 (品红)   | #141010 (黑色)     |
| **`plum`**     | 浓郁的紫色，配以黄色点缀 | #c327ab (梅子色) | #521477 (深紫色)   |
| **`sunrise`**  | 温暖的日出色调           | #fc3a52 (珊瑚色) | #e8d5b7 (棕褐色)   |

> 应用方式：在 `_config.yml` 文件中设置 `minimal_mistakes_skin: "皮肤名称"` 即可。

### 📐 页面布局 (Layouts)

Minimal-Mistakes 提供了几种针对不同内容类型的页面布局，你可以在文章或页面的 [Front Matter](https://mmistakes.github.io/minimal-mistakes/docs/layouts/) 中通过 `layout` 属性来指定。

*   **`single`**：标准的单篇文章或页面布局。
*   **`archive`**：用于展示文章列表、分类或标签聚合页。
*   **`search`**：带搜索功能的页面布局。
*   **`splash`**：适合作为着陆页的全宽布局。
*   **`home`**：带分页功能的博客首页布局。
*   
**其他布局：**

default.html
   │
   ├── single.html          → 单篇文章 / 普通内容页
   ├── archive.html         → 各种“文章列表页”的基础模板
   │    ├── posts.html      → 按年份列出所有文章
   │    ├── categories.html → 按分类列出所有文章
   │    ├── tags.html       → 按标签列出所有文章
   │    ├── category.html   → 某一个分类
   │    ├── tag.html        → 某一个标签
   │    └── collection.html → 某一个 collection
   │
   ├── home.html            → 博客首页
   ├── splash.html          → 大型落地页
   └── search.html          → 搜索页面

archive-taxonomy.html
   → 主要给 jekyll-archives 插件生成分类/标签页面

### 🧩 工具类 (Utility Classes)

主题内置了许多 CSS 工具类，无需编写额外 CSS 即可快速实现常见样式。

**可见性控制：**
*   `.hidden` / `.is--hidden`：完全隐藏元素。
*   `.visually-hidden` / `.screen-reader-text`：在视觉上隐藏，但对屏幕阅读器可见。
*   `.transparent`：使元素透明。

**文字与布局：**
*   **文字对齐**：`.text-left`, `.text-center`, `.text-right`, `.text-justify`。
*   **浮动与清除**：`.align-left`, `.align-right`, `.align-center`, `.cf` (清除浮动)。
*   **容器**：`.wrapper` (自动外边距容器), `.full` (大屏时撑满)。

**按钮样式：**
基础类 `.btn` 需配合以下修饰类使用：
*   **颜色**：`.btn--primary` (主题色), `.btn--inverse` (反色), `.btn--success` (绿色), `.btn--warning` (橙色), `.btn--danger` (红色), `.btn--info` (蓝色) 等。
*   **尺寸**：`.btn--x-large`, `.btn--large`, `.btn--small`。
*   **样式**：`.btn--block` (块级按钮), `.btn--disabled` (禁用状态)。
*   **社交品牌**：`.btn--facebook`, `.btn--twitter`, `.btn--linkedin` 等。

### 🛠️ 深度自定义 (SCSS变量)

如果上述选项仍不满足需求，Minimal-Mistakes 提供了一个全面的 [SCSS 变量系统](https://mmistakes.github.io/minimal-mistakes/docs/stylesheets/)，你可以通过覆盖这些变量来精细控制网站的每一个视觉细节：

*   **排版**：`$global-font-family`（全局字体）, `$type-size-1` 至 `$type-size-8`（字号）等。
*   **颜色**：`$background-color`（背景色）, `$text-color`（文字色）, `$link-color`（链接色）等。
*   **布局**：`$small`, `$medium`, `$large`（响应式断点）等。
*   **其他**：`$border-radius`（圆角）, `$box-shadow`（阴影）等。

### 💎 总结

Minimal-Mistakes 的样式体系非常灵活：
1.  **快速起步**：从 **9 种预设皮肤** 中选择，一键切换网站色调。
2.  **内容适配**：为不同页面选用合适的 **页面布局**。
3.  **精细调整**：利用 **工具类** 快速修饰页面元素，或通过修改 **SCSS 变量** 实现深度定制。

另外，主题对评论系统（如 Disqus、Staticman）、分析工具（Google Analytics）以及多语言本地化等也提供了很好的支持。