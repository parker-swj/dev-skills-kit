---
description: 放弃当前进行中的任务，清理状态文件，重置为干净状态
---

$ARGUMENTS

# /reset — 任务放弃 & 状态清理

> **使用场景**：当前任务进行到一半，发现方向不对、需求变化或决定重新来过时，
> 用此流程安全地清理状态，让下次 `/go` 从干净的起点开始。

## 步骤

1. **读取当前状态**：检查 `process.md` 是否存在

   - 不存在 → 兼容检查：是否存在旧的 `progress.md`？
     - 存在旧的 `progress.md` → 提示用户这是旧版文件，询问是否一并清理
     - 都不存在 → 告知用户当前没有进行中的任务，无需清理，流程结束
   - 存在 → 读取内容，向用户展示当前任务概述、复杂度和当前步骤

2. **向用户确认处理方式**（必须等待用户明确选择）：

   ```
   ⚠️ 发现进行中的任务：
     任务：[从 process.md 元信息读取的任务概述]
     复杂度：[small/medium/large 🔒]
     当前步骤：[Step N: 步骤名称 — 🔄 进行中]
   
   请选择处理方式：
   
   [A] 归档（archive）
       → 将 process.md / task_plan.md / findings.md
         复制到 .archive/tasks/YYYY-MM-DD-HH-MM/
       → 保留已调研的内容供日后参考
       → 清理工作区状态文件
   
   [B] 直接丢弃（discard）
       → 删除 process.md / task_plan.md / findings.md
       → 完全清空，重新开始
   ```

3. **执行用户选择的操作**：

   **选 A — 归档**：
   ```
   1. 创建目录：.archive/tasks/[当前时间戳]/
   2. 移动文件：process.md → .archive/tasks/[时间戳]/
                task_plan.md（若存在）→ .archive/tasks/[时间戳]/
                findings.md（若存在）→ .archive/tasks/[时间戳]/
   3. 在归档目录创建 README.md，说明放弃原因（由用户提供）和时间
   ```

   **选 B — 直接丢弃**：
   ```
   1. 删除 process.md
   2. 删除 task_plan.md（若存在）
   3. 删除 findings.md（若存在）
   ```

4. **确认清理完成**，输出摘要：

   ```
   ✅ 状态已清理
   
   操作：[归档 / 丢弃]
   已处理文件：[列出]
   
   工作区现在是干净的。
   下次使用 /go 将从头开始接收新需求。
   ```

<EXTREMELY-IMPORTANT>
**步骤 2 必须等待用户明确选择 A 或 B，不得自动决定处理方式。**
用户放弃任务可能有多种原因，保留还是删除是用户的决定。
</EXTREMELY-IMPORTANT>
