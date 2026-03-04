# 程序功能开发 Skills 筛选分析报告

> 目标：从大量 AI Agent Skills 仓库中，筛选出一套**精简、无冗余、专注程序功能开发**的 Skills 组合。

---

## 一、开发者的核心工作流

程序功能开发的日常工作流可以抽象为 **5 个阶段**：

```mermaid
graph LR
    A[需求理解] --> B[架构设计/计划]
    B --> C[编码实现]
    C --> D[测试验证]
    D --> E[代码审查/收尾]
    E -->|迭代| A
```

每个阶段需要不同类型的 Skills 支撑。下面逐一分析你现有的 6 个仓库 + 新发现的仓库，看它们分别覆盖了哪些阶段。

---

## 二、你已有的 6 个仓库深度剖析

### 1. obra/superpowers ⭐⭐⭐⭐⭐

**定位**：完整的敏捷开发方法论框架

| 阶段 | 覆盖的 Skills | 说明 |
|------|-------------|------|
| 需求理解 | `brainstorming` | 头脑风暴、苏格拉底式追问、设计验证 |
| 设计/计划 | `writing-plans` | 拆分为 2-5 分钟的小任务，每个带文件路径和验证步骤 |
| 编码实现 | `executing-plans`, `subagent-driven-development` | 批次处理 + 检查点 或 子代理并发 |
| 测试验证 | `test-driven-development`, `verification-before-completion` | RED-GREEN-REFACTOR + 完成前验证 |
| 审查/收尾 | `requesting-code-review`, `receiving-code-review`, `finishing-a-development-branch` | 代码审查 + 分支收尾 |
| 辅助 | `using-git-worktrees`, `dispatching-parallel-agents`, `systematic-debugging` | Git worktree 隔离、并行代理、系统化调试 |

> **评价**：这是**唯一一个覆盖全流程**的框架，且是强制工作流（不是建议），Agent 自动在每个阶段激活对应 Skill。**必选**。

---

### 2. OthmanAdi/planning-with-files ⭐⭐⭐⭐

**定位**：持久化计划管理（3 文件模式）

| 文件 | 作用 |
|------|------|
| `task_plan.md` | 跟踪阶段和进度 |
| `findings.md` | 存储研究发现 |
| `progress.md` | 会话日志和测试结果 |

**解决的问题**：
- ✅ Agent 上下文丢失后能恢复
- ✅ 50+ 次工具调用后不偏离目标
- ✅ 错误被记录，不会重复犯错

> **评价**：解决了 Agent 长会话中最痛的"失忆"问题。**与 superpowers 互补**——superpowers 管流程，planning-with-files 管状态持久化。**推荐保留**。

---

### 3. affaan-m/everything-claude-code ⭐⭐⭐⭐

**定位**：全方位 Claude Code 配置集合（"瑞士军刀"）

**包含内容**：
- **12+ 子代理**：planner / architect / tdd-guide / code-reviewer / security-reviewer / build-error-resolver / e2e-runner / refactor-cleaner / doc-updater 等
- **40+ Skills**：按语言分类（Go/Python/TS/Java/C++/Django/Spring Boot）+ 通用模式（backend-patterns / frontend-patterns / api-design / docker-patterns / database-migrations）
- **30+ Slash Commands**：`/plan` / `/tdd` / `/code-review` / `/build-fix` / `/e2e` / `/refactor-clean` 等
- **Hooks**：会话生命周期管理、自动 compaction
- **Rules**：编码规范、Git 工作流、安全检查

> **评价**：内容极其丰富，但**大量 Skills 与 superpowers 重叠**（如 TDD、计划、代码审查）。**不适合全装**，应该从中挑选 superpowers 没有的部分：
>
> - ✅ **按需选取**：特定语言的 patterns（如 `python-patterns`、`golang-patterns`）
> - ✅ **按需选取**：`backend-patterns`、`api-design`、`database-migrations`、`docker-patterns`
> - ✅ **按需选取**：`continuous-learning-v2`（从会话中自动提取经验，superpowers 没有）
> - ❌ **不需要**：TDD、plan、code-review（superpowers 已覆盖且更成体系）

---

### 4. EveryInc/compound-engineering-plugin ⭐⭐⭐

**定位**：复合工程方法论

**工作流**：`Plan → Work → Review → Compound → Repeat`

**核心理念**：80% 计划和审查，20% 执行。每次迭代积累知识，让下次更容易。

> **评价**：理念很好，但**核心流程与 superpowers 高度重叠**。superpowers 已经有 brainstorming→planning→executing→reviewing→finishing 的完整流程。compound-engineering 的"Compound"步骤（知识沉淀）是它的独特价值，但可以用 everything-claude-code 的 `continuous-learning-v2` 替代。
>
> **建议**：如果你已选了 superpowers，这个可以**不装**，或只参考其方法论。

