---
layout: single
title: "如何为 GitHub 开源仓库选择并配置 Ruleset：从 main 保护到 CI 门禁"
excerpt: "从个人开源项目出发，系统梳理 GitHub Ruleset 的选择、main 分支保护、PR 与 CI 门禁，以及 Dependabot、Secret scanning 和 CodeQL 等安全配置。"
categories: 技术 GitHub
tags: [GitHub, Ruleset, CI, GitHub Actions, Branch Protection, Open Source]
hidden: false
toc: true
toc_sticky: true
---

对于一个刚刚公开到 GitHub 的开源仓库，最容易出现的两个极端是：

- **完全不做保护**：任何人只要有写权限，就可能直接修改 `main`，甚至误删分支、强制推送覆盖历史。
- **保护过度**：一口气打开所有 Ruleset 选项，结果自己提交 PR 都无法合并，CI、CodeQL、审批规则互相卡住。

更合理的做法不是“能开的都开”，而是根据仓库的协作方式、CI 能力和维护人数，选择一组真正有价值的规则。

本文从一个典型的个人开源项目出发，整理一套适用于大多数 GitHub 公共仓库的 Ruleset 配置思路，并解释每一个选项为什么开、为什么不开。

---

## 一、Ruleset 到底解决什么问题？

GitHub Ruleset 用来规定：

> 哪些分支或标签可以被怎样修改，以及修改前必须满足哪些条件。

最典型的目标是保护默认分支：

```text
main
```

理想情况下，`main` 应该始终代表：

> 已经过基本验证、可以继续开发或发布的稳定代码。

因此，我们希望代码进入 `main` 之前至少经过：

```text
开发分支
   ↓
Pull Request
   ↓
CI 检查
   ↓
通过
   ↓
合并到 main
```

而不是：

```text
本地修改
   ↓
git push origin main
   ↓
直接进入主分支
```

Ruleset 就是用来强制执行前一种流程的。

---

# 二、Ruleset 和旧的 Branch Protection 有什么区别？

GitHub 过去主要通过 **Branch protection rules** 保护分支。

现在更推荐使用 **Rulesets**。

Ruleset 的优势包括：

- 可以同时管理多个规则；
- 可以指定目标分支或标签；
- 可以配置 Bypass；
- 可以和其他 Ruleset 叠加；
- 可以要求 PR、CI、Code Scanning 等条件；
- 规则结构更清晰，后续更容易扩展。

对于新建仓库，我通常建议直接使用：

```text
Settings
→ Rules
→ Rulesets
→ New ruleset
→ New branch ruleset
```

而不是优先创建旧式 Branch Protection Rule。

---

# 三、先判断你的仓库属于哪一类

配置 Ruleset 之前，先回答三个问题。

## 1. 谁在维护这个仓库？

### 情况 A：只有自己维护

例如：

```text
Maintainer:
- 我自己
```

这种仓库不适合设置：

```text
Required approvals = 1
```

因为你会得到一个很尴尬的流程：

```text
我创建 PR
   ↓
要求另一个人 Approve
   ↓
没有第二个维护者
   ↓
无法正常合并
```

个人项目通常应该：

```text
Require Pull Request    ✅
Required approvals      0
Require CI              ✅
```

也就是：

> 不强制人工审批，但强制机器检查。

---

### 情况 B：2～5 人的小团队

可以考虑：

```text
Required approvals = 1
```

并且开启：

```text
Require conversation resolution before merging
```

这样至少有另一位成员确认代码。

---

### 情况 C：成熟开源项目

可以进一步增加：

```text
Required approvals = 1~2
Require Code Owners review
Require signed commits
Require Code Scanning results
Require branch up to date
```

但这些不应该是个人仓库的默认起点。

---

# 四、推荐的个人开源仓库 Ruleset

对于一个：

- GitHub Public Repository；
- 默认分支是 `main`；
- 主要由自己维护；
- 已经有 GitHub Actions CI；

的项目，我推荐下面这一套。

```text
Protect main

Enforcement status
└── Active

Target branches
└── Default branch (main)

Bypass list
└── Empty

Rules
├── Restrict deletions                    ✅
├── Require a pull request before merging ✅
├── Require status checks to pass         ✅
├── Block force pushes                    ✅
├── Require linear history                可选
├── Require signed commits                ❌
├── Restrict updates                      ❌
└── Require deployments to succeed        ❌
```

