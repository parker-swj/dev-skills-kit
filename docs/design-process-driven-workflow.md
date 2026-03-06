# Process-Driven Workflow 设计方案

> 创建时间: 2026-03-05 17:08
> 状态: 设计中
> 目标: 用 process.md 一体化清单替代当前 AGENTS.md + progress.md 分离架构

---

## 1. 问题诊断：当前系统为什么会"乱掉"

### 核心矛盾

当前架构是"两层分离"的：

```
AGENTS.md（572行）    →  告诉 AI "你应该怎么做"（规则书）
     ↓
progress.md           →  记录 "做到哪了"（状态笔记）
```

**问题清单：**

| # | 问题 | 根因 |
|---|------|------|
| 1 | AI 上下文一长就不按规则走 | AGENTS.md 572 行太长，前面的规则被"挤出"AI 注意力范围 |
| 2 | 中断后新会话丢失上下文 | progress.md 只记录"阶段: executing"，不包含具体操作步骤 |
| 3 | AI 偷偷跳过步骤 | 规则和状态在两个文件里，AI 需要同时记住两个信息源 |
| 4 | 复杂度被 AI 悄悄降级 | 复杂度判定逻辑在 AGENTS.md 中，AI 重新评估时可能遗忘初始判定 |
| 5 | /go 恢复时还是可能跳步 | /go 依赖 AI 正确理解 AGENTS.md 的恢复映射表，长上下文中表现不稳定 |

### 比喻

> 当前做法像是——给工人一本 500 页的操作手册，然后给一个便签纸记"做到第 3 章了"。
> 工人做着做着就忘了手册里第 3 章具体要求什么。

---

## 2. 新架构设计：Process-Driven Workflow

### 核心思想

**把"手册"和"便签"合二为一。** `process.md` 不仅记录"做到哪了"，还直接包含"这一步该做什么"。

### 新旧对比

```
❌ 当前架构（两层分离）：
   AGENTS.md  =  规则（what to do）  ←  AI 容易忘
   progress.md =  状态（where am I）  ←  太简单，只有一行状态

✅ 新架构（一体化清单）：
   AGENTS.md  =  精简版规则 + 模板选择逻辑（大幅缩短）
   process.md =  规则 + 状态 + 步骤 + 上下文（一个文件搞定一切）
```

### 关键设计原则

1. **process.md 是"当前任务的完整导航"**
   - 不只是记录状态，而是包含当前复杂度对应的**完整步骤清单**
   - AI 每次只需要读这一个文件，就知道：在哪里、该做什么、之前做了什么

2. **按复杂度选择模板**
   - `small` → 轻量模板（3 步）
   - `medium` → 标准模板（7 步）
   - `large` → 完整模板（11 步）
   - 复杂度在创建时**锁定 🔒**，不可被 AI 降级

3. **每个步骤有三态**
   ```
   ⬜ 未开始     →  步骤可见，但 AI 不应跳到这里
   🔄 进行中     →  AI 当前应该关注的步骤
   ✅ 已完成     →  完成了，记录了关键产出
   ```

4. **每个步骤带"上下文槽位"**
   - 步骤完成时，AI 必须填写关键产出/决策
   - 中断重连后，新会话的 AI 只需读 process.md 就能完全恢复

5. **AI 被强制检查 process.md**
   - /go 工作流的第一步就是读 process.md
   - 每完成一个步骤，必须先更新 process.md，再进入下一步
   - 这创造了一个"检查点循环"：做一步 → 更新 process.md → 读 process.md → 做下一步

6. **每个步骤标注所需 Skills**
   - 用 `📎 Skills:` 标注该步骤需要调用的 Skill 及用途
   - AI 进入新步骤时，先读取标注的 Skill 再执行
   - Small 模板不标注（skills 不适用于 small 任务）

---

## 3. 模板设计

### 总览对比

