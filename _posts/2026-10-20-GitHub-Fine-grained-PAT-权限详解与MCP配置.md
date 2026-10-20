---
layout: single
title: "GitHub Fine-grained PAT 权限详解与 MCP Server 最小权限配置指南"
slug: "github-fine-grained-pat-mcp-permissions-guide"
excerpt: "详解 GitHub 新版细粒度令牌的 Repository、Organization、User 权限，梳理 Contents、PR、Issues、Actions、Workflows 等核心能力，提供 GitHub MCP 与 VS Code 可用配置、权限预设和报错排查方法。"
categories: 技术 GitHub
tags: [GitHub, Fine-grained PAT, MCP, GitHub Actions, AI Agent, VS Code, 权限管理]
hidden: false
toc: true
toc_sticky: true
---

## 前言

为了让 Codex、Claude Code 或 VS Code Copilot 通过 **GitHub MCP Server** 读取代码、修改文件、创建 Pull Request（PR）和管理 Issue，经常需要配置 GitHub Personal Access Token（PAT）。

但在新版 **Fine-grained personal access token** 创建界面中，`Contents`、`Pull requests`、`Actions`、`Workflows`、`Administration`、`Secrets` 等权限很容易令人困惑。

本文结合 [GitHub 2026-03-10 版本 REST API 权限文档](https://docs.github.com/zh/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens?apiVersion=2026-03-10) 和 [GitHub 官方 MCP Server](https://github.com/github/github-mcp-server)，整理一套**可以直接参照设置**的权限说明和操作教程。

> **核心原则：只给必需的仓库、必需的 API 权限和必需的 MCP 工具。** 不要为了让 AI Agent 正常工作就开启所有权限。

---

## 一、PAT、仓库范围和 MCP Toolsets 有什么区别？

### 1.1 Fine-grained PAT 与 Classic PAT

| 比较项 | Classic PAT | Fine-grained PAT |
| --- | --- | --- |
| 常见前缀 | `ghp_` | `github_pat_` |
| 权限粒度 | `repo`、`workflow` 等 Scope | 仓库、组织、账户资源的细粒度权限 |
| 仓库访问范围 | 通常较宽 | 可指定资源所有者和具体仓库 |
| 读写分离 | 相对粗粒度 | 多数操作可区分 Read 和 Write |
| 推荐方式 | 兼容性受限时再考虑 | **优先选择** |

Fine-grained PAT 也存在兼容性限制，例如部分 API 或向非所属公共仓库写入的情形，可能需要使用其他认证方式。应该先查目标 API 文档，而不是遇到 `403` 就立即换成全权限 Classic PAT。

### 1.2 四层权限共同决定最终操作能力

| 层次 | 含义 | 示例 |
| --- | --- | --- |
| Resource owner | Token 所属的账户或组织 | 个人账号 |
| Repository access | Token 允许访问的仓库 | Only select repositories |
| PAT permissions | GitHub REST API 允许的资源操作 | Contents: Read and write |
| MCP Toolsets / Read-only | 哪些工具会展示给 Agent | repos、issues、pull_requests |

即使以上四层都允许操作，也仍然受**仓库角色、Branch Protection 和 Rulesets** 约束。

例如，AI 可以创建分支和 PR，并不代表它能够绕过审核与 CI 直接修改 `main`。

### 1.3 权限等级

- **No access**：不额外授权该类私有 API 资源。
- **Read-only**：读取或查询资源。
- **Read and write**：在读取基础上允许对应写操作。
- 某些端点要求多个权限同时具备，部分端点允许几种权限任选其一。

**重要：官方权限页面是“权限 → REST 端点”的映射表，不是单纯的功能开关说明。** 最终应检查端点所需权限。

---

## 二、Repository permissions：核心权限逐项详解

日常 GitHub MCP 开发场景，先理解下面十项即可。

| 权限 | 作用 | 推荐级别 |
| --- | --- | --- |
| **Contents** | 读取、创建和修改代码、分支、提交、标签等 | 开发时 Read and write |
| **Pull requests** | 查询、创建、更新 PR，Review 与评论 | 需要 PR 时 Read and write |
| **Issues** | 读取、创建、更新和关闭 Issue | 按需 Read and write |
| **Actions** | CI/CD 工作流运行、日志、重跑、取消等 | 默认 Read-only |
| **Workflows** | 与写入工作流文件相关的 API 授权 | 默认 No access |
| **Metadata** | 查询仓库基本元信息 | 通常自动 Read-only |
| **Commit statuses** | 读取或发布传统 Commit Status | 按需 Read-only |
| **Administration** | 管理仓库设置、规则、部分破坏性操作 | No access |
| **Secrets** | Actions Secrets 的配置管理 | No access |
| **Webhooks** | 外部事件回调配置 | No access |

### 2.1 Contents：代码读写的基础权限

典型 API：

```http
GET    /repos/{owner}/{repo}/contents/{path}
PUT    /repos/{owner}/{repo}/contents/{path}
DELETE /repos/{owner}/{repo}/contents/{path}
POST   /repos/{owner}/{repo}/git/refs
```

假设对 Agent 说：

> 阅读代码，修复 Bug，创建 `fix/login-error` 分支，把修改提交到 GitHub。

通常需要 `Contents: Read and write`。

若只希望 AI 阅读私有仓库、解释项目结构、分析代码，`Read-only` 就够了。注意 **Contents Write 本身就是较强权限**，因为它允许修改仓库代码；不要低估其风险。

### 2.2 Pull requests：管理 PR

典型 API：

```http
GET  /repos/{owner}/{repo}/pulls
GET  /repos/{owner}/{repo}/pulls/{pull_number}/files
POST /repos/{owner}/{repo}/pulls
POST /repos/{owner}/{repo}/pulls/{pull_number}/reviews
```

如果要求 Agent “修复问题、提交开发分支、创建 PR，但不要合并”，一般是：

- `Contents: Write`：完成代码修改和分支提交。
- `Pull requests: Write`：创建并管理 PR。

**特别注意：合并 PR 的 REST API 通常使用 `Contents: Write`，并非单纯授予 `Pull requests: Write` 就一定能合并。** 合并还必须满足分支保护、必需 Review 和状态检查。

### 2.3 Issues：问题追踪

`Issues: Read and write` 用于创建和管理 Bug、Feature Request、任务清单、评论、标签等。

如：

> 帮我为这个问题创建 Feature Request，添加 `enhancement` 标签。

通常需要 Issues 写权限。

部分 PR 评论、标签接口会借用 `/issues/` API 路径，且可能接受 Issues **或** Pull requests 中任一权限，所以不能仅凭 URL 名称推断必须同时开启两者。

### 2.4 Actions 和 Workflows：不是同一项权限

| 权限 | 关注点 | 例子 |
| --- | --- | --- |
| Actions | 工作流运行及运行结果 | 查看 Job 日志、重跑失败 Workflow |
| Workflows | 与工作流 YAML 文件写入有关 | 修改 `.github/workflows/release.yml` |

查看 CI 失败原因，通常 `Actions: Read-only` 即可。想要手动触发、取消、重新运行 CI，才考虑 `Actions: Write`。

若 AI 要直接修改 `.github/workflows/*.yml`，通常应检查 `Contents: Write` 和 `Workflows: Write` 的组合要求。允许修改工作流文件会扩大执行风险，应按需单独授权。

### 2.5 Commit statuses 与 Checks

`Commit statuses` 是传统 Commit Status API，可表示 `success`、`failure`、`pending` 等。

它与 GitHub Checks API 是两套不同接口。不能以为开启 `Commit statuses` 就自动获得所有 Checks API 访问能力。

读取构建日志优先考虑 `Actions: Read`；只有工具明确使用 Commit Status API 时，才追加 `Commit statuses: Read`。

### 2.6 Administration、Secrets 和 Webhooks 为什么默认关闭？

- **Administration**：部分 API 涉及仓库设置、规则、协作者甚至删除仓库等高风险操作。
- **Secrets**：API 不会直接返回解密后的 Secret 明文，但写权限可以修改或删除机密配置。
- **Webhooks**：写权限可能更改向外部服务发送事件的目标地址。

普通的代码读取、修 Bug、创建 PR 不应因此得到仓库管理权限。

---

## 三、其他 Repository permissions 分类速查

下表保留 GitHub 权限页面的英文名称，方便直接在创建令牌时搜索。它们是用途摘要，**不代表所有权限都同时提供 Read 和 Write 两种等级**。

### 3.1 安全与漏洞管理

| 权限 | 用途 | 建议 |
| --- | --- | --- |
| Code scanning alerts | 查看、处理代码扫描安全告警（如 CodeQL） | 安全分析时 Read |
| Code quality | 查看代码质量检查结果 | 按需 Read |
| Dependabot alerts | 查看依赖漏洞告警 | 按需 Read |
| Dependabot secrets | 管理 Dependabot 的机密 | 关闭 |
| Secret scanning alerts | 查看疑似泄露的密钥、Token 等告警 | 按需 Read |
| Repository security advisories | 安全公告与漏洞披露 | 关闭，按需授权 |
| Attestations | 构建产物来源与完整性证明 | 通常关闭 |

如何区分？

- **Dependabot alerts**：依赖包有没有已知 CVE？
- **Code scanning alerts**：源代码里有没有静态分析发现的漏洞？
- **Secret scanning alerts**：仓库是否提交了疑似敏感凭据？

做安全审查优先授权只读，避免 AI 直接修改安全设置或批量关闭告警。

### 3.2 CI/CD 与部署

| 权限 | 用途 | 建议 |
| --- | --- | --- |
| Deployments | 部署记录与部署状态管理 | 按需 |
| Environments | 部署环境相关配置 | 默认关闭 |
| Pages | GitHub Pages 配置与部署接口 | 按需 Read |
| Artifact metadata | 构建产物元数据相关 API | 关闭 |
| Variables | GitHub Actions 普通变量管理 | 关闭 |
| Secrets | GitHub Actions 机密管理 | 关闭 |

**更新 Jekyll / GitHub Pages 博客文章，一般只需 Contents 写权限。** 仅当 Agent 要调用 Pages 管理 API 时才考虑 `Pages`。

### 3.3 Codespaces、Copilot 与 Agent

| 权限 | 用途 | 建议 |
| --- | --- | --- |
| Codespaces | 创建、查询、管理云端开发环境 | 本地开发关闭 |
| Codespaces metadata | 开发容器配置、机器规格等 | 按需 Read |
| Codespaces lifecycle admin | 启停和导出 Codespaces | 关闭 |
| Codespaces secrets | Codespaces 使用的机密 | 关闭 |
| Agent secrets | GitHub Agent 的机密配置 | 关闭 |
| Agent variables | GitHub Agent 的环境变量配置 | 关闭 |
| Copilot agent settings | Copilot Coding Agent 仓库配置 | 通常关闭 |

**并不是使用了 AI Agent 就必须开启 Agent secrets。** Codex、Claude Code 通过 MCP 修改代码，通常只需要所调用仓库 API 对应的权限。

### 3.4 仓库管理与集成扩展

| 权限 | 用途 | 建议 |
| --- | --- | --- |
| Custom properties | 仓库自定义属性 | 关闭 |
| GitHub App installation repository access | 调整 GitHub App 安装的仓库访问范围 | 关闭 |
| Repository creation | 创建仓库、Fork 或基于模板生成仓库 | 按需 Write |
| Webhooks | 管理仓库事件回调 | 关闭 |

如果 AI 的任务是**新建 GitHub 仓库**，应检查 `Repository creation`，而不是只授权 `Contents: Write`。

---

## 四、Organization permissions：组织级权限解释

Organization permissions 面向组织管理员与组织级资源，不是某个仓库的代码读写开关。

### 4.1 组织、成员与项目

| 权限 | 作用 |
| --- | --- |
| API Insights | 组织 API 使用情况 |
| Administration | 组织级管理和配置 |
| Blocking users | 组织屏蔽用户 |
| Custom organization roles | 自定义组织角色 |
| Custom properties | 组织定义的自定义属性 |
| External custom properties for repositories | 外部集成相关仓库属性 |
| Events | 组织活动事件 |
| Members | 组织成员和团队管理 |
| Projects | 组织级 GitHub Projects |
| Issue Fields | 组织 Issue 自定义字段 |
| Issue Types | 组织 Issue 类型 |

只管理仓库 Issue，用 `Repository → Issues`；要操作组织级 Projects 看板时，才考虑 `Organization → Projects`。

### 4.2 Copilot 与组织 Agent

| 权限 | 作用 |
| --- | --- |
| Agent secrets | 组织级 Agent Secrets |
| Agent variables | 组织级 Agent Variables |
| Copilot Spaces | Copilot Spaces |
| Copilot agent settings | 组织级 Copilot Agent 配置 |
| Copilot content exclusion | Copilot 内容排除策略 |
| GitHub Copilot Business | 企业 Copilot 相关管理 |
| Organization Copilot metrics | 组织 Copilot 统计 |

这些权限对应 GitHub 自身的相关服务，**不是第三方 MCP 接入的通用前置条件**。

### 4.3 组织安全、Runner 与环境

| 权限 | 作用 |
| --- | --- |
| Campaigns | 安全整改任务 |
| Hosted runner custom images | 托管 Runner 自定义镜像 |
| Network configurations | 网络配置 |
| Organization codespaces | 组织 Codespaces |
| Organization codespaces settings | Codespaces 组织设置 |
| Organization codespaces secrets | Codespaces 组织机密 |
| Organization dependabot secrets | Dependabot 组织机密 |
| Organization private registries | 私有依赖注册表 |
| Secrets | 组织 Actions Secrets |
| Self-hosted runners | 自托管 Runner |
| Variables | 组织 Actions Variables |
| Webhooks | 组织事件回调 |

对于个人仓库的日常 MCP 开发，上述组织权限**一般保持 No access**。

---

## 五、User / Account permissions：个人账号权限

这些用于用户资源管理，而不是特定仓库内容。

| 权限 | 作用 | 建议 |
| --- | --- | --- |
| Block another user | 屏蔽其他用户 | 关闭 |
| Codespaces user secrets | 个人 Codespaces 机密 | 关闭 |
| Email addresses | 查询、管理账号邮箱 | 关闭 |
| Followers | 关注关系 | 按需 |
| GPG keys | 管理账户 GPG 公钥 | 关闭 |
| Gists | 创建、修改 Gist | 用到时开启 |
| Git SSH keys | 管理账户 SSH 公钥 | 关闭 |
| Interaction limits | 用户互动限制 | 关闭 |
| Plan | 账户套餐和用量信息 | 关闭 |
| Private repository invitations | 私有仓库邀请 | 关闭 |
| Profile | 账户资料 | 关闭 |
| SSH signing keys | SSH 签名公钥 | 关闭 |
| Starring | Star 收藏 | 按需 |
| Watching | 仓库订阅与关注 | 按需 |

注意：`Git SSH keys` 是**管理登记在 GitHub 账户中的 SSH 公钥**，并不是让 MCP 读取或使用本机 SSH 私钥。普通 MCP 仓库操作不需要这项权限。

---

## 六、四套可以直接使用的 MCP 权限预设

下面均以 Repository permissions 为主；除单独说明外，其余保持 `No access`。

### 方案 A：只读代码分析

| 权限 | 等级 |
| --- | --- |
| Contents | Read-only |
| Pull requests | Read-only |
| Issues | Read-only |
| Actions | Read-only（可选） |
| Metadata | Read-only（通常自动） |

适合阅读私有仓库、分析代码、查看 PR，不允许修改远程内容。

### 方案 B：日常 AI 开发（推荐）

| 权限 | 等级 |
| --- | --- |
| **Contents** | **Read and write** |
| **Pull requests** | **Read and write** |
| Issues | Read and write（用到时） |
| Actions | Read-only |
| Commit statuses | Read-only（按需） |
| Metadata | Read-only（通常自动） |

适合 Agent 修 Bug、建分支、提交代码、创建 PR、管理 Issue 和查看 CI 日志。

### 方案 C：开发 + CI/CD

在方案 B 基础上，按具体任务增加：

- `Actions: Read and write`：触发或重跑构建。
- `Workflows: Read and write`：需要修改 `.github/workflows/` 文件时，再核对与 Contents 的组合要求。
- `Deployments`、`Pages`：真的要操作部署 API 时再加。

这类高权限推荐使用单独的 Token，不要与普通代码只读任务共享。

### 方案 D：仓库安全审查

- `Contents: Read-only`
- `Code scanning alerts: Read-only`
- `Dependabot alerts: Read-only`
- `Secret scanning alerts: Read-only`
- `Pull requests: Read-only`（按需）

先让 Agent **发现、分析、报告安全问题**，再人工决定是否自动修复或处理告警。

### 常用操作到权限的速查表

| 目标 | 重点权限 |
| --- | --- |
| 阅读私有仓库文件 | Contents: Read |
| 修改文件 / 创建分支 | Contents: Write |
| 创建 PR | Pull requests: Write；代码提交一般还需 Contents: Write |
| 合并 PR | Contents: Write + 分支保护要求 |
| 管理 Issue | Issues: Write |
| 查询 Actions 日志 | Actions: Read |
| 重新运行 Workflow | Actions: Write |
| 修改 Workflow YAML | Workflows: Write + Contents: Write（按端点检查） |
| 读取依赖漏洞 | Dependabot alerts: Read |
| 读取密钥泄露告警 | Secret scanning alerts: Read |
| 管理仓库设置 | Administration 等管理权限 |
| 新建仓库 | Repository creation 等端点要求 |

> 提示：这是场景建议，不等同于所有 GitHub REST API 端点的统一授权保证。失败时应从实际端点核对权限，而非一次性全部开启。

---

## 七、实际创建 Fine-grained PAT

创建入口：[GitHub Fine-grained PAT](https://github.com/settings/personal-access-tokens/new)。

也可依次进入：头像 → `Settings` → `Developer settings` → `Personal access tokens` → `Fine-grained tokens` → `Generate new token`。

建议配置：

| 设置项 | 示例 | 说明 |
| --- | --- | --- |
| Token name | `GitHub-MCP-Development` | 标注用途 |
| Description | `GitHub MCP for AI coding assistants` | 区分不同客户端 |
| Expiration | 90 days | 设定失效期限 |
| Resource owner | 个人账号或目标组织 | 选择资源所有者 |
| Repository access | **Only select repositories** | 限定可访问的仓库 |
| Permissions | 按第六节预设 | 最小权限 |

选择组织 Resource owner 时，可能还需遵循组织的 PAT 政策或等待管理员批准。

**不要轻易选择 `All repositories`。** 即使是自己持有的 Token，也应尽量控制到需要操作的仓库。

Token 生成后仅保存到可靠的凭据管理位置。不要提交至 Git 仓库，也不要直接写进博客示例、Issue、PR、日志和截图。泄露后应**撤销并重新生成**。

---

## 八、配置 GitHub MCP Server

官方地址：[github/github-mcp-server](https://github.com/github/github-mcp-server)。

### 8.1 VS Code：远程 MCP（推荐）

在工作区 `.vscode/mcp.json` 配置：

```json
{
  "servers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer ${input:github_mcp_pat}",
        "X-MCP-Toolsets": "context,repos,issues,pull_requests,actions"
      }
    }
  },
  "inputs": [
    {
      "type": "promptString",
      "id": "github_mcp_pat",
      "description": "GitHub Fine-grained PAT",
      "password": true
    }
  ]
}
```

上例中的 `${input:github_mcp_pat}` 应写为 VS Code 输入变量 `${input:github_mcp_pat}`（见下文），不是粘贴真实 Token。最终 `Authorization` 行应该是：

```json
"Authorization": "Bearer ${input:github_mcp_pat}"
```

VS Code 在启动 MCP 时会提示输入凭据。这样比在 JSON 文件中直接存明文令牌更合理。

如果只允许 AI 读取，给 `headers` 再加：

```json
"X-MCP-Readonly": "true"
```

**MCP Toolsets 和 PAT 权限是两回事**：把 `actions` 放进 `X-MCP-Toolsets`，不意味着自动获得 Actions 写权限；API 仍会检查 PAT。

### 8.2 本地 Docker MCP（可选）

本地运行 GitHub MCP Server 时，可以使用：

```bash
docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN \
  -e GITHUB_TOOLSETS="context,repos,issues,pull_requests,actions" \
  ghcr.io/github/github-mcp-server
```

前提是执行 Docker 命令的进程环境里已经设置 `GITHUB_PERSONAL_ACCESS_TOKEN`。**不要在可共享的命令、脚本或仓库中直接写真实 Token。**

Codex、Claude Code 和其他 MCP 客户端的 JSON / TOML 格式不完全相同，应参考对应官方安装文档，不能把 VS Code 的 `mcp.json` 原样用于全部客户端。

### 8.3 GitHub MCP Toolsets 速查

| Toolset | 作用 |
| --- | --- |
| `context` | 用户和操作上下文 |
| `repos` | 仓库信息、文件、提交 |
| `issues` | Issue |
| `pull_requests` | PR |
| `actions` | GitHub Actions |
| `git` | 底层 Git API |
| `code_security` | 代码扫描安全 |
| `dependabot` | 依赖漏洞 |
| `gists` | Gist |
| `users` | 用户信息 |

不要在没有必要时配置 `all`。限制工具范围能减少暴露的操作面，也更方便 Agent 选择工具。

官方参数说明：[Remote Server 配置](https://github.com/github/github-mcp-server/blob/main/docs/remote-server.md)。

---

## 九、常见报错及排查办法

| 问题 | 典型原因 | 检查方向 |
| --- | --- | --- |
| `401 Bad credentials` | 凭据无效、过期、已撤销 | PAT 是否正确 |
| `403 Resource not accessible by personal access token` | 权限不足、组织限制、账户权限不够 | PAT Permissions + 组织策略 |
| `404 Not Found` | 资源不存在，或当前 Token 看不到私有资源 | URL、仓库访问范围 |
| 能读代码但不能提交 | Contents 不具备写权限、Ruleset 拒绝 | Contents + 分支规则 |
| 代码已提交，但建 PR 失败 | PR 权限不足 | Pull requests: Write |
| PR 可创建但无法合并 | Contents 权限或分支保护要求未满足 | Contents + Review + Checks |
| 可看 Actions 日志但不能重跑 | 只有 Actions Read | Actions: Write |
| 修改 `.github/workflows` 失败 | 工作流文件写权限不足 | Workflows + Contents |

GitHub REST API 还可能在响应中给出：

```http
X-Accepted-GitHub-Permissions
```

它可以提示当前端点接受的权限组合。**出现报错时应先确认具体调用了哪个 API，再据此补充最小权限。**

此外，部分端点不支持 Fine-grained PAT 或对身份类型有其他限制；这不是勾选更多权限就能解决的。

---

## 十、我的 GitHub MCP 安全检查清单

- [ ] 优先使用 Fine-grained PAT。
- [ ] 选择正确的 Resource owner。
- [ ] Repository access 尽量使用 `Only select repositories`。
- [ ] 只读分析 Agent 只授予 Read，并启用 MCP Read-only。
- [ ] 需要写代码时才开启 `Contents: Write`。
- [ ] 需要创建 PR 时开启 `Pull requests: Write`。
- [ ] 查看 CI 日志不需要 `Actions: Write`。
- [ ] 不修改 Workflow YAML 就不开放 `Workflows: Write`。
- [ ] 默认关闭 `Administration`、`Secrets`、`Webhooks`。
- [ ] 默认不授予无关的组织和用户权限。
- [ ] 为安全审查、日常开发、CI/CD 管理分别使用独立 Token。
- [ ] Token 不进入 Git 历史，设置期限，定期轮换。
- [ ] `main` 配置分支保护，AI 通过分支和 PR 提交修改。
- [ ] 不将仓库 README、Issue、PR 中的内容视为可信系统指令，防范 Prompt Injection。

**推荐起点：日常开发先给 `Contents: Write`、`Pull requests: Write`、按需 `Issues: Write` 和 `Actions: Read`。之后根据具体工具报错逐项增补，而不是一开始开启全部权限。**

---

## 参考资料

1. [GitHub REST API：细粒度 PAT 所需权限（apiVersion=2026-03-10）](https://docs.github.com/zh/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens?apiVersion=2026-03-10)
2. [GitHub：管理个人访问令牌](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
3. [GitHub 官方 MCP Server](https://github.com/github/github-mcp-server)
4. [GitHub MCP Remote Server 配置](https://github.com/github/github-mcp-server/blob/main/docs/remote-server.md)

> 整理时间：2026-10-20。权限名称和 API 支持情况会更新，实际使用时请以目标 GitHub REST API 端点文档为准。
