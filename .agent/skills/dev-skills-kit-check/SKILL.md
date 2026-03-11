---
name: dev-skills-kit-check
description: 项目级变更自检清单。当向 dev-skills-kit 添加新功能、工作流（Workflow）、指令或 Skill 时，强制执行此自检清单以确保所有关联文件环境同步一致，避免平台兼容性遗漏。
---

# Dev-Skills-Kit 变更自检核对表

在 `dev-skills-kit` 这个项目中，由于需要保证六大多端平台（Antigravity / Cursor / Codex / OpenCode / Claude Code / Gemini CLI）的高级及降级配置同步，同时还要使得一键安装脚本 (`install.sh`) 能够不遗漏任何细节。

当你（AI）接到添加**新指令、新 Workflow、或是核心结构修改**时，必须自动在执行前、后核对并完成以下关联文件和模块的修改。

## 🔍 新增工作流 / 指令 (Workflow / Command) 自检清单

当你创建了一个新的功能模块（例如 `/concurrency`），你必须确保横向打通了整个系统的配置分发生态：

- [ ] **1. 创建基础执行体**
  - 在 `.agent/workflows/<name>.md` 中创建 Markdown 格式的新工作流。
  - 使用标准的 Frontmatter 包含 `description`、`argument-hint` 及 `$ARGUMENTS` 占位符。

- [ ] **2. 映射多端终端（Gemini CLI 支持）**
  - 在 `.gemini/commands/<name>.toml` 环境中建立调用文件映射。
  - 格式遵守：包含 `description` 与 `prompt`（其中 prompt 指向源 md 工作流并包含 `{{args}}`）。

- [ ] **3. 文档架构树同步**
  - 在 `.agent/builder/common/05-appendix-structure.md` 的附录树中补全新 Workflow 的显示，以确保护盾及各平台 `AGENTS.md` 包含正确的目录树。
  - 在 `AI_INSTANCE.md` 中两处核心区更新：
    - 更新“分发模型”表格和快速指南，说明该指令的存在。
    - 更新本底“仓库目录结构”，展示新文件层次。

- [ ] **4. 自动分发与状态安全 (install.sh 保护层)**
  - 如果新功能在客户端生成了特定缓存、中间件或是隔离开发区（例如 `.worktrees/`），**必须**同步将目标生成的屏蔽文件夹或文件追加到 `install.sh` 脚本中的  `GITIGNORE_ENTRIES` 数组里，避免污染用户原生项目。

- [ ] **5. 重编译验证发布基线**
  - 修改所有的 `common` 底座或添加工作流后，必需使用 `run_command` 在终端主动运行 `.agent/builder/build.sh .` 。
  - 观察状态直至成功，以确保组装出的 `AGENTS.md` (Antigravity 用) 以及 `AGENTS.cursor.md` 等全系列文件被正确覆盖。

## 🔍 新增或修改 Skill 自检清单

若功能属于方法论级别的技术补充（增加新的 `SKILL.md`）：

- [ ] **1. Skill 文件归位**
  - 新建的 Skill 遵守放在本项目的本地补充位 `.agent/skills/<name>/SKILL.md` 目录内（或利用 `update-sources.sh` 从 github-source 进行摘取）。

- [ ] **2. 核心调度表激活**
  - 务必修改 `.agent/builder/common/02-planning.md` 等规划表格或是在相应触发分类（Small/Medium/Large）的场景分级调度声明中加入新 Skill 映射词，否则 AI 在启动调度模板时无法意识到它的存在。

---

> **给 AI 的指令：**
> 如果用户提及向本套件中**新增**某种规则/工作流/功能设定，你需要隐式读取该清单（`dev-skills-kit-check`），并在完成开发时主动输出上述 Checkboxes 以证明你实现了上述所有贯通步骤。
