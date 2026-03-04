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

2. **阶段感知恢复 — 检测当前任务的执行进度**（此步骤不可跳过）：

   依次检查以下文件是否存在，推断当前所处阶段：

   ```
   检查优先级（从高到低）：
   
   a. progress.md 存在？
      → 读取 progress.md，查看最后记录的阶段和状态
      → 如果记录了 "阶段: brainstorming" 且状态为 "进行中"
        → 恢复到 brainstorming，从上次结论继续
      → 如果记录了 "阶段: openspec" 且状态为 "进行中"
        → 恢复到 openspec，继续未完成的文档
   
   b. task_plan.md 存在？
      → 读取 task_plan.md，检查哪些任务已完成、哪些待做
      → 从第一个未完成的任务继续
   
   c. openspec/ 目录存在？
      → 检查是否有进行中的变更目录（非 archive/ 下的目录）
      → 如有进行中变更，检查其中的文档完成度：
         - 只有 proposal → 恢复到 specs 生成
         - 有 specs 无 design → 恢复到 design 生成
         - 有 design 无 tasks → 恢复到 tasks 生成
         - tasks 存在 → 进入 executing-plans
      → 如无进行中变更，按正常流程走
   
   d. findings.md 存在？
      → 读取 findings.md，了解已有的研究发现
      → 结合发现判断当前阶段
   
   e. 以上文件均不存在？
      → 当前无进行中的任务，等待用户指令
   ```

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

📍 恢复检测结果：
  检测到的文件：[列出存在的 planning 文件]
  当前阶段：[brainstorming / openspec / writing-plans / executing / review / 无进行中任务]
  阶段状态：[进行中 / 已完成]
  上次断点：[简述上次执行到的位置]

下一步：[基于恢复检测，接下来要做什么]
```

5. **恢复执行**：根据步骤 2 的检测结果恢复到正确的阶段，**不得跳过未完成的阶段**

<EXTREMELY-IMPORTANT>
**绝对禁止**以下行为：
- 在 progress.md 记录为 "brainstorming 进行中" 时跳过 brainstorming
- 在 openspec 文档链未完成时跳过 openspec
- 在没有任何 planning 文件时假设某个阶段已完成
- 忽略步骤 2 的阶段检测直接进入执行

**核心原则**：宁可重复已完成的阶段，也不能跳过未完成的阶段。
</EXTREMELY-IMPORTANT>
