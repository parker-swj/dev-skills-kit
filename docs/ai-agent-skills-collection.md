# AI Agent Skills 资源合集

> 整理时间：2026-02-23 | 涵盖 Claude Code / Cursor / Copilot / Antigravity 等主流 AI 编码代理

---

## 你已有的仓库

| 仓库 | 简介 |
|------|------|
| [obra/superpowers](https://github.com/obra/superpowers) | Claude Code "超能力"集合，包含多种高级 Skills |
| [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) | 基于文件的计划驱动开发 Skills |
| [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) | Claude Code 全方位资源集合 |
| [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) | 复合工程插件，每次迭代让下次更容易 |
| [numman-ali/openskills](https://github.com/numman-ali/openskills) | 开源 Agent Skills 集合 |
| [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) | 开放规范驱动的 AI 协作框架 |

---

## ⭐ 推荐新增的 Skills 仓库

### 🔥 综合 Awesome Lists（必看）

| 仓库 | ⭐ | 简介 |
|------|-----|------|
| **[VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills)** | 🔥 | **380+ Skills 集合**，涵盖 Anthropic/Google Labs/Vercel/Stripe/HuggingFace 官方 + 社区贡献，兼容 Claude Code/Cursor/Copilot |
| **[hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)** | 🔥 | Claude Code 最全资源清单：Skills、Hooks、Slash Commands、Subagents、Plugins、Agent Orchestrators |
| **[travisvn/awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills)** | 🔥 | Claude Skills/工具/资源的策展清单，分类详细，适合快速查找 |

---

### 🏢 官方 / 半官方仓库

| 仓库 | 简介 |
|------|------|
| **[anthropics/skills](https://github.com/anthropics/skills)** | Anthropic 官方 Skills 参考实现，包含文档处理、算法艺术、数据分析等示例 |
| **[cursor/plugins](https://github.com/cursor/plugins)** | Cursor 官方插件规范 + 官方插件集合，含 Agent Skills 标准定义 |

---

### 🧩 专项 Skills 集合

| 仓库 | 侧重方向 | 简介 |
|------|----------|------|
| **[VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)** | 子代理 | **100+ 专用子代理**：API 设计、后端开发、DevOps、安全审计、前端等各领域 |
| **[ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills)** | SaaS 集成 | 侧重开发工具 + SaaS 应用自动化 Skills |
| **[heilcheng/awesome-agent-skills](https://github.com/heilcheng/awesome-agent-skills)** | 教程+工具 | Skills/工具/教程/能力清单，分类清晰，适合学习 |
| **[skillcreatorai/Awesome-Agent-Skills](https://github.com/skillcreatorai/Awesome-Agent-Skills)** | 文档处理 | 文档处理和开发代码工具 Skills，兼容 Cursor |
| **[hao-ji-xing/awesome-cursor](https://github.com/hao-ji-xing/awesome-cursor)** | Cursor | Cursor 工具和资源策展合集，包含 awesome-cursorrules |

---

### 💡 工程方法论 / 最佳实践

| 仓库/资源 | 简介 |
|-----------|------|
| **[AGENTS.md](https://agents.md)** (规范) | 为 AI Agent 提供项目级指令的开放标准，已被 60,000+ 开源项目采用 |
| **[aicodingrules.org](https://aicodingrules.org)** | AI 编码规则社区，收集了大量 CLAUDE.md / .cursorrules 模板 |
| **[agentskills.io](https://agentskills.io)** | Agent Skills 开放标准网站，定义了 SKILL.md 格式规范 |

---

## 按使用场景推荐

### 📋 项目开发迭代

| 需求 | 推荐 |
|------|------|
| **计划驱动开发** | `planning-with-files` + `compound-engineering-plugin` |
| **代码质量保障** | `VoltAgent/awesome-agent-skills` 中的 linting/testing skills |
| **文档自动生成** | `anthropics/skills` 中的文档处理 skills |
| **多代理协作** | `VoltAgent/awesome-claude-code-subagents` |
| **CI/CD 集成** | `cursor/plugins` + GitHub Agentic Workflows |

### 🔧 工具链增强

| 需求 | 推荐 |
|------|------|
| **Hooks（生命周期钩子）** | `hesreallyhim/awesome-claude-code` 中的 hooks 部分 |
| **Slash Commands（快捷命令）** | `hesreallyhim/awesome-claude-code` 中的 commands 部分 |
| **MCP Server 集成** | `VoltAgent/awesome-agent-skills` 中的 MCP 相关 |
| **SaaS 应用自动化** | `ComposioHQ/awesome-claude-skills` |

### 🏗️ 架构和规范

| 需求 | 推荐 |
|------|------|
| **项目 Agent 配置** | AGENTS.md 规范 + CLAUDE.md 最佳实践 |
| **自定义 Skills 开发** | `anthropics/skills` 参考 + agentskills.io 标准 |
| **团队协作规范** | `aicodingrules.org` 模板库 |

---

## 快速上手建议

1. **先看 Awesome Lists** → `VoltAgent/awesome-agent-skills` 和 `hesreallyhim/awesome-claude-code` 涵盖最广
2. **按需取 Skills** → 无需全部安装，只取你项目需要的 Skills 文件夹
3. **关注 SKILL.md 规范** → 理解格式后可以快速自定义 Skills
4. **结合你已有的仓库** → `superpowers` + `compound-engineering-plugin` 已经是很好的基础，补充以上资源即可覆盖绝大多数场景
