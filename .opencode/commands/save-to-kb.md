---
description: "[Action] EXPLICITLY save and verify your knowledge into the library."
---

$ARGUMENTS

# 📥 保存到知识库（显式工作流）

当你说 "保存这个！" 时触发此工作流，确保知识已写入中心化服务器。

## 1. 🔍 上下文审查
- 分析用户输入或最近的对话。
- 识别需要保存的**具体**知识（如代码片段、操作指南、架构决策）。
- 如果"解决方案"或"上下文"不明确，追问确认。

## 2. 📝 草拟内容
构建结构化知识块，不要直接堆文字。

**结构:**
- **标题**: 清晰、可搜索的标题（如 "Fix: Docker Build Timeout"）。
- **标签**: 2-3 个相关技术关键词。
- **内容**: 核心知识（问题 + 方案 + 代码）。

*如内容复杂，先展示给用户确认。*

## 3. 💾 写入知识库（支持双写/降级）
**根据环境判定存储方式。**
- **检查环境**：判断是否支持 MCP `add_knowledge` 工具，以及用户/部署配置是否要求本地保存（如指定了 `Knowledge_Mode: local`）。
- **全局保存（MCP）**：若 MCP 工具可用：
  - 调用 `add_knowledge` 传入草拟的 `content`、`title` 和 `tags`。
  - 数据将通过 MCP 协议写入中心化服务器，**等待**工具返回 "Success"。
- **本地保存（Fallback / 双写）**：若 MCP 不可用，或明确要求本地保存：
  - 将知识格式化为 Markdown 文件，带 YAML Frontmatter 含标题、分类、关联标签。
  - 写入到当前项目的 `.agent/knowledge/<kebab-case-title>.md` 文件中。
  - 如果 `.agent/knowledge/` 目录不存在，则创建。

## 4. ✅ 验证与反馈
不要假设已成功，根据存储方式验证它。
- **全局验证**：使用 `search_knowledge` 搜索刚保存的标题。
- **本地验证**：使用 `list_dir` 或类似工具确认新文件已在 `.agent/knowledge/` 目录下生成。
- **向用户确认**:
  > "✅ 已保存！我已验证其存在。
  > [若为全局] ID: [UUID]
  > [若为本地] 路径: `.agent/knowledge/...md` 
  > 后续可通过关键词搜索: [Tags]"

## 5. 🔒 隐私提醒与异常处理
- 提醒用户: "此知识存储在你的私有环境（中心化个人服务器 或 本地项目中）。"
- **网络不可达**：如果使用 SSE/mcp-remote 时服务器不可达，**自动降级**为本地文件存入 `.agent/knowledge/`，并提示用户切换为本地保存。
