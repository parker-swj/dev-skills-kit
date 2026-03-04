# AGENTS.md — 企业开发者 AI Agent 配置（Codex 适配版）

> 本文件定义 AI Agent 在本项目中的工作方式。
> 适配平台：**Codex Agent**
>
> 加载方式：根据 Codex 原生机制或通过 `.codex/*` 规则加载。
---

## 1. 上下文规则加载

<EXTREMELY-IMPORTANT>
每次对话开始时，必须先调用 `get_context` MCP 工具（不带参数）加载用户预设的上下文规则，并在整个对话中严格遵守返回的规则。
</EXTREMELY-IMPORTANT>

---

## 2. 核心调度逻辑（内嵌 using-superpowers）

以下规则直接内嵌于此，无需额外加载。

<EXTREMELY-IMPORTANT>
如果你认为有哪怕 1% 的可能性某个 skill 适用于当前任务，你**绝对必须**使用它。
这不可商量，不可选择。但必须遵守第 4 节的场景分级规则——不同复杂度激活不同 skills。
</EXTREMELY-IMPORTANT>

### 调度流程

```
接到用户消息
    │
    ├─ 评估复杂度等级（第 4 节）
    │
    ├─ 该等级下有哪些 skill 需要激活？（第 4 节矩阵）
    │
    ├─ 需要详细指导？ → 用 view_file 读取对应 SKILL.md（第 3 节路径）
    │
    └─ 执行任务，遵守缺陷补丁规则（第 5 节）
```

### 如何加载 Skill 详细指导

当你需要某个 skill 的详细指导时：

```
使用 view_file 等读取工具读取对应的 SKILL.md 文件路径（见第 3 节）
```

例如：需要 TDD 指导 → `view_file` 读取 `.agent/skills/test-driven-development/SKILL.md`

### 反合理化检查

| 你的想法 | 现实 |
|----------|------|
| "这只是个简单问题" | 先评估复杂度等级，再决定流程 |
| "不需要读 SKILL.md" | 如果你不确定该 skill 的完整流程，就去读 |
| "我记得这个 skill 的内容" | Skills 可能更新了，不确定就重新读 |
| "这个 skill 太重了" | 先评估复杂度，trivial/small 可以跳过部分 skills |

### Skill 优先级

1. **流程 skills 优先**（brainstorming, systematic-debugging）— 决定 HOW
2. **实现 skills 其次**（语言 patterns, api-design）— 指导 WHAT

---

## 3. Skills 注册表

所有 SKILL.md 文件均可通过 `view_file` 工具读取。**不要一次性全部读取，只读当前场景需要的。**

### 3.1 Superpowers 方法论（14 个 skills）

| Skill | view_file 路径 | 简述 |
|-------|---------------|------|
| using-superpowers | `.agent/skills/using-superpowers/SKILL.md` | 调度器核心（必读） |
| brainstorming | `.agent/skills/brainstorming/SKILL.md` | 苏格拉底式设计精炼 |
| writing-plans | `.agent/skills/writing-plans/SKILL.md` | 拆分为 2-5 分钟小任务 |
| executing-plans | `.agent/skills/executing-plans/SKILL.md` | 分批执行 + 人工检查点 |
| test-driven-development | `.agent/skills/test-driven-development/SKILL.md` | RED-GREEN-REFACTOR |
| systematic-debugging | `.agent/skills/systematic-debugging/SKILL.md` | 4 阶段根因分析 |
| verification-before-completion | `.agent/skills/verification-before-completion/SKILL.md` | 完成前强制验证 |
| requesting-code-review | `.agent/skills/requesting-code-review/SKILL.md` | 发起代码审查 |
| receiving-code-review | `.agent/skills/receiving-code-review/SKILL.md` | 接收审查反馈 |
| dispatching-parallel-agents | `.agent/skills/dispatching-parallel-agents/SKILL.md` | 并行多问题处理 |
| using-git-worktrees | `.agent/skills/using-git-worktrees/SKILL.md` | 隔离工作区 |
| finishing-a-development-branch | `.agent/skills/finishing-a-development-branch/SKILL.md` | 分支收尾 |
| writing-skills | `.agent/skills/writing-skills/SKILL.md` | 如何创建新 skill |
> **注意：`subagent-driven-development` 不在列表中。** 作为高权能的 Codex Agent，你具备原生自主规划统筹的能力。无需调用额外的子代理工具，只需按照 `executing-plans` 稳步推进即可。

