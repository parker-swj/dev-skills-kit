---
description: 重新加载 AGENTS.md 规则，同步当前状态，开始/继续任务
argument-hint: [可选补充说明]
---

$ARGUMENTS

# /go — 规则加载 & 状态同步

> **使用场景**：长会话中 AI 开始遗漏规则，或中断后在新窗口恢复工作。
> **放弃当前任务？** 使用 `/reset`。

## 步骤

1. 使用 `view_file` 完整读取项目根目录的 `AGENTS.md`

2. **基于 `process.md` 的状态恢复**（不可跳过）：

<EXTREMELY-IMPORTANT>
```
检查 process.md 是否存在？

  ✅ 存在：
     → 读取完整 process.md
     → 找到 🔄 步骤 = 当前恢复点
     → 读取该步骤的「关键记录」+ 「参考上下文」节
     → 如有 task_plan.md / findings.md → 一并读取
     → 读取关键记录中引用的外部产出文件：
       • openspec/[变更目录]/ 下的文档（如 Step 涉及 OpenSpec，读取 proposal/specs/design/tasks）
       • 关键记录中明确引用的 docs/learnings/ 文件
       • 其他关键记录中记载的产出文件路径
     → 从 🔄 步骤继续执行

     特殊情况：
     - 全部 ✅ → 任务已完成但 process.md 未归档（收尾步骤可能被中断）
       → 自动执行归档：创建 .archive/tasks/[时间戳]/ → 移入 process.md、task_plan.md、findings.md
       → 告知用户「上一个任务已归档完成，可以描述新需求」
     - 全部 ⬜ → 将 Step 1 设为 🔄，从头开始

  ❌ 不存在：
     → 如有旧 progress.md → 提示用户用 /reset 清理后重新开始
     → 否则等待用户描述新需求
```

**禁止**：跳过读取、跳到 ⬜ 步骤、修改复杂度（🔒 已锁定）
</EXTREMELY-IMPORTANT>

3. 输出**确认摘要**：

```
✅ AGENTS.md 已重新加载
📍 process.md：[存在/不存在] | 复杂度：[X 🔒] | 当前：[Step N — 🔄]
下一步：[...]
```
