### 3.2 状态持久化 — process.md（一体化清单）

<EXTREMELY-IMPORTANT>
**`process.md` 是当前任务的唯一导航文件和恢复依据。**

**创建规则：**
- small/medium/large 任务开始时，**第一个动作**是基于 `.agent/templates/process-[复杂度].md` 创建 `process.md`
- 复制模板 → 替换占位符 → 将 Step 1 状态设为 🔄
- 复杂度写入即 **🔒 锁定，不可降级**
- trivial 任务不创建 `process.md`

**执行规则（三态系统）：**
- ⬜ 未开始 → 不得操作 ｜ 🔄 进行中 → 唯一可操作的步骤 ｜ ✅ 已完成 → 不再修改
- 完成一个步骤后**立即**：① 改为 ✅ 并填写关键记录 → ② 下一步改为 🔄 → ③ 重新读取 process.md
- **不得跳过** ⬜ 步骤，不得同时有两个 🔄

**附属文件（process.md 的补充，不是独立状态源）：**
- `task_plan.md` — 详细计划（Medium/Large 的 writing-plans 步骤产出）
- `findings.md` — 调研发现和错误记录（2-Action Rule：每 2 次搜索后保存）

**收尾归档（最后一步完成后）：**
1. process.md 最后一步标记 ✅ 并记录完成时间
2. 全部 planning 文件移到 `.archive/tasks/[时间戳]/`
3. 执行 auto-learning
</EXTREMELY-IMPORTANT>

> `process.md` 是 `/go` 工作流的唯一恢复依据，必须始终保持最新状态。

### 3.3 经验沉淀 — auto-learning

| Skill | 路径 |
|-------|------|
| auto-learning | `.agent/skills/auto-learning/SKILL.md` |

**核心规则（内嵌，详细指导见 SKILL.md）：**
- **写入**：medium/large 任务完成验证后，自动提取经验到 `docs/learnings/<date>-<topic>.md`
- **读取**：medium/large 任务开始时，`list_dir` 扫描 `docs/learnings/`，按需读取相关经验

> 无需 Hooks 或外部工具，**所有平台通用**。

### 3.4 技术栈 Skills

> 按需使用 `view_file` 读取对应 SKILL.md 获取编码规范指导。

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