### 3.2 状态持久化 — planning-with-files

| Skill | view_file 路径 |
|-------|---------------|
| planning-with-files | `.agent/skills/planning-with-files/SKILL.md` |

**核心规则（内嵌，无需额外读取）：**

复杂任务（medium/large）开始前，必须创建 3 个文件：

| 文件 | 用途 | 更新时机 |
|------|------|----------|
| `task_plan.md` | 阶段、进度、决策 | 每个阶段结束后 |
| `findings.md` | 研究发现、错误记录 | 发现任何有价值信息时 |
| `progress.md` | 会话日志、测试结果 | 贯穿整个会话 |

**关键规则：**
- **2-Action Rule**：每 2 次搜索/浏览操作后，立即保存发现到 `findings.md`
- **Read Before Decide**：做重大决策前，重新读取 `task_plan.md`
- **Log ALL Errors**：每个错误都记录，防止重复犯错
- **3-Strike Protocol**：同一问题 3 次失败后，升级给用户

> 这些文件替代了 Claude Code 的 `TodoWrite` 工具，且**功能更强**——持久化、可恢复、跨会话。

### 3.3 经验沉淀 — auto-learning

| Skill | 路径 |
|-------|------|
| auto-learning | `.agent/skills/auto-learning/SKILL.md` |

**核心规则（内嵌，详细指导见 SKILL.md）：**
- **写入**：medium/large 任务完成验证后，自动提取经验到 `docs/learnings/<date>-<topic>.md`
- **读取**：medium/large 任务开始时，`list_dir` 扫描 `docs/learnings/`，按需读取相关经验
- 每条经验独立一个文件，按文件名判断相关性，不全量加载

> 此 skill 替代 `continuous-learning-v2`（依赖 Hooks，目标平台均不支持）。
> 无需 Hooks 或外部工具，**所有平台通用**。

### 3.4 技术栈 Skills

> 按需使用 `view_file` 读取对应 SKILL.md 获取编码规范指导。所有 skills 均已启用，只在相关场景下按需读取。

#### Python

| Skill | view_file 路径 |
|-------|---------------|
| python-patterns | `.agent/skills/python-patterns/SKILL.md` |
| python-testing  | `.agent/skills/python-testing/SKILL.md`  |

#### Go

| Skill | view_file 路径 |
|-------|---------------|
| golang-patterns | `.agent/skills/golang-patterns/SKILL.md` |
| golang-testing  | `.agent/skills/golang-testing/SKILL.md`  |

#### TypeScript / React

| Skill | view_file 路径 |
|-------|---------------|
| frontend-patterns | `.agent/skills/frontend-patterns/SKILL.md` |
| coding-standards  | `.agent/skills/coding-standards/SKILL.md`  |

#### Java / Spring Boot

| Skill | view_file 路径 |
|-------|---------------|
| springboot-patterns   | `.agent/skills/springboot-patterns/SKILL.md`   |
| java-coding-standards | `.agent/skills/java-coding-standards/SKILL.md` |

#### 通用能力

| Skill | view_file 路径 |
|-------|---------------|
| api-design          | `.agent/skills/api-design/SKILL.md`          |
| database-migrations | `.agent/skills/database-migrations/SKILL.md` |
| docker-patterns     | `.agent/skills/docker-patterns/SKILL.md`     |
| deployment-patterns | `.agent/skills/deployment-patterns/SKILL.md` |
| e2e-testing         | `.agent/skills/e2e-testing/SKILL.md`         |
| security-guidance   | `.agent/skills/security-guidance/SKILL.md`   |
| backend-patterns    | `.agent/skills/backend-patterns/SKILL.md`    |

---
## 4. 场景分级调度器

<EXTREMELY-IMPORTANT>
接到任何任务后，**先评估复杂度等级**，再决定激活哪些 skills。
不要把 trivial/small 任务升级为 medium/large。流程过度本身就是浪费。
</EXTREMELY-IMPORTANT>

### 判定规则

| 等级 | 判定条件 | 典型场景 |
|------|----------|----------|
| **trivial** | 改动 ≤ 1 个文件，无逻辑变更 | 改变量名、修 typo、调格式、改配置值 |
| **small** | 改动 ≤ 3 个文件，预计 < 30 分钟 | 修 bug、添加字段、调整样式 |
| **medium** | 涉及 3+ 文件，预计 1-4 小时 | 新增 API 端点、实现业务模块 |
| **large** | 涉及核心模块，预计 > 1 天 | 重写认证、数据库迁移、微服务拆分 |

