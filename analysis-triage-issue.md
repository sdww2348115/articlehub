# Skill 深度分析报告：triage-issue

> 来源：mattpocock/skills
> 分析日期：2026-04-28

---

## 一、Skill 的作用和核心功能

### 1.1 定位概述

`triage-issue` 是一个**自动化问题分诊（Bug Triage）+ 修复规划**的 Skill。它的核心职责是：当用户报告一个 Bug 或问题时，Agent 自动完成从问题捕获、根因分析、到生成一份 **TDD 修复计划**的完整闭环，并以 GitHub Issue 的形式输出。

这本质上是一个**端到端的开发工作流自动化**——它不只是记录问题，而是将"调查问题"和"规划修复"合并为一个连贯的半自动流程。

### 1.2 核心功能拆解

| 阶段 | 步骤 | 具体做什么 |
|------|------|----------|
| **问题捕获** | Step 1 | 获取用户描述（最多只问一个问题） |
| **根因调查** | Step 2 | 通过 Explore 子 Agent 深挖代码库 |
| **方案确定** | Step 3 | 判断最小改动范围、影响模块、测试需求 |
| **修复规划** | Step 4 | 设计 RED-GREEN 循环的 TDD 修复路径 |
| **Issue 输出** | Step 5 | 用 `gh issue create` 生成带模板的 GitHub Issue |

### 1.3 关键设计决策

**最小交互原则**：只问一个问题，然后立即开始调查。这避免了传统对话式 Bug 报告中的来回拉扯。

**输出唯一性**：Issue 创建后不经过用户审核，直接生成并返回 URL。减少等待时间，符合"mostly hands-off"的设计哲学。

---

## 二、写得好在哪里

### 2.1 结构设计：五步流水线，职责清晰

```
Capture → Explore & Diagnose → Identify Fix → Design TDD → Create Issue
```

每一步都有明确的目标和边界，不重不漏。特别值得学习的是**第三步"Identify the fix approach"单独成步**——在盲目开始写测试之前，先让 Agent 思考"这个改动应该是什么粒度"，这是避免 TDD 沦为"为测试而测试"的关键。

### 2.2 TDD Fix Plan 的设计哲学

这是整个 Skill 最精彩的部分，体现在几个规则上：

**垂直切片原则**（One test at a time, vertical slices）：
> 禁止"先写完全部测试，再写全部代码"的横向模式。坚持每次只走完一个 RED-GREEN 循环。

这直接对应 Kent Beck 原著中的 TDD 节奏感。避免了测试和代码脱节的问题。

**Durability（耐久性）原则**：
> 禁止在 Issue 中写入具体的文件路径、行号、或实现细节。只描述行为、模块和契约。

这条规则极具洞察力。大多数 Bug Issue 在代码重构后就变成了废纸。而 `triage-issue` 要求的写法让 Issue 变成了一份**与实现解耦的规格说明**，即使代码被彻底重写，Issue 依然有效。

**可读性标准**：
> "A good suggestion reads like a spec; a bad one reads like a diff."

这句话一针见血。好的修复建议描述的是"期望什么行为"，坏的建议描述的是"改哪行代码"。Skill 用这个标准训练 Agent 的输出质量，非常实用。

### 2.3 Issue 模板的结构设计

```
## Problem        ← 现象（What happened）
## Root Cause Analysis ← 根因（Why it failed）  [禁写路径/行号]
## TDD Fix Plan   ← 修复路径（RED-GREEN cycles）
## Acceptance Criteria ← 验收标准
```

这个结构刻意将"根因"和"实现细节"分离。Root Cause Analysis 描述的是**因果逻辑**，而不是代码改动。TDD Fix Plan 描述的是**行为验证路径**，而不是 diff。

### 2.4 "Mostly hands-off" 的交互哲学

Skill 明确说：**minimize questions to the user**。只问一个问题，之后不再追问。这有几个好处：

1. **降低用户认知负担**：用户不需要反复回答细节
2. **避免无限提问循环**：很多 AI Agent 失败于过度追问
3. **强调行动导向**：调查是 Agent 的事，不是用户的事

### 2.5 写作技巧亮点

**使用粗体和列表强化层次感**：
```markdown
- **Where** the bug manifests
- **What** code path is involved
- **Why** it fails
- **What** related code exists
```
四个问题用 **Where/What/Why/What** 引导词形成记忆锚点，非常易读。

