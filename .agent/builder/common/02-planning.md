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
| `progress.md` | **阶段状态机（唯一恢复依据）**、会话日志 | **每次阶段转换时立即更新**，brainstorm 开始时创建 |

<EXTREMELY-IMPORTANT>
**`progress.md` 是跨会话恢复的唯一权威状态来源。**

**写入规则：**

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

**阶段转换时必须立即更新 `progress.md` 的「当前阶段」节：**

| 转换事件 | 必须更新为 |
|---------|-----------|
| 开始 brainstorming | `阶段: brainstorming` / `状态: 进行中` |
| brainstorming 结束，进入 openspec | `阶段: openspec` / `状态: 进行中` |
| brainstorming 结束，进入 writing-plans | `阶段: writing-plans` / `状态: 进行中` |
| openspec 完成，进入 executing | `阶段: executing` / `状态: 进行中` |
| writing-plans 完成，进入 executing | `阶段: executing` / `状态: 进行中` |
| executing 完成，进入 review | `阶段: review` / `状态: 进行中` |
| 任务全部完成（review 通过） | `状态: 已完成` → **然后触发收尾归档（见下）** |

**任务完成后的收尾归档（closing 阶段）：**

review 通过、`finishing-a-development-branch` 执行后，**必须**执行以下收尾步骤：

```
1. 更新 progress.md：状态: 已完成，记录完成时间
2. 将规划文件归档到 .archive/tasks/[完成时间戳]/：
   - progress.md → .archive/tasks/[时间戳]/
   - task_plan.md（若存在）→ .archive/tasks/[时间戳]/
   - findings.md（若存在）→ .archive/tasks/[时间戳]/
3. 工作区恢复干净状态（无 planning 文件）
4. 执行 auto-learning：提取经验到 docs/learnings/
```

**`progress.md` 缺失 = 从头开始**：如果新会话中 `progress.md` 不存在，说明没有进行中的任务，等待用户描述新需求，不得假设任何阶段已完成。
</EXTREMELY-IMPORTANT>

**关键规则：**
- **Brainstorm 立即建档**：brainstorm 开始的第一个动作就是创建 `progress.md`，防跨会话丢失
- **阶段转换必更新**：每次阶段转换**立即**更新 `progress.md`，不得延迟
- **任务完成必归档**：review 通过后，planning 文件归档到 `.archive/tasks/`，工作区清空
- **2-Action Rule**：每 2 次搜索/浏览操作后，立即保存发现到 `findings.md`
- **Read Before Decide**：做重大决策前，重新读取 `task_plan.md`
- **Log ALL Errors**：每个错误都记录，防止重复犯错
- **3-Strike Protocol**：同一问题 3 次失败后，升级给用户

> 这些文件替代了 Claude Code 的 `TodoWrite` 工具，且**功能更强**——持久化、可恢复、跨会话。
> `progress.md` 是 `/go` 工作流的唯一恢复依据，必须始终保持最新状态。

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