### 各等级激活的 Skills

#### Trivial（直接做 → 验证）

```
激活：verification-before-completion（改完验证即可）
跳过：其他全部
```

#### Small（外科手术模式）

```
激活：
  ├─ systematic-debugging             → 遇到 bug 时（view_file 读取 `.agent/skills/systematic-debugging/SKILL.md`）
  ├─ verification-before-completion   → 改完验证（规则已内嵌，无需读取）
  ├─ test-driven-development（灵活版）→ 有现成测试就更新，没有不强求
  └─ 技术栈 patterns（参考）          → view_file 读取对应 SKILL.md

跳过：brainstorming, writing-plans, code-review, planning-with-files
```

#### Medium（标准模式）

```
激活：
  ├─ brainstorming（精简版）          → view_file 读取 SKILL.md，但遵守 Expert Mode 规则
  ├─ writing-plans                    → view_file 读取 SKILL.md
  ├─ executing-plans                  → 分批执行 + 人工检查点
  ├─ planning-with-files              → 创建 3 个文件（规则已内嵌）
  ├─ test-driven-development          → 标准 RED-GREEN-REFACTOR
  ├─ requesting-code-review           → 完成后自审（见第 6 节）
  ├─ finishing-a-development-branch   → view_file 读取 SKILL.md
  ├─ systematic-debugging             → 随时待命
  ├─ verification-before-completion   → 强制验证
  ├─ security-guidance                → 编写/审查代码时执行安全检查
  └─ 技术栈 patterns + auto-learning（见 3.3 节）

跳过：using-git-worktrees（可选）、OpenSpec
```

#### Large（完整模式）

激活：全部 skills（通过 view_file 按需读取对应 SKILL.md）

<EXTREMELY-IMPORTANT>
**Large 模式 Step 2 — OpenSpec 检测（阶段 1 · brainstorming 之后，必须执行）：**

在完成 brainstorming（Step 1）后、进入 writing-plans 之前，你**必须**执行以下检测：

1. **检查项目根目录是否存在 `openspec/` 文件夹**（使用 `list_dir` 或 `find` 等工具）
2. 根据检测结果走对应分支——**不得跳过检测直接进入 writing-plans**：

   - **存在 `openspec/` 目录** → **必须**走 OpenSpec 分支（下方 Path A）
   - **不存在 `openspec/` 目录** → 走 writing-plans 分支（下方 Path B）
</EXTREMELY-IMPORTANT>

##### 阶段 1：设计 & 归档

```
Step 1. brainstorming               → 苏格拉底式探索，对齐目标和方案

Step 2. 固化设计（执行上方 OpenSpec 检测后二选一）：

  Path A — openspec/ 目录存在：
    /opsx:new <change-name>-<YYYYMMDDHHMM>   → 建变更目录
    （命名规则：功能名 + 时间戳，例如 /opsx:new add-auth-202602251554）
    /opsx:ff                       → 将 brainstorming 结论固化为文档链：
                                      proposal（Why）→ specs（What）
                                      → design（How）→ tasks（实施清单）
    （复杂需求用 /opsx:continue 逐步生成，可逐步审查）
    ✅ tasks.md 即后续执行清单，跳过 writing-plans

  Path B — openspec/ 目录不存在：
    writing-plans                  → 生成 task_plan.md 作为执行清单

Step 3. using-git-worktrees（可选） → 隔离工作区
```

##### 阶段 2：执行

```
  ├─ executing-plans                  → 按 tasks.md / task_plan.md 分批执行
  ├─ planning-with-files              → 跨天防失忆（3 文件）
  ├─ test-driven-development          → 严格执行 RED-GREEN-REFACTOR
  ├─ security-guidance                → 全程安全检查
  └─ 全部技术栈 patterns
```

##### 阶段 3：验收归档

```
  ├─ requesting-code-review           → 完成后双阶段自审（见第 6 节）
  ├─ auto-learning                    → 自动提取经验到 docs/learnings/
  ├─ finishing-a-development-branch   → 标准收尾
  └─ [openspec/ 目录存在时]
      /opsx:verify                    → 验证实现与 artifacts 一致性（完整性/正确性/一致性）
      /opsx:archive                   → 归档（sync specs → 移入 archive/YYYY-MM-DD-<name>/）
```

