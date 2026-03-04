# dev-skills-kit

**让 AI 编程助手遵循 TDD、系统化调试、分级任务规划等最佳实践来帮你写代码。**

运行一条命令，就能把从多个开源仓库中精选的 ~31 个 AI Skills（涵盖方法论、技术栈规范、状态持久化）安装进你的项目，并自动适配 Antigravity、Cursor、Codex、OpenCode 四个 AI 平台。

- 🎯 **不是又一个超大提示词文件** —— Skills 按需加载，不浪费 Token
- 🔧 **不是手动复制粘贴** —— `install.sh` 一键安装到任意项目，团队统一标准
- 🔀 **自主选择加载Skills** —— 改个变量名走轻量流程，重构系统走完整方法论
- 🧠 **自主学习经验沉淀** —— 任务完成后自动提取可复用经验，后续任务按需检索历史经验作为参考

---

## 它具体做了什么？

从 [superpowers](https://github.com/obra/superpowers)（开发方法论）、[everything-claude-code](https://github.com/affaan-m/everything-claude-code)（技术栈规范）、[planning-with-files](https://github.com/OthmanAdi/planning-with-files)（状态持久化）等优质开源项目中精选 Skills，经过冲突消解、缺陷补丁、平台适配后，整合为一套可一键安装的配置集：

| 你遇到的问题 | dev-skills-kit 的解法 |
|-------------|----------------------|
| 优质 Skills 散落在多个 GitHub 仓库，收集维护成本高 | 从上游精选 ~31 个 Skills，一条命令全部装好 |
| 所有规则塞进一个大文件，每次会话全量加载浪费 Token | 拆分为独立 SKILL.md，AI 按当前任务按需读取 |
| 各 AI 平台能力不同，同一套提示词效果差异大 | 从共享源码模块化构建各平台专属配置 |
| 好的工作流靠复制粘贴同步，项目间容易偏离 | 中央仓库维护，`install.sh` 统一分发更新 |

---

## 快速开始

### 1. 获取仓库

```bash
git clone <你的仓库地址> ~/dev-skills-kit
```

### 2. 安装到目标项目

```bash
dev-skills-kit/install.sh /path/to/your-project
```

脚本自动完成以下全部工作：

- ✅ 从 `github-source/` 精选并复制 ~31 个 SKILL.md 到 `.agent/skills/`
- ✅ 运行 `build.sh` 构建四端 AGENTS 配置文件
- ✅ 分发各平台专属拦截规则（`.cursor/rules/`、`.codex/`、`.opencode/`）
- ✅ 复制工作流到 `.agent/workflows/` 和各平台的命令目录
- ✅ 将 Antigravity 适配版配置写入根目录 `AGENTS.md`
- ✅ 安装并初始化 OpenSpec（大型任务规范归档，可选）

> 首次运行时，如果 `github-source/` 不存在，脚本会自动调用 `update-sources.sh` 拉取上游源码。

### 3. 开始使用

安装后无需额外配置。AI Agent 进入项目后会自动加载对应平台的规则，并根据任务场景按需读取相关 SKILL.md。

---

## 核心设计

### 按需加载，拒绝全量注入

```
AGENTS.md（轻量骨架，始终加载）
  └─ 按需读取 → .agent/skills/xxx/SKILL.md（仅在需要时加载）
```

AGENTS.md 只定义调度逻辑和分级规则，具体的 Skill 指导（TDD 流程、调试方法论、编码规范等）以独立文件存在。AI 根据任务复杂度**按需读取**，既节约 Token，又减少长会话中的规则遗忘。

### 场景分级，拒绝一刀切

不同复杂度的任务走不同流程，避免流程过度或不足：

| 复杂度 | 流程 | 示例 |
|--------|------|------|
| **trivial** | 直接做 → 验证 | 改变量名、修 typo |
| **small** | 调试 + 验证 + 灵活 TDD | 修 bug、添加字段 |
| **medium** | 设计 → 计划 → 分批执行 → 审查 | 新增 API、业务模块 |
| **large** | 完整方法论 + OpenSpec 归档 | 系统重构、数据库迁移 |

### 一套源码，模块化构建四端配置

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
| Antigravity | 根目录 `AGENTS.md`（自动加载） | 直接使用（含降级适配） |

### 防遗忘机制

AI 在长会话中会逐渐"遗忘"规则。系统通过三层机制对抗：

1. **planning-with-files**：3 个持久化文件（`task_plan.md` / `findings.md` / `progress.md`），上下文丢失也能恢复状态
2. **定期刷新**：每完成一个阶段，重新读取计划文件
3. **`/go` 指令**：用户随时触发规则重载，将 AI 拉回正轨

### 零 Hooks 依赖

所有功能（经验沉淀、状态持久化、规则加载）纯文件驱动，不依赖 Claude Code Hooks 等平台特有机制。经验沉淀通过 `auto-learning` skill 实现——任务完成时自动提取经验到 `docs/learnings/`，新任务开始时按文件名检索相关经验。

---

## 安装后目标项目结构

```
your-project/
├── AGENTS.md                            ← Antigravity 适配版（含降级逻辑）
├── .agent/
│   ├── AGENTS.cursor.md                 ← Cursor 专属高级配置
│   ├── AGENTS.codex.md                  ← Codex 专属高级配置
│   ├── AGENTS.opencode.md               ← OpenCode 专属高级配置
│   ├── skills/                          ← ~31 个精选 Skills
│   │   ├── brainstorming/SKILL.md
│   │   ├── systematic-debugging/SKILL.md
│   │   ├── test-driven-development/SKILL.md
│   │   ├── planning-with-files/SKILL.md
│   │   ├── auto-learning/SKILL.md
│   │   ├── python-patterns/SKILL.md
│   │   ├── golang-patterns/SKILL.md
│   │   └── ...
│   └── workflows/
│       ├── go.md                        ← /go 规则重载
│       ├── learn.md                     ← /learn 经验提取
│       └── save-to-kb.md               ← /save-to-kb 知识沉淀
├── .cursor/rules/dev-skills-kit.mdc     ← Cursor 拦截入口
├── .codex/agent.rules                   ← Codex 拦截入口
└── .opencode/AGENTS.md                  ← OpenCode 拦截入口
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
| test-driven-development | RED-GREEN-REFACTOR |
| systematic-debugging | 4 阶段根因分析 |
| verification-before-completion | 完成前强制验证 |
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
| security-review / security-scan | 安全审查 |
| backend-patterns | 后端通用模式 |
| continuous-learning-v2 | 上游持续学习（参考） |

### 本地 Skills

| Skill | 用途 |
|-------|------|
| planning-with-files | 3 文件状态持久化（来源：[planning-with-files](https://github.com/OthmanAdi/planning-with-files)） |
| auto-learning | 零 Hooks 经验沉淀（替代 continuous-learning-v2） |

### 外部工具

| 工具 | 用途 |
|------|------|
| [OpenSpec](https://github.com/Fission-AI/OpenSpec) | 大型任务规范归档（CLI 工具，`install.sh` 自动安装） |

---

## 仓库结构

```
dev-skills-kit/
├── install.sh                           ← 一键安装脚本
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
│   ├── skills/                          ← 本地维护的 Skills
│   │   ├── auto-learning/SKILL.md
│   │   └── planning-with-files/SKILL.md
│   └── workflows/                       ← 工作流（/go、/learn、/save-to-kb）
├── .cursor/rules/                       ← Cursor 拦截入口（模板）
├── .codex/                              ← Codex 拦截入口（模板）
├── .opencode/                           ← OpenCode 拦截入口（模板）
├── docs/                                ← 分析文档
└── github-source/                       ← 上游全量源码（.gitignore 已排除）
    ├── superpowers/
    ├── everything-claude-code/
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

---

## 平台适配速查表

| 能力 | Antigravity | Cursor | Codex | OpenCode |
|------|-------------|--------|-------|----------|
| 规则加载方式 | `AGENTS.md` 自动加载 | `.cursor/rules/` 拦截 | `.codex/agent.rules` 拦截 | `.opencode/AGENTS.md` 拦截 |
| Skill 读取 | `view_file` | `view_file` | `view_file` | `view_file` |
| 子代理调度 | ❌ → `executing-plans` | ✅ Composer | ✅ 原生代理 | ✅ 原生 subagent |
| 任务跟踪 | `task_plan.md` 文件 | `task_plan.md` 文件 | `task_plan.md` 文件 | `task_plan.md` 文件 |
| 代码审查 | 自审检查清单 | 自审 / Composer | 自审 / 原生 | 自审 / subagent |
| 配置版本 | 降级版（含限制补丁） | 精简高级版 | 精简高级版 | subagent 增强版 |

---

## 上游仓库

| 仓库 | 地址 | 引用方式 |
|------|------|----------|
| superpowers | https://github.com/obra/superpowers | SKILL.md 方法论，由 `install.sh` 安装 |
| everything-claude-code | https://github.com/affaan-m/everything-claude-code | SKILL.md 技术栈规范，由 `install.sh` 安装 |
| planning-with-files | https://github.com/OthmanAdi/planning-with-files | SKILL.md 状态持久化，由 `install.sh` 安装 |
| OpenSpec | https://github.com/Fission-AI/OpenSpec | CLI 工具，由 `install.sh` 自动安装 |
