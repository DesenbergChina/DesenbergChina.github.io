---
layout: single
title: "软件工程中的测试与测评：从单元测试到 Agent / RAG Eval 的完整梳理"
slug: "software-testing-and-evaluation-guide"
excerpt: "系统梳理软件工程中的单元测试、集成测试、系统测试、端到端测试、验收测试、冒烟测试、回归测试，以及脚本化评测、AI/LLM/RAG/Agent Eval 的概念、边界和使用场景。"
categories: 技术 软件工程 测试
tags: [软件工程, 软件测试, Unit Test, Integration Test, E2E, Smoke Test, Regression Test, Eval, RAG, Agent, LLM]
---

## 前言

在软件项目中，经常会看到这些词：

- 单元测试（Unit Test）
- 集成测试（Integration Test）
- 系统测试（System Test）
- 端到端测试（End-to-End Test, E2E）
- 验收测试（Acceptance Test）
- 冒烟测试（Smoke Test）
- 回归测试（Regression Test）
- 脚本评测（Scripted Evaluation）
- Benchmark / Eval
- Agent / RAG / LLM 评测

这些概念看起来都在做同一件事：**给系统一个输入，看输出对不对**。

但在软件工程中，它们实际上回答的是不同的问题。

最重要的一条原则是：

> **测试的分类应该看“测试对象、测试边界和测试目的”，而不是看测试代码写成了什么形式。**

一个 Python 脚本既可以执行单元测试，也可以执行集成测试、端到端测试，甚至可以执行 LLM 的自动评测。

本文从传统软件工程测试体系出发，再扩展到目前常见的 RAG、Agent 和 LLM Evaluation，希望建立一套统一的理解框架。

---

## 1. Testing 和 Evaluation 有什么区别？

两者有重叠，但关注点不同。

### 1.1 Testing：软件是否“正确工作”

软件测试通常关注：

> 在给定条件下，软件行为是否符合明确的需求、规格或预期结果？

例如：

~~~python
def add(a, b):
    return a + b

assert add(1, 2) == 3
~~~

这里的判断非常明确：

~~~text
输入：1, 2
预期：3
实际：3
结果：PASS
~~~

因此传统软件测试通常具有较强的确定性。

### 1.2 Evaluation：系统表现“有多好”

Evaluation 更强调：

> 系统在一组任务、数据或指标上的整体表现如何？

例如对一个 RAG 系统提出 100 个问题：

~~~text
答案正确率：87%
引用命中率：92%
检索 Recall@5：95%
平均响应时间：1.8 s
~~~

这不是简单判断“程序有没有运行”，而是在衡量：

~~~text
准确性
稳定性
质量
性能
鲁棒性
成本
用户体验
~~~

可以粗略理解为：

~~~text
Testing
→ 更关注：对不对、有没有坏

Evaluation
→ 更关注：整体表现怎么样、有多好
~~~

一个成熟系统通常同时需要：

~~~text
Software Testing
+
System Evaluation
~~~

---

## 2. 软件测试常见的分类维度

软件测试没有唯一的分类方式。

### 按测试层级

~~~text
Unit Test
Integration Test
System Test
E2E Test
Acceptance Test
~~~

### 按测试目的

~~~text
Smoke Test
Regression Test
Performance Test
Security Test
Compatibility Test
~~~

### 按是否运行程序

~~~text
Static Testing
Dynamic Testing
~~~

### 按是否了解内部实现

~~~text
Black-box Testing
White-box Testing
Gray-box Testing
~~~

这里最容易混淆的是：

> **Unit Test / Integration Test 描述的是测试层级，而 Smoke Test / Regression Test 更多描述测试目的。**

因此一个测试完全可能同时属于：

~~~text
Integration Test + Regression Test
~~~

或者：

~~~text
E2E Test + Smoke Test
~~~

---

## 3. 单元测试 Unit Test

### 3.1 定义

单元测试用于验证：

> 软件中一个相对独立、可测试的最小功能单元是否正确工作。

这个“单元”通常是：

~~~text
函数
方法
类
模块中的某一段独立逻辑
~~~

例如：

~~~python
def normalize_query(query):
    return query.strip().lower()

def test_normalize_query():
    assert normalize_query("  Hello  ") == "hello"
~~~

