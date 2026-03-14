<!--
AI AGENT INSTALLATION INSTRUCTIONS
===================================
> **本文件由用户提供给你（AI Agent），用于将 dev-skills-kit 安装到用户的目标项目。**
> 本文件所在目录即为 dev-skills-kit 仓库根目录，用户已将其克隆到本地。
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

# dev-skills-kit — AI Agent 安装指引

> 本文件专供 AI Agent 阅读。项目介绍请参考 [README.md](README.md)。

## 安装 / 更新

1. **确定仓库路径**：本文件（`AI_INSTANCE.md`）所在目录即为 dev-skills-kit 根目录。
2. **确定目标项目路径**：用户当前工作的项目目录。如果用户未指定，请先询问。
3. **执行命令**：

```bash
# 首次安装
<dev-skills-kit根目录>/install.sh <目标项目路径>

# 更新（目标项目已安装过）——必须加 -f，否则会进入交互式提示
<dev-skills-kit根目录>/install.sh -f <目标项目路径>
```

4. **判断首次还是更新**：如果目标项目已存在 `.agent/skills/` 目录，视为更新场景，请使用 `-f` 标志。

## 安装完成后

告知用户：发送 `/go` 即可激活规则并进入工作状态。

## 更新上游 Skills

```bash
cd <dev-skills-kit根目录>
./update-sources.sh                       # 拉取上游最新版本
./install.sh -f <目标项目路径>              # 重新安装到目标项目
```