下面逐项解释。

---

# 五、创建 Ruleset

进入：

```text
Repository
→ Settings
→ Rules
→ Rulesets
→ New ruleset
→ New branch ruleset
```

填写：

```text
Ruleset name:
Protect main
```

然后：

```text
Enforcement status:
Active
```

`Active` 表示创建后立即生效。

---

# 六、Target branches 应该怎么选？

推荐：

```text
Add target
→ Include default branch
```

如果当前默认分支是：

```text
main
```

那么这个 Ruleset 就会保护 `main`。

相比手动写：

```text
main
```

使用：

```text
Default branch
```

还有一个好处：

如果以后默认分支名称发生变化，Ruleset 的语义仍然是：

> 保护仓库默认分支。

对于大多数普通仓库，这是最合适的选择。

---

# 七、Bypass list 要不要加自己？

对于个人开源仓库，我建议一开始：

```text
Bypass list
→ 留空
```

如果把 Repository Admin 加入 bypass，实际上意味着：

```text
普通协作者
   ↓
必须遵守 Ruleset

管理员
   ↓
可以绕过 Ruleset
```

而个人仓库里，管理员通常就是你自己。

这样很容易变成：

> Ruleset 配好了，但自己平时还是直接 push main。

保护就失去了意义。

所以推荐：

```text
Bypass list = Empty
```

真遇到紧急情况时，再临时调整规则。

---

# 八、Restrict deletions：建议开启

打开：

```text
Restrict deletions
```

它的作用是防止受保护分支被随意删除。

例如避免：

```bash
git push origin --delete main
```

导致主分支消失。

这是几乎没有额外维护成本，但非常有价值的一项保护。

推荐：

```text
Restrict deletions ✅
```

---

# 九、Require a pull request before merging：核心规则

打开：

```text
Require a pull request before merging
```

开启以后，正常开发流程会变成：

```text
feature/xxx
    ↓
Pull Request
    ↓
检查
    ↓
Merge
    ↓
main
```

而不再推荐：

```bash
git push origin main
```

---

## Required approvals 应该设置多少？

### 个人仓库

推荐：

```text
Required approvals = 0
```

这里经常被误解。

`0` 并不代表：

> PR 没意义。

它代表：

> 必须经过 PR，但不要求另一个人批准。

这样你仍然可以获得：

- CI；
- PR diff；
- Commit 检查；
- Conversation；
- Merge 记录；

但不会因为缺少第二个维护者而无法工作。

---

### 多人项目

可以调整为：

```text
Required approvals = 1
```

成熟项目还可以设置：

```text
2
```

---

# 十、Require conversation resolution：推荐开启

推荐：

```text
Require conversation resolution before merging ✅
```

如果 PR 里存在尚未解决的 Review Conversation，例如：

```text
这里存在空指针风险
这里应该增加测试
这里命名需要调整
```

在这些讨论被 Resolve 前，PR 不允许合并。

对于公开项目，这是一个非常实用的规则。

---

# 十一、Require status checks to pass：最重要的 CI 门禁

如果仓库已经有 CI，强烈建议打开：

```text
Require status checks to pass
```

它意味着：

> 指定的 CI 检查失败时，不允许代码进入 main。

例如某个 Node.js / TypeScript 项目的 CI：

```yaml
name: CI

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  check:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v6

      - name: Use Node.js
        uses: actions/setup-node@v6
        with:
          node-version: 24
          cache: npm

      - run: npm ci
      - run: npm run check
```

项目中的：

```json
{
  "scripts": {
    "lint": "eslint .",
    "build": "tsc --noEmit && node esbuild.config.mjs production",
    "test": "npm run test:core && npm run test:persistence",
    "check": "npm run lint && npm run build && npm test"
  }
}
```

实际执行链路就是：

```text
Pull Request
     ↓
CI
     ↓
check
 ├── lint
 ├── build
 └── test
     ↓
全部成功
     ↓
允许 Merge
```

---

# 十二、Status Check 到底应该选哪个？

这里非常容易选错。

