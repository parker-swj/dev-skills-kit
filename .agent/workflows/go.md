---
description: 重新加载 AGENTS.md 规则，同步当前状态，开始/继续任务
argument-hint: [可选补充说明]
---

$ARGUMENTS

# /go — 规则加载 & 状态同步

> **使用场景**：长会话中 AI 开始遗漏规则（如跳过 brainstorming、不读 SKILL.md、
> 不更新 planning 文件等），由用户手动触发此流程重置 Agent 行为。

## 步骤

1. 使用 `view_file` 完整读取项目根目录的 `AGENTS.md`

2. 读取完成后，**逐节确认以下内容仍然有效**：
   - 第 1 节：`get_context` MCP 工具已调用（如尚未调用，立即调用）
   - 第 2 节：Skill 调度逻辑已理解，将通过 `view_file` 按需加载 SKILL.md
   - 第 4 节：当前任务的复杂度等级，以及对应应激活的 Skills
   - 第 5 节：缺陷补丁规则（TDD 灵活化、3-Strike Protocol 等）

3. 输出一段简短的**确认摘要**，格式如下：

```
✅ AGENTS.md 已重新加载

当前任务复杂度：[trivial / small / medium / large]
本阶段激活的 Skills：[列出]
当前执行状态：[当前正在做什么]
下一步：[接下来要做什么]
```

4. 恢复执行当前任务（如有正在进行的任务）