| | Small | Medium | Large |
|---|---|---|---|
| 步骤数 | 3 步 | 7 步 | 11 步 |
| Brainstorming | ❌ 跳过 | ✅ 精简版 | ✅ 完整苏格拉底式 |
| OpenSpec | ❌ | ❌ | ✅ 检测并走分支 |
| 计划文件 | ❌ 不需要 | ✅ task_plan.md | ✅ task_plan.md 或 tasks.md |
| 测试要求 | 有就更新 | 标准 TDD | 严格 TDD |
| 代码审查 | ❌ | 单阶段自审 | 双阶段自审 |
| 🚪 人工 Review | ❌ | ✅ 收尾前门控 | ✅ 收尾前门控 |
| 预估总时间 | < 30 分钟 | 1-4 小时 | > 1 天 |

> **注意**：trivial 级别不生成 process.md，直接做 → 验证 → 完成。

---

### 3.1 Small 模板（3 步，轻量快速）

> 适用场景：改动 ≤ 3 个文件，预计 < 30 分钟。修 bug、添加字段、调整样式。

```markdown
# Process — [任务名称]

## 元信息
- 复杂度: small 🔒（已锁定，不可降级）
- 创建时间: [当前时间]
- 任务概述: [一句话描述]

---

## Step 1: 理解 & 定位
- 状态: ⬜ 未开始
- **关键记录**:
  - 需求理解: [...]
  - 涉及文件: [...]
  - 相关测试: [有/无]

## Step 2: 执行修改
- 状态: ⬜ 未开始
- **关键记录**:
  - 改动内容摘要: [...]
  - 遇到的问题: [...]

## Step 3: 验证 & 完成
- 状态: ⬜ 未开始
- **关键记录**:
  - 验证方式: [运行测试 / 手动验证 / smoke test]
  - 验证结果: [通过/失败]
  - 完成时间: [...]
```

**设计要点**：
- 没有 brainstorming、没有计划文件、没有代码审查
- 3 步直达：理解 → 做 → 验证
- "关键记录"仍然保留，因为即使是 small 任务也可能中断

---

### 3.2 Medium 模板（7 步，标准模式）

> 适用场景：涉及 3+ 文件，预计 1-4 小时。新增 API 端点、实现业务模块。

```markdown
# Process — [任务名称]

## 元信息
- 复杂度: medium 🔒（已锁定，不可降级）
- 创建时间: [当前时间]
- 任务概述: [一句话描述]

---

## Step 1: 需求理解 & Brainstorming
- 状态: ⬜ 未开始
- 开始时间: [...]
- **关键记录**:
  - 用户需求要点: [...]
  - 技术方案选择: [...]
  - 待确认问题: [无 / ...]
  - Expert Mode: [是/否，原因]

## Step 2: 制定计划（writing-plans）
- 状态: ⬜ 未开始
- 开始时间: [...]
- **关键记录**:
  - 计划文件: task_plan.md
  - 子任务数量: [N]
  - ⚠️ 用户是否已确认计划: ⬜ 待确认（必须等用户确认后才能进入 Step 3）

## Step 3: 执行开发（executing）
- 状态: ⬜ 未开始
- 开始时间: [...]
- **关键记录**:
  - 已完成子任务: [ ] / [N]
  - 遇到的错误: [记录到 findings.md]
  - 关键决策变更: [...]

## Step 4: 测试验证
- 状态: ⬜ 未开始
- **关键记录**:
  - 测试方式: [TDD RED-GREEN-REFACTOR / 手动验证 / smoke test]
  - 测试结果: [...]
  - 跳过 TDD 原因: [如适用，参考 AGENTS.md 5.1 节]

## Step 5: 自审 & 安全检查
- 状态: ⬜ 未开始
- **关键记录**:
  - 代码质量检查: [DRY / YAGNI / 错误处理 / 命名]
  - 安全检查: [参考 security-guidance SKILL.md]
  - 发现的问题: [🔴 Critical / 🟠 Important / 🟡 Minor]

## Step 6: 🚪 人工 Review 门控
- 状态: ⬜ 未开始
- **关键记录**:
  - AI 提交 Review 摘要: [改动文件、测试结果、自审结论]
  - ⚠️ 人工审核结果: ⬜ 待审核（必须等用户明确通过后才能继续）
  - 修订轮次记录: [如有修订，每轮追加]

## Step 7: 收尾归档
- 状态: ⬜ 未开始
- **关键记录**:
  - 经验提取: [是/否，文件: docs/learnings/...]
  - 归档路径: .archive/tasks/[时间戳]/
  - 完成时间: [...]

---

> **中断恢复指引**：新会话恢复时，找到状态为 🔄 的 Step，阅读其及之前所有 ✅ Step 的关键记录即可恢复上下文。
```