假设 Workflow：

```yaml
name: CI

jobs:
  check:
```

那么：

```text
CI
```

是 Workflow Name。

而：

```text
check
```

是 Job Name。

Ruleset 中：

```text
Status checks that are required
```

通常应该选择实际产生的状态检查：

```text
check
```

例如：

```text
Status checks that are required

check    GitHub Actions
```

这就是正确的配置。

---

# 十三、为什么最好让 CI 先成功运行一次？

第一次添加 Required Status Check 时，建议先让 Workflow 在 GitHub Actions 中至少成功执行一次。

例如：

```text
Actions
→ CI
→ check
→ Success
```

这样 GitHub 已经认识这个 Check。

之后进入：

```text
Ruleset
→ Require status checks
→ Add checks
```

就更容易直接找到：

```text
check
```

---

# 十四、Require branches to be up to date 要不要开启？

这个选项：

```text
Require branches to be up to date before merging
```

决定 PR 是否必须基于最新的 `main` 再进行检查。

可以理解成两种模式。

---

## Loose 模式

```text
Require status checks              ✅
Require branches to be up to date  ❌
```

流程：

```text
PR
↓
CI 成功
↓
允许 Merge
```

即使这期间 `main` 出现了新的提交，也不一定要求你的分支重新同步。

### 适合

- 个人项目；
- 小型仓库；
- PR 数量不多；
- 合并冲突概率较低。

这是我更推荐的个人开源项目默认设置。

---

## Strict 模式

```text
Require status checks              ✅
Require branches to be up to date  ✅
```

如果：

```text
PR A
↓
CI 成功
↓
main 又产生新提交
```

那么可能需要：

```text
PR A
↓
Update branch
↓
重新跑 CI
↓
通过
↓
Merge
```

### 适合

- 多人协作；
- 高频 Merge；
- 主分支变化很快；
- 对集成稳定性要求较高。

---

# 十五、Do not require status checks on creation 是什么？

Ruleset 中可能看到：

```text
Do not require status checks on creation
```

它主要允许新的 branch / ref 在创建时，不因为还没有 Status Check 而被 Ruleset 阻止。

普通的：

```text
Protect main
```

场景下一般不需要特别打开。

推荐保持：

```text
Do not require status checks on creation ❌
```

---

# 十六、Block force pushes：建议开启

推荐：

```text
Block force pushes ✅
```

它可以防止：

```bash
git push --force origin main
```

随意重写 `main` 的 Git 历史。

对于公开仓库，这是一个非常低成本但有效的保护。

---

# 十七、Restrict updates 为什么不要随便开？

很多人看到：

```text
Restrict updates
```

会以为：

> 这是“禁止直接修改 main”。

实际上它比这更严格。

开启以后，只有拥有 Bypass 权限的人才能更新匹配的分支。

这容易导致：

```text
PR
↓
CI 成功
↓
仍然无法 Merge
```

所以普通项目不要用它代替：

```text
Require pull request
```

推荐：

```text
Restrict updates ❌
```

---

# 十八、Require signed commits 要不要开启？

它要求提交必须是：

```text
Verified
```

也就是 Commit 使用 GPG、SSH Signing 或其他受 GitHub 认可的签名方式。

优点是可以增强 Commit 身份可信度。

但同时也增加：

- 本地 Git 配置成本；
- 多设备开发成本；
- 新贡献者参与成本；
- 自动化工具兼容成本。

因此：

### 个人或小型开源项目

```text
Require signed commits ❌
```

### 对供应链安全要求很高的成熟项目

再考虑：

```text
Require signed commits ✅
```

---

# 十九、Require linear history 要不要开？

这个规则要求主分支保持线性历史。

通常意味着禁止产生普通 Merge Commit，更偏向：

```text
Squash Merge
```

或者：

```text
Rebase Merge
```

优点：

```text
git log
```

更整洁。

缺点是会限制 Merge 策略。

所以它属于：

```text
可选
```

如果你喜欢：

```text
feature
   \____
        \____ main
```

这种明确保留分支历史的 Merge Commit，那么不要开。

如果你喜欢：

```text
A → B → C → D → E
```

这种完全线性的历史，可以开启。

---

