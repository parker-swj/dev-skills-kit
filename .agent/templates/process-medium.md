# Process — [任务名称]

## 元信息
- 复杂度: medium 🔒（已锁定，不可降级）
- 创建时间: [当前时间]
- 任务概述: [一句话描述]

---

## Step 1: 需求理解 & Brainstorming
- 状态: ⬜ 未开始
- 开始时间: [...]
- 📎 Skills: `auto-learning`（读取 docs/learnings/ 中相关经验）
- **关键记录**:
  - 用户需求要点: [...]
  - 技术方案选择: [...]
  - 待确认问题: [无 / ...]
  - Expert Mode: [是/否，原因]

## Step 2: 制定计划（writing-plans）
- 状态: ⬜ 未开始
- 开始时间: [...]
- 📎 Skills: `planning-with-files`（创建 task_plan.md / findings.md）
- **关键记录**:
  - 计划文件: task_plan.md
  - 子任务数量: [N]
  - ⚠️ 用户是否已确认计划: ⬜ 待确认（必须等用户确认后才能进入 Step 3）

## Step 3: 执行开发（executing）
- 状态: ⬜ 未开始
- 开始时间: [...]
- 📎 Skills: `planning-with-files`（2-Action Rule、3-Strike Protocol）, `security-guidance`（编码时被动检测）, `systematic-debugging`（如遇 Bug 则强制 4 阶段排查）
- **关键记录**:
  - 已完成子任务: [ ] / [N]
  - 遇到的错误: [记录到 findings.md]
  - 关键决策变更: [...]

## Step 4: 测试验证
- 状态: ⬜ 未开始
- 📎 Skills: `test-driven-development`（TDD RED-GREEN-REFACTOR）
- **关键记录**:
  - 测试方式: [TDD RED-GREEN-REFACTOR / 手动验证 / smoke test]
  - 测试结果: [...]
  - 跳过 TDD 原因: [如适用，参考 AGENTS.md 5.1 节]

## Step 5: 自审 & 安全检查
- 状态: ⬜ 未开始
- 📎 Skills: `security-guidance`（安全审查 Checklist）, `verification-before-completion`（确认所有测试/检查通过证据）
- **关键记录**:
  - 代码质量检查: [DRY / YAGNI / 错误处理 / 命名]
  - 安全检查: [参考 security-guidance，通过/问题]
  - 发现的问题: [🔴 Critical / 🟠 Important / 🟡 Minor]

## Step 6: 收尾归档
- 状态: ⬜ 未开始
- 📎 Skills: `auto-learning`（写入经验到 docs/learnings/）
- **关键记录**:
  - 经验提取: [是/否，文件: docs/learnings/...]
  - 归档路径: .archive/tasks/[时间戳]/
  - 完成时间: [...]

---

> **中断恢复指引**：新会话恢复时，找到状态为 🔄 的 Step，阅读其及之前所有 ✅ Step 的关键记录即可恢复上下文。