**设计要点**：
- Step 1 包含精简版 brainstorming（遵守 Expert Mode 快捷通道）
- Step 2 **强制等待用户确认**后才进入执行，防止 AI 自动跳过
- Step 5 单阶段自审，包含安全检查
- Step 6 **🚪 人工 Review 门控**，AI 必须提交 Review 摘要并等待用户审核通过后才能归档
- 中断恢复依赖各 Step 的关键记录，无需额外汇总区

---

### 3.3 Large 模板（11 步，完整模式）

> 适用场景：涉及核心模块，预计 > 1 天，或命中 Large 升级信号。重写认证、数据库迁移、微服务拆分。

```markdown
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
- **关键记录**:
  - **[Path A — OpenSpec]**:
    - 变更目录名: openspec/[name]-[timestamp]/
    - 文档链完成度:
      - proposal（Why）: ⬜
      - specs（What）: ⬜
      - design（How）: ⬜
      - tasks（实施清单）: ⬜
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
- **关键记录**:
  - 总任务数: [N]
  - 已完成: [ ] / [N]
  - 当前批次: [第几批 / 共几批]
  - 人工检查点: [等待用户确认 ⬜]
  - 遇到的错误: [记录到 findings.md]
  - 3-Strike 记录: [同一问题失败次数]

## Step 7: 测试（严格 TDD）
- 状态: ⬜ 未开始
- **关键记录**:
  - RED-GREEN-REFACTOR 轮次: [N]
  - 测试覆盖范围: [...]
  - 测试结果: [全部通过 / 部分失败]

## Step 8: 双阶段自审
- 状态: ⬜ 未开始
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
  - AI 提交 Review 摘要: [改动文件、测试结果、自审结论、与设计文档一致性]
  - ⚠️ 人工审核结果: ⬜ 待审核（必须等用户明确通过后才能继续）
  - 修订轮次记录: [如有修订，每轮追加]

## Step 10: 收尾（finishing-branch）
- 状态: ⬜ 未开始
- **关键记录**:
  - [OpenSpec] /opsx:verify 结果: [通过/问题]
  - [OpenSpec] /opsx:archive 完成: ⬜
  - 分支合并: [...]

## Step 11: 经验提取 & 归档
- 状态: ⬜ 未开始
- **关键记录**:
  - 经验文件: docs/learnings/[date]-[topic].md
  - 归档路径: .archive/tasks/[时间戳]/
  - 完成时间: [...]

---

> **中断恢复指引**：新会话恢复时，找到状态为 🔄 的 Step，阅读其及之前所有 ✅ Step 的关键记录即可恢复上下文。
```

**设计要点**：
- Step 1 和 Step 2 分开：先调研再 brainstorming，确保有足够信息
- Step 3 是独立的 OpenSpec 检测步骤，**不可跳过**
- Step 4 根据 Path A/B 有不同的槽位，但都在同一个步骤里
- Step 6 分批执行，带人工检查点和 3-Strike 记录
- Step 8 双阶段自审（规格 → 质量），比 Medium 多一层
- Step 9 **🚪 人工 Review 门控**，AI 必须提交 Review 摘要并等待用户审核；如需修订则循环回 Step 6/7/8 再返回
- 中断恢复依赖各 Step 的关键记录，找到 🔄 状态的 Step 即可知道断点和上下文

---

## 4. 实现方案

### 4.1 文件变更总览