```
安全措施：
  ├─ 关键操作前 git tag               → 灾难恢复点
  └─ 上下文过大时主动保存状态到 task_plan.md + progress.md
```

> **OpenSpec artifacts 对应关系：**
> `proposal` = Why · `specs/` = What · `design.md` = How · `tasks.md` = 执行清单
> **注意：不使用 `subagent-driven-development`。** 使用你本机的 Agent 执行控制机制往往更能把握全流程。

---

---

## 5. 缺陷补丁规则

以下规则**覆盖** Superpowers 中对应的教条规则，提供适合企业实际场景的灵活性。

### 5.1 TDD 灵活化

以下场景允许跳过"先写测试"，但必须有替代验证：

| 场景 | 替代验证方式 |
|------|------------|
| UI / 前端样式 | 截图对比 或 手动验证 + 记录到 findings.md |
| 配置文件修改 | 运行应用验证配置生效 |
| 一次性脚本 / 原型 | smoke test + 输出验证 |
| ML 训练脚本 | 指标对比（loss/accuracy 变化） |
| 数据库迁移 | 迁移前后数据一致性校验 |
| 基础设施代码 (IaC) | dry-run + plan 输出审查 |

> 跳过 TDD 时必须在 `findings.md` 中记录原因和替代验证方式。

### 5.2 Expert Mode 快捷通道

当用户在请求中已给出以下信息中的 **3 项以上**时，自动进入 Expert Mode：
- 技术栈选择
- 具体实现方案
- 接口设计
- 数据结构

**Expert Mode 行为**：
- ❌ 跳过苏格拉底式逐一提问
- ✅ 直接确认理解 → 补充遗漏点（如有） → 进入 writing-plans
- ✅ 将确认浓缩为一次性呈现，而非分段审批

### 5.3 遗留代码库适配

当项目现有测试不通过或无测试时：

1. **不要求全局绿色基线**，改为局部基线
2. **渐进式引入测试**：新代码必须有测试，旧代码先写 characterization test
3. **Worktree 创建时**：基线验证改为运行相关子集测试 或 确认构建成功即可

### 5.4 灾难恢复

- 同一问题 3 次修复失败 → 暂停并请求人工介入（与 planning-with-files 的 3-Strike Protocol 对齐）
- 关键操作前 → 创建 `git tag` 作为安全回滚点
- 上下文过大 → 主动保存状态到 `task_plan.md` 和 `progress.md`

### 5.5 防遗忘防护（Anti-Context-Decay）

