---

## 附录：目录结构

```
项目根目录/
├── AGENTS.md                      ← 本文件（Agent 配置，每次会话自动加载）
├── .agent/skills/
│   ├── planning-with-files/
│   │   └── SKILL.md               ← 状态持久化 skill
│   ├── brainstorming/
│   │   └── SKILL.md
│   ├── systematic-debugging/
│   │   └── SKILL.md
│   └── ...（其他精选 skills）
├── .agent/workflows/
│   └── save-to-kb.md              ← 工作流
├── task_plan.md                   ← 运行时生成（planning-with-files）
├── findings.md                    ← 运行时生成
└── progress.md                    ← 运行时生成
```
