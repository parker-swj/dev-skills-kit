---
description: 重新加载 AGENTS.md 规则，同步当前状态，开始/继续任务
argument-hint: [可选补充说明]
---

$ARGUMENTS

# /go — 规则加载 & 状态同步

> **使用场景**：长会话中 AI 开始遗漏规则（如跳过 brainstorming、不读 SKILL.md、
> 不更新 planning 文件等），由用户手动触发此流程重置 Agent 行为。
> **也适用于**：网络断开或会话中断后，用户在新窗口中恢复工作。

## 步骤

1. 使用 `view_file` 完整读取项目根目录的 `AGENTS.md`

2. **阶段感知恢复 — 以 `progress.md` 为唯一状态来源**（此步骤不可跳过）：

<EXTREMELY-IMPORTANT>
**`progress.md` 是阶段状态的唯一权威来源。**

```
检查 progress.md 是否存在？

  ✅ 存在：
     → 读取 progress.md 中的「当前阶段」节
     → 找到「阶段:」和「状态:」字段，这就是当前恢复点
     → 直接恢复到该阶段，不再检查其他任何文件
     
     阶段恢复映射：
       阶段: brainstorming  | 状态: 进行中  → 恢复 brainstorming，继续讨论
       阶段: openspec       | 状态: 进行中  → 恢复 openspec，继续文档链生成
       阶段: writing-plans  | 状态: 进行中  → 恢复 writing-plans，继续任务规划
       阶段: executing      | 状态: 进行中  → 恢复 executing，继续代码实现
       阶段: review         | 状态: 进行中  → 恢复 review，继续代码审查
       阶段: [任意]         | 状态: 已完成  → 该阶段完成，询问用户下一步

  ❌ 不存在：
     → 当前没有进行中的任务
     → 等待用户描述新需求，然后按 AGENTS.md 第 4 节正常流程开始
```

**绝对禁止**以下行为：
- `progress.md` 存在时，忽略其内容，转而检查 openspec/ 目录或 task_plan.md 来判断阶段
- `progress.md` 显示「brainstorming 进行中」时，跳过 brainstorming 直接进入任何后续阶段
- `progress.md` 显示「openspec 进行中」时，跳过 openspec 直接进入 executing
- 在没有 `progress.md` 的情况下，假设某个阶段已完成或直接进入执行
</EXTREMELY-IMPORTANT>

3. 读取完成后，**逐节确认以下内容仍然有效**：
   - 第 1 节：`get_context` MCP 工具已调用（如尚未调用，立即调用）
   - 第 2 节：Skill 调度逻辑已理解，将通过 `view_file` 按需加载 SKILL.md
   - 第 4 节：当前任务的复杂度等级，以及对应应激活的 Skills
   - 第 5 节：缺陷补丁规则（TDD 灵活化、3-Strike Protocol 等）

4. 输出一段简短的**确认摘要**，格式如下：

```
✅ AGENTS.md 已重新加载

当前任务复杂度：[trivial / small / medium / large]
本阶段激活的 Skills：[列出]

📍 恢复检测结果（来自 progress.md）：
  progress.md 状态：[存在 / 不存在]
  当前阶段：[brainstorming / openspec / writing-plans / executing / review / 无进行中任务]
  阶段状态：[进行中 / 已完成]
  上次断点：[简述 progress.md 中最后记录的内容]

下一步：[基于 progress.md 的恢复结果，接下来要做什么]
```

5. **恢复执行**：根据步骤 2 的 `progress.md` 读取结果恢复到正确的阶段
