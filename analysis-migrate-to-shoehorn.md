# Skill 深度分析：migrate-to-shoehorn

> 来源：[mattpocock/skills](https://github.com/mattpocock/skills) 项目
> 分析日期：2026-04-28

---

## 一、Skill 的作用和核心功能

### 1.1 解决的问题域

这个 skill 解决的是一个非常具体的技术迁移问题：**将测试代码中的 TypeScript `as` 类型断言迁移到 `@total-typescript/shoehorn` 库提供的方式**。

它不是通用工具，而是一个垂直场景的"翻译官"——把用户在测试文件中滥用 `as` 的现状，引导到更规范的 `shoehorn` 用法上。

### 1.2 核心功能拆解

| 功能点 | 描述 |
|--------|------|
| **教育用户** | 解释为什么 `as` 在测试中是有问题的（训练肌肉记忆、类型安全、语义模糊） |
| **提供迁移模式** | 覆盖了 3 种最常见的 `as` 用法 → 对应的 shoehorn 函数映射 |
| **给出决策表** | 用一个简明的表格说清楚 `fromPartial()` / `fromAny()` / `fromExact()` 各自的适用场景 |
| **可执行的工作流** | 从收集需求到安装、搜索、替换、验证的完整步骤清单 |

### 1.3 触发条件（description）

```
Use when user mentions shoehorn, wants to replace `as` in tests, 
or needs partial test data.
```

触发条件非常具体且可识别，减少了误匹配的概率。相比泛泛的 "helps with TypeScript"，这个描述让 AI 在听到相关关键词时能精准激活。

---

## 二、写得好的地方

### 2.1 结构设计：从 Why 到 How 的自然引导

文档的开篇不是直接扔命令，而是先讲 **Why shoehorn?**。这是一个高明的认知顺序：

1. **先建立共识** — 读者认同 `as` 有问题，迁移才有动力
2. **再展示方案** — `shoehorn` 的三个函数是对症下药
3. **最后给执行步骤** — 有了动力，执行路径自然清晰

这种结构避免了一个常见错误：**假设用户已经知道自己需要这个工具**。实际上用户很可能只是模糊地感到"测试里类型断言用起来不舒服"，这时直接给 CLI 命令会让人困惑。

### 2.2 示例选择：真实感极强

看这段示例的复杂度：

```ts
type Request = {
  body: { id: string };
  headers: Record<string, string>;
  cookies: Record<string, string>;
  // ...20 more properties
};

it("gets user by id", () => {
  // Only care about body.id but must fake entire Request
  getUser({
    body: { id: "123" },
    headers: {},
    cookies: {},
    // ...fake all 20 properties
  });
});
```

这不是为了演示而生的玩具代码，而是**真实测试场景的快照**。任何写过测试的人都会立刻认出"我只关心 body.id，但必须 fake 一大堆其他字段"的痛苦。这种真实感让读者产生共鸣，迁移的动力就从"被要求做"变成"我想做"。

### 2.3 对比式呈现：Before/After 镜像结构

所有迁移模式都用了 **Before → After** 的镜像对比：

- 同样的行数、类似的结构，只是关键行发生了变化
- 读者不需要在两个代码块之间做认知切换，直接看出差异点

更重要的是，After 块的代码行数明显少于 Before 块，**视觉上就直接传递了"shoehorn 更简洁"的信息**。这是用格式本身在说话，而不只是文字描述。

### 2.4 决策辅助：简洁的对照表

```
| Function        | Use case                                           |
| --------------- | -------------------------------------------------- |
| `fromPartial()` | Pass partial data that still type-checks           |
| `fromAny()`     | Pass intentionally wrong data (keeps autocomplete) |
| `fromExact()`   | Force full object (swap with fromPartial later)    |
```

这个表格的作用是**在执行前帮助用户做选择**，而不是等执行完了才发现用错了函数。AI 在帮用户迁移时，也可以参考这个表格来确认应该用哪个函数。

### 2.5 工作流：半自动化友好的 checklist

```
- [ ] Install: `npm i @total-typescript/shoehorn`
- [ ] Find test files with `as` assertions: `grep -r " as [A-Z]" ...`
- [ ] Replace `as Type` with `fromPartial()`
- [ ] Replace `as unknown as Type` with `fromAny()`
- [ ] Add imports from `@total-typescript/shoehorn`
- [ ] Run type check to verify
```

这是文档中最"可执行"的部分。注意它没有写成详细的脚本，而是**给了足够具体的 grep 模式和替换规则，让 AI 或用户自己去执行**。这种留白的智慧在于：

- 不同项目结构不同，一次性写死所有路径不现实
- 给的是**策略**而非**剧本**，AI 可以根据实际情况调整执行方式

### 2.6 边界意识：清晰的限制声明

文档中有一句极简短但极重要的声明：

> **Test code only.** Never use shoehorn in production code.

这是一个**反误用声明**。它明确告诉用户：shoehorn 是测试工具，不是生产代码的捷径。这个边界如果不画清楚，用户很可能会在生产代码里也用 `fromAny()` 绕过类型检查，带来安全隐患。

---

## 三、为我们构建 Skill 能带来的借鉴

### 3.1 借鉴一：触发条件要具体，不要泛泛

很多 skill 的 description 写得过于通用，比如"帮助用户处理 TypeScript 问题"。这个 skill 的 description 精准到：

- 提到 "shoehorn" 这个具体库名
- 提到 "replace `as` in tests"
- 提到 "partial test data" 这个具体需求

**建议**：我们的 skill description 应该尽量包含用户可能说出的具体关键词，而不是功能的大类描述。关键词越具体，触发越精准，误激活率越低。

### 3.2 借鉴二：从问题出发，而非从方案出发

很多 skill 的开篇是"这个 skill 可以帮你做 X"。这个 skill 的开篇是"为什么你现有的方式有问题"。**先建立痛点认知，再引出解决方案**，这个顺序在技术文档中往往比"方案先行"更有说服力。

**建议**：每个 skill 的开头应该先花 1-2 句话解释"这个 skill 解决的是什么问题"，让用户知道自己为什么需要它。

### 3.3 借鉴三：代码示例要有真实感，不要过度简化

这个 skill 最有力的部分就是那段"20 more properties"的示例——它模拟了真实的代码复杂度，而不是用简单的 `{ name: "test" } as User` 来演示。

**建议**：我们的代码示例应该反映真实场景的复杂度。如果示例太简单，用户在实际使用时会发现 skill 无法处理他们的具体情况，从而失去信任。

### 3.4 借鉴四：给出决策框架而非单一路径

`When to use each` 表格是整个 skill 中 AI 实际执行时最关键的工具。它让 AI 在多个选项之间能做出判断，而不只是机械地执行一条指令。

**建议**：如果我们的 skill 涉及多种可能的操作或函数选择，应该在文档中提供清晰的对照表，帮助 AI 在不同场景下做出正确选择。

### 3.5 借鉴五：提供可执行的检查清单，但留有灵活性

工作流的 checklist 部分给了 AI 一个**可信赖的执行路径**，但没有写死具体的文件路径和项目配置。grep 模式虽然具体，但仍然是可参数化的。

**建议**：包含实际命令的 skill 应该在工作流部分提供可运行的命令模板，同时注明哪些参数需要根据实际情况调整。这样既保证了可用性，又避免了"在我机器上跑不通"的问题。

### 3.6 借鉴六：主动声明边界和限制

"Test code only" 这句话虽然只有 4 个词，但它防止了一个重大的误用风险。技术文档往往缺少这种主动的边界声明。

**建议**：我们的 skill 应该在适当的地方明确说明**什么不该做**，特别是涉及安全、类型系统、生产代码等敏感领域时。一个好的 skill 不仅告诉用户怎么做，还告诉用户什么情况下不应该用。

### 3.7 借鉴七：使用镜像对比而非线性叙述

Before/After 结构比"旧的方式是这样的，新的方式是这样的"这类线性叙述效率高得多。读者的眼睛可以直接在两个代码块之间做视觉对比，不需要额外的文字转述。

**建议**：当我们的 skill 涉及代码转换、迁移、重构场景时，优先使用 Before/After 的镜像对比格式，而不是用段落文字描述差异。

---

## 四、总结

| 维度 | 评分（1-5） | 说明 |
|------|------------|------|
| 问题聚焦度 | ⭐⭐⭐⭐⭐ | 精准锁定一个具体迁移场景，不贪多 |
| 文档结构 | ⭐⭐⭐⭐⭐ | Why→How→Workflow，逻辑链条清晰 |
| 示例质量 | ⭐⭐⭐⭐⭐ | 真实场景，有共鸣感，不过度简化 |
| 可执行性 | ⭐⭐⭐⭐ | checklist 明确，但 grep 模式可进一步参数化 |
| 边界意识 | ⭐⭐⭐⭐ | "Test code only" 声明有力，可更显眼 |
| 决策辅助 | ⭐⭐⭐⭐⭐ | 三函数对照表是极佳的 AI 决策参考 |

**总体评价**：这是一个**高度专业化、场景精准、可执行性强**的 skill 典范。它没有试图成为一个通用的"TypeScript 助手"，而是专注于 `as` → `shoehorn` 这一个迁移场景，做到了极致。篇幅控制得也很好（没有冗长的背景知识），核心信息密度高。作为我们构建 agent skill 的参考模板，这个 skill 几乎可以在每个维度直接借鉴。