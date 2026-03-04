## 附录：平台适配速查表

| 原 Superpowers 机制 | Claude Code | Cursor Agent Mode |
|---------------------|-------------|-------------|
| 会话开始注入规则 | `SessionStart` Hook | **`.cursor/rules/*.mdc`** 引导加载 |
| 按需加载 Skill | `Skill` tool | 本原生系统的 **`view_file`** 读取 |
| 任务跟踪 | `TodoWrite` | **`task_plan.md`** 文件 |
| 子代理调度 | `Task` tool | **不使用**，你足够强大，独自完成整个流水线 |
| 代码审查子代理 | 独立 reviewer 子代理 | 你自行执行**检查清单**（第 6 节） |
| Git Worktree | ✅ 通用 | ✅ 通用 |
| TDD 流程 | ✅ 通用 | ✅ 通用 |
| 文件读写 | ✅ 通用 | ✅ 通用 |