---

### 5. numman-ali/openskills ⭐⭐⭐

**定位**：通用 Skills 加载器/包管理器

**作用**：不是 Skill 本身，而是一个**安装和管理 Skills 的 CLI 工具**。支持从 GitHub、本地路径、私有仓库安装 Skills。

> **评价**：这是一个**基础设施工具**而非 Skill。如果你使用 Claude Code 的插件市场，它的价值较小；如果你需要跨工具（Cursor/Windsurf/Aider）共享 Skills，它很有用。
>
> **建议**：看你的工具链。如果只用 Claude Code/Cursor/Antigravity，可以**不装**；如果多工具混用，保留。

---

### 6. Fission-AI/OpenSpec ⭐⭐⭐⭐

**定位**：Spec-Driven Development（规范驱动开发）

**工作流**：
```
/opsx:new → 创建变更文件夹
/opsx:ff  → 自动生成 proposal + specs + design + tasks
/opsx:apply → 逐个实现任务
/opsx:archive → 归档完成的变更
```

**与 superpowers 的区别**：
- superpowers 偏"敏捷开发"——快速迭代、TDD、子代理并发
- OpenSpec 偏"规范开发"——先写规范再编码，每个变更有完整的 proposal/specs/design/tasks 归档

> **评价**：**与 superpowers 是不同风格的互补**。适合需要严谨规范记录的场景（如团队协作、需求可追溯）。
>
> **建议**：如果你是**独立开发快速迭代** → 用 superpowers 即可；如果你需要**需求可追溯、有规范文档** → 加上 OpenSpec。

---

## 三、重叠关系矩阵

下表展示各仓库在关键能力上的覆盖情况。**重叠 = 浪费 token**，我们要消除冗余。

| 能力 | superpowers | planning-with-files | everything-claude-code | compound-engineering | openskills | OpenSpec |
|------|:-:|:-:|:-:|:-:|:-:|:-:|
| **需求分析/头脑风暴** | ✅ 核心 | — | ⚠️ planner agent | ⚠️ Plan 阶段 | — | ✅ proposal |
| **任务拆分/计划** | ✅ 核心 | ✅ 核心 | ⚠️ /plan 命令 | ⚠️ Plan 阶段 | — | ✅ tasks.md |
| **编码实现** | ✅ 核心 | — | ⚠️ 各语言 patterns | ⚠️ Work 阶段 | — | ✅ /apply |
| **TDD/测试** | ✅ 核心 | — | ⚠️ tdd-workflow | — | — | — |
| **代码审查** | ✅ 核心 | — | ⚠️ code-reviewer | ⚠️ Review 阶段 | — | — |
| **调试** | ✅ 核心 | — | ⚠️ build-error-resolver | — | — | — |
| **Git 工作流** | ✅ worktrees | — | ⚠️ git-workflow 规则 | — | — | — |
| **状态持久化/防失忆** | — | ✅ 核心 | ⚠️ memory-persistence | — | — | ⚠️ 文件夹结构 |
| **知识沉淀/学习** | — | — | ✅ continuous-learning-v2 | ✅ Compound 阶段 | — | ✅ archive |
| **多语言编码规范** | — | — | ✅ 独有 | — | — | — |
| **架构模式** | — | — | ✅ backend/frontend/api | — | — | ✅ design.md |
| **安全审查** | — | — | ✅ 独有 | — | — | — |
| **E2E 测试** | — | — | ✅ 独有 | — | — | — |
| **部署/Docker** | — | — | ✅ 独有 | — | — | — |
| **需求规范文档** | — | — | — | — | — | ✅ 独有 |
| **Skills 跨工具管理** | — | — | — | — | ✅ 独有 | — |

> **✅ = 核心能力** | **⚠️ = 有覆盖但不是主要目的** | **— = 不涵盖**
>
> **关键发现**：
> 1. superpowers + planning-with-files 覆盖了开发核心流程 + 状态持久化
> 2. compound-engineering 完全被 superpowers 覆盖，建议淘汰
> 3. everything-claude-code 的**独有价值**在于：多语言编码规范、安全审查、E2E 测试、部署模式
> 4. OpenSpec 的**独有价值**在于：需求规范文档化和归档

---

## 四、最终推荐方案

根据以上分析，推荐 **3 个层级** 的 Skills 组合，从精简到完整：

### 🥇 核心层（必装，覆盖 90% 日常开发）