```
需要新增的文件：
├── .agent/templates/process-small.md      ← Small 模板
├── .agent/templates/process-medium.md     ← Medium 模板
├── .agent/templates/process-large.md      ← Large 模板

需要修改的文件：
├── .agent/builder/common/02-planning.md   ← 重写 planning 规则，指向模板
├── .agent/builder/common/03-scheduler.md  ← 各等级增加"创建 process.md"步骤
├── .agent/workflows/go.md                 ← 恢复逻辑改为基于 process.md 的步骤读取
├── .agent/workflows/reset.md              ← process.md 替代 progress.md
├── .agent/builder/build.sh                ← 确认构建流程正常
├── AGENTS.md（及各平台变体）               ← 由 build.sh 重新构建

需要考虑兼容的文件：
├── .agent/skills/planning-with-files/SKILL.md  ← 更新或标记为被 process.md 取代
├── .agent/skills/auto-learning/SKILL.md        ← 不需要改，仍然独立运工作

可能需要删除/重命名的概念：
├── progress.md → process.md（名称变更，语义升级）
├── task_plan.md → 保留，但定位为 process.md 的附属详细计划
├── findings.md  → 保留，但定位为 process.md 的附属发现记录
```

### 4.2 核心改动详解

#### 改动 1：创建三个模板文件

位置：`.agent/templates/`

| 文件 | 内容 | 来源 |
|------|------|------|
| `process-small.md` | 本文档 3.1 节的 Small 模板 | 直接复制 |
| `process-medium.md` | 本文档 3.2 节的 Medium 模板 | 直接复制 |
| `process-large.md` | 本文档 3.3 节的 Large 模板 | 直接复制 |

AI 创建 process.md 时，复制对应模板，替换占位符即可。

#### 改动 2：重写 02-planning.md

**核心变化**：从"创建 3 个文件 + 阶段转换规则"改为"选择模板 + 创建 process.md"

```markdown
新的核心规则（示意）：

<EXTREMELY-IMPORTANT>
**process.md 是当前任务的唯一导航文件和恢复依据。**

**创建规则：**
- small/medium/large 任务开始时，第一个动作是基于对应模板创建 process.md
- 模板路径：.agent/templates/process-[复杂度].md
- 复杂度一旦写入 process.md 即锁定，不可降级

**执行规则：**
- AI 只能操作状态为 🔄 的步骤
- 完成一个步骤后，必须：
  1. 将该步骤状态改为 ✅，填写关键记录
  2. 将下一个步骤状态改为 🔄
  3. 重新读取 process.md 确认当前位置
- 不得跳过任何 ⬜ 状态的步骤

**附属文件：**
- task_plan.md — 详细计划（Medium/Large 的 writing-plans 步骤产出）
- findings.md — 调研发现和错误记录（2-Action Rule 仍然适用）
- 这两个文件是 process.md 的补充，不是独立的状态源
</EXTREMELY-IMPORTANT>
```

#### 改动 3：修改 03-scheduler.md

**核心变化**：每个等级的流程说明改为"创建 process.md → 按步骤执行"

```
现在的写法（示意）：
  Trivial → 直接做 → 验证
  Small → 直接做 → 验证（不创建 process.md）
  Medium → 创建 process.md（medium 模板）→ 按 Step 1-6 执行
  Large → 创建 process.md（large 模板）→ 按 Step 1-10 执行
```

#### 改动 4：重写 go.md 工作流

**核心变化**：恢复逻辑大幅简化

```
当前 go.md 的恢复逻辑（复杂）：
  读取 progress.md → 判断"阶段"字段 → 查映射表 → 加载对应上下文 → 恢复

新的 go.md 恢复逻辑（简单）：
  读取 process.md → 找到状态为 🔄 的步骤 → 读取该步骤的关键记录 → 继续执行
```

这大幅减少了 go.md 中的逻辑复杂度，因为恢复信息全在 process.md 里，不需要映射表。

#### 改动 5：更新 reset.md

**变化较小**：把 `progress.md` 引用改为 `process.md`，其他逻辑不变。

### 4.3 实施步骤顺序