**对比式强调**：
> "A good suggestion reads like a spec; a bad one reads like a diff."

用一句话说清了高质量输出和低质量输出的区别，比长篇规则说明有效得多。

**示例驱动**：虽然 Skill 本身没有示例代码，但 RED-GREEN 循环的描述方式本身就是一种很好的示例——它告诉 Agent"这样写才对"。

---

## 三、为我们构建 Skill 的提示与借鉴

### 3.1 工作流型 Skill 的模板框架

`triage-issue` 是一个典型的工作流型 Skill，它的结构可以直接借鉴：

```
## Process
### 1. [阶段名]
[目标] + [具体操作] + [禁止做什么]

### 2. [阶段名]
...

### N. [阶段名]
[输出物格式/模板]
```

我们构建类似的工作流 Skill 时，可以：
- **每步明确输入和输出**：输入来自上一步，输出流向下一步
- **用禁止条款约束 Agent 行为**："Do NOT ask follow-up questions"、"Do NOT include specific file paths"
- **用输出模板固化格式**：减少输出不一致的问题

### 3.2 "行为描述优先于实现描述"的原则

这个 Skill 最值得借鉴的设计原则是：**始终描述行为，不描述实现**。

这对我们的 Skill 设计有直接启发：
- 我们的 Skill 描述应该是"做什么"而非"怎么做"
- 规则文档应该用"期望的输出质量标准"而非"具体的实现步骤"
- 测试 Skill 中的验证条件，应该是**可观测的行为**，而非内部状态

### 3.3 TDD Fix Plan 的输出格式可以迁移

RED-GREEN 循环的描述格式：

```
1. **RED**: Write a test that [describes expected behavior]
   **GREEN**: [Minimal change to make it pass]
```

这个格式非常清晰，可以迁移到我们的多种场景：
- **代码审查 Skill**：RED = 发现问题，GREEN = 修复建议
- **重构规划 Skill**：RED = 当前行为测试，GREEN = 目标实现
- **功能新增 Skill**：RED = 新功能规格测试，GREEN = 实现代码

### 3.4 "问一个问题，然后行动"模式

问题捕获阶段的处理方式：

```
最多问一个问题 → 立即开始调查
```

这是一个非常聪明的**交互降噪**设计。避免了 AI Agent 最常见的毛病：不断提问而不是产出。可以作为我们所有"调查型"Skill 的默认交互模式。

### 3.5 Issue 模板的可复用性

整个 Issue 模板的结构（Problem / Root Cause / Fix Plan / Acceptance Criteria）是一个**通用的技术文档结构**，适用于：

- Bug 报告
- 技术债清理
- 重构规划
- Feature 设计

我们可以将其提炼为一个**通用 Issue 模板 Skill**，让所有需要输出 Issue 的流程都遵循这个结构。

### 3.6 子 Agent 的使用

Step 2 明确要求使用 `Agent tool with subagent_type=Explore` 进行深度调查。这给我们的启示是：

> **复杂调查类任务应该通过子 Agent 分解**，而不是在一个 Agent 内部循环调用工具。

当我们构建类似"调查+分析+输出"复合型 Skill 时，可以预先设计好子 Agent 的类型和职责。

### 3.7 "Durability"意识——让输出更长寿

这个 Skill 有一个很高级的设计意识：**输出的内容应该在代码重构后依然有效**。

这对我们的 Skill 设计有重要提醒：
- 避免在 Skill 输出中引用具体实现细节（文件名、行号、函数名）
- 用**行为契约**和**模块关系**替代**代码位置**
- 定期回顾 Skill 输出的 Issue/文档，验证它们在代码变化后是否还有价值

---

## 四、总结

`triage-issue` 是一个**质量极高的工程实践类 Skill**，它的价值不仅在于功能本身，更在于它展示了一种**如何将工程方法论（TDD、根因分析）产品化、Skill 化**的路径。

其核心启示：

1. **工作流 Skill 要有清晰的分步和边界**，每步的输入输出必须明确
2. **用禁止条款来约束 Agent 行为**，比用正向描述更有效
3. **输出要可度量、可持久**——描述行为而非实现
4. **交互要最小化**，让 Agent 承担调查工作，用户只负责提供初始信号
5. **Issue/文档模板是 Skill 输出的骨架**，好的模板能倒逼 Agent 输出高质量内容

---

*分析完成。文档已保存至 `/home/admin/.openclaw/workspace/articlehub/analysis-triage-issue.md`*
