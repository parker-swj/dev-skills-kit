<!--
AI AGENT INSTALLATION INSTRUCTIONS
===================================
用户已将此文件路径提供给你，请按以下步骤将 dev-skills-kit 安装到用户的当前项目：

1. 确定 dev-skills-kit 仓库路径：本文件（AI_INSTANCE.md）所在目录即为 dev-skills-kit 根目录
2. 确定目标项目路径：用户当前工作的项目目录（询问用户或根据上下文判断）
3. 执行安装/更新：
   - 首次安装：运行 <dev-skills-kit根目录>/install.sh <目标项目路径>
   - 更新（已安装过）：运行 <dev-skills-kit根目录>/install.sh -f <目标项目路径>
     （-f 标志强制覆盖旧文件，确保最新配置生效。不加 -f 会弹出交互式提示，无法自动完成）
4. 如果用户说"安装"且目标项目已存在 .agent/skills/ 目录，说明是更新场景，请使用 -f 标志

注意：如果用户未指定目标项目路径，请先询问。
安装完成后所有技术栈 Skills 均已启用，AI 会按需读取对应 SKILL.md，无需额外配置。
-->

# dev-skills-kit

为 **Antigravity**、**Cursor Agent**、**Codex Agent**、**OpenCode Agent**、**Claude Code** 和 **Gemini CLI** 等平台精选的 Skills 配置集合，可无配置一键同时安装到多端项目。

## 分发模型

| 内容 | 位置 | 说明 |
|------|------|------|
| `.agent/skills/<name>/SKILL.md` | 安装到目标项目 | 精选的 SKILL.md 文件，按需从上游摘取 |
| `.agent/workflows/` | 安装到目标项目 | 工作流（`/go`、`/learn`、`/reset`、`/save-to-kb`） |
| `.agent/templates/` | 安装到目标项目 | process.md 模板（small/medium/large 三套步骤清单） |
| `.agent/AGENTS.*.md` | 安装到目标项目 | **纯净高级配置**：专为高权限 Agent（Cursor/Codex/OpenCode）优化脱去限制的规则 |
| `.cursor/rules/` 等 | 安装到目标项目 | **拦截规避器**：强制各目标 Agent 读取对应的纯净极客配置，跳过受限制基础版 `AGENTS.md` |
| `.claude/commands/` | 安装到目标项目 | Claude Code 命令（工作流映射为 slash commands） |
| `.gemini/` | 安装到目标项目 | Gemini CLI 命令 + settings.json（注册 slash commands + 启用 AGENTS.md） |
| `AGENTS.md` | 追加/合并到目标项目 | **核心降级配置**：专供 Antigravity 等基础工具链强制读取的降级版要求 |
| `github-source/` | **保留在本仓库** | 上游全量源码，仅用于 `update-sources.sh` 更新 |

> 目标项目**完全自给自足**：Skills 以单个 SKILL.md 文件存在于 `.agent/skills/`，  
> 路径全部为相对路径，项目可随意迁移到任何机器。

---

## 快速开始

### 1. Clone 本仓库（一次性操作）

```bash
git clone https://github.com/parker-swj/dev-skills-kit.git ~/dev-skills-kit
```

### 2. 安装到你的项目

使用以下命令一键安装：

```bash
~/dev-skills-kit/install.sh /path/to/your-project

# 如需强制覆盖所有已存在文件（不提示），使用 --force：
~/dev-skills-kit/install.sh -f /path/to/your-project
```

> **交互式安全机制**：如果目标项目中已存在同名文件且内容不同，脚本会暂停并询问你是否覆盖。
> 你可以选择：`[y]`覆盖 / `[n]`跳过 / `[d]`查看差异 / `[a]`全部覆盖 / `[s]`全部跳过。

脚本会自动提供涵盖 **Antigravity / Cursor / Codex / OpenCode / Claude Code / Gemini CLI** 的六端完美物理兼容配置，执行内容包括：
- 将精选的 SKILL.md 文件复制到 `.agent/skills/`（28 个上游精选 + 6 个本地维护 = **~34 个 Skills**）
- 运行 `build.sh` 从共享模块构建各平台专属 AGENTS 配置文件
- 将专为高能平台（Cursor/Codex/OpenCode）脱离限制编制的高级纯净配置分发到 `.agent/AGENTS.*.md` 
- 将各专属平台的独立拦截规则复制到它们所需的配置目录，例如：
  - `.cursor/rules/` (Cursor) 
  - `.codex/` (Codex)
  - `.opencode/` (OpenCode)
  - `.claude/commands/` (Claude Code)
  - `.gemini/commands/` + `.gemini/settings.json` (Gemini CLI)
- 将工作流同步到 Codex 全局 prompts 目录（`$HOME/.codex/prompts/`）
- 将供基础工具链（如 Antigravity）必备的基础降级核心配置追加到根目录的 `AGENTS.md` 中
- 自动更新目标项目 `.gitignore`（追加 AI 工具运行时目录和临时文件规则）

### 3. 开始使用

安装完成。所有技术栈 Skills（Python · Go · TypeScript/React · Java/Spring Boot · API · Docker · 安全等）均已启用，AI 会按照任务场景按需读取对应 SKILL.md，无需手动配置。

### 4. 搭配使用 OpenSpec（任务规范归档）

OpenSpec 是一个独立的 CLI 工具。**当使用 `install.sh` 时，脚本会自动尝试为你全局安装 `@fission-ai/openspec` 并在目标项目执行 `openspec init --tools antigravity,cursor,codex,opencode,gemini` 初始化多平台支持。**

如果你之前安装失败，或者想手动安装，可以执行：

