# Process — [任务名称]

## 元信息
- 复杂度: large 🔒（已锁定，不可降级）
- 创建时间: [当前时间]
- 任务概述: [一句话描述]
- 升级信号: [命中了哪条 large 升级信号]

---

## Step 1: 初始调研 & 创建 process.md
- 状态: ⬜ 未开始
- 开始时间: [...]
- 📎 Skills: `auto-learning`（读取 docs/learnings/ 中相关经验）
- **关键记录**:
  - 项目背景: [...]
  - 历史报错: [强制记录，无则写无]
  - 相关经验: [docs/learnings/ 中是否有相关文件]
  - 调研发现: [代码结构探索、初步思路]

## Step 2: Brainstorming（完整苏格拉底式）
- 状态: ⬜ 未开始
- 开始时间: [...]
- **关键记录**:
  - 讨论轮数: [N]
  - 核心结论: [...]
  - 方案选择及理由: [...]
  - 被否决的方案: [...]
  - 待确认: [...]

## Step 3: OpenSpec 检测
- 状态: ⬜ 未开始
- **关键记录**:
  - openspec/ 目录是否存在: [是/否]
  - 选择路径: [Path A: OpenSpec / Path B: writing-plans]

## Step 4: 设计固化
- 状态: ⬜ 未开始
- 开始时间: [...]
- 📎 Skills: `planning-with-files`（创建 task_plan.md / findings.md）
- **关键记录**:
  - **[Path A — OpenSpec]**:
    - 执行: `/opsx:new <功能名>-<YYYYMMDDHHMM>` → 建变更目录
    - 执行: `/opsx:ff` → 固化为文档链（复杂需求用 `/opsx:continue` 逐步生成）
    - 变更目录名: openspec/[name]-[timestamp]/
    - 文档链完成度:
      - proposal（Why）: ⬜
      - specs（What）: ⬜
      - design（How）: ⬜
      - tasks（实施清单）: ⬜
    - ✅ tasks.md 即后续执行清单，跳过 writing-plans
  - **[Path B — writing-plans]**:
    - task_plan.md 已生成: ⬜
    - 子任务数量: [N]
  - ⚠️ 用户是否已确认设计: ⬜ 待确认（必须确认后才能继续）

## Step 5: 工作区准备
- 状态: ⬜ 未开始
- **关键记录**:
  - Git Worktree: [使用/跳过]
  - git tag 安全点: [tag 名称]
  - 分支名: [...]

## Step 6: 分批执行（executing-plans）
- 状态: ⬜ 未开始
- 开始时间: [...]
- 📎 Skills: `planning-with-files`（2-Action Rule、3-Strike Protocol）, `security-guidance`（编码时被动检测）, `systematic-debugging`（如遇 Bug 则强制 4 阶段排查）
- **关键记录**:
  - 总任务数: [N]
  - 已完成: [ ] / [N]
  - 当前批次: [第几批 / 共几批]
  - 人工检查点: [等待用户确认 ⬜]
  - 遇到的错误: [记录到 findings.md]
  - 3-Strike 记录: [同一问题失败次数]

## Step 7: 测试（严格 TDD）
- 状态: ⬜ 未开始
- 📎 Skills: `test-driven-development`（RED-GREEN-REFACTOR 循环）
- **关键记录**:
  - RED-GREEN-REFACTOR 轮次: [N]
  - 测试覆盖范围: [...]
  - 测试结果: [全部通过 / 部分失败]

## Step 8: 双阶段自审
- 状态: ⬜ 未开始
- 📎 Skills: `security-guidance`（安全审查 Checklist）
- **关键记录**:
  - **阶段 1 — 规格合规**:
    - 每个计划任务都已实现: [是/否]
    - 无多做计划外功能: [是/否]
    - 无少做计划中功能: [是/否]
    - 实现与设计文档一致: [是/否]
  - **阶段 2 — 代码质量**:
    - 代码清洁度: [通过/问题]
    - 测试质量: [通过/问题]
    - 架构 SOLID: [通过/问题]
    - 安全检查: [参考 security-guidance，通过/问题]
  - 发现的问题: [🔴 Critical / 🟠 Important / 🟡 Minor]

## Step 9: 收尾（finishing-branch）
- 状态: ⬜ 未开始
- 📎 Skills: `verification-before-completion`（运行验证命令并确认证据后才能声明成功）
- **关键记录**:
  - [OpenSpec] `/opsx:verify` 结果: [通过/问题]（验证实现与 artifacts 一致性）
  - [OpenSpec] `/opsx:archive` 完成: ⬜（sync specs → 移入 archive/YYYY-MM-DD-<name>/）
  - 分支合并: [...]

## Step 10: 经验提取 & 归档
- 状态: ⬜ 未开始
- 📎 Skills: `auto-learning`（写入经验到 docs/learnings/）
- **关键记录**:
  - 经验文件: docs/learnings/[date]-[topic].md
  - 归档路径: .archive/tasks/[时间戳]/
  - 完成时间: [...]

---

> **中断恢复指引**：新会话恢复时，找到状态为 🔄 的 Step，阅读其及之前所有 ✅ Step 的关键记录即可恢复上下文。
