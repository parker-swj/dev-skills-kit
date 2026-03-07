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
  - ⚠️ 用户是否已确认设计: ⬜ 待确认
  - ⏳ **以下为阻塞点：必须将设计摘要展示给用户，等待用户明确说"确认"或"继续"后才能进入 Step 5，严禁自动跳过**

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
  - ⏳ **以下为阻塞点：每批次执行完成后，必须向用户汇报进度摘要，等待用户明确说"确认"或"继续"后才能继续下一批次，严禁自动跳过**
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

## Step 9: 🚪 人工 Review 门控
- 状态: ⬜ 未开始
- **关键记录**:
  - **AI 提交 Review 摘要**（进入此步骤时必须填写）:
    - 改动文件列表: [...]
    - 测试结果汇总: [全部通过 / ...]
    - 自审结论: [无问题 / 已修复问题...]
    - 与设计文档的一致性: [一致 / 偏差说明]
  - ⚠️ 人工审核结果: ⬜ 待审核
  - ⏳ **必须等待用户明确说"通过"或"approved"后才能进入 Step 10，严禁自动跳过此步骤**
  - **修订轮次记录**（如用户要求修订，每轮追加）:
    - 第 1 轮:
      - 审核结果: [✅ 通过 / 🔄 需修订]
      - 用户反馈: [...]
      - 修订内容: [...]
      - 重新测试: [通过/失败]
    - 第 N 轮: [...]
  - 最终批准时间: [...]

> **修订循环规则**：用户反馈"需修订"时，根据修订范围分三级处理：
>
> | 级别 | 用户反馈类型 | 回退目标 | 后续步骤 |
> |------|-------------|---------|---------|
> | 🟢 小修 | 代码细节（命名、格式、小 bug） | 直接在 Step 9 内修改 | 改完 → 重新提交 Review |
> | 🟡 中修 | 实现逻辑需重做 | 回到 Step 6（执行）| Step 6→7→8→9 重走 |
> | 🔴 大修 | 设计/需求层面变更 | 回到 **Step 4（设计固化/OpenSpec）** | Step 4→5→6→7→8→9 全部重走 |
>
> **process.md 状态变更操作**（以 🔴 大修为例）：
> ```
> Step 4: ✅ → 🔄   ← 回退目标，重新开始
> Step 5: ✅ → ⬜   ← 重置
> Step 6: ✅ → ⬜   ← 重置
> Step 7: ✅ → ⬜   ← 重置
> Step 8: ✅ → ⬜   ← 重置
> Step 9: 🔄 → ⬜   ← Review 步骤也重置，待重新进入
> ```
> ⚠️ **重置步骤的关键记录不得删除**，保留作为历史对比（可标注 `[第 1 轮]` `[第 2 轮]`）
>
> **大修回退操作步骤**：
> 1. 按上表修改 process.md 中各 Step 状态
> 2. 在 Step 9 修订轮次记录中追加本轮修订信息
> 3. 更新 OpenSpec 文档（proposal/specs/design/tasks）或 task_plan.md
> 4. 从 Step 4（🔄）开始重新正向执行
> 5. 最终回到 Step 9，重新提交 Review 摘要等待用户审核
>
> **所有级别通用**：修订完成后重新填写「AI 提交 Review 摘要」→ 再次等待用户说"通过" → 循环直到通过

## Step 10: 收尾（finishing-branch）
- 状态: ⬜ 未开始
- 📎 Skills: `verification-before-completion`（运行验证命令并确认证据后才能声明成功）
- **关键记录**:
  - **[Path A — OpenSpec 专属，跳过此部分如使用 Path B]**:
    - `/opsx:verify` 结果: [通过/问题]（验证实现与 artifacts 一致性）
    - ⚠️ **`/opsx:archive` 完成: ⬜**（**必须执行** — sync specs → 移入 archive/YYYY-MM-DD-\<name\>/，等效 CLI: `openspec archive <change-name>`）
  - 分支合并: [...]

## Step 11: 经验提取 & 归档
- 状态: ⬜ 未开始
- 📎 Skills: `auto-learning`（写入经验到 docs/learnings/）
- **关键记录**:
  - ⚠️ [OpenSpec] 归档确认: [Path A: `/opsx:archive` 已在 Step 10 完成 / Path B: 不适用]
  - 经验文件: docs/learnings/[date]-[topic].md
  - **归档清理**:
    - 归档目录: .archive/tasks/[时间戳]/
    - 移入归档的文件:
      - `process.md` ✅
      - `task_plan.md`（若存在）✅
      - `findings.md`（若存在）✅
    - ⚠️ 归档完成后工作区不应残留 `process.md`
  - 完成时间: [...]

---

> **中断恢复指引**：新会话恢复时（`/go`），执行以下恢复：
> 1. 读取完整 `process.md`，找到 🔄 步骤为恢复点
> 2. 阅读 🔄 及之前所有 ✅ Step 的**关键记录**
> 3. 读取附属文件（如存在）：`task_plan.md`、`findings.md`
> 4. 读取关键记录中**引用的外部产出文件**：
>    - `openspec/[变更目录]/` 下已生成的文档（proposal/specs/design/tasks）
>    - `docs/learnings/` 中被 Step 1 关键记录引用的经验文件
>    - 其他关键记录中明确记载的文件路径
> 5. 从 🔄 步骤继续执行，**禁止**跳步或降级复杂度

