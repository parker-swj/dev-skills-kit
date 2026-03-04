## 7. 不使用清单

| 不纳入 | 原因 |
|--------|------|
| **subagent-driven-development** | 你是拥有全局权限的单体智能主体，无须额外委托 |
| **compound-engineering-plugin** | 被 Superpowers + auto-learning 完全覆盖 |
| **openskills** | 工具层，非 Skill 本身 |
| ECC 的 `/tdd`、`/plan`、`/code-review` commands | 与 Superpowers 流程冲突 |
| ECC 的 planner / tdd-guide agents | 与 Superpowers 流程冲突 |
| Claude Code Hooks（SessionStart 等） | 已被 `.codex/` 或主工作流规则机制替代 |
| Claude Code `Skill` tool | 已由 `view_file` 统一切换替代 |
| Claude Code `TodoWrite` | 已由 planning-with-files 的 3 文件替代 |
