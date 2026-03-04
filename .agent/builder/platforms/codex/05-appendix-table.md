## 附录：平台适配速查表

| 原 Superpowers 机制 | Claude Code | Codex Agent |
|---------------------|-------------|-------------|
| 会话开始注入规则 | `SessionStart` Hook | **`.codex/` 配置或启动拦截** |
| 按需加载 Skill | `Skill` tool | 系统提供的 **`view_file`** 工具 |
| 任务跟踪 | `TodoWrite` | **`task_plan.md`** 作为记忆库 |
| 子代理调度 | `Task` tool | **忽略**，由主 Agent 将多流统合执行 |
| 代码审查子代理 | 独立 reviewer 子代理 | 由主 Agent 以多阶段执行**自审检查**（第 6 节） |
| Git Worktree | ✅ 通用 | ✅ 通用 |
| TDD 流程 | ✅ 通用 | ✅ 通用 |
| 文件读写 | ✅ 通用 | ✅ 通用 |
