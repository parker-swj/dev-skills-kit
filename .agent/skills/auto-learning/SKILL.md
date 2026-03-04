---
name: auto-learning
description: 无 Hooks 的自动经验沉淀系统。任务结束时自动提取经验，新任务开始时按需检索。适用于所有 CLI 平台。
version: 1.0.0
---

# Auto Learning — 跨平台自动经验沉淀

无需 Hooks，通过工作流内嵌实现自动经验的提取、存储和检索。
替代 `continuous-learning-v2`（依赖 Claude Code Hooks，其他平台不可用）。

## 何时激活

- **写入**：每个 medium/large 任务完成验证后、声明完成前（必经门控）
- **读取**：每个 medium/large 任务开始时（brainstorming 或 writing-plans 之前）

## 存储结构

```
docs/learnings/
├── 2026-03-01-retry-backoff-strategy.md
├── 2026-03-02-docker-multi-stage-pitfall.md
└── 2026-03-04-postgres-migration-lock.md
```

每个文件是一条**独立的、原子化的经验记录**，文件名格式：`YYYY-MM-DD-<关键词>.md`

## 写入流程（任务完成时自动执行）

任务通过 `verification-before-completion` 后，在声明完成前：

1. 判断本次任务是否产生了值得记录的经验（以下任一即可）：
   - 遇到了非显而易见的问题并解决
   - 发现了可复用的模式或技巧
   - 踩了坑，下次应避免
   - 做了重要的技术决策及其理由

2. 如果有，在 `docs/learnings/` 目录下创建新文件，内容格式：

```markdown
---
date: YYYY-MM-DD
domain: <领域标签，如 python / docker / database / api / testing / git>
task: <任务简述>
complexity: medium / large
---

# <经验标题>

## 问题/场景
<遇到了什么问题，或在什么场景下>

## 解决方案
<怎么解决的，关键步骤>

## 根因 / 原理
<为什么会这样，底层原因>

## 可复用规则
- <提炼为简洁的行动规则，未来可直接参考>
```

3. 如果本次任务没有新经验产生（纯例行操作），跳过，不创建空文件

## 读取流程（新任务开始时自动执行）

开始 medium/large 任务时，在 brainstorming 或 writing-plans 之前：

1. 用 `list_dir` 查看 `docs/learnings/` 目录（如果存在）
2. 根据**文件名和当前任务的相关性**，判断是否需要读取
3. 只读取**可能相关的**文件（不全读），获取历史经验作为参考
4. 如果目录不存在或没有相关经验，正常继续

> **关键原则**：读取是**按需的**，不是全量加载。看文件名即可判断相关性。

## 不适用的场景

- **trivial / small 任务**：不写入也不读取（开销不值得）
- **纯文档/配置修改**：通常不产生技术经验
- **与已有记录完全重复的经验**：不重复记录

## 与其他 Skills 的关系

| Skill | 关系 |
|-------|------|
| verification-before-completion | 先验证通过，再写入经验，最后声明完成 |
| planning-with-files | `findings.md` 记录当次任务细节，`learnings/` 提炼跨任务经验 |
| systematic-debugging | 调试过程的根因发现是经验的重要来源 |

## 执行顺序

```
任务完成
  → verification-before-completion（验证通过）
  → auto-learning（提取经验到 docs/learnings/）
  → finishing-a-development-branch（收尾）
```

## 设计理念

- **原子化**：一个文件 = 一条经验，可独立删除/更新
- **按需检索**：通过文件名过滤，不浪费 token
- **零依赖**：不依赖 Hooks / 外部工具 / 特定平台 API
- **渐进积累**：随着项目推进，经验库自然生长
