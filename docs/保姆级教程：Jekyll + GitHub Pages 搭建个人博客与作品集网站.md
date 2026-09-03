---
published: false
---

# 保姆级教程：Jekyll + GitHub Pages 搭建个人博客与作品集网站

（2025 年 12 月更新，适配最新环境与主题版本）

## 摘要

本教程将手把手教你利用 Jekyll 静态网站生成器，配合 GitHub Pages 的免费托管服务，搭建一个同时具备**个人博客**与**专业作品集**功能的个人网站 —— 整个过程完全免费，且无需服务器或后端开发知识。我们会从零基础环境搭建起步，覆盖 GitHub 仓库配置、热门主题安装、核心功能定制到最终上线的完整流程，全程采用最通用的技术方案，确保新手也能零障碍上手。

为了兼顾美观性、易用性与功能扩展性，我们将选择**Minimal Mistakes**作为网站的主主题：这是一款经过大量开发者验证的响应式 Jekyll 主题，在全球范围内被广泛用于搭建博客、作品集等个人站点；它的设计简洁专业、适配所有现代浏览器与移动设备，同时对 Jekyll 生态的插件支持度极高，能满足博客写作、项目展示、评论交互、内容检索等多样化需求[(25)](https://wenku.csdn.net/doc/476u1cuc62)。

通过本教程的学习，你将掌握静态网站从本地搭建到上线托管的全链路开发流程，完成一个具备以下核心能力的个人网站：



* 内容创作区：支持 Markdown 格式的个人技术博客或日常文章发布；

* 成果展示区：以响应式画廊形式呈现项目案例、设计作品、研究成果等；

* 用户交互功能：集成免费的评论系统，支撑读者与作者的互动交流；

* 内容检索功能：添加轻量级全站搜索框，方便访客快速查找感兴趣的内容；

* 响应式适配：自动适配桌面、平板、手机等不同设备的屏幕宽度，保证阅读体验的一致性。

## 为什么选择这个技术栈？

在正式开始搭建前，我们先来梳理本技术栈的核心优势，理解为什么选择 Jekyll+GitHub Pages+Minimal Mistakes 的组合 —— 这一方案并非随意搭配，而是综合了成本、学习曲线、功能扩展性等多维度因素，对个人开发者来说几乎是当前的最优选择。

### Jekyll 的核心价值

作为 GitHub Pages 官方默认支持的静态网站生成器，Jekyll 是整个技术栈的核心基础，它的技术优势完美贴合个人网站的开发与运维需求：



* **无后端架构，极简运维**：Jekyll 的核心逻辑是将 Markdown 格式的文章内容与 HTML/CSS 编写的模板页面，直接渲染生成浏览器可直接识别的静态文件 —— 包括 HTML、CSS、JavaScript、图片等，无需额外配置服务器端环境或数据库支撑。这意味着你不需要花费精力维护服务器、排查后端服务故障，也不用担心数据库泄密或被拖库的风险，上传到 GitHub 的内容文件本身就具备版本追溯能力，运维成本被压缩到了极致[(36)](https://docs.github.com/enterprise/2.6/user/articles/setting-up-your-github-pages-site-locally-with-jekyll)。

* **天然适配 GitHub Pages，部署流程自动化**：GitHub Pages 对 Jekyll 的支持是 “底层级、无额外配置” 的 —— 当你将 Jekyll 网站的源代码推送到 GitHub 仓库的指定分支时，GitHub 的构建集群会自动识别代码中的 Jekyll 环境依赖，按照预设的规则完成静态文件的编译与打包，再将生成的静态资源分发到全球内容节点，完成全站的部署上线。整个过程完全由 GitHub 的托管资源完成，不需要额外的第三方部署工具或 CI/CD 流水线配置；即使后续你对网站的安全性、访问速度有更高要求，需要迁移到 Cloudflare Pages、Vercel 等其他静态托管平台，也只需重新配置域名解析即可，无需改动网站的任何底层逻辑[(9)](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll)。

* **基于 Markdown 的内容管理，专注创作本身**：Markdown 是当前技术圈与内容创作领域的通用轻量化标记语言，只要会写微信公众号或知乎文章，就能轻松掌握基础的 Markdown 语法。Jekyll 默认支持所有标准 Markdown 语法，还兼容部分 GitHub Flavored Markdown（GFM）的扩展格式 —— 这意味着你可以用 Markdown 编写所有网站内容，包括博客文章、项目介绍、作品集说明等，无需额外学习网站后台的复杂编辑器，也无需花费精力调整内容的样式格式，能将所有精力集中在内容创作上[(36)](https://docs.github.com/enterprise/2.6/user/articles/setting-up-your-github-pages-site-locally-with-jekyll)。

* **成熟的主题生态，快速实现功能适配**：Jekyll 的主题生态经过十余年的沉淀，已经覆盖了个人博客、作品集、技术文档、小组件展示等几乎所有个人网站的使用场景，大部分主题采用 “内容与表现分离” 的架构设计 —— 只需修改少量的配置文件，就能在不改动网站业务逻辑的前提下，完成从博客布局到作品集布局的多场景适配。本教程选择的 Minimal Mistakes 主题，就是其中的典型代表：它不仅原生支持博客与作品集的双场景布局，还预设了文章归档、标签分类、评论区、搜索栏等常用功能的基础代码，几乎可以实现 “开箱即用”，无需从零开始编写页面样式。

### GitHub Pages 的核心优势

GitHub Pages 是 GitHub 提供的免费静态网站托管服务，几乎完全覆盖了个人网站的所有核心需求，是托管 Jekyll 类静态站点的最优选择之一：



* **免费托管，无流量或带宽限制**：作为 GitHub 官方提供的基础服务，GitHub Pages 对用户的公开仓库永久免费，且不设流量、带宽或请求次数的限制 —— 这意味着即使你的网站被搜索引擎收录，或在社交平台上被大规模分享，也不会出现因流量过载导致的访问故障，更无需额外支付扩容成本。对于预算有限的个人开发者来说，这无疑是最低成本的托管方案[(9)](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll)。

* **天然集成 GitHub 的版本控制与协作能力**：GitHub Pages 的托管流程完全依托 GitHub 的 Git 版本控制能力 —— 你在本地对网站内容的每一次添加、修改、删除，都会被 Git 完整记录；当你将代码推送到远程仓库后，GitHub 会自动识别更新并部署最新版本，让网站的内容维护和版本迭代完全可控。后续如果需要回滚到历史版本、或邀请其他开发者参与网站内容的共建，只需借助 GitHub 的现有功能就能完成，无需额外学习其他协作工具。

* **自定义域名支持，专业度提升无成本**：GitHub Pages 默认会提供一个以`github.io`为后缀的免费二级域名 —— 例如`yourname.github.io`，但如果你有自己的顶级域名（例如`yourname.com`），也可以通过修改域名的 CNAME 或 A 记录解析，将顶级域名绑定到 GitHub Pages 的托管站点上。整个配置过程只需几分钟，且不会产生任何额外费用；绑定顶级域名后，无论是用于个人品牌展示还是项目宣传，都能有效提升网站的专业形象。

* **自动的 SSL 证书管理，全站 HTTPS 化**：信息安全是个人网站不可忽视的核心环节。GitHub Pages 为所有托管在其上的站点，默认提供了由 Let’s Encrypt 签发的免费 SSL 证书，且证书的申请、安装、续期全过程都由 GitHub 的后台服务自动完成，无需用户手动干预。开启 HTTPS 后，用户与网站之间的所有通信都会被加密，浏览器地址栏会显示安全锁标识，这不仅能提升用户的访问安全感，还对网站的搜索引擎收录效果有正向的促进作用[(9)](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll)。

### 为什么是 Minimal Mistakes 主题？

在众多适配 Jekyll 的博客 / 作品集双用途主题中，Minimal Mistakes 是最适合新手的选择 —— 它的设计逻辑完全围绕 “开箱即用” 和 “低代码定制” 的目标展开，对没有前端开发经验的用户极其友好，具体优势体现在以下几个方面：



* **双用途布局原生支持，无需额外开发**：该主题从底层架构上同时适配博客、作品集两种内容展示场景 —— 博客部分支持按文章发布年份、内容分类、阅读标签进行自动归档；作品集部分则提供了专门的项目卡片布局、图片画廊展示格式与项目详情页模板，你只需按照预设的规范添加项目内容，就能自动生成专业的作品集页面，无需自己从零编写页面布局代码[(25)](https://wenku.csdn.net/doc/476u1cuc62)。

* **响应式设计适配所有设备，保证多端体验的一致性**：随着移动互联网的普及，越来越多的用户会通过手机或平板设备浏览网站。Minimal Mistakes 的所有布局组件，都采用了响应式设计的技术规范，能够根据不同设备的屏幕宽度、分辨率和屏幕方向，自动调整页面内容的布局方式、字体大小、图片尺寸与交互元素的位置 —— 无论是在桌面电脑、平板还是手机上，用户都能获得一致的视觉体验和交互体验。

* **丰富的内置组件，覆盖常用功能场景**：该主题内置了大量可直接配置使用的功能组件，几乎覆盖了个人网站的所有常用场景 —— 包括但不限于文章阅读进度条、目录导航栏、社交媒体分享按钮、作者个人信息侧边栏、相关文章推荐区、标签云、分类归档页等。这些组件默认样式与主题整体设计风格保持一致，无需额外调整 CSS 样式；即使需要修改细节样式，也可以通过自定义 Sass 变量的方式，集中调整全局样式，无需逐个修改页面元素。

* **完整的中文文档与社区支持，新手遇到问题能快速排查**：Minimal Mistakes 的官方文档非常详尽，覆盖了从主题安装、基础配置到高级定制的所有环节，且大部分配置场景都提供了可直接复用的代码示例；更重要的是，该主题在国内开发者社区中活跃度极高 —— 如果你在配置过程中遇到问题，可以在 GitHub 的官方仓库、CSDN、掘金等技术平台上搜索相关解决方案，或在社区中发帖咨询，通常都能得到快速回复。

* **原生兼容主流评论与搜索插件，集成过程无需复杂开发**：静态网站的评论和搜索功能，一直是新手开发者的难点。Minimal Mistakes 主题预先内置了对多种主流评论系统的直接配置支持 —— 包括基于 GitHub Discussions 的免费评论系统 Giscus、基于 GitHub Issues 的评论插件 Utterances、通用评论服务 Disqus 等，几乎覆盖了所有免费的评论技术方案；同时它也兼容轻量级的客户端搜索插件 Simple-Jekyll-Search，配合主题自带的搜索栏布局，可以快速实现全站内容的检索能力，无需额外开发后端接口。

## 技术栈选型确认

根据你的需求（博客 + 作品集 + 评论 + 搜索），本教程采用以下技术方案，确保兼容性和可扩展性：



| 技术组件                       | 用途         | 选择理由                                                                      |
| -------------------------- | ---------- | ------------------------------------------------------------------------- |
| **Jekyll**                 | 静态网站生成器    | GitHub Pages 官方默认支持，无需额外构建流程；生态成熟，插件丰富；基于 Markdown 的内容管理，专注创作本身           |
| **GitHub Pages**           | 免费静态网站托管服务 | 直接托管 Jekyll 生成的静态文件，自动部署、免费提供 HTTPS 访问与自定义域名支持                            |
| **Minimal Mistakes Theme** | 网站前端主题模板   | 专门适配博客与作品集的双场景布局，响应式设计兼容所有设备；预集成了评论、搜索、归档等常用功能组件                          |
| **Giscus**                 | 评论系统       | 基于 GitHub Discussions 实现的免费评论服务，无广告、无用户数限制；与 Minimal Mistakes 主题的集成配置极其简单 |
| **Simple-Jekyll-Search**   | 全站搜索功能     | 轻量级纯客户端搜索方案，无需后端数据库支撑；配置完成后即可实现文章与项目内容的实时检索                               |

上述技术选型的所有组件，均为开源或免费服务，完全覆盖个人级网站的使用场景，且不存在隐含成本或后续升级费用。

## 第 0 章：环境准备与工具安装

在正式搭建网站之前，需要在本地计算机上安装必要的软件工具，以保证后续开发、调试、部署流程的顺利进行。这是整个搭建流程中最基础的环节，所有工具安装完成后，还需要验证各工具的版本兼容性，避免因环境问题导致后续配置故障。

### 0.1 安装必要的开发工具

Jekyll 的本地构建环境依赖 Ruby 语言和 Node.js 运行时环境，同时需要 Git 工具对网站代码进行版本控制与推送。下面将分操作系统详细介绍各工具的安装步骤，确保本地环境与后续 GitHub Pages 的构建环境一致性。

#### 0.1.1 安装 Git

Git 是目前全球最流行的分布式版本控制工具，是将本地网站代码上传到 GitHub 仓库的前提 —— 所有代码的版本管理、远程同步都需要依托 Git 的命令行工具完成。安装完成后，可以在终端中运行`git --version`命令验证安装是否成功；如果终端显示了版本号，则说明 Git 安装正常。



* **Windows 系统**：

1. 访问 Git 官方下载页面（[https://git-scm.com/download/win](https://git-scm.com/download/win)），下载最新版本的 Windows 安装包；

2. 运行下载的安装包，所有配置选项保持默认值不变，连续点击 “下一步” 完成安装；

3. 安装完成后，系统会自动配置一个名为 “Git Bash” 的命令行终端 —— 后续所有与 Git 相关的操作，都需要在这个终端中执行。

* **MacOS 系统**：

1. 打开系统自带的 “终端”（Terminal）应用；

2. 执行命令：`brew install git`，系统会自动安装 Homebrew 包管理器（如果尚未安装），再通过 Homebrew 完成 Git 的安装；

3. 安装结束后，在终端中输入`git --version`，如果显示了版本号，则说明安装成功。

* **Linux 系统（以 Ubuntu/Debian 为例）** ：

1. 打开系统自带的终端应用；

2. 执行命令：`sudo apt update && sudo apt install git`，系统会自动安装 Git 并完成基础配置；

3. 安装结束后，在终端中输入`git --version`，如果显示了版本号，则说明安装成功。

#### 0.1.2 安装 Ruby 和 Gem

Ruby 是 Jekyll 运行所依赖的底层编程语言，RubyGems 是 Ruby 的包管理器 —— 所有 Jekyll 的插件和主题，都会通过 RubyGems 进行安装和管理。这是整个本地环境中最关键的依赖环节，必须严格按步骤安装，避免出现版本兼容问题。

需要特别注意的是，Jekyll 对 Ruby 的版本有严格要求 —— 必须是 2.5.0 及以上的稳定版本；如果版本过低，后续安装 Jekyll 时会直接报错。安装完成后，可以在终端中运行`ruby -v`和`gem -v`命令，验证 Ruby 和 RubyGems 的版本是否符合要求。



* **Windows 系统**：

1. 访问 RubyInstaller 官方下载页面（[https://rubyinstaller.org/downloads/](https://rubyinstaller.org/downloads/)），选择推荐的带有 “Devkit” 的 Ruby 稳定版本进行下载 ——Devkit 是 Ruby 的开发工具链，包含了后续编译 Jekyll 插件所需的底层 C++ 依赖；

2. 运行下载的安装包，在安装向导的最后一步，务必勾选 “Run ridk install” 选项 —— 这会在安装完成后自动启动 Devkit 的配置流程；

3. 在随后弹出的命令行配置窗口中，输入数字 “3” 并按回车键，选择 “MSYS2 and MINGW development tool chain” 进行安装；这一过程会自动下载并配置所有底层编译依赖，需要等待几分钟；

4. 安装完成后，关闭所有打开的命令行窗口，再重新打开一个新的命令行终端，执行`ruby -v`和`gem -v`命令，确认 Ruby 和 RubyGems 安装成功。

* **MacOS 系统**：

1. MacOS 系统通常会预装 Ruby，但系统自带的 Ruby 版本往往过低，且没有配置完整的开发依赖 —— 为了避免权限问题，建议先通过 Homebrew 安装最新版本的 Ruby；

2. 打开系统自带的 “终端” 应用，执行命令：`brew install chruby ruby-install`；这会先安装 chruby 版本管理器，再通过 ruby-install 工具下载最新版本的 Ruby；

3. 安装完成后，执行命令：`ruby-install ruby`，这会自动下载并配置最新的稳定版 Ruby；

4. 为了让系统默认使用新安装的 Ruby 版本，还需要配置 shell 环境变量 —— 执行命令：`echo "source $(brew --prefix)/opt/chruby/share/chruby/chruby.sh" >> ~/.zshrc`；如果使用的是系统自带的 bash 终端，需要将命令中的`.zshrc`替换为`.bash_profile`；

5. 配置完成后，重启终端，执行`ruby -v`和`gem -v`命令，确认 Ruby 和 RubyGems 安装成功。

* **Linux 系统（以 Ubuntu/Debian 为例）** ：

1. 打开系统自带的终端应用，先更新系统的软件包索引：`sudo apt update`；

2. 安装 Ruby 和相关开发依赖：`sudo apt install ruby-full build-essential`；

3. 安装完成后，执行`ruby -v`和`gem -v`命令，确认 Ruby 和 RubyGems 安装成功。

#### 0.1.3 安装 Jekyll 和 Bundler

在安装完 Ruby 和 RubyGems 后，接下来需要安装 Jekyll 核心程序和 Bundler 依赖管理器 ——Bundler 是 Ruby 的依赖管理工具，它会根据项目根目录下的`Gemfile`文件的声明，自动下载并安装所有与 Jekyll 相关的依赖插件，避免不同插件之间的版本冲突。

安装完成后，可以在终端中运行`jekyll -v`命令，验证 Jekyll 的安装状态；如果终端显示了版本号，则说明 Jekyll 安装正常。需要特别注意的是，Windows 系统下必须使用命令行终端（如 Git Bash、CMD 或 PowerShell）执行所有 Jekyll 相关命令，不能使用 WSL（Windows Subsystem for Linux）的终端环境，否则后续本地调试时会出现路径兼容问题。

* **Windows/MacOS/Linux 系统**：

1. 打开一个新的命令行终端窗口；

2. 执行命令：`gem install jekyll bundler`—— 系统会自动下载并安装最新版本的 Jekyll 和 Bundler，以及所有相关的依赖包；

3. 安装完成后，执行`jekyll -v`命令，确认 Jekyll 安装成功。

### 0.2 注册相关服务账号

在正式开始建站前，需要先注册几个必要的在线服务账号，以保证后续所有功能的正常集成 —— 这些账号都是免费的，且不需要额外的企业资质或身份验证。


1. **GitHub 账号**：如果还没有 GitHub 账号，先访问 GitHub 官方网站（[https://github.com/](https://github.com/)）完成注册 —— 注册时需选择一个容易记忆的用户名，后续你的网站域名将直接使用这个用户名；例如，用户名为`codercat`，则对应的 GitHub Pages 站点域名是`codercat.github.io`。

2. **Giscus 评论系统账号**：Giscus 是基于 GitHub Discussions 的免费评论系统，无需额外注册账号 —— 只要你有 GitHub 账号，就可以直接登录 Giscus 的官方网站（[https://giscus.app/zh-CN](https://giscus.app/zh-CN)），完成后续的评论系统配置。

## 第 1 章：创建 GitHub 仓库与初始化 Jekyll 项目

本节将引导你创建一个新的 GitHub 代码仓库，并在本地初始化 Jekyll 项目环境，最终将本地的 Jekyll 源代码同步到 GitHub 仓库中。这是网站从本地文件到线上托管的关键衔接步骤，必须严格按照命名规则与配置要求操作。

### 1.1 创建 GitHub 仓库

GitHub 仓库是存储网站源代码的远程代码库，也是 GitHub Pages 托管服务的核心部署源 —— 只有将本地代码上传到符合命名规则的仓库中，GitHub 才能自动完成后续的构建部署流程。



1. 登录你的 GitHub 账号，在 GitHub 任意页面的右上角，点击页面右上角的 “+” 按钮，在下拉菜单中选择 “New repository”，进入新建仓库页面；

2. 在 “Repository name” 输入框中，严格按照以下规则输入仓库名称：`用户名.github.io`—— 这里的用户名必须与你的 GitHub 账号用户名完全一致，包括大小写；例如，如果你的 GitHub 用户名是`codercat`，则仓库名称必须是`codercat.github.io`。这是 GitHub Pages 识别用户站点的特殊命名规则，只有符合这一规则的仓库，才能被 GitHub Pages 直接识别为需要托管的站点代码；

3. 仓库的 “Visibility”（可见性）选项必须设置为 “Public”—— 如果使用 GitHub Free 账号，只有公开仓库才能被 GitHub Pages 识别为托管源；如果设置为私有仓库，后续部署时会直接报错；

4. 勾选 “Add a README file” 选项 —— 这会自动初始化仓库的默认分支，并创建一个`README.md`文件，后续可以在这个文件中添加网站的介绍内容；

5. 完成上述设置后，点击页面底部的 “Create repository” 按钮，完成仓库的创建；

6. 创建完成后，进入仓库的代码页面，点击 “Code” 按钮，复制仓库的远程 HTTPS 地址；后续会将本地的项目代码与之关联，实现代码的远程同步。

### 1.2 克隆仓库到本地

在完成远程仓库的创建后，需要将仓库克隆到本地计算机，再在仓库内执行 Jekyll 项目的初始化操作。这一步骤的核心是将远程仓库的代码同步到本地文件夹，后续所有的网站代码编写和文件修改，都将在这个本地文件夹中完成。



1. 打开 Git Bash 终端（Windows 系统）或系统自带的 “终端” 应用（MacOS/Linux 系统）；

2. 执行命令：`git clone 远程仓库地址`—— 将上一步中复制的仓库远程 HTTPS 地址，替换掉命令中的 “远程仓库地址” 部分；

3. 执行命令：`cd 仓库名称`—— 进入刚才克隆到本地的仓库目录；例如，如果仓库名称是`codercat.github.io`，则需要执行`cd codercat.github.io`命令；

4. 此时本地仓库中只有一个默认的`README.md`文件，接下来需要在这个目录下初始化 Jekyll 项目环境。

### 1.3 初始化 Jekyll 项目

接下来，我们将在本地仓库目录内创建一个全新的 Jekyll 站点，并配置 Minimal Mistakes 主题 —— 这一步骤会自动生成所有 Jekyll 项目必需的基础文件和目录结构，为后续的网站配置和内容添加打好基础。



1. 在当前的本地仓库目录下，执行命令：`jekyll new . --force`—— 这个命令会在当前目录下初始化一个新的 Jekyll 站点；其中的`.`符号表示 “在当前目录下初始化站点”，`--force`参数的作用是强制覆盖当前目录下的现有文件（如`README.md`），避免初始化过程中出现文件冲突提示；

2. 执行命令：`bundle install`—— 这个命令会自动安装所有 Jekyll 项目的依赖包，包括 Jekyll 核心框架、默认的 Markdown 解析器、Liquid 模板引擎等；所有依赖包都会被安装到项目目录下的`vendor/bundle`文件夹中，不会与系统全局的 Ruby 环境产生冲突；

3. 接下来，需要将 Minimal Mistakes 主题添加到项目的依赖配置文件中 —— 用 VS Code 或其他任意纯文本编辑器，打开项目根目录下的`Gemfile`文件，在文件的末尾添加一行代码：`gem "minimal-mistakes-jekyll"`；

4. 保存`Gemfile`文件后，再次在终端中执行命令：`bundle install`——Bundler 会自动下载并安装 Minimal Mistakes 主题的所有相关依赖，完成主题的本地集成；

5. 安装完成后，用 VS Code 或其他任意纯文本编辑器，打开项目根目录下的`_config.yml`文件，这是 Jekyll 项目的全局配置文件，后续所有的网站定制化配置都将在这个文件中完成；需要将文件中的`theme:`配置项，修改为`minimal-mistakes-jekyll`，指定 Jekyll 使用刚安装的 Minimal Mistakes 主题；

6. 为了验证主题配置是否生效，接下来在终端中执行命令：`bundle exec jekyll serve`—— 这个命令会启动 Jekyll 的本地构建服务，以及一个静态文件服务器；

7. 待终端中显示 “Server running... press ctrl-c to stop” 字样后，打开浏览器，在地址栏中输入`http://localhost:4000`，如果看到了 Jekyll 的默认欢迎页面，说明主题配置成功，本地环境已经正常运行。

## 第 2 章：配置 Minimal Mistakes 主题基础架构

在本节中，我们将对网站的核心基础架构进行定制化配置，包括网站的标题、描述、作者信息、导航栏布局等，完成博客与作品集的基础页面架构搭建。这些配置项都集中在`_config.yml`文件中，修改完成后需要重启本地服务才能生效。

### 2.1 配置站点基本信息

打开项目根目录下的`_config.yml`文件，这是 Jekyll 项目的全局配置文件，文件中已经包含了部分默认配置项，需要替换成我们自己的网站信息。以下是需要修改的核心配置项及参考配置值，你可以根据自己的需求，调整配置项的内容：



```
# 站点基础信息

title: "我的个人空间" # 网站的标题，会显示在浏览器标签页和网站顶部导航栏中

email: "your-email@example.com" # 你的联系邮箱地址，会显示在网站的侧边栏或页脚中

description: "记录技术学习、项目实践和思考的个人博客；展示我的作品集和项目成果。" # 网站的描述信息，会被搜索引擎抓取到，有助于提升SEO效果

baseurl: "" # 站点的基础路径，用户级站点需要设置为空字符串

url: "https://yourname.github.io" # 你的GitHub Pages站点的完整访问URL，必须与仓库命名一致

icon: "/assets/images/favicon.ico" # 网站的收藏夹图标，建议将图片文件存放到对应的目录下

# 主题配置

theme: minimal-mistakes-jekyll # 指定使用Minimal Mistakes主题，这是之前已经配置过的项

remote_theme: "mmistakes/minimal-mistakes@4.28.1" # 加载远程主题的指定版本，确保与官方版本兼容

# 文章链接的永久链接结构

permalink: /:categories/:title/ # 设置文章的URL结构，默认以分类和文章标题作为链接的相对路径
```

上述配置项中，`remote_theme`配置项的版本号（@4.28.1），可以替换为 Minimal Mistakes 主题的最新版本号；如果使用默认的主题版本，可以不用修改这一配置项的值。

### 2.2 配置顶部导航栏

网站的顶部导航栏是用户访问博客和作品集的核心入口，需要先配置导航栏的菜单结构，将默认的导航链接替换为我们自己的博客、作品集、关于等页面链接。Minimal Mistakes 主题支持通过`_data/navigation.yml`文件，对导航栏的结构进行可视化配置，无需修改任何 HTML 或 Liquid 模板代码。



1. 在项目根目录下，找到`_data`文件夹 —— 如果该文件夹不存在，则手动创建一个；

2. 在`_data`文件夹内，创建一个名为`navigation.yml`的新文件 —— 这个文件的作用是存储导航栏的菜单结构，Jekyll 会在构建站点时自动读取这个文件中的配置，将菜单结构渲染到网站的顶部导航栏中；

3. 在`navigation.yml`文件中，按照 YAML 语法格式，配置导航栏的菜单项列表；下列代码是一个适配博客与作品集的典型配置示例，你可以根据自己的需求，调整菜单项的名称和链接路径：

4. 保存`navigation.yml`文件，重启本地 Jekyll 服务，即可在网站的顶部导航栏中，看到新配置的菜单项。



```
# 顶部导航栏配置

main:

&#x20; - title: "首页"

&#x20;   url: /

&#x20; - title: "博客文章"

&#x20;   url: /posts/

&#x20; - title: "作品集"

&#x20;   url: /portfolio/

&#x20; - title: "分类归档"

&#x20;   url: /categories/

&#x20; - title: "标签云"

&#x20;   url: /tags/

&#x20; - title: "关于我"

&#x20;   url: /about/
```

### 2.3 创建通用页面模板

我们需要创建几个通用页面，作为博客、作品集、个人介绍等不同内容板块的独立页面，用于承载不同类型的内容。Minimal Mistakes 主题提供了多种预设的页面布局模板，可以直接根据需求选择对应的模板，快速创建出符合主题样式的页面，无需自己编写 CSS 样式。

在项目根目录下的`_pages`文件夹中，创建以下`.md`格式的 Markdown 文件 —— 如果`_pages`文件夹不存在，则手动创建一个；每个文件都需要以 YAML 格式的头部配置信息开头，指定页面的布局、标题、访问链接等基础属性。

#### 什么是YAML 格式的头部配置信息

它有一个专业名字叫 Front Matter（前置数据），指的是文件最开头的一段用 --- 上下两条横线夹住的文字。Jekyll 规定：凡是页面文件（.md 或 .markdown），都要以这个开头，它用来告诉 Jekyll 这个页面该怎么渲染。

拿你项目里 about.markdown 举例，开头的部分就是 Front Matter：

---
layout: single
title: About
permalink: /about/
---
（下面才是页面正文内容……）
三条横线里每个字段的含义
对照教程原文，这句话拆开就是：

原文说法	对应字段	作用
布局	layout: page（已弃用）	告诉 Jekyll 用哪种页面模板来渲染（首页 home、文章 post、单页 single 等）
标题	title: About	页面显示的标题，会出现在浏览器标签和页面顶部
访问链接	permalink: /about/	这个页面在网站上对应的 URL 地址，这里是 https://你的域名/about/

- 没有 Front Matter 的文件，Jekyll 会直接当成普通静态文件原样复制，不经过任何渲染处理；
- 有 Front Matter 的文件，Jekyll 才会把它当页面处理，用 layout 指定的模板渲染、把 title 等信息填进页面、按 permalink 生成链接。

#### 2.3.1 博客文章列表页面

创建`_pages/posts.md`文件，作为博客文章的列表页面，显示所有博客文章的摘要信息：



```
---

layout: home

title: "博客文章"

permalink: /posts/

pagination:

&#x20; enabled: true

&#x20; collection: 'posts'

&#x20; per_page: 10

&#x20; permalink: '/page/:num/'

&#x20; sort_field: 'date'

&#x20; sort_reverse: true

---

这里是我的博客文章列表，记录我的技术学习、项目实践和思考感悟。
```

上述配置中，`layout: home`指定使用主题的首页布局模板；`permalink`指定了页面的访问链接为`https://yourname.github.io/posts/`；`pagination`段配置了文章的分页规则，每页最多显示 10 篇文章，按文章发布时间倒序排列。

#### 2.3.2 作品集展示页面

创建`_pages/portfolio.md`文件，作为作品集的首页，采用响应式画廊布局展示所有项目卡片：



```
---

layout: collection

title: "我的作品集"

permalink: /portfolio/

collection: portfolio

entries_layout: grid

columns: 2

sort_by: date

sort_order: reverse

---

这里是我的项目作品集，展示我的技术项目、设计作品和研究成果。
```

上述配置中，`layout: collection`指定使用主题的集合布局模板；`collection: portfolio`指定了该页面将读取`_portfolio`文件夹下的所有项目内容文件；`entries_layout: grid`设置项目以网格卡片形式展示，`columns: 2`设置在宽屏设备下每行显示 2 个项目卡片。

#### 2.3.3 分类归档页面

创建`_pages/categories.md`文件，作为文章的分类归档页面，将所有博客文章按分类进行聚合展示：



```
---

layout: categories

title: "文章分类"

permalink: /categories/

---

按分类浏览我的所有文章。
```

#### 2.3.4 标签归档页面

创建`_pages/tags.md`文件，作为文章的标签归档页面，将所有博客文章按标签进行聚合展示：



```
---

layout: tags

title: "文章标签"

permalink: /tags/

---

按标签浏览我的所有文章。
```

#### 2.3.5 个人介绍页面

创建`_pages/about.md`文件，作为你的个人介绍页面，展示你的头像、简介、社交链接等个人信息：



```
---

layout: single

title: "关于我"

permalink: /about/

---

## 个人简介

我是一名热爱技术的全栈开发者，对前端开发、架构设计和静态站点生成技术有深入研究。

热爱开源，喜欢折腾新工具，擅长将复杂技术方案转化为简单可落地的实现。

本博客用于记录技术学习、项目实践和思考感悟；作品集展示我的公开项目和成果。

## 联系我

- GitHub: [@yourname](https://github.com/yourname)

- 邮箱: your-email@example.com

- 知乎: [@yourname](https://www.zhihu.com/yourname)
```

上述配置中，`layout: single`指定使用主题的通用单页布局模板，这是 Minimal Mistakes 主题默认的标准文章页面布局。


---

### 2.4 配置作者信息与侧边栏
Minimal Mistakes 主题的侧边栏，可以显示你的头像、个人简介、社交链接等核心个人信息，能有效提升网站的专业形象。

> 💡 Minimal Mistakes 有两种作者配置模式：
> - **多作者模式（推荐，教程使用此方式）**：配置写在项目根目录 `_data/authors.yml`；
> - **单作者简易模式**：直接写在 `_config.yml` 的顶层 `author:`。

侧边栏配置（多作者模式）位于项目根目录下的`_data/authors.yml`文件中，如果文件不存在需要手动新建。打开该文件，在其中添加你的个人信息；下列配置示例中，需要将`avatar`配置项的值，替换为你自己的头像图片路径。

```yaml
# _data/authors.yml 作者信息配置（多作者模式，default代表默认作者）
default:
  name: "你的名字"
  avatar: "/assets/images/bio-photo.jpg" # 头像图片路径，建议将图片文件存放到对应的目录下
  bio: "全栈开发者 / 技术博主 / 开源爱好者" # 个人简介，会显示在头像下方
  location: "杭州，中国" # 你的所在地区
  links: # 社交链接菜单，会显示在侧边栏中
    - label: "GitHub"
      icon: "fab fa-github"
      url: "https://github.com/yourname"
    - label: "邮箱"
      icon: "fas fa-envelope"
      url: "mailto:your-email@example.com"
    - label: "知乎"
      icon: "fab fa-zhihu"
      url: "https://www.zhihu.com/yourname"
```

> 注意：`_data/authors.yml` 中顶层键 `default:` 是主题约定，代表**默认作者**，不要修改这个key名称。

完成上述配置后，还需要在`_config.yml`文件中，启用作者信息侧边栏的全局默认配置 —— 在`_config.yml`文件末尾，添加以下配置代码：

```yaml
# _config.yml 默认配置项
defaults:
  # 对所有文章类型的页面启用作者信息、阅读进度、评论区、分享按钮等组件
  - scope:
      path: ""
      type: posts
    values:
      layout: single
      author_profile: true # 启用作者信息侧边栏
      read_time: true # 启用文章阅读进度显示
      comments: true # 启用评论区
      share: true # 启用社交分享按钮
      related: true # 启用相关文章推荐区
  # 对所有独立页面启用作者信息侧边栏
  - scope:
      path: ""
      type: pages
    values:
      layout: single
      author_profile: true
```

**多作者模式（`_data/authors.yml`）**：必须在页面的 front matter 或 `defaults` 里额外指定 `author: default`，主题才会去文件里找对应的作者信息，否则不会读取。



> ⚠️重要提示：
> 1. YAML文件**只能使用普通空格缩进，禁止Tab制表符**；复制网页示例代码时谨防带入不可见特殊空格，会造成 `Psych::SyntaxError` 解析报错；
> 2. 修改`_config.yml`配置文件后**必须重启Jekyll本地服务，浏览器直接刷新页面不会加载新配置**；普通Markdown文章修改无需重启。

重启本地 Jekyll 服务操作：在运行服务的终端窗口按下 `Ctrl + C` 停止服务，再执行：
```bash
bundle exec jekyll serve
```
访问`http://127.0.0.1:4000`，检查导航栏、侧边栏、各个通用页面是否正常显示。



---

## 第 3 章：添加网站核心内容

在完成基础架构配置后，接下来需要添加网站的核心内容：博客文章与作品集项目内容。这一步骤将详细说明如何按照主题预设的格式，添加博客文章与作品集项目内容，让网站从默认的演示站点，变成具备实际内容的个人站点。

### 3.1 管理博客文章

在 Jekyll 中，所有博客文章都必须存放在项目根目录下的`_posts`文件夹内 —— 这是 Jekyll 的默认内容识别目录，只有存放在这个文件夹内的 Markdown 文件，才会被 Jekyll 识别为博客文章，并加入到文章列表、归档、分页等逻辑中。如果`_posts`文件夹不存在，则需要手动创建一个。

#### 3.1.1 添加第一篇博客文章

博客文章的文件名，必须遵循 Jekyll 的默认命名规范：`年-月-日-文章标题.md`—— 例如，2025 年 12 月 31 日发布的标题为 “我的静态网站搭建历程” 的文章，对应的文件名应为`2025-12-31-my-first-post.md`。这一命名规范是 Jekyll 识别文章发布时间的唯一标准，必须严格遵循。

在`_posts`文件夹内，创建一个符合上述命名规范的`.md`文件，文件内容的示例如下：

```
---

layout: single # 使用单页布局模板

title: "我用Jekyll+GitHub Pages搭建了个人网站" # 文章标题

excerpt: "作为一名开发者，我为什么选择Jekyll+GitHub Pages的组合，搭建我的个人网站。" # 文章摘要，会显示在文章列表中

categories: [技术, 网站开发] # 文章所属的分类，会显示在文章列表中

tags: [Jekyll, GitHub Pages, 静态网站, 前端开发] # 文章的标签，会显示在文章列表中

hidden: true # 设为true时，该文章不会被索引到，适合写草稿

---

## 前言

作为一名开发者，我一直想搭建一个完全属于自己的个人网站——不用关心服务器维护、不用升级后端版本、不用支付数据库托管费用，且能完全自由定制网站的功能细节。在对比了市面上所有主流方案后，我最终选择了「Jekyll+GitHub Pages」的技术组合，这是一个免费、简洁且高效的静态网站解决方案。

## 为什么选择这个技术栈？

在正式开始搭建前，我对比了市面上的几种主流静态网站方案，最终选择这个组合的核心理由有以下几个：

- **完全免费**：GitHub Pages提供了免费的静态文件托管服务，且没有流量或带宽限制；Jekyll是开源软件，不需要支付任何授权费用；

- **极简运维**：Jekyll可以将Markdown格式的文章内容，直接渲染成静态文件，不需要配置后端服务器或数据库；GitHub会自动完成所有的构建和部署工作；

- **Markdown支持**：我平时写技术文档都用Markdown，用它来写博客文章，可以完全专注于内容本身，不需要额外学习网站后台的复杂编辑器；

- **版本控制**：所有文章内容都存放在GitHub仓库中，可以随时随地在不同设备上进行修改，不用担心内容丢失。

## 搭建过程的关键步骤

我将整个搭建过程整理成了一份完整的教程，分享给大家。

### 1. 环境准备

首先需要在本地计算机上安装Git、Ruby和Jekyll。整个过程的详细步骤可以参考[环境准备与工具安装](#环境准备与工具安装)部分。

### 2. 初始化站点

安装完必要的工具后，就可以在本地创建一个新的Jekyll站点，并配置好Minimal Mistakes主题。

### 3. 编写内容

编写文章和项目内容，所有内容都使用Markdown格式编写。

### 4. 部署上线

将本地的所有代码和内容推送到GitHub仓库，GitHub Pages会自动完成构建和部署工作。

## 总结

整个搭建过程，从环境配置到内容上线，总共只花了几个小时——后续的内容维护，只需要在本地编写Markdown文件，推送到GitHub即可，完全不需要额外的运维精力。如果你也想搭建一个属于自己的个人网站，强烈推荐尝试这个技术组合。
```

上述内容中，文件开头的 YAML 配置部分，是 Jekyll 识别文章属性的核心依据，所有配置项都不能随意删除或修改；配置部分的下面是文章的正文内容，完全支持标准的 Markdown 格式，以及部分 GFM 的扩展格式，如表格、代码块、任务列表等。

#### 3.1.2 博客文章管理技巧



* **文章摘要控制**：在文章的 YAML 配置部分，可以通过`excerpt`配置项，自定义文章的摘要内容 —— 如果不设置这个配置项，Jekyll 会自动截取文章正文的前一段落作为摘要；如果需要手动控制摘要的显示长度，可以在文章正文的指定位置添加`<!--more-->`注释，注释之前的内容会被自动截取为文章摘要。

* **分类与标签规范**：文章的`categories`和`tags`配置项，用于设置文章的分类和标签 —— 分类用于将文章按大的内容板块聚合，标签用于标记文章的技术栈或关键词；这两个配置项的值，必须使用英文逗号分隔，且不能包含特殊字符；如果有多个分类或标签，需要用方括号包裹。

* **文章草稿处理**：如果文章尚未编写完成，暂时不希望显示在网站的文章列表中，可以将文章的 YAML 配置部分添加`hidden: true`配置项 —— 这篇文章会被保留在仓库中，但不会被 Jekyll 加入到文章列表、归档、分页等逻辑中；待文章编写完成后，删除这一配置项，或改为`hidden: false`，文章就会正常显示在网站中。

### 3.2 管理作品集内容

在 Minimal Mistakes 主题中，作品集的项目内容，默认存放在项目根目录下的`_portfolio`文件夹内 —— 这是主题预设的内容识别目录，只有存放在这个文件夹内的 Markdown 文件，才会被识别为作品集项目，并显示在`/portfolio/`页面的项目列表中。如果`_portfolio`文件夹不存在，则需要手动创建一个。

#### 3.2.1 添加第一个项目

在`_portfolio`文件夹内，创建一个新的`.md`文件，例如`2025-12-31-project-1.md`—— 项目文件的文件名同样需要遵循`年-月-日-项目标题.md`的命名规范，文件内容的示例如下：



```
---

layout: single # 使用单页布局模板

title: "个人财务统计分析系统" # 项目的标题

excerpt: "一个基于Python和React的个人财务数据统计分析系统，支持数据可视化报表和多维度账单统计。" # 项目的摘要，会显示在项目卡片中

gallery: # 项目的图片画廊，会显示在项目详情页中

&#x20; - url: /assets/images/portfolio/project-1-full.jpg # 项目的完整预览图

&#x20;   image_path: /assets/images/portfolio/project-1-thumb.jpg # 项目的缩略图，会显示在项目卡片中

&#x20;   alt: "系统首页的预览图" # 图片的替代文本，用于图片加载失败时的显示

categories: [软件开发, 全栈开发] # 项目所属的分类

tags: [Python, React, 数据可视化, 全栈开发] # 项目的技术栈标签

hidden: false # 设为true时，该项目不会被索引，适合保密项目

---

## 项目概述

这是我在2025年独立开发的个人财务数据统计分析系统，采用前后端分离的技术架构，前端基于React和Ant Design Pro实现，后端基于Python的FastAPI框架实现，支持用户上传账单明细、自动对账单进行多维度分类统计、生成交互式数据可视化报表、导出统计结果为Excel格式的文件等核心功能。

## 技术栈

- **前端**：React 18、TypeScript、Ant Design Pro、ECharts

- **后端**：Python 3.11、FastAPI、SQLAlchemy、MySQL

- **部署**：Docker、Docker Compose、Nginx

## 功能特性

1. 支持手动上传或通过Excel文件批量导入账单明细

2. 自动对账单进行多维度分类统计，支持按支出类型、支付时间、支付账户等维度进行筛选查询

3. 生成交互式数据可视化报表，支持按月份、季度、年份的收支趋势分析

4. 支持导出统计结果为Excel格式或PDF格式的文件

5. 基于JWT的用户身份认证机制，保证数据的安全性

## 项目预览

{% include gallery caption="系统的主要页面预览图" %}

## 项目源码

- GitHub: [@yourname/financial-analysis-system](https://github.com/yourname/financial-analysis-system)

- 在线演示: [https://yourname.github.io/demo/financial-analysis-system](https://yourname.github.io/demo/financial-analysis-system)
```

上述内容中，文件开头的 YAML 配置部分，有一个`gallery`配置项，用于指定项目的预览图片 —— 需要将项目的缩略图和完整预览图，分别存放在`/assets/images/portfolio/`目录下，缩略图建议尺寸为 600×400 像素，完整预览图建议尺寸为 1920×1080 像素；在项目详情页中，`{% include gallery %}`标签会自动将配置的图片渲染成响应式画廊。

#### 3.2.2 作品集管理技巧



* **项目显示顺序**：Minimal Mistakes 主题默认按照项目的发布时间，倒序排列作品集列表 —— 即最新添加的项目，会显示在作品集列表的最前面；如果需要手动调整项目的显示顺序，可以在项目的 YAML 配置部分，添加`date`配置项，将项目的发布时间设置为需要的排序时间。

* **项目摘要控制**：与博客文章类似，可以通过`excerpt`配置项，自定义项目的摘要内容 —— 如果不设置这个配置项，Jekyll 会自动截取项目正文的前一段落作为摘要；项目摘要会显示在`/portfolio/`页面的项目卡片中，建议控制在 100 字以内。

* **私有项目处理**：如果项目暂时不希望公开显示在网站的作品集列表中，可以将项目的 YAML 配置部分添加`hidden: true`配置项 —— 这篇项目文件会被保留在仓库中，但不会被 Jekyll 加入到作品集列表中；待项目需要公开时，删除这一配置项，或改为`hidden: false`，项目就会正常显示在作品集列表中。

* **图片优化处理**：作品集的图片文件，是影响网站加载速度的核心因素 —— 所有缩略图和预览图，都需要在上传到仓库前进行压缩处理；建议使用 TinyPNG 等在线压缩工具，将图片压缩到原大小的 30% 以内，同时保证图片的显示质量，避免影响网站的首屏加载速度。

## 第 4 章：添加评论系统

静态网站本身没有后端服务器或数据库支撑，无法原生实现评论功能 —— 要实现评论功能，必须借助第三方托管的评论服务。这类服务会将评论数据存储在第三方的数据库中，我们仅需在网站的指定页面中，嵌入第三方评论服务的前端脚本，即可将评论功能集成到站点中。

本教程选择的方案是**Giscus**—— 一款基于 GitHub Discussions 的免费评论系统，无广告、无用户数限制、完全开源，是当前最适配 Jekyll 类静态站点的评论技术方案，也是 Minimal Mistakes 主题官方推荐的评论系统之一。

### 4.1 为什么选择 Giscus？

在选择评论系统时，我对比了国内用户常用的 Disqus、Utterances、Gitalk 等主流评论服务，最终选择 Giscus 的核心理由有以下几个：



* **完全免费，没有隐藏成本**：Giscus 是基于 GitHub Discussions 开发的开源评论系统，完全免费使用，且没有评论数量、访客数量或请求次数的限制；

* **基于 GitHub 账号登录，无需额外注册**：用户评论时，只需要通过自己的 GitHub 账号授权登录，即可发表评论，不需要额外注册账号；对于技术类站点的访客来说，这是极低门槛的登录方式；

* **评论数据存储在 GitHub 仓库中，内容完全可控**：所有评论数据都会被存储在 GitHub 仓库的 Discussions 板块中，不需要额外依赖第三方的数据库，内容所有权完全属于网站所有者，不用担心评论数据丢失；

* **无广告，不会影响用户体验**：Giscus 是开源项目，不会在评论区插入任何广告，能保持网站的内容区域干净整洁；

* **高度可定制化，适配网站的设计风格**：支持自定义评论区的主题颜色、位置、加载时机等细节，可以完全匹配网站的整体设计风格；

* **与 Minimal Mistakes 主题的集成配置极其简单**：主题官方内置了对 Giscus 的直接配置支持，只需在`_config.yml`中添加几个配置项，即可完成集成，不需要额外编写 HTML 或 JavaScript 代码。

### 4.2 配置 Giscus 应用

在将 Giscus 评论系统集成到网站之前，需要先在 GitHub 仓库中完成 Giscus 应用的初始化配置，让 Giscus 应用获得仓库的 Discussions 权限，用于后续的评论数据存储。



1. 打开浏览器，登录你的 GitHub 账号，进入 Giscus 的官方网站（[https://giscus.app/zh-CN](https://giscus.app/zh-CN)）；

2. 在 “配置” 区域的 “仓库” 输入框中，输入你的作品集仓库的完整名称，格式为`你的用户名/你的用户名.github.io`；例如，如果你的 GitHub 用户名是`codercat`，则需要输入`codercat/codercat.github.io`；

3. 向下滚动页面，在 “仓库设置” 区域，仔细阅读给出的两个检查项，确认你的仓库符合 Giscus 的安装条件：

* 检查你的仓库是否为公开仓库 —— 如果是私有仓库，Giscus 将无法正常读取 Discussions 数据；

* 检查你的仓库是否已经启用了 Discussions 功能 —— 如果没有启用，需要进入仓库的 “Settings” 选项卡，在左侧的 “Features” 区域中，勾选 “Discussions” 选项；

1. 在 “页面→Discussions 映射关系” 区域，选择 “页面路径名称” 选项 —— 这一配置的作用是，将网站的每个文章或项目页面，与仓库 Discussions 中的一个独立讨论主题一一对应；

2. 在 “Discussion 分类” 区域，选择 “Announcements” 分类 —— 这一配置的作用是，将所有评论相关的讨论主题，统一归类到 Discussions 的 Announcements 分类下；如果你的仓库中没有这个分类，可以点击 “Create new category” 链接，在弹出的窗口中新建一个 Announcements 分类；

3. 在 “功能” 区域，勾选以下所有选项 —— 这些配置的作用是，启用评论区的所有核心功能，包括访客的评论回复、表情互动、按时间排序显示评论等；

4. 完成所有配置后，点击页面底部的 “获取配置” 按钮，Giscus 会根据你的配置，自动生成一段 JavaScript 嵌入代码；需要将这段代码复制到剪贴板，后续会用它来配置 Minimal Mistakes 主题的评论系统。

### 4.3 集成到 Minimal Mistakes 主题

在主题中，启用 Giscus 评论系统的配置非常简单，只需要在`_config.yml`文件中，添加几行配置项，即可完成集成，不需要额外修改任何 HTML 或 Liquid 模板代码。



1. 打开项目根目录下的`_config.yml`文件，在文件的末尾，添加以下配置代码：



```
# 评论系统配置

comments:

&#x20; provider: "giscus" # 指定使用Giscus作为评论系统

&#x20; giscus:

&#x20;   repo: "你的用户名/你的用户名.github.io" # 你的仓库完整名称

&#x20;   repo_id: "上一步中获取的仓库ID" # 你的仓库的唯一ID，在Giscus生成的配置代码中可以找到

&#x20;   category: "Announcements" # 刚才在Discussions中创建的分类名称

&#x20;   category_id: "上一步中获取的分类ID" # 刚才创建的分类的唯一ID，在Giscus生成的配置代码中可以找到

&#x20;   mapping: "pathname" # 页面与Discussions主题的映射规则

&#x20;   input_position: "top" # 评论输入框的位置，设置在评论区列表的上方

&#x20;   theme: "light" # 评论区的主题颜色，浅色模式

&#x20;   lang: "zh-CN" # 评论区的显示语言，设置为简体中文

&#x20;   loading: "lazy" # 评论区的懒加载模式，只有用户滚动到评论区附近时，才加载评论数据
```

上述配置项中，`repo_id`和`category_id`的值，需要替换成刚才在 Giscus 官网生成的配置代码中对应的属性值；这两个值是 Giscus 关联仓库 Discussions 的核心凭证，必须严格复制，不能有丝毫差错。



1. 接下来，需要在`_config.yml`文件的`defaults`配置项中，确认所有文章和项目页面都已启用评论区功能 —— 在`defaults`配置项的`posts`和`pages`作用域下，确保`comments: true`配置项已存在；如果没有，需要手动添加这一配置项；

2. 保存`_config.yml`文件，重启本地 Jekyll 服务，此时打开任意一篇文章或项目详情页，在页面的底部，就可以看到 Giscus 的评论区组件；

3. 评论区的显示效果和功能配置，与你在 Giscus 官网的初始配置完全一致；如果需要调整评论区的主题颜色、语言或加载时机，可以重新在 Giscus 官网生成配置代码，替换掉`_config.yml`中的对应配置项即可。

## 第 5 章：添加站内搜索功能

静态网站的搜索功能，与动态站点的搜索功能有本质区别 —— 静态站点没有后端的数据库支撑，也没有独立的搜索引擎接口，只能通过客户端 JavaScript，对站点内的所有内容进行关键词匹配，实现检索能力。

本教程选择的方案是**Simple-Jekyll-Search**—— 一款轻量级的纯客户端搜索插件，专门为 Jekyll 网站量身定制。它的原理是，在站点构建时，自动生成一个包含所有文章和项目内容的 JSON 格式索引文件；用户在搜索框中输入关键词时，插件会在这个本地的 JSON 索引文件中，进行全文关键词匹配检索，再将检索结果实时渲染到页面上 —— 整个过程完全在用户的浏览器中完成，不需要额外的后端接口支撑。

### 5.1 为什么选择 Simple-Jekyll-Search？

在选择搜索插件时，我对比了 Algolia、Lunr.js、Tipue Search 等主流搜索方案，最终选择 Simple-Jekyll-Search 的核心理由有以下几个：



* **纯客户端实现，无需后端支持**：整个搜索功能完全在用户的浏览器中完成，不需要额外的后端服务器或数据库支撑，也不会产生任何第三方服务的调用费用；

* **轻量级资源占用，不影响网站加载性能**：插件的压缩后体积仅为 53KB，不会影响网站的首屏加载速度；同时它采用懒加载技术，只有用户点击搜索框时，才会加载插件的核心资源；

* **配置流程简单，适配 Minimal Mistakes 主题的搜索布局**：插件的配置过程仅需几分钟，不需要额外编写复杂的代码；Minimal Mistakes 主题官方已经内置了搜索框的布局样式，只需将插件的搜索结果组件与主题的搜索栏进行关联即可；

* **支持中文全文检索，适配中文内容场景**：插件默认支持中文的全文关键词匹配，不需要额外配置分词规则；用户输入中文关键词时，能正确匹配到相关的文章和项目内容；

* **开源且免费使用，无任何功能限制**：插件采用 MIT 开源协议，完全免费使用，且没有检索次数、关键词数量、内容索引大小的限制；

* **与 Minimal Mistakes 主题的集成配置极其简单**：主题官方内置了对该插件的搜索栏布局组件，只需在`_config.yml`中添加几个配置项，再生成内容索引文件即可完成集成。

### 5.2 配置搜索功能的数据源

插件需要一个 JSON 格式的索引文件，作为全站搜索功能的数据源 —— 这个文件会在 Jekyll 构建站点时，自动生成，包含所有文章和项目的标题、访问链接、摘要内容和关键词信息。



1. 在项目根目录下，创建一个名为`search.json`的文件 —— 这个文件的内容，是一段 Liquid 模板代码，作用是遍历所有文章和项目内容，将必要的检索信息以 JSON 数组的格式，输出到文件中；

2. 将以下代码，复制到`search.json`文件中，覆盖掉文件的所有默认内容：



```
---

---

[

&#x20; {% for post in site.posts %}

&#x20;   {

&#x20;     "title"    : "{{ post.title | escape }}",

&#x20;     "category" : "{{ post.categories | join: ', ' }}",

&#x20;     "tags"     : "{{ post.tags | join: ', ' }}",

&#x20;     "url"      : "{{ site.baseurl }}{{ post.url }}",

&#x20;     "date"     : "{{ post.date | date: '%Y-%m-%d' }}",

&#x20;     "excerpt"  : "{{ post.excerpt | strip_html | escape }}"

&#x20;   }{% unless forloop.last %},{% endunless %}

&#x20; {% endfor %}

&#x20; {% for project in site.portfolio %}

&#x20;   {

&#x20;     "title"    : "{{ project.title | escape }}",

&#x20;     "category" : "{{ project.categories | join: ', ' }}",

&#x20;     "tags"     : "{{ project.tags | join: ', ' }}",

&#x20;     "url"      : "{{ site.baseurl }}{{ project.url }}",

&#x20;     "date"     : "{{ project.date | date: '%Y-%m-%d' }}",

&#x20;     "excerpt"  : "{{ project.excerpt | strip_html | escape }}"

&#x20;   }{% unless forloop.last %},{% endunless %}

&#x20; {% endfor %}

]
```

上述代码的作用是，在 Jekyll 构建站点时，自动遍历所有的博客文章和作品集项目内容，将它们的标题、分类、标签、访问链接、发布日期、摘要信息等检索必要的属性，以 JSON 数组的格式，输出到`search.json`文件中；插件会在用户输入关键词时，读取这个文件中的数据，完成检索操作。

### 5.3 安装搜索插件并集成到主题

接下来，需要将 Simple-Jekyll-Search 插件，添加到网站的静态资源中，再将插件的搜索逻辑，与 Minimal Mistakes 主题的搜索栏布局进行关联，完成搜索功能的集成。



1. 在项目根目录下，创建一个名为`assets/js`的文件夹 —— 如果该文件夹已经存在，则跳过这一步；

2. 访问 Simple-Jekyll-Search 的官方 GitHub 仓库（[https://github.com/christian-fei/Simple-Jekyll-Search](https://github.com/christian-fei/Simple-Jekyll-Search)），下载插件的最新压缩包，解压后将`simple-jekyll-search.min.js`文件，复制到刚才创建的`assets/js`文件夹中；

3. 用 VS Code 或其他纯文本编辑器，打开项目根目录下的`_config.yml`文件，在文件的末尾，添加以下配置代码，启用主题的搜索功能，并指定搜索结果的渲染逻辑：



```
# 搜索功能配置

search: true # 启用全站搜索功能

search_provider: "simple-jekyll-search" # 指定使用Simple-Jekyll-Search作为搜索插件

search:

&#x20; placeholder: "搜索文章、项目和标签..." # 搜索框的默认提示文本

&#x20; label: "搜索" # 搜索框的前置标签文本

&#x20; input_id: "search-input" # 搜索框的DOM元素ID

&#x20; results_id: "results-container" # 搜索结果容器的DOM元素ID

&#x20; search_without_empty_query: true # 允许用户在不输入任何关键词的情况下，查看所有搜索结果
```



1. 接下来，需要在`_layouts/default.html`文件中，引入插件的 JavaScript 依赖库 ——Minimal Mistakes 主题的默认布局文件中，已经预留了搜索框的位置，只需要将插件的脚本文件，引入到布局文件中；

2. 重启本地 Jekyll 服务，此时在网站的顶部导航栏中，就可以看到搜索框；在搜索框中输入文章或项目的关键词，搜索结果就会在搜索框下方实时展示，点击搜索结果项，就可以跳转到对应的文章或项目详情页。

### 5.4 优化搜索结果的展示效果

完成基础集成后，还需要对搜索结果的展示效果进行优化，让它更匹配 Minimal Mistakes 主题的默认样式，提升用户的搜索体验。



1. 在项目根目录下的`_assets/css`文件夹中，创建一个名为`custom-search.css`的文件，在这个文件中添加自定义的搜索结果样式，让搜索结果的显示风格，与网站的整体设计风格保持一致；

2. 打开项目根目录下的`_config.yml`文件，在`head`配置项中，添加刚才创建的`custom-search.css`文件的引用地址，让 Jekyll 在构建站点时，将这个样式文件，引入到所有页面的`head`标签中；

3. 重启本地 Jekyll 服务，再次进行搜索操作，此时搜索结果的展示样式，就会与网站的整体设计风格完全匹配；

4. 插件的搜索结果中，默认会显示文章或项目的标题、分类、发布日期和摘要；如果需要调整搜索结果的显示字段、或匹配规则，可以在`search.json`文件中，修改 Liquid 模板代码，调整插件的配置项。

## 第 6 章：部署网站到 GitHub Pages

在完成本地的所有配置和内容编写后，需要将本地的网站源代码，推送到 GitHub 的远程仓库，再将仓库部署到 GitHub Pages 的托管服务中，完成网站的上线发布。

### 6.1 推送本地代码到 GitHub

首先，需要将本地的所有网站源代码，提交到 Git 的本地版本库，再推送到 GitHub 的远程仓库中 —— 这一步骤是将本地内容同步到 GitHub 的核心环节，后续的 GitHub Pages 构建部署流程，会自动读取远程仓库的最新代码，完成全站的构建和部署。



1. 打开 Git Bash 终端（Windows 系统）或系统自带的 “终端” 应用（MacOS/Linux 系统），进入到项目的根目录中；

2. 执行命令：`git status`—— 这个命令会列出当前目录下，所有已修改或已添加的文件，检查这些文件是否是需要上传的内容；

3. 执行命令：`git add .`—— 这个命令会将当前目录下的所有修改过的文件，添加到 Git 的暂存区中；

4. 执行命令：`git commit -m "Initial commit with Jekyll site and theme configuration"`—— 这个命令会将暂存区中的所有文件，提交到 Git 的本地版本库中；提交信息需要准确描述本次提交的主要内容，方便后续追溯版本；

5. 执行命令：`git branch -M main`—— 这个命令会将本地仓库的默认分支名，设置为`main`；

6. 执行命令：`git remote add origin https://github.com/你的用户名/你的用户名.github.io.git`—— 这个命令会将本地仓库，与 GitHub 上的远程仓库进行关联；需要将命令中的远程仓库地址，替换成你自己的仓库 HTTPS 地址；

7. 执行命令：`git push -u origin main`—— 这个命令会将本地仓库的`main`分支上的所有代码，推送到 GitHub 的远程仓库中；这一过程需要输入你的 GitHub 账号名和密码，验证通过后，代码就会开始上传；

8. 待终端中显示上传成功的提示信息后，说明本地代码已经全部推送到 GitHub 的远程仓库。

### 6.2 配置 GitHub Pages 的构建源

在将代码推送到远程仓库后，需要在 GitHub 的仓库设置中，配置 GitHub Pages 的构建源 —— 指定 GitHub 的构建集群，从哪个分支读取网站的源代码，并完成静态文件的构建和部署。



1. 在浏览器中，打开你的 GitHub 仓库的主页面，点击仓库页面顶部的 “Settings” 选项卡，进入仓库的设置页面；

2. 在设置页面的左侧导航栏中，找到 “Pages” 选项，点击进入 GitHub Pages 的配置页面；

3. 在 “Build and deployment” 区域的 “Source” 下拉菜单中，选择 “Deploy from a branch” 选项 —— 这个配置的作用是，指定 GitHub Pages 的构建源，为仓库的指定分支；

4. 在 “Branch” 下拉菜单中，选择`main`分支 —— 这个配置的作用是，指定 GitHub 的构建集群，从仓库的`main`分支中，读取网站的源代码；右侧的下拉菜单中，选择`/(root)`选项，表示从仓库的根目录下读取源代码；

5. 点击页面底部的 “Save” 按钮，保存刚才的配置；

6. 配置完成后，GitHub 会自动开始构建并部署你的网站；点击仓库页面顶部的 “Actions” 选项卡，可以查看构建和部署的实时日志流程 —— 这个过程通常需要 2-5 分钟的时间；

7. 待 “Actions” 页面中显示构建和部署流程成功完成后，再次进入 “Settings”→“Pages” 页面，在页面的顶部，就可以看到网站的正式访问 URL；

8. 打开浏览器，在地址栏中输入这个 URL，就可以访问到你的正式上线的网站了。

### 6.3 验证网站的所有功能

在部署完成后，需要对网站的所有核心功能进行验证，确保所有功能都正常工作，没有出现 404 错误、功能异常或样式错乱的情况。需要重点验证以下几个核心点：



* **站点访问验证**：打开浏览器，访问你的网站的正式 URL，检查网站的首页、导航栏、侧边栏、页脚等全局元素，是否正常显示，布局是否存在错乱问题；

* **博客文章验证**：进入博客文章列表页面，检查所有文章是否正常显示，文章的摘要、发布日期、分类和标签是否正常；进入文章的详情页面，检查页面的布局、图片、代码格式、是否正常显示；

* **作品集项目验证**：进入作品集页面，检查所有项目是否正常显示，项目的缩略图、摘要、发布日期是否正常；进入项目的详情页面，检查项目的预览图片、描述信息、技术栈标签是否正常显示；

* **评论功能验证**：打开任意一篇文章或项目详情页，滚动到页面的底部，检查 Giscus 的评论区是否正常加载；使用你的 GitHub 账号，在评论区发表一条测试评论，检查评论是否能正常显示、提交和回复；

* **搜索功能验证**：点击网站顶部导航栏中的搜索框，输入任意一个博客文章或项目的关键词，检查搜索结果是否正常显示，点击搜索结果项，是否能正常跳转到对应的页面；

* **移动端适配验证**：打开手机的浏览器，访问网站的正式 URL，检查网站的布局、文字、图片和交互元素，是否正常适配手机的屏幕宽度，是否存在元素显示不全、文字大小过小、交互元素难以点击等问题；

* **HTTPS 安全验证**：在浏览器中，检查地址栏中是否显示了安全锁标识 —— 如果没有显示，需要重新进入仓库的 “Settings”→“Pages” 页面，勾选 “Enforce HTTPS” 选项，强制全站使用 HTTPS 通信协议。

### 6.4 后续的内容更新与维护

网站上线后，后续的内容更新与维护的流程会非常简单，只需要按照以下步骤操作，即可完成内容的更新：

1. 在本地的项目目录中，编写新的博客文章或作品集项目内容，或修改已有的内容文件；

2. 打开 Git Bash 终端（Windows 系统）或系统自带的 “终端” 应用（MacOS/Linux 系统），执行命令：`git pull origin main`，将远程仓库的最新代码，同步到本地的项目目录中 —— 这一步骤是为了避免多人协作时，出现代码版本冲突的问题；

3. 执行命令：`git add .`，将刚才修改过的文件，添加到 Git 的暂存区中；

4. 执行命令：`git commit -m "添加新的博客文章/更新项目内容"`，将暂存区中的文件，提交到 Git 的本地版本库中；

5. 执行命令：`git push origin main`，将本地版本库中的代码，推送到 GitHub 的远程仓库中；

6. 推送完成后，GitHub 会自动开始构建并部署更新后的网站；等待 2-5 分钟后，刷新网站的正式 URL，就可以看到更新后的内容了。

## 总结与后续优化建议

至此，你已经完成了个人博客与作品集网站的全部搭建工作 —— 网站已经正式上线运行，具备博客发布、作品集展示、评论交互、全文检索等完整核心功能；后续，你可以根据自己的需求，对网站的功能和细节进行进一步的定制化优化。

### 技术栈回顾

我们使用了以下技术方案，完成了整个网站的从无到有的搭建和上线：



* **静态网站生成器**：Jekyll，将 Markdown 格式的内容，渲染为静态的 HTML 文件；

* **免费静态网站托管服务**：GitHub Pages，存储网站的静态文件，分发到全球内容节点，提供免费的 HTTPS 访问；

* **前端主题模板**：Minimal Mistakes，提供响应式布局、通用页面模板、组件库，减少自定义 CSS 样式的开发工作量；

* **评论系统**：Giscus，基于 GitHub Discussions 实现的免费评论服务，与 GitHub 账号体系无缝衔接；

* **站内搜索功能**：Simple-Jekyll-Search，轻量级的纯客户端全文检索插件，无需后端服务支撑。

### 后续功能扩展与优化建议

在完成基础搭建后，你可以根据自己的实际需求，对网站的功能、性能、安全性以及运营能力进行进一步优化。以下是几个常见的优化方向建议：

#### 1. 绑定自定义域名

GitHub Pages 提供的默认域名（yourname.github.io），仅用于临时访问 —— 如果需要提升网站的专业形象，建议购买一个独立的顶级域名（如`yourname.com`），并将其绑定到 GitHub Pages 的托管站点上。

你可以在 Cloudflare、阿里云、腾讯云等域名注册商处，购买自己的顶级域名；然后在 GitHub 仓库的 “Settings”→“Pages” 页面中，将你购买的顶级域名，添加到 “Custom domain” 输入框中；最后，在你的域名注册商的管理后台，添加一个 CNAME 类型的解析记录，将顶级域名指向`yourname.github.io`—— 等待解析生效后，就可以通过顶级域名访问你的网站了。

#### 2. 网站性能优化

静态网站的加载速度，是影响用户体验的核心指标 —— 你可以通过以下几个常用的手段，对网站的性能进行进一步优化：



* **开启 GitHub Pages 的 CDN 加速功能**：在 GitHub 仓库的 “Settings”→“Pages” 页面中，勾选 “Enforce HTTPS” 选项，GitHub 会自动启用全球 CDN 加速功能，将网站的静态资源分发到全球各地的边缘节点上，提升不同地区用户的访问速度；

* **压缩所有图片资源**：在上传图片资源到仓库前，使用 TinyPNG、Squoosh 等在线图片压缩工具，对所有图片进行无损压缩处理 —— 将图片压缩到原大小的 30% 以内，减少图片文件的体积，缩短页面的加载时间；

* **启用浏览器缓存机制**：通过在仓库中添加`_headers`文件，自定义资源的缓存规则，设置 CSS、JavaScript、图片等静态资源的缓存过期时间，让用户再次访问网站时，可以直接从本地缓存中加载资源，提升二次访问的加载速度；

* **优化 CSS 和 JavaScript 资源**：删除 Minimal Mistakes 主题中，你没有用到的 CSS 和 JavaScript 文件，减少全局资源的加载体积；

* **启用 ZIP 压缩机制**：在 GitHub 仓库的 “Settings”→“Pages” 页面中，启用 “压缩静态文件” 选项，GitHub 会自动在传输过程中，对静态文件进行 Gzip 或 Brotli 压缩，缩短资源的传输时间。

#### 3. 网站的 SEO 与运营能力优化

为了让你的网站更容易被搜索引擎收录，提升内容的曝光率，你可以对网站的 SEO 细节，进行以下几个方面的优化：



* **配置全站的 SEO 元信息**：在`_config.yml`文件中，配置网站的标题、描述、关键词、作者信息等全局 SEO 元信息；在每个文章和项目页面的 YAML 配置中，添加独立的标题、描述、关键词元信息，提升搜索引擎对内容的识别能力；

* **生成站点地图并提交到搜索引擎**：安装`jekyll-sitemap`插件，让 Jekyll 在构建站点时，自动生成`sitemap.xml`文件 —— 这个文件包含了网站的所有页面 URL，将这个文件提交到 Google Search Console、Bing Webmaster Tools 等搜索引擎管理平台，可以加速搜索引擎收录网站的页面；

* **安装 SEO 优化插件**：安装`jekyll-seo-tag`插件，自动为所有页面生成标准的 SEO 元标签，提升搜索引擎对内容的解析效率；

* **添加社会化分享按钮**：在`_config.yml`文件中，配置社交分享的平台链接，启用 Minimal Mistakes 主题自带的社会化分享按钮，让用户可以方便地将你的文章或项目内容，分享到微信、微博、知乎、Twitter 等社交平台，提升内容的传播量；

* **添加网站访问统计分析工具**：在网站中接入 Google Analytics、百度统计、Cloudflare Analytics 等第三方访问统计分析工具，实时监测网站的流量来源、用户访问行为、热门内容等运营数据，为后续内容运营提供数据支撑。

#### 4. 功能扩展

根据你的实际需求，还可以对网站的功能，进行进一步的定制化开发，常见的扩展方向建议如下：



* **添加文章的目录导航组件**：启用 Minimal Mistakes 主题自带的目录导航组件，在文章的右侧侧边栏，显示文章的多级目录结构，方便用户快速长文的定位内容；

* **添加文章的阅读进度显示**：在`_config.yml`文件中，启用`read_time`配置项，在文章的顶部或底部，显示文章的预计阅读时间，提升用户的阅读体验；

* **添加作品集的分类筛选功能**：修改作品集的布局模板，添加分类筛选的 UI 组件 —— 让用户可以通过点击分类标签，筛选对应分类下的项目内容；

* **添加文章的分页阅读功能**：使用`jekyll-paginate-v2`插件，替代 Jekyll 默认的分页功能，实现更灵活的分页配置；

* **添加邮件订阅功能**：接入 Mailchimp、Buttondown 等第三方邮件订阅服务，在网站中嵌入订阅表单，让用户可以订阅你的博客更新；

* **添加内容评论审核功能**：在 Giscus 的配置中，启用评论审核功能 —— 所有用户提交的评论，需要经过你的审核后，才会显示在评论区中，避免垃圾评论或不当内容的出现。

#### 5. 主题的定制化与细节调整

如果你对主题的默认设计风格不满意，可以对 Minimal Mistakes 主题的样式和布局，进行进一步的定制化调整，常见的优化方向建议如下：



* **自定义主题的配色方案**：修改项目根目录下的`_sass/_variables.scss`文件，调整主题的主色调、辅助色调、链接颜色、背景颜色等全局配色变量，将主题的默认配色，修改为符合你个人品牌风格的配色方案；

* **自定义主题的字体方案**：在`_sass/_variables.scss`文件中，调整主题的全局字体家族、字号、行高、文字颜色等排版变量，将主题的默认字体方案，替换为你喜欢的字体组合；

* **修改主题的布局结构**：通过自定义布局的 CSS 样式，或修改主题的 Liquid 模板文件，调整全局的布局结构 —— 例如，将侧边栏的位置，从左侧移动到右侧，或调整内容区域的宽度、边距；

* **自定义主题的组件样式**：修改主题的按钮、卡片、表单元素、评论区等核心组件的样式，让网站的整体设计风格，更符合你的个人审美；

* **升级主题到最新版本**：定期将 Minimal Mistakes 主题升级到最新版本，获取主题的最新功能、安全补丁和性能优化，避免旧版本的主题出现安全漏洞。

#### 6. 内容维护与长期运营

网站上线后，内容的持续更新与运营，是保持网站活跃度的核心关键 —— 你可以通过以下几个方式，对网站的内容进行长期维护：



* **制定内容更新计划**：设定固定的内容更新频率 —— 例如，每周发布一篇新的技术文章，或每两个月发布一个新的项目成果，持续为用户提供有价值的内容，提升用户的回访率；

* **规范内容的编写格式**：制定统一的 Markdown 编写规范 —— 例如，文章的标题层级、图片尺寸、代码块风格、摘要长度，保证所有文章和项目内容的格式风格统一；

* **建立内容的备份机制**：在 GitHub 仓库的基础上，定期将网站的所有内容，备份到其他存储介质 —— 例如，本地硬盘、云存储服务，避免仓库出现意外时，内容无法恢复；

* **与读者进行互动**：定期回复评论区的读者留言，了解读者的阅读需求，根据读者的反馈方向，调整后续的内容创作方向；

* **建立内容的更新提醒机制**：接入第三方的邮件订阅服务，或在网站中添加 RSS 订阅功能，让用户可以及时获取你的最新内容更新。

通过本教程的学习，你已经掌握了静态网站从本地搭建到上线托管的全链路开发流程，完成了一个具备博客发布、作品集展示、评论交互、全文检索功能的专业级个人网站的搭建工作。如果你在搭建或使用过程中遇到技术问题，可以在 GitHub 仓库中提交 issue，或在相关技术社区中搜索解决方案。

祝你写作、展示愉快！

**参考资料&#x20;**

[1] 实例讲解如何使用Jekyll搭建一个静态网站-CSDN博客[ https://blog.csdn.net/weixin_44026962/article/details/135724271](https://blog.csdn.net/weixin_44026962/article/details/135724271)

[2] Setting up your GitHub Pages site locally with Jekyll[ https://docs.github.com/enterprise/2.6/user/articles/setting-up-your-github-pages-site-locally-with-jekyll](https://docs.github.com/enterprise/2.6/user/articles/setting-up-your-github-pages-site-locally-with-jekyll)

[3] 如何将 Jekyll 部署到云开发静态网站托管-腾讯云开发者社区-腾讯云[ https://cloud.tencent.com/developer/article/1613275](https://cloud.tencent.com/developer/article/1613275)

[4] 2025重磅发布:GitHub Pages Gem权威指南——从环境一致性到零误差部署的Jekyll开发实战-CSDN博客[ https://blog.csdn.net/gitblog_00423/article/details/140982134](https://blog.csdn.net/gitblog_00423/article/details/140982134)

[5] 使用Jekyll + GitHub Pages搭建个人博客_jekyll安装-CSDN博客[ https://blog.csdn.net/zzy979481894/article/details/132678717](https://blog.csdn.net/zzy979481894/article/details/132678717)

[6] 使用Github Pages + Jekyll搭建个人博客 - 赛狗屁 - 博客园[ https://www.cnblogs.com/saigoupi/p/19004892](https://www.cnblogs.com/saigoupi/p/19004892)

[7] Github Pages + Jekyll 搭建项目wiki(完整版) - lockly - 博客园[ https://www.cnblogs.com/bktown/p/18650249/github-jekyll-to-build-a-project-wiki-1p1axk](https://www.cnblogs.com/bktown/p/18650249/github-jekyll-to-build-a-project-wiki-1p1axk)

[8] Cómo Ejecutar el Blog Localmente[ https://github.com/asoesem/asoesem.github.io/wiki/C%C3%B3mo-Ejecutar-el-Blog-Localmente/8dbd99e929518caac022bc805bae56420665b884](https://github.com/asoesem/asoesem.github.io/wiki/C%C3%B3mo-Ejecutar-el-Blog-Localmente/8dbd99e929518caac022bc805bae56420665b884)

[9] Creating a GitHub Pages site with Jekyll[ https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll)

[10] GitHub Pages + Github action with Jekyll[ https://gist.github.com/eonist/58e3a94e7bc98218a89b3998887d4919](https://gist.github.com/eonist/58e3a94e7bc98218a89b3998887d4919)

[11] Build Your Personal Website A hands-on tutorial with Jekyll and GitHub Pages[ https://ai-vnv.kfupm.io/pdfs/tutorial-building-academic-website-jekyll-github-pages.pdf](https://ai-vnv.kfupm.io/pdfs/tutorial-building-academic-website-jekyll-github-pages.pdf)

[12] Deploying a Free Static Website with Jekyll and GitHub Pages (WIP)[ https://github.com/Suhas-Kadhane/Technical-Writing-Portfolio/wiki/Deploying-a-Free-Static-Website-with-Jekyll-and-GitHub-Pages-(WIP)](https://github.com/Suhas-Kadhane/Technical-Writing-Portfolio/wiki/Deploying-a-Free-Static-Website-with-Jekyll-and-GitHub-Pages-(WIP))

[13] GitHub Pages and Jekyll: A Detailed Guide[ https://pappater.github.io/docs/GitHub%20Pages%20and%20Jekyll/](https://pappater.github.io/docs/GitHub%20Pages%20and%20Jekyll/)

[14] GitHub Pages+Jekyll 静态网站搭建(二)_github 课题组网站-CSDN博客[ https://blog.csdn.net/Taylor_Kurt/article/details/149366989](https://blog.csdn.net/Taylor_Kurt/article/details/149366989)

[15] Deploy to GitHub Pages[ https://zer0-mistakes.com/docs/deployment/github-pages/](https://zer0-mistakes.com/docs/deployment/github-pages/)

[16] Creación de un sitio de GitHub Pages con Jekyll[ https://docs.github.com/es/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll](https://docs.github.com/es/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll)

[17] Jekyll + Chirpy + GitHub Pages 搭建博客_chirpy 网站-CSDN博客[ https://blog.csdn.net/m0_60169980/article/details/149246674](https://blog.csdn.net/m0_60169980/article/details/149246674)

[18] 如何快速为Jekyll博客添加轻量级搜索功能:Simple-Jekyll-Search完整指南-CSDN博客[ https://blog.csdn.net/gitblog_00060/article/details/138839030](https://blog.csdn.net/gitblog_00060/article/details/138839030)

[19] Staticman与Jekyll集成实战:打造功能完善的静态博客评论系统-CSDN博客[ https://blog.csdn.net/gitblog_00839/article/details/142277730](https://blog.csdn.net/gitblog_00839/article/details/142277730)

[20] Simple-Jekyll-Search[ https://github.com/christian-fei/simple-jekyll-search](https://github.com/christian-fei/simple-jekyll-search)

[21] jekyll-search-bar[ https://github.com/sorphwer/jekyll-search-bar](https://github.com/sorphwer/jekyll-search-bar)

[22] 무료로 댓글 기능 제공하는 서비스 TOP 3[ https://www.macaronics.net/m05/computer/view/2417](https://www.macaronics.net/m05/computer/view/2417)

[23] 博客建站10 - 选择博客评论系统 - [1. 本网站的系统架构](#1-本网站的系统架构) - [2. 博客系统的选择 - 掘金[ https://juejin.cn/post/7457372411957985343](https://juejin.cn/post/7457372411957985343)

[24] 怎么在 GitHub 上用 jekyll 搭建自己的博客 | 魔筝炼药师[ https://shouyuanman.github.io/posts/How-to-build-jekyll-blog/](https://shouyuanman.github.io/posts/How-to-build-jekyll-blog/)

[25] Minimal Mistakes:一款面向个人博客与作品集的响应式Jekyll主题 - CSDN文库[ https://wenku.csdn.net/doc/476u1cuc62](https://wenku.csdn.net/doc/476u1cuc62)

[26] pineapple:一款专注于展示项目的极简主义Jekyll主题-CSDN博客[ https://blog.csdn.net/gitblog_00623/article/details/147155213](https://blog.csdn.net/gitblog_00623/article/details/147155213)

[27] Livvic Jekyll theme[ https://jekyllthemes.io/theme/livvic-portfolio-jekyll-theme](https://jekyllthemes.io/theme/livvic-portfolio-jekyll-theme)

[28] Sites[ https://github.com/jekyll/jekyll/wiki/Sites](https://github.com/jekyll/jekyll/wiki/Sites)

[29] 推荐文章:Jekyll-Dash主题——打造个性化的博客体验-CSDN博客[ https://blog.csdn.net/gitblog_00798/article/details/142273103](https://blog.csdn.net/gitblog_00798/article/details/142273103)

[30] All the latest updates[ https://jekyllthemes.io/blog](https://jekyllthemes.io/blog)

[31] Joseph Jekyll theme[ https://jekyllthemes.io/theme/joseph-blog-jekyll-theme](https://jekyllthemes.io/theme/joseph-blog-jekyll-theme)

[32] 推荐开源项目:Jekyll-Uno - 简约优雅的静态博客主题-CSDN博客[ https://blog.csdn.net/gitblog_00017/article/details/137766688](https://blog.csdn.net/gitblog_00017/article/details/137766688)

[33] 使用 Jekyll 构建你的网站 - 初入门-CSDN博客[ https://blog.csdn.net/FloraCHY/article/details/135191964](https://blog.csdn.net/FloraCHY/article/details/135191964)

[34] jekyll/docs/_docs/installation/macos.md at master · jekyll/jekyll · GitHub[ https://github.com/jekyll/jekyll/blob/master/docs/_docs/installation/macos.md](https://github.com/jekyll/jekyll/blob/master/docs/_docs/installation/macos.md)

[35] Windows上装Jekyll前，Ruby环境要怎么配?RubyInstaller里的Devkit有啥用? - CSDN文库[ https://wenku.csdn.net/answer/9tujdfr0oi8f](https://wenku.csdn.net/answer/9tujdfr0oi8f)

[36] Setting up your GitHub Pages site locally with Jekyll[ https://docs.github.com/enterprise/2.6/user/articles/setting-up-your-github-pages-site-locally-with-jekyll](https://docs.github.com/enterprise/2.6/user/articles/setting-up-your-github-pages-site-locally-with-jekyll)

[37] Machine Setup[ https://zer0-mistakes.com/quickstart/machine-setup/](https://zer0-mistakes.com/quickstart/machine-setup/)

[38] 使用Github Pages + Jekyll搭建个人博客 - 赛狗屁 - 博客园[ https://www.cnblogs.com/saigoupi/p/19004892](https://www.cnblogs.com/saigoupi/p/19004892)

[39] Build Your Personal Website A hands-on tutorial with Jekyll and GitHub Pages[ https://ai-vnv.kfupm.io/pdfs/tutorial-building-academic-website-jekyll-github-pages.pdf](https://ai-vnv.kfupm.io/pdfs/tutorial-building-academic-website-jekyll-github-pages.pdf)

[40] Creación de sitios estáticos con Jekyll y GitHub Pages[ https://pdfs.semanticscholar.org/8cf6/a5a5af38f310d0830984f7f7d0653511be29.pdf](https://pdfs.semanticscholar.org/8cf6/a5a5af38f310d0830984f7f7d0653511be29.pdf)

[41] Creating a GitHub Pages site with Jekyll[ https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll?apiVersion=2022-11-28&platform=windows](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll?apiVersion=2022-11-28&platform=windows)

[42] Build Your Personal Website A hands-on tutorial with Jekyll and GitHub Pages[ https://ai-vnv.kfupm.io/pdfs/tutorial-building-academic-website-jekyll-github-pages.pdf](https://ai-vnv.kfupm.io/pdfs/tutorial-building-academic-website-jekyll-github-pages.pdf)

[43] 2025 GitHub Pages极简指南:从仓库到个人站点的7步进阶-CSDN博客[ https://blog.csdn.net/gitblog_00851/article/details/151272776](https://blog.csdn.net/gitblog_00851/article/details/151272776)

[44] buildplan.github.io/docs-jekyll-site/getting-started.md at main · buildplan/buildplan.github.io · GitHub[ https://github.com/buildplan/buildplan.github.io/blob/main/docs-jekyll-site/getting-started.md](https://github.com/buildplan/buildplan.github.io/blob/main/docs-jekyll-site/getting-started.md)

[45] Deploying Chirpy Jekyll Blog to GitHub Pages from Kali Linux[ https://davidtkeane.github.io/posts/deploying-chirpy-to-github-pages/](https://davidtkeane.github.io/posts/deploying-chirpy-to-github-pages/)

[46] Complete Guide to GitHub Pages: Build Professional Static Websites from Scratch[ https://timinsight.com/github-pages-complete-guide-en/](https://timinsight.com/github-pages-complete-guide-en/)

[47] Creación de un sitio de GitHub Pages con Jekyll[ https://docs.github.com/es/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll](https://docs.github.com/es/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll)

[48] GitHub Pages[ https://github.com/Prathameshphutane/Github-pages](https://github.com/Prathameshphutane/Github-pages)

[49] Jekyll + Chirpy + GitHub Pages 搭建博客_chirpy 网站-CSDN博客[ https://blog.csdn.net/m0_60169980/article/details/149246674](https://blog.csdn.net/m0_60169980/article/details/149246674)

[50] Adding Comments to a Static Site: Why I Chose Giscus for Jekyll[ https://mcgarrah.org/jekyll-giscus-comments-implementation/](https://mcgarrah.org/jekyll-giscus-comments-implementation/)

[51] Cirrus for Jekyll[ https://github.com/Arnaud-Ferriere/Cirrus-for-Jekyll](https://github.com/Arnaud-Ferriere/Cirrus-for-Jekyll)

[52] 5分钟，为你的博客增加评论功能如果你有自己的个人博客网站，为了增加互动，评论功能是必不可少的。可以借助giscus这一工 - 掘金[ https://juejin.cn/post/7358033080126570548](https://juejin.cn/post/7358033080126570548)

[53] Giscus评论系统设置指南[ https://github.com/awesome-crypto-tutorial/awesome-crypto-tutorial.github.io/blob/main/GISCUS_SETUP.md](https://github.com/awesome-crypto-tutorial/awesome-crypto-tutorial.github.io/blob/main/GISCUS_SETUP.md)

[54] Giscus Comments[ https://zer0-mistakes.com/docs/features/giscus-comments/](https://zer0-mistakes.com/docs/features/giscus-comments/)

[55] 怎么在 GitHub 上用 jekyll 搭建自己的博客 | 魔筝炼药师[ https://shouyuanman.github.io/posts/How-to-build-jekyll-blog/](https://shouyuanman.github.io/posts/How-to-build-jekyll-blog/)

[56] 个人网站如何免费引入评论功能 giscus | Echo Blog[ http://houbb.github.io/2025/07/12/personal-website-discuss](http://houbb.github.io/2025/07/12/personal-website-discuss)

[57] Minimal Mistakes布局系统终极指南:掌握单页、归档、搜索和首页布局-CSDN博客[ https://blog.csdn.net/gitblog_00438/article/details/154966124](https://blog.csdn.net/gitblog_00438/article/details/154966124)

[58] Minimal主题开发者指南:深入理解Jekyll主题架构与扩展-CSDN博客[ https://blog.csdn.net/gitblog_01128/article/details/144503012](https://blog.csdn.net/gitblog_01128/article/details/144503012)

[59] Personal Website with Minimal Mistakes Jekyll Theme HOWTO - Part II[ https://elenigregor.github.io/Personal%20Website%20with%20Minimal%20Mistakes%20Jekyll%20Theme%20HOWTO%20-%20Part%20II%20_%20Cross-Validated.pdf](https://elenigregor.github.io/Personal%20Website%20with%20Minimal%20Mistakes%20Jekyll%20Theme%20HOWTO%20-%20Part%20II%20_%20Cross-Validated.pdf)

[60] Minimal Mistakes Jekyll[ https://github.com/limyunkai19/minimal-mistakes-jekyll](https://github.com/limyunkai19/minimal-mistakes-jekyll)

[61] 直接给我搭建一个个人博客 - CSDN文库[ https://wenku.csdn.net/answer/70tq4e4775](https://wenku.csdn.net/answer/70tq4e4775)

[62] Theme Setup[ https://blog.bibanon.org/theme-setup/](https://blog.bibanon.org/theme-setup/)

[63] 最精简的GitHub Pages解决方案:Minimal主题全方位实战指南-CSDN博客[ https://blog.csdn.net/gitblog_00471/article/details/144690840](https://blog.csdn.net/gitblog_00471/article/details/144690840)

[64] binzeli.github.io/README_zh_Hant.md at main · binzeli/binzeli.github.io · GitHub[ https://github.com/binzeli/binzeli.github.io/blob/main/README_zh_Hant.md](https://github.com/binzeli/binzeli.github.io/blob/main/README_zh_Hant.md)

[65] 如何快速为Jekyll博客添加轻量级搜索功能:Simple-Jekyll-Search完整指南-CSDN博客[ https://blog.csdn.net/gitblog_00060/article/details/138839030](https://blog.csdn.net/gitblog_00060/article/details/138839030)

[66] 最详细的个人博客教程搭建教程，最快5分钟快速搭建简约风格博客_简约博客-CSDN博客[ https://blog.csdn.net/u011644231/article/details/103613600](https://blog.csdn.net/u011644231/article/details/103613600)

[67] Github Blog 검색기능 추가(Simple-Jekyll-Search)[ https://velog.io/@langoustine/Github-Blog-%EA%B2%80%EC%83%89%EA%B8%B0%EB%8A%A5%EC%B6%94%EA%B0%80-Simple-Jekyll-Search](https://velog.io/@langoustine/Github-Blog-%EA%B2%80%EC%83%89%EA%B8%B0%EB%8A%A5%EC%B6%94%EA%B0%80-Simple-Jekyll-Search)

[68] How to Add Search to Your Static Site Generator (Jekyll, Hugo, Gatsby, Nikola, etc.)[ https://www.stephanmiller.com/static-site-search/](https://www.stephanmiller.com/static-site-search/)

[69] Simple-Jekyll-Search[ https://github.com/EricMCR/Simple-Jekyll-Search/blob/master/README.md](https://github.com/EricMCR/Simple-Jekyll-Search/blob/master/README.md)

[70] 本地搜索功能实现:让用户秒找内容的documentation-theme-jekyll配置-CSDN博客[ https://blog.csdn.net/gitblog_00249/article/details/155725133](https://blog.csdn.net/gitblog_00249/article/details/155725133)

[71] Simple-Jekyll-Search[ https://www.rubycoloredglasses.com/bower_components/simple-jekyll-search/](https://www.rubycoloredglasses.com/bower_components/simple-jekyll-search/)

[72] Minimal Mistakes布局系统终极指南:掌握单页、归档、搜索和首页布局-CSDN博客[ https://blog.csdn.net/gitblog_00438/article/details/154966124](https://blog.csdn.net/gitblog_00438/article/details/154966124)

[73] Minimal Mistakes布局系统终极指南:掌握单页、归档、搜索和首页布局-CSDN博客[ https://blog.csdn.net/gitblog_00438/article/details/154966124](https://blog.csdn.net/gitblog_00438/article/details/154966124)

[74] Personal Website with Minimal Mistakes Jekyll Theme HOWTO - Part II[ https://elenigregor.github.io/Personal%20Website%20with%20Minimal%20Mistakes%20Jekyll%20Theme%20HOWTO%20-%20Part%20II%20_%20Cross-Validated.pdf](https://elenigregor.github.io/Personal%20Website%20with%20Minimal%20Mistakes%20Jekyll%20Theme%20HOWTO%20-%20Part%20II%20_%20Cross-Validated.pdf)

[75] mmistakes主题快速入门指南:Jekyll静态网站生成器最小错误远程主题配置与使用 - CSDN文库[ https://wenku.csdn.net/doc/2xdw7mprfr](https://wenku.csdn.net/doc/2xdw7mprfr)

[76] 📐 A flexible two-column Jekyll theme. Perfect for personal sites, blogs, and portfolios hosted on GitHub or your own server.[ https://github.com/nnamon/minimal-mistakes](https://github.com/nnamon/minimal-mistakes)

[77] Minimal Mistakes:轻量级响应式Jekyll博客主题，支持Sass定制与多端适配 - CSDN文库[ https://wenku.csdn.net/doc/h2rv3y3qkt](https://wenku.csdn.net/doc/h2rv3y3qkt)

[78] Configuring My Personal Portfolio Blog with Jekyll and Minimal Mistakes[ https://gordonyfg.github.io/blog/post-github_pages/](https://gordonyfg.github.io/blog/post-github_pages/)

[79] Folder Structure and Guide[ https://github.com/Hybrid-Outpost/hybridoutpost.github.io/wiki/Folder-Structure-and-Guide](https://github.com/Hybrid-Outpost/hybridoutpost.github.io/wiki/Folder-Structure-and-Guide)

[80] 如何快速为Jekyll博客添加轻量级搜索功能:Simple-Jekyll-Search完整指南-CSDN博客[ https://blog.csdn.net/gitblog_00060/article/details/138839030](https://blog.csdn.net/gitblog_00060/article/details/138839030)

[81] GitHub - joshuadl12/Simple-Jekyll-Search: A JavaScript library to add search functionality to any Jekyll blog. · GitHub[ https://github.com/joshuadl12/Simple-Jekyll-Search](https://github.com/joshuadl12/Simple-Jekyll-Search)

[82] Jekyll[ https://christian.kuelker.info/en_US/Quick-Guide/DevOps/Web/SSG/jekyll.pdf](https://christian.kuelker.info/en_US/Quick-Guide/DevOps/Web/SSG/jekyll.pdf)

[83] Minimal Mistakes Jekyll theme[ https://github.com/JekyllNet/minimal-mistakes/blob/master/README.md](https://github.com/JekyllNet/minimal-mistakes/blob/master/README.md)

[84] wyhong3103/minimal-mistakes-jekyll[ https://github.com/wyhong3103/minimal-mistakes-jekyll](https://github.com/wyhong3103/minimal-mistakes-jekyll)

[85] Minimal Mistakes Jekyll[ https://github.com/MedericCar/minimal-mistakes-jekyll/blob/master/README.md](https://github.com/MedericCar/minimal-mistakes-jekyll/blob/master/README.md)

[86] Minimal Mistakes Jekyll Theme[ https://github.com/jin-zhe/minimal-mistakes/blob/master/README.md](https://github.com/jin-zhe/minimal-mistakes/blob/master/README.md)

[87] Minimal Mistakes Jekyll theme[ https://github.com/pwyckoff/minimal-mistakes](https://github.com/pwyckoff/minimal-mistakes)

[88] Minimal Mistakes布局系统终极指南:掌握单页、归档、搜索和首页布局-CSDN博客[ https://blog.csdn.net/gitblog_00438/article/details/154966124](https://blog.csdn.net/gitblog_00438/article/details/154966124)

[89] Minimal Mistakes[ https://github.com/ajcurated/minimal-mistakes/blob/master/README.md](https://github.com/ajcurated/minimal-mistakes/blob/master/README.md)

[90] Minimal Mistakes:一款支持多皮肤与响应式布局的Jekyll主题 - CSDN文库[ https://wenku.csdn.net/doc/5cbj8gqjnx](https://wenku.csdn.net/doc/5cbj8gqjnx)

[91] 最精简的GitHub Pages解决方案:Minimal主题全方位实战指南-CSDN博客[ https://blog.csdn.net/gitblog_00471/article/details/144690840](https://blog.csdn.net/gitblog_00471/article/details/144690840)

[92] Minimal Mistakes Jekyll theme[ https://github.com/mmistakes/minimal-mistakes](https://github.com/mmistakes/minimal-mistakes)

[93] gh-pages-minima-starter 项目教程-CSDN博客[ https://blog.csdn.net/gitblog_00057/article/details/139913406](https://blog.csdn.net/gitblog_00057/article/details/139913406)

[94] Minimal Mistakes[ https://www.jekylltemplates.com/theme/mmistakes-minimal-mistakes/](https://www.jekylltemplates.com/theme/mmistakes-minimal-mistakes/)

[95] Minimal主题部署完全手册:从本地测试到生产环境发布-CSDN博客[ https://blog.csdn.net/gitblog_00172/article/details/148864198](https://blog.csdn.net/gitblog_00172/article/details/148864198)

[96] 最精简的GitHub Pages解决方案:Minimal主题全方位实战指南-CSDN博客[ https://blog.csdn.net/gitblog_00471/article/details/144690840](https://blog.csdn.net/gitblog_00471/article/details/144690840)

[97] minimal-mistakes/docs/_docs/05-configuration.md at 8a67ce8e41ec850f2d7c373aa47739b2abfee6f1 · mmistakes/minimal-mistakes · GitHub[ https://github.com/mmistakes/minimal-mistakes/blob/8a67ce8e41ec850f2d7c373aa47739b2abfee6f1/docs/_docs/05-configuration.md](https://github.com/mmistakes/minimal-mistakes/blob/8a67ce8e41ec850f2d7c373aa47739b2abfee6f1/docs/_docs/05-configuration.md)

[98] Jekyll + Chirpy + GitHub Pages 搭建博客_chirpy 网站-CSDN博客[ https://blog.csdn.net/m0_60169980/article/details/149246674](https://blog.csdn.net/m0_60169980/article/details/149246674)

[99] I’m having trouble adding Giscus comments to all Jekyll posts, and it’s not working as expected.[ https://solutionfall.com/question/im-having-trouble-adding-giscus-comments-to-all-jekyll-posts-and-its-not-working-as-expected/?show=votes](https://solutionfall.com/question/im-having-trouble-adding-giscus-comments-to-all-jekyll-posts-and-its-not-working-as-expected/?show=votes)

[100] 怎么在 GitHub 上用 jekyll 搭建自己的博客 | 魔筝炼药师[ https://shouyuanman.github.io/posts/How-to-build-jekyll-blog/](https://shouyuanman.github.io/posts/How-to-build-jekyll-blog/)

[101] Giscus 评论系统配置指南[ https://github.com/MaviProject/MaviProject.github.io/blob/main/GISCUS_SETUP.md](https://github.com/MaviProject/MaviProject.github.io/blob/main/GISCUS_SETUP.md)

[102] 如何在 chirpy 中配置 giscus 评论功能[ https://usingnow.github.io/blog/2022-06-03-config-giscus/](https://usingnow.github.io/blog/2022-06-03-config-giscus/)

[103] Giscus Comments[ https://zer0-mistakes.com/docs/features/giscus-comments/](https://zer0-mistakes.com/docs/features/giscus-comments/)

[104] 最精简的GitHub Pages解决方案:Minimal主题全方位实战指南-CSDN博客[ https://blog.csdn.net/gitblog_00471/article/details/144690840](https://blog.csdn.net/gitblog_00471/article/details/144690840)

[105] Step by Step Tutorial[ https://jekyllrb.com/docs/step-by-step/06-data-files/](https://jekyllrb.com/docs/step-by-step/06-data-files/)

[106] minimal-mistakes/docs/_data/navigation.yml at master · mmistakes/minimal-mistakes · GitHub[ https://github.com/mmistakes/minimal-mistakes/blob/master/docs/_data/navigation.yml](https://github.com/mmistakes/minimal-mistakes/blob/master/docs/_data/navigation.yml)

[107] minimal mistakes theme 지킬 블로그 초기 설정하기[ https://blog.syki66.com/2020/04/12/minimal-mistakes-theme/](https://blog.syki66.com/2020/04/12/minimal-mistakes-theme/)

[108] Jekyll 个人主页模板使用指南[ https://github.com/WindGraham/Personal-Site/blob/main/README.md](https://github.com/WindGraham/Personal-Site/blob/main/README.md)

[109] minimal-mistakes/theme-setup.md at navigation-links · root-project/minimal-mistakes · GitHub[ https://github.com/root-project/minimal-mistakes/blob/navigation-links/theme-setup.md](https://github.com/root-project/minimal-mistakes/blob/navigation-links/theme-setup.md)

[110] Adding a New Category to a Jekyll Blog (Minimal Mistakes)[ https://cmaven.github.io/en/github_blog/gitblog-add-category/](https://cmaven.github.io/en/github_blog/gitblog-add-category/)

[111] Multilevel Navigation Using Jekyll: A Step-by-Step Guide  2024-12-7 10:29:31 Author: hackernoon.com(查看原文) 阅读量:0 收藏[ https://buaq.net/go-279688.html](https://buaq.net/go-279688.html)

[112] Minimal Mistakes布局系统终极指南:掌握单页、归档、搜索和首页布局-CSDN博客[ https://blog.csdn.net/gitblog_00438/article/details/154966124](https://blog.csdn.net/gitblog_00438/article/details/154966124)

[113] Minimal Mistakes Jekyll Theme[ https://github.com/benswift/minimal-mistakes](https://github.com/benswift/minimal-mistakes)

[114] GitHub - Luo-Jia-Yu/minimal-mistakes: :triangular_ruler: A flexible two-column Jekyll theme perfect for building personal sites, blogs, and portfolios. · GitHub[ https://github.com/Luo-Jia-Yu/minimal-mistakes](https://github.com/Luo-Jia-Yu/minimal-mistakes)

[115] Minimal Mistakes Jekyll theme[ https://github.com/mmistakes/minimal-mistakes](https://github.com/mmistakes/minimal-mistakes)

[116] GitHub - rebeccali/minimal-mistakes: :triangular_ruler: A flexible two-column Jekyll theme. Perfect for personal sites, blogs, and portfolios hosted on GitHub or your own server.[ https://github.com/rebeccali/minimal-mistakes](https://github.com/rebeccali/minimal-mistakes)

[117] Minimal Mistakes Jekyll theme[ https://github.com/leonardoeloy/minimal-mistakes](https://github.com/leonardoeloy/minimal-mistakes)

[118] An Example Github Pages Document[ http://adamvi.github.io/Markdown_Document/An_Example_Github_Pages_Document.pdf](http://adamvi.github.io/Markdown_Document/An_Example_Github_Pages_Document.pdf)

[119] soochoe/minimal-mistakes[ https://github.com/soochoe/minimal-mistakes](https://github.com/soochoe/minimal-mistakes)