这里测试的问题非常局部：

> normalize_query() 这个函数本身写得对不对？

### 3.2 典型特点

单元测试通常具有：

~~~text
范围小
执行快
结果稳定
容易定位错误
尽量隔离外部依赖
~~~

理想情况下，不应依赖真实的：

~~~text
数据库
网络
第三方 API
LLM
远程文件服务器
~~~

否则测试可能变慢、不稳定，而且失败时难以判断究竟是代码问题还是外部服务问题。

### 3.3 Mock、Stub 和 Fake

为了隔离依赖，经常使用 Test Double。

Stub：返回事先准备好的结果。

~~~python
class StubRetriever:
    def search(self, query):
        return ["固定文档"]
~~~

Mock：除了提供返回值，还可以检查是否被调用、调用次数以及传入参数。

Fake：提供一个简化但真正可工作的替代实现，例如：

~~~text
真实数据库 → 内存数据库
真实对象存储 → 临时目录
~~~

Test Double 的目标不是模拟得越真实越好，而是：

> **控制测试环境，让测试只关注当前代码单元。**

---

## 4. 集成测试 Integration Test

集成测试关注：

> 两个或多个模块组合后，接口和交互是否正确。

例如 RAG 系统：

~~~text
Document Loader
      ↓
Embedding
      ↓
Vector Store
      ↓
Retriever
~~~

如果测试：

~~~text
文档入库
→ 真实写入测试向量库
→ 发起检索
→ 验证是否找到目标文档
~~~

这已经不再是纯单元测试，而更符合 Integration Test。

集成测试主要发现：

~~~text
字段名不一致
JSON Schema 不一致
数据库事务问题
接口版本不匹配
时间格式不一致
状态传递错误
参数单位错误
连接配置错误
~~~

可以简单记忆：

~~~text
Unit Test
→ 验证组件内部

Integration Test
→ 验证组件之间
~~~

---

## 5. 系统测试 System Test

系统测试关注：

> 整个软件系统是否满足设计和需求。

例如一个知识库问答系统：

~~~text
上传文档
→ 文档解析
→ 分块
→ Embedding
→ 向量数据库
→ 检索
→ LLM
→ 返回答案和引用
~~~

如果完整系统已经部署起来，从外部接口调用并验证：

~~~text
HTTP 状态码
答案结构
引用结构
错误码
权限控制
~~~

那么通常属于系统测试。

它测试的是：

> **完整系统，而不是某一个内部模块。**

---

## 6. 端到端测试 E2E Test

E2E 的核心思想是：

> 从用户入口一直测试到系统最末端，再返回最终结果。

例如：

~~~text
用户在网页上传 PDF
        ↓
后端接收文件
        ↓
数据库
        ↓
向量检索
        ↓
LLM
        ↓
网页显示答案
~~~

如果测试工具真正模拟：

~~~text
打开页面
点击上传
输入问题
点击发送
检查页面答案
~~~

就是典型 E2E。

它最接近真实用户场景，但通常：

~~~text
执行慢
环境复杂
失败定位困难
维护成本高
容易受到网络和外部服务影响
~~~

因此通常只保留关键业务路径的 E2E 测试。

---

## 7. 验收测试 Acceptance Test

验收测试回答：

> 系统是否满足业务方、用户或合同规定的验收条件？

例如需求规定：

~~~text
用户上传 PDF 后，
必须可以针对 PDF 内容进行问答，
回答必须返回引用来源。
~~~

验收测试更关注：

~~~text
业务需求
用户需求
合同要求
产品需求
~~~

而不是内部代码实现。

---

## 8. Smoke Test：冒烟测试

Smoke Test 用于快速确认：

> 一个构建版本最基本、最关键的功能是否能够运行。

它不追求全面，只检查：

~~~text
系统能不能启动
数据库能不能连接
核心 API 能不能响应
关键业务链路能不能走通
~~~

例如 Agent：

~~~text
Agent 启动
→ Tool Router 启动
→ Trace 创建
→ Budget 初始化
→ 返回 Response
~~~

如果这些都正常，至少说明核心链路没有直接坏掉。

### Offline Smoke

对于依赖真实 LLM 或第三方 API 的 Agent，可以关闭真实调用，使用 Fake / Stub：

~~~text
用户请求
  ↓