# 二十、Release Workflow 不应该成为普通 PR 的 Required Check

假设仓库还有：

```text
.github/workflows/release.yml
```

并且它只在 Tag 时运行：

```yaml
on:
  push:
    tags:
      - '*'
```

那么这个 Workflow 不应该配置成：

```text
main 的 Required Status Check
```

否则会出现：

```text
普通 PR
↓
等待 Release Check
↓
Release 只有 tag 才运行
↓
PR 一直等不到
```

所以需要区分：

```text
CI
→ PR 质量检查
→ 应该 Required

Release
→ Tag / 发布流程
→ 不应该作为普通 PR Required
```

---

# 二十一、推荐的最终 Ruleset

个人维护的开源仓库可以直接使用下面这套。

```text
Ruleset name:
Protect main

Enforcement:
Active

Target:
Default branch

Bypass list:
Empty

Rules:

✅ Restrict deletions

✅ Require a pull request before merging
   ├── Required approvals: 0
   └── Require conversation resolution: ✅

✅ Require status checks to pass
   ├── check
   └── Require branches to be up to date: ❌

✅ Block force pushes

❌ Restrict updates
❌ Require signed commits
❌ Require deployments to succeed

🟡 Require linear history
   根据自己的 Git 历史偏好决定
```

---

# 二十二、不同类型仓库应该怎么选？

| 规则 | 个人开源项目 | 小团队 | 成熟项目 |
|---|---:|---:|---:|
| Require PR | ✅ | ✅ | ✅ |
| Required approvals | 0 | 1 | 1～2 |
| Require CI | ✅ | ✅ | ✅ |
| Branch up to date | ❌ | 可选 | ✅ |
| Conversation resolution | ✅ | ✅ | ✅ |
| Restrict deletions | ✅ | ✅ | ✅ |
| Block force pushes | ✅ | ✅ | ✅ |
| Linear history | 可选 | 可选 | 按规范 |
| Signed commits | ❌ | 可选 | 可考虑 |
| Code Owners | ❌ | 可选 | ✅ |
| Code Scanning required | 后期开 | 可选 | 推荐 |

可以把原则总结成一句话：

> **先建立最小有效保护，再随着协作规模增加规则。**

---

# 二十三、配置完成后，日常代码应该怎么推？

Ruleset 配置完成以后，不再把：

```bash
git push origin main
```

作为正常开发方式。

推荐流程：

```bash
# 1. 回到 main
git switch main

# 2. 获取最新代码
git pull origin main

# 3. 创建开发分支
git switch -c feature/your-change

# 4. 修改代码

# 5. 提交
git add .
git commit -m "feat: your change"

# 6. 推送开发分支
git push -u origin feature/your-change
```

然后：

```text
GitHub
→ Open Pull Request
→ CI
→ check
→ Success
→ Merge
```

合并完成后：

```bash
git switch main
git pull origin main
```

删除本地开发分支：

```bash
git branch -d feature/your-change
```

如果远程也不需要：

```bash
git push origin --delete feature/your-change
```

---

# 二十四、如果已经在 main 上修改了代码怎么办？

## 尚未 Commit

直接：

```bash
git switch -c feature/my-change
```

当前修改会跟着进入新分支。

然后：

```bash
git add .
git commit -m "feat: my change"
git push -u origin feature/my-change
```

---

## 已经 Commit，但还没有 Push

同样可以：

```bash
git switch -c feature/my-change
git push -u origin feature/my-change
```

确保 Commit 已经安全存在于开发分支后，再让本地 `main` 对齐远程：

```bash
git switch main
git fetch origin
git reset --hard origin/main
```

注意：

```text
git reset --hard
```

会删除当前分支尚未保存的本地修改，执行前必须确认代码已经安全保存。

---

# 二十五、Ruleset 之外还应该开启哪些安全功能？

Ruleset 解决的是：

> 谁能怎样修改分支。

它不是完整的仓库安全体系。

对于公开仓库，还建议进入：

```text
Settings
→ Advanced Security
```

根据仓库情况开启：

```text
Dependency graph
Dependabot alerts
Dependabot security updates

Secret scanning
Push protection

CodeQL
```

---

## Dependabot

如果仓库有：