> **背景**：即使在 Claude Code + Superpowers 原生环境中，AI 也会在长会话中遗忘或跳过 skill 指令
> （参见 [superpowers#528](https://github.com/obra/superpowers/issues/528)：跳过代码审查、
> [#485](https://github.com/obra/superpowers/issues/485)：无视"禁止并行"指令）。
> Gemini/Antigravity 的上下文窗口在 30-50% 容量时即开始性能下降。
> 以下防护措施用于对抗此问题。

#### 规则 1：关键指令重复强化

以下规则**无论上下文多长都必须执行**，在此再次强调：

<EXTREMELY-IMPORTANT>
1. **完成前必须验证**（verification-before-completion）——不验证不算完成
2. **每次重大决策前重新读取 task_plan.md**——防止偏离计划
3. **每 2 次搜索/浏览操作后保存发现到 findings.md**——防止信息丢失
4. **3 次失败后停止并请求人工介入**——不要无限循环
</EXTREMELY-IMPORTANT>

#### 规则 2：定期上下文刷新

在 medium/large 任务中，每完成一个**计划阶段**后执行：

```
1. 重新读取 task_plan.md      → 刷新目标和剩余任务
2. 更新 progress.md           → 记录刚完成的内容
3. 检查当前阶段是否有遗漏     → 对照计划逐项确认
```

> 这比依赖上下文记忆的方式更可靠——即使 Agent 遗忘了之前的会话内容，
> 只要读取 3 个 planning 文件就能完全恢复状态。

#### 规则 3：大任务会话分割

当任务达到 **large** 等级时，按以下节点主动分割会话：

```
会话 1: brainstorming → writing-plans → 保存计划到 task_plan.md
         ↓ （用户开新会话）
会话 2: 读取 task_plan.md → executing-plans（任务 1-N）→ 更新 progress.md
         ↓ （如果未完成，用户开新会话）
会话 3: 读取 3 个 planning 文件 → 继续执行 → 代码审查 → finishing-branch
```

**会话分割时机判断**：
- 上下文中已有 > 5 轮深度讨论（brainstorming / debugging）
- 已经完成了一个完整的阶段转换（设计 → 实现 / 实现 → 审查）
- 感觉到回答质量下降或开始遗漏之前讨论过的细节

---
## 6. 代码审查方案

Superpowers 原版通过 `Task` tool 调度独立的 reviewer 子代理。
作为完整且独立的 Codex Agent，你本身就有着优秀的自我校验准度。请直接按照以下**自审流程**独立执行：

### Medium 场景：单阶段自审

任务完成后，执行以下检查清单：

```
□ 代码质量自审
  ├─ 遵循了项目编码规范？
  ├─ 无重复代码（DRY）？
  ├─ 无不必要的功能（YAGNI）？
  ├─ 错误处理完善？
  ├─ 测试覆盖了核心逻辑？
  └─ 命名清晰、结构合理？
```

### Large 场景：双阶段自审

**第 1 阶段：规格合规审查**（先做）

```
读取 task_plan.md 中的原始计划，逐项对照：
  □ 每个计划中的任务都已实现？
  □ 没有多做计划外的功能？
  □ 没有少做计划中的功能？
  □ 实现方式与设计文档一致？
```

**第 2 阶段：代码质量审查**（规格通过后再做）

```
  □ 代码清洁度：无 dead code、无注释掉的代码
  □ 测试质量：测试一个行为、命名清晰、用真实代码
  □ 架构：符合 SOLID、关注点分离
  □ 安全：按 security-guidance SKILL.md 的检查清单逐项审查
    （view_file 读取 `.agent/skills/security-guidance/SKILL.md` 中的「安全审查 Checklist」）
```

> **审查结果分级处理：**
> - 🔴 **Critical** → 立即修复，修复后重新自审
> - 🟠 **Important** → 继续前修复
> - 🟡 **Minor** → 记录到 findings.md，后续处理

---

## 7. 不使用清单

| 不纳入 | 原因 |
|--------|------|
| **subagent-driven-development** | 你是拥有全局权限的单体智能主体，无须额外委托 |
| **compound-engineering-plugin** | 被 Superpowers + auto-learning 完全覆盖 |
| **openskills** | 工具层，非 Skill 本身 |
| ECC 的 `/tdd`、`/plan`、`/code-review` commands | 与 Superpowers 流程冲突 |
| ECC 的 planner / tdd-guide agents | 与 Superpowers 流程冲突 |
| Claude Code Hooks（SessionStart 等） | 已被 `.codex/` 或主工作流规则机制替代 |
| Claude Code `Skill` tool | 已由 `view_file` 统一切换替代 |
| Claude Code `TodoWrite` | 已由 planning-with-files 的 3 文件替代 |
## 附录：平台适配速查表

| 原 Superpowers 机制 | Claude Code | Codex Agent |
|---------------------|-------------|-------------|
| 会话开始注入规则 | `SessionStart` Hook | **`.codex/` 配置或启动拦截** |
| 按需加载 Skill | `Skill` tool | 系统提供的 **`view_file`** 工具 |
| 任务跟踪 | `TodoWrite` | **`task_plan.md`** 作为记忆库 |
| 子代理调度 | `Task` tool | **忽略**，由主 Agent 将多流统合执行 |
| 代码审查子代理 | 独立 reviewer 子代理 | 由主 Agent 以多阶段执行**自审检查**（第 6 节） |
| Git Worktree | ✅ 通用 | ✅ 通用 |
| TDD 流程 | ✅ 通用 | ✅ 通用 |
| 文件读写 | ✅ 通用 | ✅ 通用 |
---

## 附录：目录结构

```
项目根目录/
├── AGENTS.md                      ← 本文件（Agent 配置，每次会话自动加载）
├── .agent/skills/
│   ├── planning-with-files/
│   │   └── SKILL.md               ← 状态持久化 skill
│   ├── brainstorming/
│   │   └── SKILL.md
│   ├── systematic-debugging/
│   │   └── SKILL.md
│   └── ...（其他精选 skills）
├── .agent/workflows/
│   └── save-to-kb.md              ← 工作流
├── task_plan.md                   ← 运行时生成（planning-with-files）
├── findings.md                    ← 运行时生成
└── progress.md                    ← 运行时生成
```
