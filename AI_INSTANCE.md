# dev-skills-kit — AI Agent 安装指引

> **本文件由用户提供给你（AI Agent），用于将 dev-skills-kit 安装到用户的目标项目。**
> 本文件所在目录即为 dev-skills-kit 仓库根目录，用户已将其克隆到本地。

---

## 安装步骤

1. **确定仓库路径**：本文件（`AI_INSTANCE.md`）所在目录即为 dev-skills-kit 根目录。
2. **确定目标项目路径**：用户当前工作的项目目录。如果用户未指定，请先询问。
3. **执行安装**：

```bash
# 首次安装
<dev-skills-kit根目录>/install.sh <目标项目路径>

# 更新（目标项目已安装过）——必须加 -f，否则会进入交互式提示
<dev-skills-kit根目录>/install.sh -f <目标项目路径>
```

4. **判断首次还是更新**：如果目标项目已存在 `.agent/skills/` 目录，视为更新场景，请使用 `-f` 标志。

> 安装脚本一键完成：精选 ~34 个 Skills → 构建六端 AGENTS 配置（Antigravity / Cursor / Codex / OpenCode / Claude Code / Gemini CLI）→ 分发各平台拦截规则 → 复制 process.md 模板 → 安装 OpenSpec → 更新 `.gitignore`。

---

## 安装完成后

- 所有技术栈 Skills（Python · Go · TypeScript/React · Java/Spring Boot · API · Docker · 安全等）均已就绪，AI 按任务场景按需读取对应 SKILL.md，无需额外配置。
- 用户发送 `/go` 即可激活规则并进入工作状态。

---

## 更新上游 Skills

```bash
cd <dev-skills-kit根目录>
./update-sources.sh                       # 拉取上游最新版本
./install.sh -f <目标项目路径>              # 重新安装到目标项目
```

---

## 上游仓库

| 仓库 | 说明 |
|------|------|
| [superpowers](https://github.com/obra/superpowers) | SKILL.md 方法论 |
| [everything-claude-code](https://github.com/affaan-m/everything-claude-code) | 技术栈编码规范 |
| [planning-with-files](https://github.com/OthmanAdi/planning-with-files) | 状态持久化 |
| [OpenSpec](https://github.com/Fission-AI/OpenSpec) | 大型任务规范归档 CLI |

> 更多设计细节和完整目录结构请参考 [README.md](README.md)。
