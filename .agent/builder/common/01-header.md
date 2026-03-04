---

## 1. 上下文规则加载

<EXTREMELY-IMPORTANT>
每次对话开始时，必须先调用 `get_context` MCP 工具（不带参数）加载用户预设的上下文规则，并在整个对话中严格遵守返回的规则。
</EXTREMELY-IMPORTANT>

---

## 2. 核心调度逻辑（内嵌 using-superpowers）

以下规则直接内嵌于此，无需额外加载。

<EXTREMELY-IMPORTANT>
如果你认为有哪怕 1% 的可能性某个 skill 适用于当前任务，你**绝对必须**使用它。
这不可商量，不可选择。但必须遵守第 4 节的场景分级规则——不同复杂度激活不同 skills。
</EXTREMELY-IMPORTANT>

### 调度流程

```
接到用户消息
    │
    ├─ 评估复杂度等级（第 4 节）
    │
    ├─ 该等级下有哪些 skill 需要激活？（第 4 节矩阵）
    │
    ├─ 需要详细指导？ → 用 view_file 读取对应 SKILL.md（第 3 节路径）
    │
    └─ 执行任务，遵守缺陷补丁规则（第 5 节）
```

### 如何加载 Skill 详细指导

当你需要某个 skill 的详细指导时：

```
使用 view_file 等读取工具读取对应的 SKILL.md 文件路径（见第 3 节）
```

例如：需要 TDD 指导 → `view_file` 读取 `.agent/skills/test-driven-development/SKILL.md`

### 反合理化检查

| 你的想法 | 现实 |
|----------|------|
| "这只是个简单问题" | 先评估复杂度等级，再决定流程 |
| "不需要读 SKILL.md" | 如果你不确定该 skill 的完整流程，就去读 |
| "我记得这个 skill 的内容" | Skills 可能更新了，不确定就重新读 |
| "这个 skill 太重了" | 先评估复杂度，trivial/small 可以跳过部分 skills |

### Skill 优先级

1. **流程 skills 优先**（brainstorming, systematic-debugging）— 决定 HOW
2. **实现 skills 其次**（语言 patterns, api-design）— 指导 WHAT

---

## 3. Skills 注册表

所有 SKILL.md 文件均可通过 `view_file` 工具读取。**不要一次性全部读取，只读当前场景需要的。**

### 3.1 Superpowers 方法论（14 个 skills）

| Skill | view_file 路径 | 简述 |
|-------|---------------|------|
| using-superpowers | `.agent/skills/using-superpowers/SKILL.md` | 调度器核心（必读） |
| brainstorming | `.agent/skills/brainstorming/SKILL.md` | 苏格拉底式设计精炼 |
| writing-plans | `.agent/skills/writing-plans/SKILL.md` | 拆分为 2-5 分钟小任务 |
| executing-plans | `.agent/skills/executing-plans/SKILL.md` | 分批执行 + 人工检查点 |
| test-driven-development | `.agent/skills/test-driven-development/SKILL.md` | RED-GREEN-REFACTOR |
| systematic-debugging | `.agent/skills/systematic-debugging/SKILL.md` | 4 阶段根因分析 |
| verification-before-completion | `.agent/skills/verification-before-completion/SKILL.md` | 完成前强制验证 |
| requesting-code-review | `.agent/skills/requesting-code-review/SKILL.md` | 发起代码审查 |
| receiving-code-review | `.agent/skills/receiving-code-review/SKILL.md` | 接收审查反馈 |
| dispatching-parallel-agents | `.agent/skills/dispatching-parallel-agents/SKILL.md` | 并行多问题处理 |
| using-git-worktrees | `.agent/skills/using-git-worktrees/SKILL.md` | 隔离工作区 |
| finishing-a-development-branch | `.agent/skills/finishing-a-development-branch/SKILL.md` | 分支收尾 |
| writing-skills | `.agent/skills/writing-skills/SKILL.md` | 如何创建新 skill |
