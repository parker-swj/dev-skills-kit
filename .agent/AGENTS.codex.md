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

### 3.2 状态持久化 — process.md（一体化清单）

<EXTREMELY-IMPORTANT>
**`process.md` 是当前任务的唯一导航文件和恢复依据。**

**创建规则：**
- small/medium/large 任务开始时，**第一个动作**是基于 `.agent/templates/process-[复杂度].md` 创建 `process.md`
- 复制模板 → 替换占位符 → 将 Step 1 状态设为 🔄
- 复杂度写入即 **🔒 锁定，不可降级**
- trivial 任务不创建 `process.md`

**执行规则（三态系统）：**
- ⬜ 未开始 → 不得操作 ｜ 🔄 进行中 → 唯一可操作的步骤 ｜ ✅ 已完成 → 不再修改
- 完成一个步骤后**立即**：① 改为 ✅ 并填写关键记录 → ② 下一步改为 🔄 → ③ 重新读取 process.md
- **不得跳过** ⬜ 步骤，不得同时有两个 🔄

**附属文件（process.md 的补充，不是独立状态源）：**
- `task_plan.md` — 详细计划（Medium/Large 的 writing-plans 步骤产出）
- `findings.md` — 调研发现和错误记录（2-Action Rule：每 2 次搜索后保存）

**收尾归档（最后一步完成后）：**
1. process.md 最后一步标记 ✅ 并记录完成时间
2. 全部 planning 文件移到 `.archive/tasks/[时间戳]/`
3. 执行 auto-learning
</EXTREMELY-IMPORTANT>

> `process.md` 是 `/go` 工作流的唯一恢复依据，必须始终保持最新状态。

### 3.3 经验沉淀 — auto-learning

| Skill | 路径 |
|-------|------|
| auto-learning | `.agent/skills/auto-learning/SKILL.md` |

**核心规则（内嵌，详细指导见 SKILL.md）：**
- **写入**：medium/large 任务完成验证后，自动提取经验到 `docs/learnings/<date>-<topic>.md`
- **读取**：medium/large 任务开始时，`list_dir` 扫描 `docs/learnings/`，按需读取相关经验

> 无需 Hooks 或外部工具，**所有平台通用**。

### 3.4 技术栈 Skills

> 按需使用 `view_file` 读取对应 SKILL.md 获取编码规范指导。

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
| **large** | 涉及核心模块，预计 > 1 天，**或**命中下方任一升级信号 | 重写认证、数据库迁移、微服务拆分 |

**⚠️ Large 升级信号（命中任一条即升级为 large）：**
- 引入新外部依赖（架构层面改变）
- 引入全新能力/子系统（从零构建）
- 多个交叉关注点（≥ 3 个正交关注点有耦合）
- 跨模块影响（波及多个现有模块的初始化、配置或接口）

> 文件数量和工时是表层指标。架构级信号才是区分 medium 和 large 的关键。

### 各等级激活 Skills 与流程

#### Trivial — 直接做，不创建 process.md

```
激活：verification-before-completion
流程：直接修改 → 验证 → 完成
```

#### Small — 基于 `process-small.md` 模板，3 步

```
激活：systematic-debugging, verification-before-completion, TDD（灵活版）, 技术栈 patterns
跳过：brainstorming, writing-plans, code-review
```

#### Medium — 基于 `process-medium.md` 模板，6 步

```
激活：brainstorming（精简版，遵守 Expert Mode）, writing-plans, executing-plans,
      TDD, requesting-code-review, finishing-a-development-branch,
      systematic-debugging, verification-before-completion, security-guidance,
      技术栈 patterns + auto-learning
跳过：using-git-worktrees（可选）、OpenSpec
```

#### Large — 基于 `process-large.md` 模板，10 步

```
激活：全部 skills（通过 view_file 按需读取对应 SKILL.md）
强制会话分割：在 process.md 的「会话分割记录」节记录断点
```

<EXTREMELY-IMPORTANT>
**Large Step 3 — OpenSpec 检测（brainstorming 之后，必须执行）：**

1. 检查项目根目录是否存在 `openspec/` 文件夹
2. **存在** → 走 OpenSpec 分支（Step 4 的 Path A）
3. **不存在** → 走 writing-plans 分支（Step 4 的 Path B）
4. **不得跳过检测**直接进入 writing-plans
</EXTREMELY-IMPORTANT>
> **注意：不使用 `subagent-driven-development`。** 使用你本机的 Agent 执行控制机制往往更能把握全流程。

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
| 数据库迁移 | 迁移前后数据一致性校验 |
| 基础设施代码 (IaC) | dry-run + plan 输出审查 |

> 跳过 TDD 时必须在 `findings.md` 中记录原因和替代验证方式。

### 5.2 Expert Mode 快捷通道

当用户在请求中已给出以下信息中的 **3 项以上**时，自动进入 Expert Mode：
- 技术栈选择、具体实现方案、接口设计、数据结构

**Expert Mode 行为**：跳过苏格拉底式逐一提问 → 直接确认理解 → 补充遗漏点 → 进入 writing-plans

### 5.3 遗留代码库适配

- **不要求全局绿色基线**，改为局部基线
- **渐进式引入测试**：新代码必须有测试，旧代码先写 characterization test

### 5.4 灾难恢复

- 同一问题 3 次修复失败 → 暂停并请求人工介入（3-Strike Protocol）
- 关键操作前 → 创建 `git tag` 作为安全回滚点
- 上下文过大 → 主动保存状态到 `process.md` 当前步骤的关键记录

### 5.5 防遗忘防护（Anti-Context-Decay）

<EXTREMELY-IMPORTANT>
**无论上下文多长都必须执行：**
1. **完成前必须验证**（verification-before-completion）
2. **重大决策前重新读取 process.md / task_plan.md**
3. **每 2 次搜索/浏览后保存发现到 findings.md**
4. **3 次失败后停止并请求人工介入**
</EXTREMELY-IMPORTANT>

**大任务会话分割**：Large 任务在设计完成、执行完成等自然断点主动分割会话，在 process.md 的「会话分割记录」节记录断点。

---
## 6. 代码审查

Codex Agent 拥有优秀的自我校验准度，任务完成后直接执行**自审**：

- **Medium**（process.md Step 5）：单阶段自审 — 代码质量（DRY/YAGNI/错误处理/命名）+ 安全检查
- **Large**（process.md Step 8）：双阶段自审 — 先规格合规（对照 task_plan.md 逐项）→ 再代码质量 + 安全

> 审查结果分级：🔴 Critical（立即修复）/ 🟠 Important（继续前修复）/ 🟡 Minor（记录到 findings.md）

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
| Claude Code `TodoWrite` | 已由 process.md 一体化清单替代 |
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
├── .agent/templates/
│   ├── process-small.md           ← Small 模板（3 步）
│   ├── process-medium.md          ← Medium 模板（6 步）
│   └── process-large.md           ← Large 模板（10 步）
├── .agent/workflows/
│   └── save-to-kb.md              ← 工作流
├── process.md                     ← 运行时生成（基于模板，一体化清单）
├── task_plan.md                   ← 运行时生成（process.md 附属）
└── findings.md                    ← 运行时生成（process.md 附属）
```
