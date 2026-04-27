# Skill 深度分析：ubiquitous-language

> 来源：[mattpocock/skills](https://github.com/mattpocock/skills) — `ubiquitous-language`
> 分析日期：2026-04-28

---

## 一、Skill 的作用和核心功能

### 1.1 解决的问题

在 DDD（领域驱动设计）实践中，开发者和领域专家之间的对话经常出现**术语混乱**的问题：

- 同一个词在不同人口中指代不同概念（歧义）
- 不同词被用来描述同一个概念（同义词）
- 术语定义模糊、被过度使用（语义过载）

这类问题如果不在早期解决，后续代码和沟通都会充满误解。`ubiquitous-language` skill 正是为解决这个问题而设计。

### 1.2 核心功能

| 功能 | 说明 |
|------|------|
| **对话扫描** | 从当前对话中提取领域相关的名词、动词和概念 |
| **歧义检测** | 识别同义词、近义词、模糊词使用问题 |
| **术语表生成** | 生成结构化术语表，附带定义和建议的规范术语 |
| **冲突标记** | 显式标记术语使用中的歧义和冲突，给出明确建议 |
| **示例对话** | 生成开发者与领域专家的模拟对话，展示术语在实际场景中的使用 |
| **关系建模** | 用自然语言表达概念之间的基数关系（1:1、1:N 等） |
| **增量更新** | 多次调用时能读取已有文件并增量更新，而非每次重写 |

### 1.3 输出文件

输出为 `UBIQUITOUS_LANGUAGE.md`，保存在工作目录中，包含：

1. **术语表**（分组的表格）
2. **关系描述**（基数关系）
3. **示例对话**（Dev 与 Domain Expert 的模拟对话）
4. **标记的歧义**（Flagged ambiguities）

### 1.4 技术细节

- `disable-model-invocation: true` — 该 skill 禁用模型自动调用，说明它被设计为**由 Agent 显式调用**，而非由 AI 自动触发。这是一种有意的设计决策。
- 输出的格式非常结构化，有明确的模板约束，减少了输出的随意性。

---

## 二、写得好的地方（设计亮点、写作技巧）

### 2.1 设计亮点

#### 亮点 1：精确的触发条件（description 设计）

```yaml
name: ubiquitous-language
description: Extract a DDD-style ubiquitous language glossary from the current 
  conversation, flagging ambiguities and proposing canonical terms. 
  Saves to UBIQUITOUS_LANGUAGE.md. 
  Use when user wants to define domain terms, build a glossary, 
  harden terminology, create a ubiquitous language, 
  or mentions "domain model" or "DDD".
```

描述写得非常精准：
- 说明了**做什么**（提取术语表、标记歧义、提出规范术语）
- 说明了**输出是什么**（保存到 `UBIQUITOUS_LANGUAGE.md`）
- 列出了**触发场景**（定义领域术语、建立词汇表、DDD 相关）
- 包含了**关键词触发器**（"domain model"、"DDD"）

这种写法让 Agent 能清晰地判断什么时候该调用这个 skill。

#### 亮点 2：结构化的输出模板

skill 中提供了一个**完整的 Markdown 模板**，包含：

- 分组术语表（多个表格，按生命周期/人物等分组）
- 关系描述（用自然语言表达基数关系）
- 示例对话（Dev 与 Domain Expert 的格式）
- 歧义标记（明确的冲突说明）

这个模板的价值在于：**约束了输出格式的下限**，即使 AI 水平一般，输出也不会太差。

#### 亮点 3：「做决定」而非「给选项」

规则明确说：

> **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others as aliases to avoid.

这是一种**强制做决定**的设计。AI 在处理同义词时不能给用户列出三个选项然后问「你想选哪个」，而是必须选一个，并说明为什么不选其他的。这让输出更有用，也更符合 skill 作为「执行者」而非「顾问」的定位。

#### 亮点 4：明确排除不相关的内容

规则中写道：

> Skip the names of modules or classes unless they have meaning in the domain language.
> Skip generic programming concepts (array, function, endpoint) unless they have domain-specific meaning.

这种**负向约束**非常重要。它告诉 AI：
- 不要把技术实现细节当领域术语
- 不要把通用编程概念当作领域概念

这防止了输出变得臃肿且失去重点。

#### 亮点 5：增量更新机制（Re-running）

> When invoked again in the same conversation:
> 1. Read the existing `UBIQUITOUS_LANGUAGE.md`
> 2. Incorporate any new terms from subsequent discussion
> 3. Update definitions if understanding has evolved
> 4. Re-flag any new ambiguities
> 5. Rewrite the example dialogue to incorporate new terms

这是一个很实用的设计。术语表不是一次性生成的，而是随着对话演进逐步完善的。这模拟了真实项目中术语共识逐渐形成的过程。

#### 亮点 6：示例对话的设计

```md
> **Dev:** "When a **Customer** places an **Order**, do we create the **Invoice** immediately?"
> **Domain expert:** "No — an **Invoice** is only generated once a **Fulfillment** is confirmed..."
```

示例对话有以下几个特点：
- 格式统一：**Dev:** 和 **Domain expert:** 交替
- 术语加粗：让术语在上下文中突出显示
- 揭示边界：对话明确展示了 Invoice 的生命周期与 Order 生命周期是不同的，这是核心领域知识
- 长度适中：3-5 个回合，不冗长

这种示例对话的价值在于：它本身就是一个**领域知识验证工具**，如果示例对话写不出来或写出来不自然，说明术语定义还有问题。

---

### 2.2 写作技巧

#### 技巧 1：规则采用「主动词 + 要求」的结构

每个规则都以动词开头，明确说明**做什么**：

- Be opinionated.
- Flag conflicts explicitly.
- Only include terms relevant for domain experts.
- Keep definitions tight.
- Show relationships.
- Write an example dialogue.

这种写法让规则读起来像**指令清单**，而不是「建议」。

#### 技巧 2：「定义什么是什么」而非「描述功能」

> Keep definitions tight. One sentence max. Define what it IS, not what it does.

这条规则非常关键。它防止了定义变成「功能描述」，而是回到**概念本质**。比如：

- ❌ "Invoice is the thing we send to customers to request payment"（描述功能）
- ✅ "Invoice is a request for payment sent to a customer after delivery"（定义本质）

#### 技巧 3：表格结构设计合理

术语表的列设计：

| 列名 | 作用 |
|------|------|
| Term | 规范术语名，加粗 |
| Definition | 一句话定义 |
| Aliases to avoid | 明确列出要避免的同义词 |

第三列「Aliases to avoid」设计得很巧妙——它不是简单列出同义词，而是引导使用者**主动避免**这些词，从而减少团队内的术语混乱。

#### 技巧 4：分组的灵活性

> Group terms into multiple tables when natural clusters emerge (e.g. by subdomain, lifecycle, or actor). Each group gets its own heading and table. If all terms belong to a single cohesive domain, one table is fine — don't force groupings.

这里加了一个明智的兜底规则：**不要强制分组**。如果领域本身是连贯的，单个表格就够了。这防止了为了分组而分组，导致结构变得人为复杂。

---

## 三、为我们构建 Skill 能带来的提示/借鉴

### 3.1 Skill 设计层面的借鉴

#### 借鉴 1：description 要写得像「触发器+承诺」

description 应该包含：
- **触发条件**：用户说了什么/场景是什么时会调用
- **交付承诺**：调用后会生成什么、输出到哪里

当前的 `ubiquitous-language` description 做到了这一点。我们设计新 skill 时也应该遵循这个模式。

#### 借鉴 2：提供完整的输出模板

不要只说「输出格式要清晰」，而是直接给出**可用的 Markdown 模板**。这样：
- AI 输出的一致性更高
- 用户能直接使用或在此基础上修改
- 减少了歧义和协商成本

#### 借鉴 3：用 `disable-model-invocation: true` 控制触发方式

对于某些 skill，如果设计为由 Agent 主动调用而非 AI 自动判断，应该设置 `disable-model-invocation: true`。这防止了 AI 在不恰当的时机调用 skill，也明确了**调用权在 Agent/用户**这一设计意图。

#### 借鉴 4：规则要「可执行」，不要模糊

❌ 模糊规则： "Try to be consistent with terminology"  
✅ 可执行规则："Be opinionated. Pick the best term and list others as aliases."

可执行的规则让 AI 的输出更可靠，也更容易评估质量。

### 3.2 内容写作层面的借鉴

#### 借鉴 5：用表格组织结构化信息

当信息有明确的字段和类型时，表格比段落更清晰。术语表的关系用表格呈现，一目了然。

#### 借鉴 6：给示例对话加上「验证功能」

示例对话不只是装饰——它实际上验证了术语定义是否足够清晰：如果 AI 写不出自然的对话，说明术语之间的边界还不清楚。这个思路可以迁移到其他 skill 中：让输出本身成为一个**自验证工具**。

#### 借鉴 7：增量更新比一次性输出更实用

很多 skill 都有「会话中的多次调用」场景，提前设计好增量更新机制比每次完全重写更有价值。我们设计类似 skill 时应该考虑：
- 是否有持久化文件？
- 再次调用时是否需要读取已有内容？
- 如何合并新内容？

#### 借鉴 8：明确「不该做什么」和「该做什么」同样重要

规则中明确排除模块名、通用编程概念等内容，这是负向约束。设计 skill 时，除了告诉 AI「做什么」，也要告诉它**不做什么**，这样能显著减少输出中的噪音。

### 3.3 通用启发

| 启发 | 应用场景 |
|------|----------|
| 触发条件要具体（DDD/domain model） | 所有 skill 的 description 设计 |
| 输出模板要完整且可直接使用 | 涉及文件生成的 skill |
| 强制做决定，避免给选项 | 需要输出确定性结果的 skill |
| 增量更新机制 | 有持久化输出的 skill |
| 示例对话作为验证工具 | 涉及术语、规则、流程定义的 skill |
| 负向约束同样重要 | 所有 skill 的规则设计 |

---

## 四、总体评价

### 优点

1. **问题定向**：直接解决 DDD 实践中真实的痛点——术语混乱
2. **结构清晰**：模板+规则双重约束，输出质量有保障
3. **可执行性强**：规则明确到可以直接按步骤执行
4. **设计周全**：增量更新、触发条件控制、输出格式约束都有考虑
5. **示例对话设计精妙**：不仅展示术语，还起到了验证和教学的作用

### 可改进之处

1. **没有明确处理「术语冲突无法调和」的情况**：如果对话中两个概念完全无法统一，skill 是否应该报错或给出警告？
2. **缺少验收标准**：如何判断生成的术语表「足够好」？没有明确的评估维度。
3. **示例对话的生成没有给出具体指导**：虽然要求 3-5 个 exchanges，但没有说明如何让对话「自然且有信息量」，新手可能写出空洞的对话。

---

## 五、结论

`ubiquitous-language` 是一个**高质量的参考 skill**。它在问题定义、触发设计、输出约束、规则表述等方面都展现出了良好的设计品味。对于我们构建自己的 skill，特别是涉及**结构化输出、文件生成、领域知识提取**的场景，这个 skill 提供了可以直接借鉴的模式和思路。

最值得借鉴的核心设计哲学是：**让 skill 成为能做决定的执行者，而不是给用户留一堆选项的顾问。**