```text
package.json
package-lock.json
requirements.txt
pyproject.toml
Cargo.toml
```

等依赖文件，Dependabot 可以检测已知依赖漏洞。

推荐：

```text
Dependabot alerts             ✅
Dependabot security updates   ✅
```

---

## Secret scanning + Push protection

建议公开仓库开启：

```text
Secret scanning ✅
Push protection ✅
```

例如误提交：

```text
API_KEY=...
TOKEN=...
PRIVATE_KEY=...
```

Push Protection 可以尝试在 Push 阶段阻止支持类型的 Secret 进入仓库。

注意：

```text
.gitignore
```

不能替代 Secret scanning。

`.gitignore` 主要防止某些文件被跟踪，而 Secret scanning 检查的是实际提交内容。

---

## CodeQL

如果仓库使用 GitHub 支持良好的语言，例如：

```text
JavaScript
TypeScript
Python
Java
C/C++
C#
Go
Ruby
Swift
Kotlin
```

可以考虑：

```text
CodeQL
→ Set up
→ Default
```

个人项目刚开始时，我建议：

```text
CodeQL 扫描             ✅
CodeQL 作为 Required     ❌
```

先观察扫描是否稳定。

等确认每个 PR 都可以稳定产生 Code Scanning 结果后，再考虑把它升级成强制门禁。

---

# 二十六、一个比较合理的开源仓库保护结构

最终可以形成：

```text
Developer
    │
    ▼
feature/*
    │
    ▼
Push
    │
    ├───────────────┐
    │               │
    ▼               ▼
Pull Request   Push Protection
    │
    ▼
GitHub Actions
    │
    ▼
check
 ├── lint
 ├── build
 └── test
    │
    ▼
Ruleset
    │
 ┌──┴──┐
 │     │
失败   成功
 │     │
禁止   Merge
Merge   │
        ▼
       main
```

如果以后项目进一步成熟，可以继续增加：

```text
CodeQL
Dependabot
Code Owners
Required Review
Signed Commits
Release Attestation
```

但它们应该是在已有稳定开发流程之上的增强，而不是一开始全部堆上去。

---

# 二十七、我自己的推荐原则

配置 GitHub Ruleset 时，我更推荐遵循下面四条原则。

## 1. main 必须稳定

至少要求：

```text
PR + CI
```

---

## 2. 不要为了“看起来安全”而增加无意义规则

例如个人仓库只有一个维护者，却设置：

```text
Required approvals = 1
```

只会降低开发效率。

---

## 3. CI 必须检查真正重要的东西

好的 Required Check 应该包含：

```text
lint
build / type check
test
```

而不是：

```bash
echo "CI passed"
```

Ruleset 本身不会提高代码质量。

真正提高质量的是：

```text
Ruleset
   +
有效 CI
```

---

## 4. 随着项目成熟逐步提高保护等级

推荐演进路径：

```text
阶段 1
PR + CI

        ↓

阶段 2
PR + CI + Dependabot + Secret Protection

        ↓

阶段 3
Required Review + CodeQL

        ↓

阶段 4
Code Owners + Signed Commit + 更严格供应链规则
```

而不是从第一天就把所有选项全部开启。

---

# 总结

对于大多数个人维护的 GitHub 开源仓库，我认为最值得作为默认配置的是：

```text
Protect main

✅ Require Pull Request
✅ Require Status Check
✅ Restrict deletions
✅ Block force pushes
✅ Require conversation resolution

Required approvals = 0
Require branch up to date = false

❌ Restrict updates
❌ Signed commits
❌ Release Workflow Required
```

再配合：

```text
CI:
lint
+ build
+ test
```

就已经建立了一套非常实用的主分支保护体系。

核心思想并不是：

> Ruleset 越严格越好。

而是：

> **让进入 main 的每一次修改，都经过与你的项目规模相匹配的验证。**

---

# 参考资料

- GitHub Docs — About rulesets  
  https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets

- GitHub Docs — Creating rulesets for a repository  
  https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/creating-rulesets-for-a-repository

- GitHub Docs — Available rules for rulesets  
  https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets

- GitHub Docs — Quickstart for securing your repository  
  https://docs.github.com/en/code-security/getting-started/quickstart-for-securing-your-repository
