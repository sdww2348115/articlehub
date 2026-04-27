# Matt Pocock TDD Skill 深度分析

## 1. Skill 的作用和核心功能

### 1.1 定位与目标场景

这是一个面向 AI Agent 的 **Test-Driven Development（TDD）实践指导 Skill**。它的触发条件非常明确：

- 用户想要用 TDD 方式构建功能或修复 bug
- 用户提到 "red-green-refactor" 这一 TDD 核心口诀
- 用户要求写集成测试（integration tests）
- 用户要求测试先行开发（test-first development）

它不是教你"什么是 TDD"的科普文，而是一份 **给 AI Agent 的操作手册**——告诉 AI 在 TDD 循环中每一步该做什么、怎么做、避免什么。

### 1.2 核心功能模块

该 Skill 围绕 TDD 的四个核心环节组织内容：

| 模块 | 内容概要 |
|------|----------|
| **Philosophy（理念）** | 区分好测试与坏测试的原则，强调行为验证而非实现细节 |
| **Anti-Pattern: Horizontal Slices（反模式）** | 批判"先写全部测试再写全部实现"的错误做法 |
| **Workflow（工作流）** | Planning → Tracer Bullet → Incremental Loop → Refactor 四步闭环 |
| **Checklist（检查清单）** | 每个循环结束时使用的五项核查表 |

### 1.3 依赖的外部文档

Skill 本身只提供框架和原则，细节分散在多个配套文档中：

- `tests.md` — 测试示例
- `mocking.md` — Mock 使用指南
- `deep-modules.md` — 深度模块设计
- `interface-design.md` — 可测试性接口设计
- `refactoring.md` — 重构候选识别

这种设计让主文档保持精简，细节按需查阅，符合 **SKILL.md 应该是"操作手册"而非"百科全书"** 的原则。

---

## 2. 写得好的地方（设计亮点、写作技巧）

### 2.1 精准的 AI 使用场景定位

Skill 的 `description` 字段写得极为精准，只用一句话就覆盖了所有触发场景：

```
"Use when user wants to build features or fix bugs using TDD, 
mentions 'red-green-refactor', wants integration tests, 
or asks for 'test-first development'."
```

这是给 AI 看的触发条件，不是给人类读的营销文案。每个关键词都对应一个明确的用户意图，没有废话。

### 2.2 理念层与操作层分离

文档在 **Philosophy** 部分花大量篇幅讲"为什么"（测试应验证行为而非实现），而在 **Workflow** 部分专注讲"怎么做"（一步测试、一步实现、再重构）。这种 **认知层（principle）与执行层（procedure）分离** 的结构，让 Skill 在不同使用阶段都能发挥作用：

- 开始时：理解核心理念
- 执行时：按工作流操作
- 回顾时：用 checklist 核查

### 2.3 强硬的反模式警示

"Anti-Pattern: Horizontal Slices" 是整篇文档中最有力的部分之一。它不仅告诉你"不应该怎么做"，还详细解释了**为什么**那种做法会产生糟糕的测试：

> "Tests written in bulk test _imagined_ behavior, not _actual_ behavior"

> "You outrun your headlights, committing to test structure before understanding the implementation"

这些论断配上可视化对比图（WRONG vs RIGHT），让反模式的危害一目了然。这是一种高效的**对比式写作**——用"反面案例 + 结果"加深印象。

### 2.4 术语精准且统一

TDD 领域有大量专有术语，文档对每个关键概念都有明确界定：

- **Tracer bullet**（示踪弹）：指第一个端到端贯通的测试，证明路径可行
- **Vertical slices**（纵向切片）：对比 Horizontal slices（横向切片），强调每次做一个完整行为
- **Integration-style tests**（集成风格测试）：区别于单元测试，强调通过公共接口验证

术语统一且在首次出现时明确解释，降低了理解门槛。

### 2.5 Planning 阶段的"确认用户"设计

在 Planning 阶段，Skill 明确要求 Agent **向用户确认**以下事项：

- 接口该怎么设计
- 哪些行为最需要测试
- 测试范围（不能测所有东西）

这是一个优秀设计：**Skill 不替用户做决定，而是引导 Agent 去问**。这避免了 AI 盲目扩展范围或假设错误需求。

### 2.6 五项 Checklist 简洁有力

