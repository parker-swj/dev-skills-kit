## 附录：平台适配速查表

| 原 Superpowers 机制 | Claude Code | OpenCode |
|---------------------|-------------|-------------|
| 会话开始注入规则 | `SessionStart` Hook | **`.opencode/AGENTS.md`** 拦截加载 |
| 按需加载 Skill | `Skill` tool | 通过 **`view_file`** 读取 |
| 任务跟踪 | `TodoWrite` | **`task_plan.md`** 作为目标管理 |
| 子代理调度 | `Task` tool | **不使用基础工具**，走原生 `subagent`（如 `@reviewer`）调度 |
| 代码审查子代理 | 独立 reviewer 子代理 | 你调度专属 review subagent 或进行自我审查（第 6 节） |
| Git Worktree | ✅ 通用 | ✅ 通用 |
| TDD 流程 | ✅ 通用 | ✅ 通用 |
| 文件读写 | ✅ 通用 | ✅ 通用 |