```
阶段 1：创建模板（无风险，纯新增）
  1. 创建 .agent/templates/process-small.md
  2. 创建 .agent/templates/process-medium.md
  3. 创建 .agent/templates/process-large.md

阶段 2：修改构建源文件（核心改动）
  4. 重写 .agent/builder/common/02-planning.md
  5. 修改 .agent/builder/common/03-scheduler.md
  6. 重写 .agent/workflows/go.md
  7. 更新 .agent/workflows/reset.md

阶段 3：重新构建 & 验证
  8. 运行 .agent/builder/build.sh 重新生成各平台 AGENTS.md
  9. 对比新旧 AGENTS.md，确认内容正确
  10. 用一个 medium 任务实际测试新流程

阶段 4：更新安装脚本
  11. 更新 install.sh，确保模板文件被正确安装
  12. 更新 .gitignore（process.md 是运行时生成文件）
```

---

## 5. 风险和注意事项

### 5.1 向后兼容

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| 已有用户的 progress.md 会失效 | 中断恢复可能失败 | go.md 增加兼容逻辑：如果 progress.md 存在但 process.md 不存在，提示用户迁移 |
| AGENTS.md 变短后对 AI 行为的改变 | AI 可能不知道某些细节规则 | 关键规则仍然内嵌在 AGENTS.md，只是流程步骤移到了模板里 |

### 5.2 模板与现有 Skill 的关系

```
process.md 替代/吸收了：
  ├── progress.md 的全部功能（状态跟踪）
  ├── planning-with-files SKILL.md 的部分规则（文件管理）
  └── AGENTS.md 中的阶段转换表（流程控制）

process.md 不替代：
  ├── task_plan.md（仍然需要，是详细计划）
  ├── findings.md（仍然需要，是调研记录）
  ├── 各 SKILL.md（brainstorming、TDD 等的具体操作指导）
  └── go.md / reset.md（工作流入口）
```

### 5.3 关键设计决策记录

| 决策 | 选择 | 理由 |
|------|------|------|
| 文件名用 process.md 还是 progress.md | **process.md** | 语义更准确：它不只是"进度"，而是"完整流程" |
| Small 是否也需要 process.md | **是** | 即使是 Small 任务也可能中断，3 步清单几乎没有额外成本 |
| Trivial 是否需要 process.md | **否** | 改个变量名不需要建档，过度流程化是浪费 |
| 模板放在模板目录还是 SKILL.md 里 | **模板目录** | 模板是"要复制的文件"，Skill 是"要读的指导"，职责不同 |
| task_plan.md 和 findings.md 是否合并到 process.md | **不合并** | process.md 是"导航"，task_plan.md 是"详细地图"，合并会让 process.md 太长 |

---

## 6. FAQ

**Q: AGENTS.md 会变短多少？**
A: 预计从 572 行减少到约 300-350 行。阶段转换表、大段的恢复映射逻辑都会移到模板和 go.md 中。

**Q: 每次 AI 都要读 process.md，会不会浪费 token？**
A: Small 模板约 30 行，Medium 约 60 行，Large 约 120 行。相比 AGENTS.md 的 572 行，反而更省 token，因为 AI 不再需要每次都从 AGENTS.md 中提取流程信息。

**Q: 如果 AI 还是不按 process.md 执行怎么办？**
A: 这是一个"概率游戏"。当前系统 AI 需要同时理解 572 行规则 + 简短 progress.md，新系统只需要理解一个 process.md。信息密度更高、更集中，AI 跟丢的概率显著降低。如果仍然出问题，用 /go 强制刷新即可。

**Q: 现有的 planning-with-files SKILL.md 怎么处理？**
A: 保留但更新定位。planning-with-files 的核心理念（"文件系统是持久记忆"）仍然有效，只是具体的文件管理规则从 3 文件（progress + task_plan + findings）变成了 1+2 文件（process.md 为主 + task_plan + findings 为辅）。

---

## 7. 下一步

确认本设计方案后，按 4.3 节的实施步骤执行：
1. 先创建三个模板文件
2. 再修改构建源文件
3. 最后重新构建并测试




