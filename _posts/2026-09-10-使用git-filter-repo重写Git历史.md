---
layout: single
title: "使用 git-filter-repo 重写 Git 历史：彻底删除误提交目录的完整实践"
excerpt: "记录一次使用 git-filter-repo 从整个 Git 历史中彻底删除目录的完整流程，包括备份、验证、origin 丢失原因、多个远程仓库恢复与强制推送。"
categories: 技术 Git
tags: [Git, GitHub, git-filter-repo, 版本控制, Git历史重写]
hidden: false
---

## 前言

在日常开发中，我们有时会误将不应该进入仓库的内容提交到 Git，例如：

```text
docs/superpowers/
```

之后即使执行：

```bash
git rm -r docs/superpowers
git commit
git push
```

也只是从**当前版本**删除，这些文件依然存在于旧的 Git commit 中。

如果目标是：

> 不仅从当前仓库删除，还希望从整个 Git 历史中彻底清除该目录。

那么就需要进行 Git 历史重写（History Rewrite）。目前更推荐使用：

```text
git-filter-repo
```

而不是老旧的：

```text
git filter-branch
```

本文记录一次完整的 `git-filter-repo` 实践流程。

## 1. 普通删除和历史删除有什么区别？

首先必须理解：

```bash
git rm
```

和：

```bash
git filter-repo
```

解决的是两个完全不同的问题。

假设 Git 历史如下：

```text
A -- B -- C -- D
```

其中 `A`、`B`、`C` 都包含 `docs/superpowers/`。如果只在 `D` 中执行：

```bash
git rm -r docs/superpowers
git commit
```

那么结果只是当前版本没有该目录，旧提交中依然存在。

`git rm` 解决的是：

> 从当前版本删除。

而 `git filter-repo` 解决的是：

> 修改历史提交，让指定路径仿佛从未被提交过。

## 2. 什么时候应该重写 Git 历史？

不要把历史重写当成普通文件删除工具。普通文档、代码文件如果只是“不再需要”，通常执行 `git rm` 即可。

真正适合使用 `git filter-repo` 的场景包括：

- 误提交密码、Token、API Key；
- 误提交 SSH 私钥或其他敏感凭证；
- 误提交隐私数据；
- 误提交大型二进制文件；
- 误提交不应该进入仓库的目录；
- 希望彻底移除某类历史文件。

历史重写会改变 commit SHA，因此属于影响较大的操作。

## 3. 安装 git-filter-repo

如果本机还没有 `git filter-repo`，可以通过 Python 安装：

```bash
python -m pip install git-filter-repo
```

安装完成后检查：

```bash
git filter-repo --version
```

## 4. 操作前检查仓库状态

进入仓库后首先执行：

```bash
git status
```

推荐在下面的状态下进行历史重写：

```text
nothing to commit, working tree clean
```

如果还有未提交的改动，先提交或妥善保存。

## 5. 重写历史前先做备份

历史重写属于破坏性操作，建议首先创建一个完整 Git Bundle：

```bash
git bundle create ../repo-before-filter.bundle --all
```

然后验证：

```bash
git bundle verify ../repo-before-filter.bundle
```

如果后续操作出现问题，可以使用：

```bash
git clone repo-before-filter.bundle repo-recovery
```

恢复仓库。

## 6. 建议提前记录远程仓库地址

先查看当前远程：

```bash
git remote -v
```

如果有多个远程，例如：

```text
origin
gitee
```

PowerShell 中可以提前保存：

```powershell
$origin = git remote get-url origin
$gitee = git remote get-url gitee
```

这样历史重写结束后可以方便恢复。

## 7. 正式删除历史中的目录

假设目标目录是：

```text
docs/superpowers/
```

执行：

```bash
git filter-repo --force --path docs/superpowers/ --invert-paths
```

这是整个操作的核心命令。

### `--path`

```bash
--path docs/superpowers/
```