Agent
  ↓
Fake LLM
  ↓
Tool Router
  ↓
Budget
  ↓
Trace
  ↓
Fallback
~~~

它可以证明：

~~~text
Agent 没有崩溃
Trace 链路正常
Budget 正常
异常降级正常
Tool 路由基本正常
~~~

但不能证明：

~~~text
真实模型回答准确
真实模型推理合理
Tool 选择质量高
答案事实正确
RAG 检索质量高
~~~

因此：

> **Smoke Test 证明“能跑”，不等于证明“跑得好”。**

---

## 9. Regression Test：回归测试

Regression Test 的核心问题是：

> 修改代码以后，原来正常的功能有没有被意外破坏？

例如之前修复过“空 query 导致服务崩溃”，就应该增加：

~~~python
def test_empty_query_should_not_crash():
    result = ask("")
    assert result.status == "invalid_input"
~~~

以后这个测试一直保留。

工程中一个非常重要的习惯是：

> **每修复一个 Bug，尽量增加一个能够复现这个 Bug 的回归测试。**

---

## 10. Sanity Test 和 Smoke Test

两者经常混用。

### Smoke Test

范围较广、深度较浅：

~~~text
登录能不能用？
查询能不能用？
上传能不能用？
~~~

### Sanity Test

范围较窄，针对某次修改快速确认。

例如只修改了文档上传模块，可以重点检查：

~~~text
PDF 上传
DOCX 上传
非法文件上传
超大文件上传
~~~

简单记忆：

~~~text
Smoke：
整个系统大概还能不能跑？

Sanity：
这次修改的地方大概正常吗？
~~~

---

## 11. 功能测试和非功能测试

### Functional Testing

验证软件有没有完成应该完成的功能：

~~~text
登录
注册
文件上传
搜索
删除
支付
Agent Tool 调用
~~~

### Non-functional Testing

关注系统工作得怎么样。

常见类型包括：

**Performance Testing**

~~~text
延迟
吞吐量
并发量
资源使用
~~~

**Load Testing**

验证预期负载下是否稳定。

**Stress Testing**

不断增加压力，观察系统什么时候开始失败、如何失败以及能否恢复。

**Security Testing**

例如：

~~~text
认证
授权
SQL Injection
XSS
SSRF
越权访问
敏感信息泄露
Prompt Injection
~~~

**Compatibility Testing**

例如：

~~~text
Windows / Linux / macOS
Chrome / Edge / Firefox
不同 API 版本
不同数据库版本
~~~

---

## 12. 黑盒、白盒和灰盒测试

### Black-box Testing

不知道内部实现，只关注：

~~~text
输入
→
输出
~~~

例如调用登录 API，然后检查 HTTP 状态码和 Token。

### White-box Testing

测试者了解内部实现，会针对：

~~~text
if 分支
循环
异常路径
内部状态
函数调用
~~~

设计测试。单元测试通常具有较强的白盒属性。

### Gray-box Testing

介于两者之间：知道部分内部结构，但主要从外部接口验证系统。

---

## 13. Static Testing 和 Dynamic Testing

### Static Testing

不运行程序，例如：

~~~text
Code Review
静态代码分析
类型检查
Lint
SAST
~~~

常见工具：

~~~text
Ruff
ESLint
mypy
SonarQube
CodeQL
~~~

### Dynamic Testing

真正运行程序并观察行为，例如：

~~~text
pytest
JUnit
Playwright
API Test
Load Test
~~~

---

## 14. 什么是 Scripted Evaluation？

这是 AI 项目里很常见的说法，但需要注意：

> **Scripted Evaluation 并不像 Unit Test、Integration Test 那样是严格的测试层级。**

“脚本”只是表示：

~~~text
评测过程由程序自动执行
~~~

例如准备：

~~~python
cases = [
    {
        "question": "公司的退款期限是多少？",
        "expected_status": "success",
        "expected_keywords": ["30天", "退款"]
    }
]
~~~

评测脚本：

~~~python
for case in cases:
    result = ask(case["question"])

    assert result.status == case["expected_status"]

    assert any(
        keyword in result.answer
        for keyword in case["expected_keywords"]
    )
~~~

流程：

~~~text
预设测试集
      ↓
调用系统
      ↓
