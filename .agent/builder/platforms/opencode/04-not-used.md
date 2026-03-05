## 7. 不使用清单

| 不纳入 | 原因 |
|--------|------|
| **subagent-driven-development** | 你可以使用自带的 subagents，且更为强大灵活 |
| **compound-engineering-plugin** | 被 Superpowers + auto-learning 完全覆盖 |
| **openskills** | 工具层，非 Skill 本身 |
| ECC 的 `/tdd`、`/plan`、`/code-review` commands | 与 Superpowers 流程冲突 |
| ECC 的 planner / tdd-guide agents | 与 Superpowers 流程冲突 |
| Claude Code Hooks（SessionStart 等） | 已由 `.opencode/` 代理拦截规则替代 |
| Claude Code `Skill` tool | 已由 `view_file` 等文件读取工具替代 |
| Claude Code `TodoWrite` | 已由 process.md 一体化清单替代 |