表示匹配该目录。

### `--invert-paths`

与 `--path` 配合后表示：

> 删除指定路径，保留其他内容。

因此可以理解为：

```text
扫描所有 commit
        ↓
寻找 docs/superpowers/
        ↓
将其删除
        ↓
保留其他所有文件
```

### `--force`

`git-filter-repo` 默认更希望在一个新的 clone 中执行。如果确认仓库、备份和目标路径都正确，可以使用 `--force` 允许在当前仓库执行。

## 8. 为什么执行之后 origin 会消失？

执行 `git filter-repo` 后，再运行：

```bash
git remote -v
```

可能会发现 `origin` 不见了。

这并不是错误，而是 `git-filter-repo` 的安全设计之一。

原因是历史已经被重写，后续往远程推送通常需要 force push。为了避免用户无意中立刻覆盖原远程历史，`git-filter-repo` 会移除 `origin`。

因此：

```text
origin 消失 ≠ 仓库损坏
```

## 9. 恢复远程仓库

如果之前已经保存：

```powershell
$origin
$gitee
```

可以恢复：

```powershell
git remote add origin $origin
```

如果第二个远程也不存在：

```powershell
git remote add gitee $gitee
```

然后检查：

```bash
git remote -v
```

## 10. 如何验证历史真的删除干净？

历史重写后不要立刻推送，应该先验证。

### 方法一：查看指定路径历史

```bash
git log --all -- docs/superpowers/
```

正常情况下应该没有输出。

### 方法二：检查 Git 对象引用

PowerShell：

```powershell
git rev-list --objects --all | Select-String "docs/superpowers/"
```

Linux / Git Bash：

```bash
git rev-list --objects --all | grep "docs/superpowers/"
```

正常情况下也应该没有输出。

### 方法三：检查当前工作区

PowerShell：

```powershell
Test-Path docs/superpowers
```

应该输出：

```text
False
```

## 11. 为什么需要强制推送？

历史重写前：

```text
A -- B -- C -- D
```

重写之后：

```text
A' -- B' -- C' -- D'
```

相关 commit 的 SHA 已经发生变化，因此普通：

```bash
git push origin main
```

通常会遇到 non-fast-forward 拒绝。

需要：

```bash
git push --force origin main
```

如果希望更谨慎，也可以在合适场景下使用：

```bash
git push --force-with-lease origin main
```

## 12. 同时维护两个不同 remote

如果仓库有两个不同名字的远程，例如：

```text
origin
gitee
```

历史重写后分别推送即可：

```bash
git push --force origin main
git push --force gitee main
```

如果还需要同步 tags：

```bash
git push --force --tags origin
git push --force --tags gitee
```

如果需要推送所有本地分支：

```bash
git push --force --all origin
git push --force --all gitee
```

需要注意，两次 push 是两个独立操作，并不是事务。可能出现一个远程成功、另一个失败的情况。

## 13. 如果仓库开启了 Branch Protection / Ruleset

如果 `main` 配置了禁止 force push 的规则，那么：

```bash
git push --force origin main
```

可能会被拒绝。

需要到 GitHub 仓库的 Ruleset 或 Branch Protection 中检查是否禁止了 force push。如果确实要进行历史重写，可以临时调整规则，完成后再恢复保护。

## 14. 路径曾经改名时要特别注意

假设目录历史上曾经历：

```text
superpowers/
↓
docs/old-superpowers/
↓
docs/superpowers/
```

那么只写：

```bash
git filter-repo --path docs/superpowers/ --invert-paths
```

不会自动删除旧路径。

应该一次指定所有历史路径：

```bash
git filter-repo --force \
  --path superpowers/ \
  --path docs/old-superpowers/ \
  --path docs/superpowers/ \
  --invert-paths
```

PowerShell：

```powershell
git filter-repo --force `
  --path superpowers/ `
  --path docs/old-superpowers/ `
  --path docs/superpowers/ `
  --invert-paths
```