```
┌─────────────────────────────────────────────────────┐
│  obra/superpowers          → 全流程开发方法论         │
│  OthmanAdi/planning-with-files → 状态持久化/防失忆    │
└─────────────────────────────────────────────────────┘
```

**为什么只需要这两个？**

| 你要做的事 | superpowers 会自动激活 |
|-----------|---------------------|
| 接到新需求 | `brainstorming` → 追问细节、探索方案 |
| 确认方案后 | `using-git-worktrees` → 创建隔离分支 |
| 开始开发 | `writing-plans` → 拆分为小任务 |
| 写代码 | `test-driven-development` → 强制先写测试 |
| 并行开发 | `subagent-driven-development` → 多子代理并发 |
| 开发中途 | `systematic-debugging` → 系统化调试 |
| 代码写完 | `requesting-code-review` → 自动审查 |
| 全部完成 | `finishing-a-development-branch` → 合并/PR |

**planning-with-files 补充什么？**
- Agent 中途断了 → 用 3 个文件恢复上下文
- 长任务跨多个会话 → 进度不丢失

---

### 🥈 增强层（按需添加，补充核心层没有的能力）

从 `everything-claude-code` 中**只选取以下独有 Skills**：

| 你的需求 | 从 ECC 中选取 |
|---------|-------------|
| 用 Python 开发 | `python-patterns/` + `python-testing/` |
| 用 Go 开发 | `golang-patterns/` + `golang-testing/` |
| 用 TypeScript/React 开发 | `frontend-patterns/` + `coding-standards/` |
| 用 Java/Spring Boot 开发 | `springboot-patterns/` + `java-coding-standards/` |
| 需要 REST API 设计指导 | `api-design/` |
| 需要数据库迁移模式 | `database-migrations/` |
| 需要 Docker/部署模式 | `docker-patterns/` + `deployment-patterns/` |
| 需要 E2E 测试 | `e2e-testing/` |
| 想让 Agent 从经验中学习 | `continuous-learning-v2/` |
| 需要安全审查 | `security-review/` + `security-scan/` |

> [!IMPORTANT]
> **不要全装 everything-claude-code！** 只挑选你项目技术栈需要的 Skills。
> 全装会严重浪费 token 并可能与 superpowers 冲突。

---

### 🥉 规范层（团队协作 / 需求可追溯时添加）

```
┌─────────────────────────────────────────────────────┐
│  Fission-AI/OpenSpec       → 需求规范驱动开发         │
└─────────────────────────────────────────────────────┘
```

**什么时候需要？**
- ✅ 团队协作，需要对齐需求
- ✅ 功能需求需要可追溯（审计/合规）
- ✅ 大型功能，需要 proposal → specs → design → tasks 的完整文档链
- ❌ 个人快速开发小功能 → 不需要，superpowers 的 brainstorming 够用

---

### ❌ 建议淘汰

| 仓库 | 原因 |
|------|------|
| **compound-engineering-plugin** | 核心流程被 superpowers 完全覆盖，"知识沉淀"能力被 ECC 的 continuous-learning-v2 替代 |
| **openskills** | 工具层，非 Skill 本身。Claude Code/Cursor 已有内置技能加载机制 |

---

## 五、快速决策树

```
你是什么类型的开发者？
│
├─ 🧑‍💻 个人开发者，快速迭代
│   └─ ✅ superpowers + planning-with-files
│       └─ 按你的技术栈从 ECC 中挑 1-3 个语言/框架 Skills
│
├─ 👥 团队开发者，需要规范
│   └─ ✅ superpowers + planning-with-files + OpenSpec
│       └─ 按你的技术栈从 ECC 中挑 Skills + security-review
│
└─ 🏢 企业级开发，完整工程体系
    └─ ✅ superpowers + planning-with-files + OpenSpec
        └─ 从 ECC 中挑 Skills + security-review + e2e-testing
            + deployment-patterns + docker-patterns
```

---

## 六、实操建议

### 安装顺序

1. **先装 superpowers** — 它会接管你的开发流程
2. **再装 planning-with-files** — 与 superpowers 无冲突，纯互补
3. **按需从 ECC 复制 Skills** — 只复制需要的文件夹到 `.claude/skills/`
4. **如有需要装 OpenSpec** — 独立的规范层，不会与上述冲突

### 避免冲突的关键

- ⚠️ **不要同时装 superpowers 和 compound-engineering**（流程冲突）
- ⚠️ **不要全装 ECC** 的 agents 和 commands（会与 superpowers 的 TDD/plan/review 冲突）
- ✅ ECC 的 `skills/` 目录下的**语言模式和架构模式**可以安全共存（它们是知识参考，不是流程控制）


