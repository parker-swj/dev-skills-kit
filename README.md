# dev-skills-kit

**对主流开源 AI 开发 Skills 的优点提纯——去掉教条，保留精华，补上缺失。**

运行一条命令，就能把从多个开源仓库中精选的 ~33 个 AI Skills（涵盖方法论、技术栈规范、状态持久化）安装进你的项目，并自动适配 Antigravity、Cursor、Codex、OpenCode、Gemini CLI、Claude Code 六个 AI 平台。

---

## 为什么需要这个项目？

市面上已经有很多优秀的 AI 编程 Skills 开源项目，但**每个都有明显的短板**。直接使用任何单一项目，你都会遇到问题：

### 上游项目的优点与缺点

#### [superpowers](https://github.com/obra/superpowers) — 开发方法论框架

**✅ 优点：唯一覆盖完整开发流程的框架**
- 14 个 Skills 组成严格有序的开发管线：需求分析 → 设计 → 计划 → TDD → 代码审查 → 分支收尾
- "反合理化"防御设计——预判并封堵 AI 跳过规则的借口
- 三层质量保障：TDD + 双阶段审查 + 验证核查门
- 将人类的软件工程最佳实践编码为 AI 可执行的标准操作程序

**❌ 缺点：过度理想化，现实中处处碰壁**
- 🔴 **小任务流程过载**：改个变量名也要走 brainstorming → 计划 → worktree → 子代理 → 审查 6 步流程
- 🔴 **Token 爆炸**：每个任务 3 个子代理（实现者 + 规格审查 + 质量审查），10 个任务 ≥ 30 次子代理调用
- 🔴 **平台强绑定**：深度依赖 Claude Code 的 `Task` tool / `Skill` tool / `TodoWrite`，其他平台无法直接使用
- 🟠 **TDD 教条化**："先写测试，没有例外"——但 UI、配置文件、ML 脚本、IaC 并不适合严格 TDD
- 🟠 **假设干净代码库**：要求启动时测试全绿，遗留代码库直接卡在第一步
- 🟡 **用户疲劳**：苏格拉底式逐个追问，经验丰富的开发者 30 分钟回答完问题才能开始写代码
- 🟡 **无学习机制**：Skills 是静态文档，没有从执行历史中自动积累经验的能力

#### [everything-claude-code](https://github.com/affaan-m/everything-claude-code) — 全方位配置集合

**✅ 优点：覆盖面极广的技术栈规范**
- 40+ Skills 按语言分类（Go / Python / TypeScript / Java / Spring Boot）
- 覆盖 Superpowers 没有的领域：安全审查、E2E 测试、Docker 部署、数据库迁移
- `continuous-learning-v2` 提供经验沉淀能力

**❌ 缺点：大而全但缺乏体系**
- 🔴 **与 Superpowers 大量冲突**：TDD、计划、代码审查流程各有一套，同时启用会打架
- 🟠 **全量加载浪费 Token**：所有规则塞进单个大文件，每次会话全量注入上下文
- 🟡 **经验沉淀依赖 Hooks**：`continuous-learning-v2` 需要 Claude Code Hooks，其他平台不可用

#### [planning-with-files](https://github.com/OthmanAdi/planning-with-files) — 状态持久化

**✅ 优点：解决 AI 长会话"失忆"痛点**
- 3 个文件（`task_plan.md` / `findings.md` / `progress.md`）让 Agent 上下文丢失后能完全恢复
- 2-Action Rule 防止信息丢失，3-Strike Protocol 防止无限循环

**❌ 缺点：纯工具，缺乏方法论指导**
- 🟡 只管"记住状态"，不管"怎么做开发"——需要与方法论框架配合才有意义

#### [OpenSpec](https://github.com/Fission-AI/OpenSpec) — 规范驱动开发

**✅ 优点：需求可追溯的完整文档链**
- proposal（Why）→ specs（What）→ design（How）→ tasks（执行清单）完整归档
- 适合团队协作和审计合规场景

**❌ 缺点：只适合大型任务**
- 🟡 对日常中小型开发来说流程过重，90% 的任务用不上

### 本项目的本质

