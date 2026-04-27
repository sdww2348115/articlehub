# Skill 深度分析：git-guardrails-claude-code

> 来源：[mattpocock/skills](https://github.com/mattpocock/skills) — `git-guardrails-claude-code`

---

## 一、Skill 的作用和核心功能

### 1.1 解决的问题

这是一个 **安全加固类 Skill**，用于在 Claude Code 环境中设置 Git 操作的安全护栏（Guardrails）。

在日常开发中，Claude Code 可能会执行一些**破坏性的 Git 命令**，例如：
- 强制推送 `git push --force`
- 强行重置 `git reset --hard`
- 清理未跟踪文件 `git clean -f`
- 强制删除分支 `git branch -D`

这些操作一旦执行，数据不可逆。因此这个 Skill 的核心目标就是：**在命令实际执行之前进行拦截**，防止误操作导致代码丢失。

### 1.2 核心功能拆解

| 功能模块 | 说明 |
|---|---|
| **PreToolUse Hook 拦截** | 利用 Claude Code 的 Hook 机制，在 Bash 工具执行前触发检查脚本 |
| **危险命令检测** | 覆盖 `push`、`reset --hard`、`clean`、`branch -D`、`checkout .` 等 5 类危险操作 |
| **可定制性** | 支持用户自行增删拦截模式，适应不同项目需求 |
| **范围可选** | 支持"项目级"和"全局级"两套安装方式 |
| **验证机制** | 提供测试命令，确保安装后立即验证有效性 |

### 1.3 技术实现路径

```
用户触发 Claude Code 执行 git 命令
       ↓
Claude Code 执行 Bash 工具（触发 PreToolUse Hook）
       ↓
hook script (block-dangerous-git.sh) 接收命令
       ↓
解析命令 → 匹配危险模式列表
       ↓
命中 → exit code 2 + stderr 输出阻止信息
未命中 → 放行，命令正常执行
```

---

## 二、写得好的地方（设计亮点、写作技巧）

### 2.1 结构设计：从问题到方案，逻辑清晰

整个 Skill 的文档采用了 **"问题 → 拦截列表 → 实施步骤 → 验证"** 的线性结构，读者的认知路径与实际操作路径完全一致：

```
What Gets Blocked  →  这是什么（读者先知道威胁是什么）
↓
Steps              →  怎么做（读者立刻知道如何落地）
↓
Verify             →  怎么验证（收尾动作，确保有效）
```

这种结构的好处是：**读者即使跳读，也能快速抓住重点**。

### 2.2 精准的触发描述（description）

```yaml
description: >
  Set up Claude Code hooks to block dangerous git commands
  (push, reset --hard, clean, branch -D, etc.)
  before they execute.
  Use when user wants to prevent destructive git operations,
  add git safety hooks, or block git push/reset in Claude Code.
```

亮点：
- **括号列举具体命令**：`push, reset --hard, clean, branch -D` — 让用户一看就知道它能拦住哪些操作
- **"before they execute"** 强调它是**预防性**而非**事后补救**的
- **Use when** 模式直接告诉 AI 在什么场景下应该调用这个 Skill，这是 skill 设计中非常重要的元信息

### 2.3 分支决策前置（Step 1: Ask scope）

```markdown
Ask the user: install for **this project only** (`.claude/settings.json`)
or **all projects** (`~/.claude/settings.json`)?
```

这是一个很好的**用户参与式设计**：

- 不替用户做决定，而是给出选项，让用户根据自己需求选择
- 同时**明确标注了两种路径对应的配置文件路径**，让选择有依据
- 这降低了"装错了位置"的焦虑感

### 2.4 配置合并而非覆盖

```markdown
If the settings file already exists, merge the hook into existing
`hooks.PreToolUse` array — don't overwrite other settings.
```

这一句话非常关键。很多 Skill 在修改配置文件时会直接覆盖，导致用户原有的配置丢失。而这里明确要求"合并"，体现了**保守最小化干预**的设计哲学。

### 2.5 提供验证步骤（Step 5）

```bash
echo '{"tool_input":{"command":"git push origin main"}}' | <path-to-script>
```

验证步骤的价值：
- **安装即验证**，不依赖用户自行判断是否生效
- 使用的是 **JSON 输入流模拟 Claude Code 的调用格式**，体现了对平台行为的深度理解
- 期望结果明确（exit code 2 + stderr BLOCKED），用户可以立刻知道成功与否

### 2.6 代码片段的精确性

所有 JSON 配置示例都包含完整的结构，且在 keys 上做了**对齐和缩进**，方便用户直接复制使用而不会因为格式错误导致 Claude Code 无法解析。

### 2.7 危险命令列表的"精选"策略

被拦截的命令列表控制得非常好：

| 命令 | 为什么拦截 |
|---|---|
| `git push` (含 `--force`) | 远程覆盖，不可逆 |
| `git reset --hard` | 工作区更改全部丢失 |
| `git clean -f` / `-fd` | 未跟踪文件被删除 |
| `git branch -D` | 分支永久删除 |
| `git checkout .` / `git restore .` | 未提交的更改被丢弃 |

没有贪多求全，只拦截**真正不可逆**的操作。日常的 `commit`、`merge`、`rebase` 等操作不在列表中——这体现了**精准而非过度防御**的设计理念。

### 2.8 自定义扩展的友好设计（Step 4）

```markdown
Ask if user wants to add or remove any patterns from the blocked list.
Edit the copied script accordingly.
```

将自定义权交给用户，而不是把所有可能都内置进脚本，保持了脚本的轻量化。

---

## 三、为我们构建 Skill 能带来的启示与借鉴

### 3.1 Skill 的元信息设计（description）值得学习

好的 description 应包含：
1. **这个 Skill 做什么**（一句话概括核心功能）
2. **具体覆盖什么**（列举关键命令/场景）
3. **Use when 场景描述**（帮助 AI 判断何时调用）

我们在写新 Skill 时，应避免过于笼统的 description（如"帮助用户管理文件"），而应该像这个例子一样，**具体到命令级别**。

### 3.2 始终考虑"安装后验证"

Step 5 提供了一种很好的实践：**每一步实施操作都应伴随验证步骤**。我们在设计 Skill 时，可以思考：

- 安装类 Skill → 有无验证命令可以测试生效？
- 配置修改类 Skill → 修改后是否需要确认配置格式正确？
- 数据操作类 Skill → 操作后是否有查询接口验证结果？

### 3.3 配置文件修改应遵循"合并优先"原则

当 Skill 需要修改 `.claude/settings.json` 这类用户配置文件时，**永远不要直接覆盖整个文件**。应该：
- 先读取现有配置
- 合并新内容
- 写回文件

我们在构建 Skill 时，如果涉及配置文件的修改，需要实现合并逻辑，而不是简单重写。

### 3.4 区分"项目级"和"全局级"的安装策略

这个 Skill 提供了双层选项，这是一种很好的**渐进式信任模型**设计思路：

- **项目级**：更安全，适合团队共享项目
- **全局级**：更便捷，适合个人开发环境

我们在设计需要持久化配置的 Skill 时，也可以考虑这种分层策略，让用户自己选择信任级别。

### 3.5 Hook 机制是扩展 AI Agent 行为的优雅方式

Claude Code 的 PreToolUse Hook 机制允许在工具执行前进行拦截，这是一个非常强大的扩展点。这个 Skill 精准地利用了这个机制来构建安全护栏。

这启示我们：**AI Agent 的行为控制不一定靠 Prompt 工程，也可以靠系统层的 Hook 机制**。我们在设计 Skill 时，可以思考目标平台提供了哪些类似的扩展点，然后利用它们而不是硬编码行为。

### 3.6 危险操作拦截类 Skill 的通用模板

如果未来我们需要构建类似的"安全护栏"类 Skill，可以参照以下结构：

```markdown
# Skill Name

## 目标
（一句话说清楚拦截什么）

## 拦截列表
（精确的命令列表，说明拦截理由）

## 实施步骤
1. 确认范围（项目/全局）
2. 部署拦截脚本
3. 修改配置（合并而非覆盖）
4. 自定义调整（是否需要增删）
5. 验证有效性

## 验证方法
（提供一键验证命令）
```

### 3.7 保持 Skill 的单一职责

这个 Skill 只有一个职责：**拦截危险 Git 命令**。它没有试图加入"自动提交"、"分支清理建议"等周边功能。这种**单一职责**让 Skill 更易于理解、维护和测试。

我们在构建 Skill 时，也应尽量保持每个 Skill 的职责边界清晰。

---

## 四、总结

`git-guardrails-claude-code` 是一个**设计精良的安全类 Skill**，其优点集中在：

1. **精准的问题定义**：明确知道要拦截哪些危险命令，不多不少
2. **良好的用户交互设计**：将选择权交给用户，不替用户做决定
3. **安全的配置文件操作**：合并而非覆盖，避免破坏用户既有配置
4. **完整的生命周期覆盖**：安装 → 配置 → 自定义 → 验证，闭环完整
5. **精炼的文档风格**：每一步都有明确动作，无废话

对于我们构建自己的 Skill 而言，这个案例最重要的借鉴是：**好的 Skill 不是功能的堆砌，而是对一个问题域的精准切割和优雅解决方案**。