获得答案
      ↓
自动评分
      ↓
统计结果
~~~

例如：

~~~text
总问题数：100
成功：94
失败：6

Status Pass Rate：94%
Answer Keyword Match：88%
Citation Match：91%
~~~

这就是典型的 Scripted Evaluation。

---

## 15. 为什么 Scripted Evaluation 不等于 Unit Test？

假设完整系统是：

~~~text
Question
   ↓
API
   ↓
Agent
   ↓
Retriever
   ↓
Vector DB
   ↓
LLM
   ↓
Tool
   ↓
Answer
~~~

脚本向整个系统提出：

~~~text
“PPO 的 clipped objective 是什么？”
~~~

然后检查答案中有没有：

~~~text
clip
ratio
policy
~~~

这不是在测试某个函数，而是在评价：

> **整套系统面对真实任务时表现如何。**

因此它更接近：

~~~text
System Evaluation
E2E Evaluation
AI Eval
Benchmark
~~~

---

## 16. 为什么 AI / LLM 系统特别需要 Evaluation？

传统程序经常可以写出：

~~~text
输入 A
必须得到输出 B
~~~

但 LLM 输出具有：

~~~text
随机性
开放性
语义等价
多种正确表达
~~~

例如问“什么是动态规划？”，下面这些表达都可能正确：

~~~text
通过保存子问题结果避免重复计算。

将问题拆成重叠子问题，并利用状态转移求解。

使用状态表示和转移方程解决具有最优子结构的问题。
~~~

如果只使用精确字符串相等，很难合理判断质量。

所以 AI 系统需要专门的 Evaluation。

---

## 17. RAG 常见的评测对象

RAG 可以拆成：

~~~text
Query
  ↓
Retrieval
  ↓
Context
  ↓
Generation
  ↓
Answer
~~~

因此不能只看最终答案。

### 检索评测

常见指标包括：

~~~text
Recall@K
Precision@K
MRR
~~~

Recall@K 关注正确文档是否出现在前 K 个结果中。

Precision@K 关注前 K 个结果中真正相关的比例。

MRR 关注正确结果第一次出现的位置是否足够靠前。

### 生成结果评测

可以检查：

~~~text
Correctness
Relevance
Completeness
Faithfulness
~~~

其中 Faithfulness 很重要：

> 答案是否真正由检索上下文支持，而不是模型自己编造。

### 引用评测

应该区分：

~~~text
是否存在 Citation
Citation 是否指向正确文档
引用内容是否真正支持答案
~~~

所以“答案里有引用”不能自动证明引用正确。

---

## 18. Agent 评测为什么更复杂？

Agent 往往包含：

~~~text
LLM
Tool Calling
Planning
Memory
State
Retry
Budget
Trace
Fallback
~~~

因此不能只看最终答案，还应该评测执行过程。

常见指标：

~~~text
Tool Selection Accuracy
Tool Argument Accuracy
Task Success Rate
Step Count
Token Cost
Latency
Retry Count
Budget Violation
Safety Violation
~~~

例如用户问实时天气，正确行为可能要求调用 Weather Tool。

如果 Agent 直接凭模型记忆回答，即使结果碰巧正确，也可能属于执行策略错误。

---

## 19. Offline Eval 和 Online Eval

### Offline Evaluation

使用固定数据集离线运行。

例如：

~~~text
100 个固定问题
100 个期望答案
100 个期望 Tool
~~~

优点：

~~~text
可重复
便于版本对比
适合 CI
成本可控
~~~

### Online Evaluation

系统真正上线以后，从实际用户流量观察：

~~~text
任务成功率
用户反馈
重新提问率
人工接管率
错误率
延迟
成本
~~~

可以理解为：

~~~text
Offline Eval
→ 适合开发阶段和回归

Online Eval
→ 适合验证真实用户环境
~~~

---

## 20. Golden Dataset：评测集

AI 系统通常需要维护一个稳定的 Golden Dataset，也叫：

~~~text
Golden Set
Eval Dataset
Benchmark Dataset
~~~

例如：

~~~yaml
- question: "项目支持哪些文件格式？"
  expected_status: success
  expected_keywords:
    - PDF
    - DOCX
  expected_source:
    - docs/upload.md
~~~

数据集应该逐渐积累：