**dev-skills-kit 不是简单打包**——它是对上述各家优点的**提纯**，加上缺陷的**补丁**：

| 上游问题 | 提纯方案 |
|----------|----------|
| Superpowers 小任务流程过载 | **场景分级调度器**：trivial / small / medium / large 四级，改变量名 2 秒做完，重构系统走完整方法论 |
| Superpowers TDD 教条化 | **TDD 灵活化**：UI 用截图对比、配置用运行验证、IaC 用 dry-run，跳过时记录原因 |
| Superpowers 平台强绑定 | **模块化构建六端配置**：一套源码生成 Antigravity / Cursor / Codex / OpenCode / Gemini CLI / Claude Code 各自的最优配置 |
| ECC 经验沉淀依赖 Hooks | **零 Hooks 的 auto-learning**：纯文件驱动，任务完成自动提取经验，新任务按需检索，所有平台通用 |
| ECC 与 Superpowers 冲突 | **冲突消解**：方法论用 Superpowers，技术栈规范从 ECC 精选，去掉重叠的 TDD/plan/review agents |
| 所有规则全量注入浪费 Token | **按需加载**：AGENTS.md 只含调度骨架，具体 SKILL.md 按任务复杂度动态读取 |
| AI 长会话遗忘规则 | **process.md 统一状态管理** + 定期刷新 + `/go` 手动重载 |
| Superpowers 缺少学习机制 | **auto-learning** 自动沉淀经验到 `docs/learnings/`，后续任务按文件名检索 |
| Superpowers 用户疲劳 | **Expert Mode**：用户提供 3+ 项需求细节时，跳过苏格拉底追问，直接确认 → 开干 |
| AI 中断后丢失上下文 | **process.md 模板系统**：统一导航 + 状态机，中断恢复时 `/go` 读取 process.md 即可全面恢复 |

> **一句话总结**：Superpowers 的方法论是骨架，缺陷补丁是关节，ECC 的技术 Skills 是肌肉，process.md 是记忆。四者提纯组合，灵活分级，才是适合真实项目的最优解。

---

## 它具体做了什么？

