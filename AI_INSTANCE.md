<!--
AI AGENT INSTALLATION INSTRUCTIONS
===================================
用户已将此文件路径提供给你，请按以下步骤将 dev-skills-kit 安装到用户的当前项目：

1. 确定 dev-skills-kit 仓库路径：本文件（README.md）所在目录即为 dev-skills-kit 根目录
2. 确定目标项目路径：用户当前工作的项目目录（询问用户或根据上下文判断）
3. 执行安装：运行 <dev-skills-kit根目录>/install.sh <目标项目路径>

注意：如果用户未指定目标项目路径，请先询问。
安装完成后所有技术栈 Skills 均已启用，AI 会按需读取对应 SKILL.md，无需额外配置。
-->

# dev-skills-kit

为 **Antigravity**、**Cursor Agent**、**Codex Agent** 和 **OpenCode Agent** 等平台精选的 Skills 配置集合，可无配置一键同时安装到多端项目。

## 分发模型

| 内容 | 位置 | 说明 |
|------|------|------|
| `.agent/skills/<name>/SKILL.md` | 安装到目标项目 | 精选的 SKILL.md 文件，按需从上游摘取 |
| `.agent/workflows/` | 安装到目标项目 | 工作流（`/save-to-kb` 等） |
| `.agent/AGENTS.*.md` | 安装到目标项目 | **纯净高级配置**：专为高权限 Agent（Cursor/Codex/OpenCode）优化脱去限制的规则 |
| `.cursor/rules/` 等 | 安装到目标项目 | **拦截规避器**：强制各目标 Agent (含 `.opencode`, `.codex`) 读取对应的纯净极客配置，跳过受限制基础版 `AGENTS.md` |
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

脚本会自动提供涵盖 **Antigravity / Cursor / Codex / OpenCode** 的四端完美物理兼容配置，执行内容包括：
- 将精选的 SKILL.md 文件复制到 `.agent/skills/`
- 将专为高能平台（Cursor/Codex/OpenCode）脱离限制编制的高级纯净配置分发到 `.agent/AGENTS.*.md` 
- 将各专属平台的独立拦截规则复制到它们所需的配置目录，例如：
  - `.cursor/rules/` (Cursor) 
  - `.codex/` (Codex)
  - `.opencode/` (OpenCode)
- 将供基础工具链（如 Antigravity）必备的基础降级核心配置追加到根目录的 `AGENTS.md` 中

### 3. 开始使用

安装完成。所有技术栈 Skills（Python · Go · TypeScript/React · Java/Spring Boot · API · Docker · 安全等）均已启用，AI 会按照任务场景按需读取对应 SKILL.md，无需手动配置。

### 4. 搭配使用 OpenSpec（任务规范归档）

OpenSpec 是一个独立的 CLI 工具。**当使用 `install.sh` 时，脚本会自动尝试为你全局安装 `@fission-ai/openspec` 并在目标项目执行 `openspec init`。**

如果你之前安装失败，或者想手动安装，可以执行：

```bash
npm install -g @fission-ai/openspec
cd /path/to/your-project
openspec init
```

> **何时需要**：`medium` 及以上级别任务（涉及 3+ 文件、预计 1 小时以上）推荐使用。  
> **如何触发**：只要检测到项目根目录存在 `openspec/` 文件夹，AI Agent 就会自动走 OpenSpec 规范归档分支。

---

## 安装后目标项目结构

```
your-project/
├── .cursor/rules/
│   └── dev-skills-kit.mdc            ← 拦截引导 Cursor 读取其专属高级配置
├── .codex/
│   └── agent.rules                  ← 拦截引导 Codex 读取其专属高级配置
├── .opencode/
│   └── AGENTS.md                    ← 拦截引导 OpenCode 读取其专属高级配置
├── AGENTS.md                        ← 专供基础工具链（如 Antigravity）必读的降级版配置
└── .agent/
    ├── AGENTS.cursor.md             ← 纯净的高阶 Agent (Cursor) 优化配置 (无降级打补丁语句)
    ├── AGENTS.codex.md              ← 纯净的高阶 Agent (Codex) 优化配置 (无降级打补丁语句)
    ├── AGENTS.opencode.md           ← 纯净的高阶 Agent (OpenCode) 优化配置 (使用原生 subagent 等)
    ├── skills/
    │   ├── planning-with-files/     ← 状态持久化
    │   │   └── SKILL.md
    │   ├── brainstorming/
    │   │   └── SKILL.md
    │   ├── systematic-debugging/
    │   │   └── SKILL.md
    │   └── ...（共 ~26 个精选 Skills）
    └── workflows/
        └── save-to-kb.md            ← /save-to-kb 指令
```

---

## dev-skills-kit 仓库结构

```
install.sh                       ← 一键安装脚本
update-sources.sh                ← 更新上游 Skills 源码
AGENTS.md                        ← 自动从 builder 中生成的 Antigravity 配置
.agent/
├── builder/                     ← 各平台 AGENTS.*.md 独立模块构建拼装脚本与源码
├── skills/                      
└── workflows/save-to-kb.md      ← 工作流
github-source/                   ← 上游全量源码（仅供 update-sources.sh 使用）
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