~~~text
正常案例
边界案例
历史 Bug
高风险案例
困难案例
异常案例
~~~

它和传统软件中的 Regression Test Suite 作用非常相似。

---

## 21. Keyword Match 的优缺点

最简单的自动评测方式之一是 Expected Keywords。

例如答案中必须出现：

~~~text
Trace
Budget
Fallback
~~~

优点：

~~~text
简单
便宜
确定性强
适合 CI
容易理解
~~~

缺点：

~~~text
不能判断完整语义
容易误判
可能被关键词堆砌“骗过”
无法评价完整性
~~~

例如：

~~~text
PPO 不使用 clip。
~~~

虽然包含 PPO 和 clip，但结论可能是错误的。

因此 Keyword Match 更适合作为：

> **低成本的基础检查，而不是最终质量判断。**

---

## 22. LLM-as-a-Judge 和 Human Evaluation

开放式回答还可以让另一个模型担任 Judge：

~~~text
Question
Expected Answer
Actual Answer
      ↓
Judge LLM
      ↓
Score
~~~

例如：

~~~text
Correctness：4/5
Relevance：5/5
Faithfulness：3/5
~~~

优点是可以评价语义，缺点是 Judge 自己也可能出错，而且评分存在模型偏置和成本。

因此重要项目通常组合：

~~~text
规则评测
+
LLM Judge
+
人工抽样
~~~

人工评测适合：

~~~text
构建 Golden Dataset
校验自动指标
发布前抽样
高风险案例检查
~~~

---

## 23. Code Coverage 是什么？

Coverage 用来衡量测试执行到了多少代码。

常见指标：

~~~text
Line Coverage
Branch Coverage
Function Coverage
~~~

但是：

> **Coverage 高不等于测试质量高。**

100% Coverage 仍然可能存在大量 Bug。

Coverage 更适合作为“哪里可能没测到”的提示指标，而不是软件质量分数。

---

## 24. 什么是 Flaky Test？

Flaky Test 指：

> 代码没有变化，但同一个测试有时通过、有时失败。

常见原因：

~~~text
网络
时间
线程竞争
随机数
真实 API
测试顺序
共享数据库状态
异步任务
~~~

Flaky Test 会严重降低测试体系的可信度。

优秀测试应该尽量做到：

~~~text
Deterministic
Repeatable
Isolated
Fast
~~~

---

## 25. 测试金字塔 Test Pyramid

经典策略通常强调：

~~~text
              E2E
             /   \
          System
         /        \
     Integration
    /              \
   Unit Unit Unit Unit
~~~

核心思想不是严格比例，而是：

> 越靠近底层的测试通常越多，越靠近完整系统的测试通常越少。

原因：

| 测试 | 速度 | 成本 | 定位问题 |
|---|---:|---:|---:|
| Unit | 快 | 低 | 容易 |
| Integration | 中 | 中 | 中等 |
| E2E | 慢 | 高 | 困难 |

因此常见组合是：

~~~text
大量 Unit Tests
+
适量 Integration Tests
+
少量关键 E2E Tests
~~~

AI 系统还需要额外维护：

~~~text
Eval Suite
~~~

---

## 26. 在 CI/CD 中如何组织？

可以采用：

~~~text
提交代码
   ↓
Lint / Static Analysis
   ↓
Unit Tests
   ↓
Integration Tests
   ↓
Smoke Tests
   ↓
Build
   ↓
Eval Suite
   ↓
Deploy
   ↓
E2E / Online Monitoring
~~~

如果真实 LLM 调用成本较高，可以分层执行：

~~~text
Pull Request：
Unit + Integration + Offline Smoke

main：
增加小规模 Eval

Release：
完整 Eval Suite
~~~

---

## 27. 一个 Agent / RAG 项目的完整测试体系

假设项目包含：

~~~text
文档入库
检索
问答
Agent Tool
Trace
Budget
LLM
~~~

### Unit Test

测试：

~~~text
文档解析函数
Chunk 切分逻辑
Query Normalize
Tool 参数解析
Budget 计算
Trace 数据结构
异常转换
~~~

### Integration Test

测试：

~~~text
文档入库 + 数据库
Embedding + Vector DB
Retriever + Vector DB
Agent + Tool Registry
Trace + Agent Runtime
~~~

