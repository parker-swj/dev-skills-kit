## 附录：平台适配速查表

| 原 Superpowers 机制 | Claude Code | Antigravity | OpenCode |
|---------------------|-------------|-------------|----------|
| 会话开始注入规则 | `SessionStart` Hook | **AGENTS.md**（自动加载） | `.opencode/` 代理拦截规则 |
| 按需加载 Skill | `Skill` tool | **`view_file`** 读取 SKILL.md | **`view_file`** 读取 SKILL.md |
| 任务跟踪 | `TodoWrite` | **`task_plan.md`** 文件 | **`task_plan.md`** 文件 |
| 子代理调度 | `Task` tool | **不可用**，用 `executing-plans` | **原生 `subagent` 调度** |
| 代码审查子代理 | 独立 reviewer 子代理 | **自审检查清单**（第 6 节） | **自审 或 委派专门的 reviewer subagent** |
| Git Worktree | ✅ 通用 | ✅ 通用 | ✅ 通用 |
| TDD 流程 | ✅ 通用 | ✅ 通用 | ✅ 通用 |
| 文件读写 | ✅ 通用 | ✅ 通用 | ✅ 通用 |