从 [superpowers](https://github.com/obra/superpowers)（开发方法论）、[everything-claude-code](https://github.com/affaan-m/everything-claude-code)（技术栈规范）、[planning-with-files](https://github.com/OthmanAdi/planning-with-files)（状态持久化）等优质开源项目中精选 Skills，经过冲突消解、缺陷补丁、平台适配后，整合为一套可一键安装的配置集：

| 你遇到的问题 | dev-skills-kit 的解法 |
|-------------|----------------------|
| 优质 Skills 散落在多个 GitHub 仓库，收集维护成本高 | 从上游精选 ~33 个 Skills，一条命令全部装好 |
| 所有规则塞进一个大文件，每次会话全量加载浪费 Token | 拆分为独立 SKILL.md，AI 按当前任务按需读取 |
| 各 AI 平台能力不同，同一套提示词效果差异大 | 从共享源码模块化构建各平台专属配置 |
| 好的工作流靠复制粘贴同步，项目间容易偏离 | 中央仓库维护，`install.sh` 统一分发更新 |

---

## 快速开始

### 第 1 步：获取仓库（一次性操作）

```bash
git clone https://github.com/parker-swj/dev-skills-kit.git ~/dev-skills-kit
```

### 第 2 步：安装到目标项目（二选一）

#### 方式一：让 AI 帮你装（最简单 ⭐）

在你的目标项目目录下，打开任意 AI 编程助手（Antigravity、Cursor、Codex、OpenCode 等），对 AI 说：

```
请阅读 ~/dev-skills-kit/AI_INSTANCE.md 并按照说明安装到当前项目
```

AI 会读取安装指引，自动执行 `install.sh`，全程无需手动操作。

#### 方式二：手动运行脚本

```bash
~/dev-skills-kit/install.sh /path/to/your-project
```

两种方式都会自动完成以下全部工作：

- ✅ 从 `github-source/` 精选并复制 ~27 个上游 SKILL.md 到 `.agent/skills/`
- ✅ 复制 6 个本地维护的 Skills（auto-learning、planning-with-files、security-guidance、systematic-debugging、test-driven-development、verification-before-completion）
- ✅ 运行 `build.sh` 构建四端 AGENTS 配置文件
- ✅ 分发各平台专属拦截规则（`.cursor/rules/`、`.codex/`、`.opencode/`、`.gemini/`、`.claude/`）
- ✅ 复制 process.md 模板到 `.agent/templates/`（small / medium / large 三种复杂度）
- ✅ 复制工作流到 `.agent/workflows/` 和各平台的命令目录
- ✅ 将 Antigravity 适配版配置写入根目录 `AGENTS.md`（支持标记区块更新）
- ✅ 安装并初始化 OpenSpec（大型任务规范归档，可选）
- ✅ 自动更新目标项目 `.gitignore`（排除 AI 工具运行时文件）

> 首次运行时，如果 `github-source/` 不存在，脚本会自动调用 `update-sources.sh` 拉取上游源码。

### 第 3 步：开始使用

安装后无需额外配置。AI Agent 进入项目后会自动加载对应平台的规则，并根据任务场景按需读取相关 SKILL.md。

---

## 核心设计

### Process-Driven Workflow（核心创新）

传统的 `AGENTS.md`（规则）+ `progress.md`（状态）分离模式在长会话中容易导致 AI "失忆"和复杂度衰变。dev-skills-kit 引入了统一的 **process.md 模板系统**：

```
.agent/templates/
├── process-small.md     ← 3 步速战流程
├── process-medium.md    ← 7 步标准流程
└── process-large.md     ← 11 步完整方法论（含 OpenSpec）
```

**工作原理：**

1. **任务开始**：AI 评估复杂度，从模板创建 `process.md` 到项目根目录
2. **状态机驱动**：每一步有三种状态——⬜ 未开始 → 🔄 进行中 → ✅ 已完成
3. **复杂度锁定**：复杂度一旦确定即锁定在 `process.md` 中，防止会话中途"降级"
4. **中断恢复**：`/go` 命令读取 `process.md`，找到 🔄 步骤，恢复完整上下文
5. **任务归档**：所有步骤 ✅ 后，`process.md` 自动归档，保持工作区干净

**复杂度级别对应的流程步骤：**

| 复杂度 | 步骤数 | 流程 | 示例 |
|--------|--------|------|------|
| **trivial** | 0 | 直接做 → 验证（无 process.md） | 改变量名、修 typo |
| **small** | 3 | 理解 → 执行 → 验证 | 修 bug、添加字段 |
| **medium** | 7 | 头脑风暴 → 计划 → 执行 → 测试 → 审查 → 归档 | 新增 API、业务模块 |
| **large** | 11 | 调研 → 头脑风暴 → OpenSpec → 设计 → 工作区 → 分批执行 → 严格 TDD → 审查 → 收尾 → 归档/学习 | 系统重构、数据库迁移 |

### 按需加载，拒绝全量注入

```
AGENTS.md（轻量骨架，始终加载）
  └─ 按需读取 → .agent/skills/xxx/SKILL.md（仅在需要时加载）
```

AGENTS.md 只定义调度逻辑和分级规则，具体的 Skill 指导（TDD 流程、调试方法论、编码规范等）以独立文件存在。AI 根据任务复杂度**按需读取**，既节约 Token，又减少长会话中的规则遗忘。

### 一套源码，模块化构建多端配置

`build.sh` 将共享组件和平台特有组件拼装为各平台专属的 AGENTS 配置文件：

```
.agent/builder/
├── common/                  ← 共享核心（Skills 注册表、场景分级器、缺陷补丁）
│   ├── 01-header.md
│   ├── 02-planning.md
│   ├── 03-scheduler.md
│   ├── 04-defect-rules.md
│   └── 05-appendix-structure.md
├── platforms/
│   ├── antigravity/         ← 无子代理 → 用 executing-plans 替代
│   ├── cursor/              ← 有 Composer → 精简配置
│   ├── codex/               ← 有原生代理 → 精简配置
│   └── opencode/            ← 有 subagent → 启用原生调度
└── build.sh                 ← 拼装脚本：common + platform → AGENTS.*.md
```

### 平台拦截与路由

各平台的规则入口文件会引导 AI 读取**该平台专属的高级配置**，而非直接使用根目录的降级版 `AGENTS.md`：

| 平台 | 拦截入口 | 引导目标 |
|------|----------|----------|
| Cursor | `.cursor/rules/dev-skills-kit.mdc` | `.agent/AGENTS.cursor.md` |
| Codex | `.codex/agent.rules` | `.agent/AGENTS.codex.md` |
| OpenCode | `.opencode/AGENTS.md` | `.agent/AGENTS.opencode.md` |
| Gemini CLI | `.gemini/settings.json` + `.gemini/commands/` | 根目录 `AGENTS.md`（自动加载） |
| Claude Code | `.claude/commands/` | 根目录 `AGENTS.md` + Slash Commands |
| Antigravity | 根目录 `AGENTS.md`（自动加载） | 直接使用（含降级适配） |

### 防遗忘与中断恢复机制

AI 在长会话中会逐渐"遗忘"规则，会话中断更会丢失全部上下文。系统通过多层机制对抗：

1. **process.md 统一状态管理**：任务全流程记录在 `process.md` 中，每一步的状态、关键决策、产出文件均有记录，中断后可完全恢复
2. **`/go` 指令恢复**：用户触发 `/go`，AI 读取 `process.md`，定位到 🔄 步骤，加载所有前置步骤的上下文（包括 `task_plan.md`、OpenSpec 文档等）
3. **定期刷新**：每完成一个阶段，重新读取计划文件
4. **复杂度锁定**：防止中断恢复时 AI 将任务从 large "降级"为 medium

### 零 Hooks 依赖

所有功能（经验沉淀、状态持久化、规则加载）纯文件驱动，不依赖 Claude Code Hooks 等平台特有机制。经验沉淀通过 `auto-learning` skill 实现——任务完成时自动提取经验到 `docs/learnings/`，新任务开始时按文件名检索相关经验。

---

## 安装后目标项目结构

```
your-project/
├── AGENTS.md                            ← Antigravity / Gemini CLI 适配版（含标记区块）
├── process.md                           ← 任务导航清单（运行时生成，任务完成后归档）
├── task_plan.md                         ← 任务规划草稿（medium+ 生成）
├── findings.md                          ← 调研发现草稿（运行时生成）
├── .agent/
│   ├── AGENTS.cursor.md                 ← Cursor 专属高级配置
│   ├── AGENTS.codex.md                  ← Codex 专属高级配置
│   ├── AGENTS.opencode.md               ← OpenCode 专属高级配置
│   ├── skills/                          ← ~33 个精选 Skills
│   │   ├── brainstorming/SKILL.md
│   │   ├── systematic-debugging/SKILL.md
│   │   ├── test-driven-development/SKILL.md
│   │   ├── verification-before-completion/SKILL.md
│   │   ├── planning-with-files/SKILL.md
│   │   ├── auto-learning/SKILL.md
│   │   ├── security-guidance/SKILL.md
│   │   ├── python-patterns/SKILL.md
│   │   ├── golang-patterns/SKILL.md
│   │   └── ...
│   ├── templates/                       ← process.md 模板（按复杂度分级）
│   │   ├── process-small.md
│   │   ├── process-medium.md
│   │   └── process-large.md
│   └── workflows/
│       ├── go.md                        ← /go 规则重载 + 中断恢复
│       ├── learn.md                     ← /learn 经验提取
│       ├── reset.md                     ← /reset 重置任务状态
│       └── save-to-kb.md               ← /save-to-kb 知识沉淀
├── .cursor/rules/dev-skills-kit.mdc     ← Cursor 拦截入口
├── .codex/agent.rules                   ← Codex 拦截入口
├── .opencode/AGENTS.md                  ← OpenCode 拦截入口
├── .gemini/                             ← Gemini CLI 配置
│   ├── settings.json                    ← 自动加载 AGENTS.md
│   └── commands/                        ← Slash Commands（/go、/learn 等）
└── .claude/commands/                    ← Claude Code Slash Commands
```

> 目标项目**完全自给自足**：所有路径为相对路径，项目可随意迁移，无外部依赖。

---

## Skills 清单

### 方法论 Skills（来源：[superpowers](https://github.com/obra/superpowers)）

| Skill | 用途 |
|-------|------|
| using-superpowers | 调度器核心 |
| brainstorming | 苏格拉底式设计精炼 |
| writing-plans | 任务拆分为 2-5 分钟小任务 |
| executing-plans | 分批执行 + 人工检查点 |
| requesting-code-review | 发起代码审查 |
| receiving-code-review | 接收审查反馈 |
| dispatching-parallel-agents | 并行多问题处理 |
| using-git-worktrees | 隔离工作区 |
| finishing-a-development-branch | 分支收尾 |
| writing-skills | 创建新 Skill |

### 技术栈 Skills（来源：[everything-claude-code](https://github.com/affaan-m/everything-claude-code)）

| Skill | 适用场景 |
|-------|----------|
| python-patterns / python-testing | Python 项目 |
| golang-patterns / golang-testing | Go 项目 |
| frontend-patterns / coding-standards | TypeScript / React |
| springboot-patterns / java-coding-standards | Java / Spring Boot |
| api-design | REST API 设计 |
| database-migrations | 数据库迁移 |
| docker-patterns / deployment-patterns | 容器化部署 |
| e2e-testing | 端到端测试 |
| backend-patterns | 后端通用模式 |
| continuous-learning-v2 | 上游持续学习（参考） |

### Anthropic 官方 Skills（来源：[claude-code/plugins](https://github.com/anthropics/claude-code/tree/main/plugins)）

| Skill | 用途 | 安装方式 |
|-------|------|----------|
| frontend-design | 高质量前端设计，避免 AI 泛化美学（独特排版、配色、动效指导） | 上游 clone（`update-sources.sh`） |

### 本地维护的 Skills

这些 Skills 不来自上游仓库，而是本项目自行创建或改编维护的：

| Skill | 用途 | 来源 |
|-------|------|------|
| auto-learning | 零 Hooks 经验沉淀（替代 continuous-learning-v2） | 原创 |
| planning-with-files | 3 文件状态持久化 | 改编自 [planning-with-files](https://github.com/OthmanAdi/planning-with-files) |
| security-guidance | 安全编码指导，检测命令注入、XSS、反序列化等常见漏洞模式 | 改编自 Anthropic 安全插件（原版为 Python Hook，无 SKILL.md） |
| test-driven-development | RED-GREEN-REFACTOR 循环，强调灵活 TDD | 改编自 superpowers（增加灵活化补丁） |
| systematic-debugging | 4 阶段根因分析，禁止猜测式修复 | 改编自 superpowers（增强实用性） |
| verification-before-completion | 完成前强制运行验证命令，证据先于断言 | 改编自 superpowers（增强门控机制） |

### 外部工具

| 工具 | 用途 |
|------|------|
| [OpenSpec](https://github.com/Fission-AI/OpenSpec) | 大型任务规范归档（CLI 工具，`install.sh` 自动安装） |

---

## 工作流命令

安装后可在任意支持的 AI 平台中使用以下 Slash Commands：

| 命令 | 用途 |
|------|------|
| `/go` | 重新加载 AGENTS.md 规则，同步当前状态，从 `process.md` 恢复中断的任务 |
| `/learn` | 分析当前会话，提取可复用的经验模式并保存到知识库 |
| `/reset` | 放弃当前进行中的任务，清理 `process.md` 等状态文件，重置为干净状态 |
| `/save-to-kb` | 将知识显式保存并验证到知识库中 |

---

## 仓库结构

```
dev-skills-kit/
├── install.sh                           ← 一键安装脚本（含安全复制 + 冲突提示）
├── update-sources.sh                    ← 拉取上游最新源码到 github-source/
├── AGENTS.md                            ← build.sh 生成的 Antigravity 版配置
├── AI_INSTANCE.md                       ← AI Agent 安装指引
├── enterprise-developer-skills-guide.md ← 设计决策指南（场景分级方法论）
├── .agent/
│   ├── builder/                         ← 模块化构建系统
│   │   ├── build.sh                     ← 拼装脚本
│   │   ├── common/                      ← 共享核心组件（5 个模块）
│   │   └── platforms/                   ← 平台特有组件（4 个平台）
│   ├── AGENTS.cursor.md                 ← build.sh 生成
│   ├── AGENTS.codex.md                  ← build.sh 生成
│   ├── AGENTS.opencode.md               ← build.sh 生成
│   ├── skills/                          ← 本地维护的 Skills（6 个）
│   │   ├── auto-learning/SKILL.md
│   │   ├── planning-with-files/SKILL.md
│   │   ├── security-guidance/SKILL.md
│   │   ├── systematic-debugging/SKILL.md
│   │   ├── test-driven-development/SKILL.md
│   │   └── verification-before-completion/SKILL.md
│   ├── templates/                       ← process.md 模板（按复杂度分级）
│   │   ├── process-small.md
│   │   ├── process-medium.md
│   │   └── process-large.md
│   └── workflows/                       ← 工作流（4 个 Slash Commands）
│       ├── go.md
│       ├── learn.md
│       ├── reset.md
│       └── save-to-kb.md
├── .cursor/rules/                       ← Cursor 拦截入口（模板）
├── .codex/                              ← Codex 拦截入口（模板）
├── .opencode/                           ← OpenCode 拦截入口（模板）
├── .gemini/                             ← Gemini CLI 配置（commands + settings）
├── docs/                                ← 分析文档
└── github-source/                       ← 上游全量源码（.gitignore 已排除）
    ├── superpowers/
    ├── everything-claude-code/
    ├── claude-code/                     ← Anthropic 官方（仅保留 plugins/skills/）
    ├── planning-with-files/
    └── OpenSpec/
```

---

## 更新上游 Skills

```bash
cd ~/dev-skills-kit
./update-sources.sh              # 拉取最新源码到 github-source/
./install.sh /path/to/project    # 重新安装到目标项目
```

> `install.sh` 支持 `-f|--force` 参数强制覆盖，不加参数时会对内容有变化的文件逐一提示。

---

## 平台适配速查表

| 能力 | Antigravity | Cursor | Codex | OpenCode | Gemini CLI | Claude Code |
|------|-------------|--------|-------|----------|------------|-------------|
| 规则加载方式 | `AGENTS.md` 自动加载 | `.cursor/rules/` 拦截 | `.codex/agent.rules` 拦截 | `.opencode/AGENTS.md` 拦截 | `.gemini/settings.json` 指定 | `AGENTS.md` 自动加载 |
| Skill 读取 | `view_file` | `view_file` | `view_file` | `view_file` | `view_file` | `view_file` |
| 子代理调度 | ❌ → `executing-plans` | ✅ Composer | ✅ 原生代理 | ✅ 原生 subagent | ❌ → `executing-plans` | ✅ Task tool |
| Slash Commands | `.agent/workflows/` | `.agent/workflows/` | `~/.codex/prompts/` | `.agent/workflows/` | `.gemini/commands/` | `.claude/commands/` |
| 配置版本 | 降级版（含限制补丁） | 精简高级版 | 精简高级版 | subagent 增强版 | 降级版 | 降级版 |

---

## 上游仓库

| 仓库 | 地址 | 引用方式 |
|------|------|----------|
| superpowers | https://github.com/obra/superpowers | SKILL.md 方法论，由 `install.sh` 安装 |
| everything-claude-code | https://github.com/affaan-m/everything-claude-code | SKILL.md 技术栈规范，由 `install.sh` 安装 |
| claude-code/plugins | https://github.com/anthropics/claude-code/tree/main/plugins | Anthropic 官方 Skills（frontend-design），改编为 SKILL.md |
| planning-with-files | https://github.com/OthmanAdi/planning-with-files | SKILL.md 状态持久化，由 `install.sh` 安装 |
| OpenSpec | https://github.com/Fission-AI/OpenSpec | CLI 工具，由 `install.sh` 自动安装 |