### E2E Test

测试：

~~~text
上传文档
→ 提问
→ 检索
→ LLM
→ 返回答案和引用
~~~

### Smoke Test

测试：

~~~text
服务能启动
Agent 能执行
Trace 能建立
Budget 能工作
Fallback 能触发
~~~

### Scripted Eval

预设：

~~~text
问题
期望状态
答案关键词
引用关键词
预期 Tool
~~~

批量运行后统计：

~~~text
Task Success Rate
Keyword Match
Citation Match
Tool Accuracy
~~~

### Real-model Eval

打开真实模型后进一步验证：

~~~text
答案质量
推理质量
Tool Selection
Citation Faithfulness
复杂任务成功率
~~~

---

## 28. 如何判断一个测试属于哪一类？

遇到一个测试时，可以依次问四个问题：

### ① 测试对象是什么？

~~~text
单个函数？
几个模块？
整个服务？
完整用户流程？
~~~

### ② 外部依赖是否真实参与？

~~~text
数据库？
网络？
LLM？
第三方 API？
~~~

### ③ 测试目标是什么？

~~~text
验证代码逻辑？
验证模块接口？
验证业务流程？
验证系统质量？
~~~

### ④ 判定标准是什么？

~~~text
精确值？
状态码？
业务规则？
关键词？
评分指标？
人工评价？
~~~

例如：

~~~text
测试 calculate_budget()
→ Unit Test
~~~

而：

~~~text
调用完整 Agent，
检查 Trace、Tool、答案和 Citation
→ System / E2E Test + Evaluation
~~~

---

## 29. 最常见的概念误区

### 误区 1：只要用 pytest 就是单元测试

错误。

pytest 只是测试框架，它可以运行：

~~~text
Unit Test
Integration Test
API Test
E2E Test
~~~

### 误区 2：只要写成脚本就是“脚本测试”

错误。

脚本只是实现形式，真正分类时仍然要看测试对象、范围和目的。

### 误区 3：Smoke Test 通过说明系统质量没问题

错误。

Smoke 只能说明：

~~~text
基本链路能跑
~~~

不能证明：

~~~text
结果正确
性能优秀
模型回答可靠
~~~

### 误区 4：关键词匹配可以证明 LLM 回答正确

不能。

它只能证明输出包含某些字符串，不能完整证明语义正确。

### 误区 5：Coverage 越高，软件质量一定越高

Coverage 只说明代码是否被执行过，不能证明断言是否有效。

---

## 30. 最后建立一套统一理解框架

可以把整个体系理解为：

~~~text
                 软件质量保障
                       │
       ┌───────────────┴───────────────┐
       │                               │
   Software Testing                Evaluation
       │                               │
 ┌─────┼─────┐                  ┌──────┼──────┐
 │     │     │                  │      │      │
Unit  Integration  E2E        Rule   Metric   Human
~~~

传统软件工程主要关注：

~~~text
程序是否按照规格正确运行
~~~

AI 系统在此基础上还必须回答：

~~~text
答案质量怎么样？
检索质量怎么样？
Agent 决策怎么样？
引用是否可信？
成本和延迟怎么样？
~~~

所以现代 Agent / RAG 系统通常需要：

~~~text
Unit Test
+
Integration Test
+
E2E Test
+
Smoke Test
+
Regression Test
+
Eval Suite
~~~

而不是只依赖其中一种。

---

## 总结

如果只记住几个核心概念，可以记下面这些：

~~~text
Unit Test
→ 一个代码单元是否正确？

Integration Test
→ 多个组件组合是否正确？

System Test
→ 整个系统是否满足要求？

E2E Test
→ 从用户入口到最终结果是否跑通？

Acceptance Test
→ 是否满足业务验收条件？

Smoke Test
→ 最基本的核心链路还能不能跑？

Regression Test
→ 新修改有没有破坏原来的功能？

Scripted Evaluation
→ 用预设数据集批量运行系统并自动评分。

AI / LLM Eval
→ 系统在真实任务上的质量到底怎么样？
~~~

最关键的一点是：

> **测试层级描述“测哪里”，测试目的描述“为什么测”，评测指标描述“怎么判断表现”。**

把这三件事分开以后，大部分测试术语就不会再混乱了。
