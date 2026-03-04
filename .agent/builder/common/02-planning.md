### 3.2 状态持久化 — planning-with-files

| Skill | view_file 路径 |
|-------|---------------|
| planning-with-files | `.agent/skills/planning-with-files/SKILL.md` |

**核心规则（内嵌，无需额外读取）：**

复杂任务（medium/large）开始前，必须创建 3 个文件：

| 文件 | 用途 | 更新时机 |
|------|------|----------|
| `task_plan.md` | 阶段、进度、决策 | 每个阶段结束后 |
| `findings.md` | 研究发现、错误记录 | 发现任何有价值信息时 |
| `progress.md` | 会话日志、当前阶段、测试结果 | **brainstorm 开始时立即创建**，贯穿整个会话 |

<EXTREMELY-IMPORTANT>
**Brainstorm 立即建档规则（防跨会话丢失）：**

medium/large 任务进入 brainstorming 阶段时，**第一个动作**必须是创建 `progress.md`，写入：

```markdown
# Progress Log

## 当前阶段
阶段: brainstorming
状态: 进行中
复杂度: [medium/large]
任务概述: [一句话描述用户需求]
开始时间: [当前时间]

## 参考上下文 (调研与报错)
> ⚠️ **声明**：以下记录的 AI 调研项目内容及历史报错信息仅供由于中断新开会话时继承作为**参考方向**，**并非 100% 准确**，在使用时需要再次验证。
- **历史报错**: [强制记录之前发生的报错信息或异常，无则写无]
- **调研发现**: [强制记录已经调研的项目背景、代码结构探索和初步思路]

## Brainstorm 记录
[随着讨论推进，持续记录关键结论、决策和待确认项]
```

**每轮 brainstorm 对话后**，立即将新的结论追加到 `progress.md` 的 "Brainstorm 记录"部分。
这确保即使网络断开，新会话也能通过读取 `progress.md` 恢复到正确的阶段。

阶段转换时（如 brainstorm → openspec / writing-plans），必须更新 `progress.md` 中的「当前阶段」和「状态」。
</EXTREMELY-IMPORTANT>

**关键规则：**
- **Brainstorm 立即建档**：brainstorm 开始的第一个动作就是创建 `progress.md`，防跨会话丢失
- **2-Action Rule**：每 2 次搜索/浏览操作后，立即保存发现到 `findings.md`
- **Read Before Decide**：做重大决策前，重新读取 `task_plan.md`
- **Log ALL Errors**：每个错误都记录，防止重复犯错
- **3-Strike Protocol**：同一问题 3 次失败后，升级给用户
- **阶段转换必更新**：每次阶段转换（brainstorm→openspec→plan→execute→review）必须更新 `progress.md`

> 这些文件替代了 Claude Code 的 `TodoWrite` 工具，且**功能更强**——持久化、可恢复、跨会话。

### 3.3 经验沉淀 — auto-learning

| Skill | 路径 |
|-------|------|
| auto-learning | `.agent/skills/auto-learning/SKILL.md` |

**核心规则（内嵌，详细指导见 SKILL.md）：**
- **写入**：medium/large 任务完成验证后，自动提取经验到 `docs/learnings/<date>-<topic>.md`
- **读取**：medium/large 任务开始时，`list_dir` 扫描 `docs/learnings/`，按需读取相关经验
- 每条经验独立一个文件，按文件名判断相关性，不全量加载

> 此 skill 替代 `continuous-learning-v2`（依赖 Hooks，目标平台均不支持）。
> 无需 Hooks 或外部工具，**所有平台通用**。

### 3.4 技术栈 Skills

> 按需使用 `view_file` 读取对应 SKILL.md 获取编码规范指导。所有 skills 均已启用，只在相关场景下按需读取。

#### Python

| Skill | view_file 路径 |
|-------|---------------|
| python-patterns | `.agent/skills/python-patterns/SKILL.md` |
| python-testing  | `.agent/skills/python-testing/SKILL.md`  |

#### Go

| Skill | view_file 路径 |
|-------|---------------|
| golang-patterns | `.agent/skills/golang-patterns/SKILL.md` |
| golang-testing  | `.agent/skills/golang-testing/SKILL.md`  |

#### TypeScript / React

| Skill | view_file 路径 |
|-------|---------------|
| frontend-patterns | `.agent/skills/frontend-patterns/SKILL.md` |
| coding-standards  | `.agent/skills/coding-standards/SKILL.md`  |

#### Java / Spring Boot

| Skill | view_file 路径 |
|-------|---------------|
| springboot-patterns   | `.agent/skills/springboot-patterns/SKILL.md`   |
| java-coding-standards | `.agent/skills/java-coding-standards/SKILL.md` |

#### 通用能力

| Skill | view_file 路径 |
|-------|---------------|
| api-design          | `.agent/skills/api-design/SKILL.md`          |
| database-migrations | `.agent/skills/database-migrations/SKILL.md` |
| docker-patterns     | `.agent/skills/docker-patterns/SKILL.md`     |
| deployment-patterns | `.agent/skills/deployment-patterns/SKILL.md` |
| e2e-testing         | `.agent/skills/e2e-testing/SKILL.md`         |
| security-guidance   | `.agent/skills/security-guidance/SKILL.md`   |
| backend-patterns    | `.agent/skills/backend-patterns/SKILL.md`    |

---
