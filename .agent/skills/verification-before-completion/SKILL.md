---
name: verification-before-completion
description: 完成前验证门控。声明任务完成、修复成功或测试通过前，必须运行验证命令并确认输出，证据先于断言。
version: 1.0.0
source: https://github.com/AgentSuperPowers/superpowers/tree/main/skills/verification-before-completion
---

# Verification Before Completion — 完成前验证门控

声称工作完成却没有验证，是不诚实，不是高效。

> **来源**: 改编自 [Agent Superpowers - verification-before-completion](https://github.com/AgentSuperPowers/superpowers/tree/main/skills/verification-before-completion)
> **改编说明**: 原版面向 Claude Code，本版改为跨平台通用格式。

## 核心原则

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

如果你没有在**本次操作中**运行验证命令，你就不能声称它通过了。

## 何时激活

**在以下场景之前必须执行：**
- 声称任务完成 / 修复成功 / 测试通过
- 表达满意（"Great!"、"Done!"、"完成了！"）
- 提交代码、创建 PR
- 进入下一个任务

## 验证门控流程

```
声称任何状态前：

1. 识别：什么命令能证明这个声称？
2. 运行：执行完整命令（新鲜的、完整的）
3. 阅读：完整输出，检查退出码，计算失败数
4. 验证：输出是否确认了声称？
   - 否 → 陈述实际状态 + 证据
   - 是 → 陈述声称 + 证据
5. 然后才能：做出声称

跳过任何步骤 = 猜测，不是验证
```

## 常见验证要求

| 声称 | 需要的证据 | 不充分的证据 |
|------|-----------|-------------|
| 测试通过 | 测试命令输出：0 失败 | 上次运行、"应该能过" |
| Lint 干净 | Linter 输出：0 错误 | 部分检查、外推 |
| 构建成功 | 构建命令：exit 0 | "Linter 通过了" |
| Bug 已修复 | 测试原始症状：通过 | "代码改了，应该好了" |
| 回归测试有效 | Red-Green 循环验证 | 测试只运行通过一次 |
| 需求已满足 | 逐条对照检查清单 | "测试过了" |

## 回归测试的完整验证

```
✅ 正确流程：
  写测试 → 运行（通过） → 撤销修复 → 运行（必须失败） → 恢复修复 → 运行（通过）

❌ 错误流程：
  "我写了回归测试"（没有做 red-green 验证）
```

## 红旗 — 立即停止

- 使用 "应该"、"大概"、"似乎"
- 验证前表达满意
- 准备提交/推送但没验证
- 依赖部分验证
- 在想 "就这一次"
- **任何暗示成功但没有运行验证命令的措辞**

## 常见借口 vs 现实

| 借口 | 现实 |
|------|------|
| "应该能用了" | 运行验证命令 |
| "我很有信心" | 信心 ≠ 证据 |
| "就这一次" | 没有例外 |
| "Linter 过了" | Linter ≠ 编译器 |
| "我累了" | 疲劳 ≠ 借口 |
| "部分检查够了" | 部分证明不了什么 |

## 与其他 Skills 的关系

| Skill | 关系 |
|-------|------|
| test-driven-development | TDD 的 GREEN 阶段就是验证；本 Skill 是最终的完成门控 |
| auto-learning | 先通过验证门控，再写入经验，最后声明完成 |
| planning-with-files | 验证结果记录到 findings.md |
| security-guidance | 安全审查也需要验证证据 |

## 执行顺序

```
任务完成
  → test-driven-development（测试通过）
  → verification-before-completion（运行验证命令，确认输出）
  → auto-learning（提取经验）
  → 声明完成
```

## 设计理念

- **证据优先**：没有运行命令就没有资格声称结果
- **零信任**：不信任"上次运行"、"应该可以"、"我很有信心"
- **跨平台**：适用于所有 AI 编程助手
- **不阻断**：验证通过就继续，不增加额外负担