```bash
npm install -g @fission-ai/openspec
cd /path/to/your-project
openspec init --tools antigravity,cursor,codex,opencode,gemini
```

> **何时需要**：`medium` 及以上级别任务（涉及 3+ 文件、预计 1 小时以上）推荐使用。  
> **如何触发**：只要检测到项目根目录存在 `openspec/` 文件夹，AI Agent 就会自动走 OpenSpec 规范归档分支。

---

## 安装后目标项目结构

```
your-project/
├── AGENTS.md                            ← 专供基础工具链（如 Antigravity）必读的降级版配置
├── .agent/
│   ├── AGENTS.cursor.md                 ← 纯净的高阶 Agent (Cursor) 优化配置
│   ├── AGENTS.codex.md                  ← 纯净的高阶 Agent (Codex) 优化配置
│   ├── AGENTS.opencode.md               ← 纯净的高阶 Agent (OpenCode) 优化配置
│   ├── skills/                          ← ~34 个精选 Skills
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
│   ├── templates/
│   │   ├── process-small.md             ← Small 任务模板（3 步）
│   │   ├── process-medium.md            ← Medium 任务模板（7 步）
│   │   └── process-large.md             ← Large 任务模板（11 步）
│   └── workflows/
│       ├── go.md                        ← /go 规则重载
│       ├── learn.md                     ← /learn 经验提取
│       ├── reset.md                     ← /reset 任务重置
│       └── save-to-kb.md               ← /save-to-kb 知识沉淀
├── .cursor/rules/
│   └── dev-skills-kit.mdc              ← 拦截引导 Cursor 读取其专属高级配置
├── .codex/
│   └── agent.rules                     ← 拦截引导 Codex 读取其专属高级配置
├── .opencode/
│   └── AGENTS.md                       ← 拦截引导 OpenCode 读取其专属高级配置
├── .claude/commands/                    ← Claude Code slash commands（从 workflows 映射）
│   ├── go.md
│   ├── learn.md
│   ├── reset.md
│   └── save-to-kb.md
└── .gemini/
    ├── commands/                        ← Gemini CLI slash commands
    │   ├── go.toml
    │   ├── learn.toml
    │   ├── reset.toml
    │   └── save-to-kb.toml
    └── settings.json                    ← Gemini CLI 配置（启用 AGENTS.md 自动加载）
```

---

## dev-skills-kit 仓库结构

```
dev-skills-kit/
├── install.sh                           ← 一键安装脚本
├── update-sources.sh                    ← 更新上游 Skills 源码
├── AI_INSTANCE.md                       ← AI Agent 安装指引（本文件）
├── AGENTS.md                            ← 自动从 builder 中生成的 Antigravity 配置
├── enterprise-developer-skills-guide.md ← 设计决策指南（场景分级方法论）
├── .agent/
│   ├── builder/                         ← 模块化构建系统
│   │   ├── build.sh                     ← 拼装脚本：common + platform → AGENTS.*.md
│   │   ├── common/                      ← 共享核心组件（Skills 注册表、场景分级器、缺陷补丁）
│   │   └── platforms/                   ← 平台特有组件（antigravity / cursor / codex / opencode）
│   ├── AGENTS.cursor.md                 ← build.sh 生成
│   ├── AGENTS.codex.md                  ← build.sh 生成
│   ├── AGENTS.opencode.md               ← build.sh 生成
│   ├── skills/                          ← 本地维护的 Skills（6 个）
│   │   ├── auto-learning/SKILL.md       ← 零 Hooks 经验沉淀
│   │   ├── planning-with-files/SKILL.md ← 3 文件状态持久化
│   │   ├── security-guidance/SKILL.md   ← 改编自 Anthropic Hook 插件
│   │   ├── systematic-debugging/SKILL.md ← 系统化调试（4 阶段根因分析）
│   │   ├── test-driven-development/SKILL.md ← TDD 灵活化
│   │   └── verification-before-completion/SKILL.md ← 完成前强制验证
│   ├── templates/                       ← process.md 模板（small/medium/large）
│   └── workflows/                       ← 工作流（/go、/learn、/reset、/save-to-kb）
├── .cursor/rules/                       ← Cursor 拦截入口（模板）
├── .codex/                              ← Codex 拦截入口（模板）
├── .opencode/                           ← OpenCode 拦截入口（模板）
├── .gemini/                             ← Gemini CLI 配置（commands + settings）
├── docs/                                ← 分析文档
└── github-source/                       ← 上游全量源码（仅供 update-sources.sh 使用）
    ├── superpowers/
    ├── everything-claude-code/
    ├── planning-with-files/
    └── OpenSpec/
```

---

## 更新上游 Skills

```bash
cd ~/dev-skills-kit
./update-sources.sh          # 拉取上游最新版本到 github-source/
git add github-source/
git commit -m "chore: update upstream skills"
git push

# 重新安装到目标项目（同步更新所有的 SKILL.md）
./install.sh /path/to/your-project
```

---

## 上游仓库

| Skills 库 | 上游地址 | 说明 |
|-----------|---------|------|
| superpowers | https://github.com/obra/superpowers | SKILL.md 方法论，由 `install.sh` 安装 |
| everything-claude-code | https://github.com/affaan-m/everything-claude-code | SKILL.md 技术栈规范，由 `install.sh` 安装 |
| planning-with-files | https://github.com/OthmanAdi/planning-with-files | SKILL.md 状态持久化，由 `install.sh` 安装 |
| OpenSpec | https://github.com/Fission-AI/OpenSpec | **外部 CLI 工具**，由 `install.sh` 尝试自动安装和初始化，供大型任务规范归档使用 |