## 15. 完整 PowerShell 操作模板

假设：

```text
删除目录：docs/superpowers/
远程：origin、gitee
主分支：main
```

可以按照下面的顺序执行：

```powershell
# 1. 检查工作区
git status

# 2. 保存远程地址
$origin = git remote get-url origin
$gitee = git remote get-url gitee

# 3. 备份仓库
git bundle create ../repo-before-filter.bundle --all
git bundle verify ../repo-before-filter.bundle

# 4. 确认工具可用
git filter-repo --version

# 5. 查看目标路径历史
git log --all -- docs/superpowers/
git rev-list --objects --all | Select-String "docs/superpowers/"

# 6. 重写历史
git filter-repo --force --path docs/superpowers/ --invert-paths

# 7. 验证
git log --all -- docs/superpowers/
git rev-list --objects --all | Select-String "docs/superpowers/"
Test-Path docs/superpowers

# 8. 恢复远程
git remote add origin $origin

# 如果 gitee 也被删除，再执行：
# git remote add gitee $gitee

git remote -v

# 9. 推送重写后的历史
git push --force origin main
git push --force gitee main
```

## 16. `git rm`、`git rm --cached` 与 `git filter-repo` 对照

| 操作 | 当前版本 | Git 历史 | 本地文件 |
| --- | --- | --- | --- |
| `git rm` | 删除 | 保留 | 删除 |
| `git rm --cached` | 删除追踪 | 保留 | 保留 |
| `git filter-repo` | 删除 | 删除 | 删除 |

可以用下面的判断规则：

```text
只是文件以后不用了
        ↓
git rm

本地需要，但不希望 Git 管理
        ↓
git rm --cached
+
.gitignore

需要从历史中彻底清除
        ↓
git filter-repo
```

## 17. 一个重要的安全问题：删除 Token 不等于 Token 重新安全

如果历史中包含 GitHub Token、API Key、密码、SSH Key 等敏感凭证，即使已经通过 `git filter-repo` 把它们从历史中删除，也不能认为这些凭证还能继续使用。

正确做法应该是：

```text
凭证泄漏
    ↓
立即 revoke / 失效旧凭证
    ↓
生成新凭证
    ↓
修改系统配置
    ↓
再清理 Git 历史
```

`git-filter-repo` 的作用是清理历史，而不是恢复已经泄漏凭证的安全性。

## 18. 多人协作仓库需要特别谨慎

历史重写后，其他开发者本地仍可能保留旧历史。如果继续在旧 clone 上 pull、merge、push，甚至可能重新把旧历史带回远程仓库。

因此多人协作仓库进行历史重写后，最简单、最稳妥的处理方式通常是让协作者重新 clone：

```bash
git clone <repository-url>
```

## 19. 最佳实践

进行 Git 历史重写时，建议始终遵循：

```text
确认路径
→ git status
→ 记录所有 remote
→ git bundle 备份
→ git filter-repo
→ git log 验证
→ git rev-list 验证
→ 恢复 origin
→ 检查 branch protection / Ruleset
→ force push
→ 再次验证远程
```

最关键的三个原则是：

```text
备份
验证
强推前检查
```

## 总结

如果只是删除当前仓库中的文件：

```bash
git rm
```

如果文件仍需保留在本地：

```bash
git rm --cached
```

并配合 `.gitignore`。

如果希望某个目录从整个 Git 历史中彻底消失，则可以使用：

```bash
git filter-repo --force --path <directory>/ --invert-paths
```

例如：

```bash
git filter-repo --force --path docs/superpowers/ --invert-paths
```

但真正可靠的历史重写流程，不应该只记住这一条命令，而应该记住完整链路：

```text
备份
→ 重写
→ 验证
→ 恢复远程
→ 强制推送
→ 再验证
```

这才是一次安全、可回退、可验证的 Git 历史清理。