每个循环结束时的 Checklist 精炼到只有五项，每项都是一个**可直接判断的陈述句**：

```
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only
[ ] Test would survive internal refactor
[ ] Code is minimal for this test
[ ] No speculative features added
```

没有歧义，Agent 可以直接对着检查，不需要额外解释。

### 2.7 强约束的时机规则

文档有一条铁律：

> **Never refactor while RED.** Get to GREEN first.

这一句话解决了 TDD 新手最常见的困惑——什么时候可以重构。把它作为显式规则而非默认假设，体现了对执行纪律的重视。

---

## 3. 为我们构建 Skill 能带来什么提示/借鉴

### 3.1 Skill 描述（description）应该怎么写

**借鉴**：description 是 AI 判断"该不该用这个 Skill"的首要依据。应该包含：

- 用户可能的原话（如 "red-green-refactor"）
- 明确的功能标签（如 "integration tests"、"test-first"）
- 避免模糊描述，确保 AI 能精准匹配

**反面教材**：不要写"这是一个关于 TDD 的 Skill，适合想学 TDD 的人"这种人类友好的营销文案，AI 需要的是关键词匹配。

### 3.2 原则与操作分离的结构

**借鉴**：当我们构建复杂 Skill 时，应该将"为什么做"（Philosophy/Principles）与"怎么做"（Workflow/Steps）分开。

这样做的好处是：
- 用户/AI 可以在不同阶段只读取需要的部分
- 原则部分更稳定，操作部分更容易迭代更新
- 文档长度可控，不会因为细节过多而显得冗长

### 3.3 外部文档的"配套引用"模式

**借鉴**：将细节内容拆到独立文档中，主 SKILL.md 只保留框架。这种模式的优点是：

- 主文档简洁，AI 快速判断是否适用
- 配套文档可以独立维护和扩展
- 引用关系清晰（`[tests.md](tests.md)`）

我们构建 Skill 时，可以考虑将"扩展阅读"和"详细示例"放到单独文件中，主文档保持精炼。

### 3.4 "向用户确认"作为 Skill 的内置约束

**借鉴**：Planning 阶段要求 Agent 向用户确认接口和行为优先级，这是一个很好的 **Human-in-the-loop** 设计。

我们构建面向 AI Agent 的 Skill 时，应该思考：
- 哪些决策应该由 AI 自己做？
- 哪些决策需要用户确认？
- 如何在 Skill 流程中显式嵌入"向用户确认"这一步？

### 3.5 可视化的对比呈现

**借鉴**：Horizontal vs Vertical 的对比图（WRONG/RIGHT）比纯文字描述有效得多。在技术文档中，**图表 > 表格 > 代码块 > 纯文字**。

我们写 Skill 时，应该多用：
- ASCII 图示展示流程
- 对比表格（Do vs Don't）
- 代码示例（正确 vs 错误）

### 3.6 约束规则应该简洁且绝对

**借鉴**：文档中 "Never refactor while RED" 是一条简洁、绝对、无需讨论的规则。好的 Skill 应该包含一些**不容妥协的底线规则**。

我们在构建 Skill 时，可以问自己：
- 这个领域有哪些绝对不应该做的事？
- 有哪些只有一种正确方式的决策？

将这些提炼为简洁的规则，比列出大量"可选建议"更有价值。

### 3.7 Checklist 作为质量门禁

**借鉴**：五项 Checklist 是每个 TDD 循环的出口检查，确保质量标准不被遗忘。

我们构建 Skill 时，可以为关键步骤配备简短的 Checklist：
- 步骤开始前的准备检查
- 步骤结束时的质量检查
- 整体流程的完成度确认

Checklist 的好处是：Agent 执行时不会遗漏关键验证点，用户检查 Agent 工作时也有据可依。

---

## 总结

| 维度 | 核心要点 |
|------|----------|
| **作用** | 给 AI Agent 的 TDD 操作手册，聚焦 red-green-refactor 循环 |
| **亮点** | 精准的触发条件、人机分离设计、强约束规则、可视化对比、简洁 Checklist |
| **借鉴价值** | description 写法、原则/操作分离、配套文档引用、向用户确认机制、约束规则简洁化、Checklist 质量门禁 |

这个 Skill 的成功之处在于：**它不试图教 TDD，而是教 AI 如何执行 TDD**。这个定位差异决定了它的写法——不是教科书，而是操作手册。
