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

## Step 6: 🚪 人工 Review 门控
- 状态: ⬜ 未开始
- **关键记录**:
  - **AI 提交 Review 摘要**（进入此步骤时必须填写）:
    - 改动文件列表: [...]
    - 测试结果汇总: [全部通过 / ...]
    - 自审结论: [无问题 / 已修复问题...]
  - ⚠️ 人工审核结果: ⬜ 待审核
  - ⏳ **必须等待用户明确说"通过"或"approved"后才能进入 Step 7，严禁自动跳过此步骤**
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
> | 🟢 小修 | 代码细节（命名、格式、小 bug） | 直接在 Step 6 内修改 | 改完 → 重新提交 Review |
> | 🟡 中修 | 实现逻辑需重做 | 回到 Step 3（执行）| Step 3→4→5→6 重走 |
> | 🔴 大修 | 需求/计划层面变更 | 回到 **Step 2（制定计划）** | Step 2→3→4→5→6 全部重走 |
>
> **process.md 状态变更操作**（以 🔴 大修为例）：
> ```
> Step 2: ✅ → 🔄   ← 回退目标，重新开始
> Step 3: ✅ → ⬜   ← 重置
> Step 4: ✅ → ⬜   ← 重置
> Step 5: ✅ → ⬜   ← 重置
> Step 6: 🔄 → ⬜   ← Review 步骤也重置，待重新进入
> ```
> ⚠️ **重置步骤的关键记录不得删除**，保留作为历史对比（可标注 `[第 1 轮]` `[第 2 轮]`）
>
> **大修回退操作步骤**：
> 1. 按上表修改 process.md 中各 Step 状态
> 2. 在 Step 6 修订轮次记录中追加本轮修订信息
> 3. 更新 task_plan.md（修改/新增/删除子任务）
> 4. 用户确认新计划后，从 Step 3（🔄）开始重新执行
> 5. 最终回到 Step 6，重新提交 Review 摘要等待用户审核
>
> **所有级别通用**：修订完成后重新填写「AI 提交 Review 摘要」→ 再次等待用户说"通过" → 循环直到通过

## Step 7: 收尾归档
- 状态: ⬜ 未开始
- 📎 Skills: `auto-learning`（写入经验到 docs/learnings/）
- **关键记录**:
  - 经验提取: [是/否，文件: docs/learnings/...]
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
> 4. 读取关键记录中**引用的外部文件**（如 `docs/learnings/` 中的经验文件）
> 5. 从 🔄 步骤继续执行，**禁止**跳步或降级复杂度

