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
├── .agent/templates/
│   ├── process-small.md           ← Small 模板（3 步）
│   ├── process-medium.md          ← Medium 模板（6 步）
│   └── process-large.md           ← Large 模板（10 步）
├── .agent/workflows/
│   └── save-to-kb.md              ← 工作流
├── process.md                     ← 运行时生成（基于模板，一体化清单）
├── task_plan.md                   ← 运行时生成（process.md 附属）
└── findings.md                    ← 运行时生成（process.md 附属）
```
