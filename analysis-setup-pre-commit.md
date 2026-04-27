# Skill 深度分析：setup-pre-commit

> 来源：[mattpocock/skills](https://github.com/mattpocock/skills) — `setup-pre-commit`
> 分析日期：2026-04-28

---

## 一、Skill 的作用和核心功能

### 1.1 解决什么问题

`setup-pre-commit` 是一个**安装引导型** Skill，用于在当前项目中一键配置完整的 pre-commit 工作流。它解决的问题是：

- 手动配置 Husky + lint-staged + Prettier 繁琐且容易出错
- 不同开发者的本地配置容易不一致
- 团队没有统一的代码质量门槛

### 1.2 核心功能

Skill 实现了 **8 个步骤**的流水线，涵盖：

| 步骤 | 动作 | 产出 |
|------|------|------|
| 1 | 检测包管理器 | 确定使用 npm/pnpm/yarn/bun |
| 2 | 安装依赖 | `husky lint-staged prettier` |
| 3 | 初始化 Husky | 创建 `.husky/` 目录，修改 `prepare` 脚本 |
| 4 | 写入 pre-commit hook | `.husky/pre-commit` 执行 lint-staged + typecheck + test |
| 5 | 配置 lint-staged | `.lintstagedrc` 规定只对 staged 文件跑 Prettier |
| 6 | 补齐 Prettier 配置 | 若缺失则写入默认 `.prettierrc` |
| 7 | 验证清单 | 检查所有产物是否就位 |
| 8 | 首次 commit | 触发 hook 作为冒烟测试 |

### 1.3 能力边界

Skill 的设计非常**专注**——只做 pre-commit 环境的搭建，不涉及：
- ESLint 配置
- CI/CD 配置
- 其他 git hooks（commit-msg、pre-push 等）
- 项目初始化（`npm init` 等）

这种专注使得 Skill 的描述、使用场景和实现都非常清晰，降低了认知负担。

---

## 二、写得好的地方

### 2.1 描述字段（description）写得精准

```yaml
description: >
  Set up Husky pre-commit hooks with lint-staged (Prettier),
  type checking, and tests in the current repo. Use when user wants
  to add pre-commit hooks, set up Husky, configure lint-staged, or
  add commit-time formatting/typechecking/testing.
```

**优点：**
- 用一句话说清楚**是什么**（Husky + lint-staged + Prettier + typecheck + test）
- 明确列出触发词：`add pre-commit hooks`、`set up Husky`、`configure lint-staged`、`commit-time formatting/typechecking/testing`
- Agent 在收到相关指令时能**直接匹配**，无需推理

### 2.2 标题结构清晰，信息分层优秀

文档使用了**五层标题**，层层递进：

```
# Setup Pre-Commit Hooks          ← 大标题：主题
## What This Sets Up              ← 前置说明：产出清单
### 1. Detect package manager      ← 步骤一
### 2. Install dependencies       ← 步骤二
...
### 8. Commit                     ← 步骤八
## Notes                          ← 补充说明
```

读者可以从任何层级快速定位信息。**"What This Sets Up"** 小节以列表形式先告知用户将要建立什么，再进入步骤细节，符合"先概览后细节"的认知顺序。

### 2.3 自适应逻辑写得漂亮

```markdown
**Adapt**: Replace `npm` with detected package manager.
If repo has no `typecheck` or `test` script in package.json,
omit those lines and tell the user.
```

这段话展示了 Skill 的**智能适应性**：
- 根据检测到的包管理器动态调整命令
- 检查 `package.json` 中是否真的存在 `typecheck`/`test` 脚本，不存在就跳过
- 跳过时**主动告知用户**，而不是静默忽略

这是很多简单 Skill 做不到的——它们往往假设所有项目都有完整的 scripts，结果在真实项目中报错。

### 2.4 验证清单（Verify）的设计

```markdown
### 7. Verify

- [ ] `.husky/pre-commit` exists and is executable
- [ ] `.lintstagedrc` exists
- [ ] `prepare` script in package.json is `"husky"`
- [ ] `prettier` config exists
- [ ] Run `npx lint-staged` to verify it works
```

使用 **Checkbox 风格**的验证清单：
- 每一条对应一个真实的文件系统状态或命令执行
- 可操作性强：Agent 可以逐条执行检查
- 给用户（和 Agent）一个明确的完成标准

### 2.5 冒烟测试思维（Step 8）

> Stage all changed/created files and commit with message:
> `Add pre-commit hooks (husky + lint-staged + prettier)`
> This will run through the new pre-commit hooks — a good smoke test that everything works.

**这是整个 Skill 的点睛之笔。** 它把"创建 hook"和"验证 hook"合并为一个动作——第一次 commit 就是冒烟测试。这避免了"配置完但没验证"的情况。

### 2.6 Notes 章节的补充价值

```markdown
## Notes
- Husky v9+ doesn't need shebangs in hook files
- `prettier --ignore-unknown` skips files Prettier can't parse
- The pre-commit runs lint-staged first, then full typecheck and tests
```

三个 Notes 涵盖了：
1. **版本差异处理**：Husky v9+ 行为变化，提醒避免 shebang
2. **参数选择解释**：`--ignore-unknown` 是为了跳过图片等无法解析的文件
3. **执行顺序说明**：lint-staged 先跑（快，只管 staged 文件），然后 typecheck + test（全量）

这些是"知道但容易忘"的细节，直接写在文档里节省了大量查文档的时间。

### 2.7 代码块的合理使用

- Step 3 的 `npx husky init` 用 **bash 代码块**（可执行命令）
- Step 4 的 hook 文件用**无语言纯文本代码块**（避免高亮干扰）
- Step 5、6 的配置文件用 **JSON 代码块**（语义匹配）

不同的代码块类型对应不同的使用场景，清晰不混乱。

---

## 三、为我们构建 Skill 能带来的借鉴

### 3.1 描述字段的撰写规范

**借鉴点：** description 应该包含两部分：
1. **功能描述**：这个 Skill 是做什么的
2. **触发词列表**：用户在什么情况下会需要这个 Skill

我们的一些 Skill 描述过于笼统，如"查询日历"——应该补充"创建会议"、"修改日程"、"查看空闲时间"等具体触发场景。

### 3.2 步骤化 + 前置说明模式

**借鉴点：** 面向操作的 Skill 建议采用：
```
## What This Does / Sets Up
## Step 1 / Step 2 / ...
## Notes
```

这种模式比"直接列步骤"多了"先告知产出，再展示过程"的价值。

### 3.3 自适应逻辑是区分好 Skill 和普通 Skill 的关键

**借鉴点：** 一个优秀的 Skill 不应该是"打印固定指令"，而应该：
- 检查当前环境状态
- 根据状态调整行为
- 缺失时主动告知用户

在我们的飞书、企业微信等 Skill 中，可以增加类似的检测逻辑（如"检测目标多维表格是否存在"、"检测用户是否有权限"）。

### 3.4 验证和冒烟测试不可或缺

**借鉴点：** 对于"修改配置文件"、"创建资源"这类操作，建议：
1. 操作后增加验证步骤（检查文件是否创建/修改成功）
2. 如果可能，用实际操作本身作为冒烟测试（如"创建后立即读取验证"）

### 3.5 保持专注，单一职责

**借鉴点：** `setup-pre-commit` 的边界控制得非常好——它只做 pre-commit，不做 ESLint、CI 等。这种**单一职责**让 Skill 更易维护、更易测试、更易被发现（description 不会因为功能太多而变得模糊）。

我们在构建 Skill 时应该抵制"把所有相关功能都塞进一个 Skill"的冲动，优先拆分成独立 Skill。

### 3.6 配置类产品应提供默认模板

**借鉴点：** Step 6 中，如果 `.prettierrc` 不存在，Skill 会写入一套**经过选择的默认值**。这比"什么都不做"或"报错说配置缺失"要好得多。

我们构建飞书文档、Bitable 等 Skill 时，如果用户未提供配置，也应提供合理的默认模板，而不是让用户手足无措。

---

## 四、总结评价

| 维度 | 评分 | 说明 |
|------|------|------|
| 描述精准度 | ⭐⭐⭐⭐⭐ | 触发词完整，功能描述清晰 |
| 结构清晰度 | ⭐⭐⭐⭐⭐ | 五层标题，信息分层合理 |
| 自适应逻辑 | ⭐⭐⭐⭐ | 能根据环境调整行为，但可以更细 |
| 可执行性 | ⭐⭐⭐⭐⭐ | 步骤明确，输出物清晰 |
| 验证覆盖 | ⭐⭐⭐⭐⭐ | 清单 + 冒烟测试双重保障 |
| 文档完整性 | ⭐⭐⭐⭐ | Notes 补充了关键细节 |

**总体评价：** 这是一个**标杆级别的安装引导型 Skill**。它的精妙之处不在于用了什么复杂技术，而在于：对用户需求的精准理解、对操作流程的严谨设计、以及在自动化同时保留灵活性的平衡感。

---

*分析人：subagent | 任务编号：aea85879-0aec-4334-8f09-598f23fe670f*