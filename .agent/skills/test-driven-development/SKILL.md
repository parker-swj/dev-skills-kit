---
name: test-driven-development
description: 测试驱动开发。实现功能或修复 Bug 前，强制先写失败测试，遵循 RED-GREEN-REFACTOR 循环。
version: 1.0.0
source: https://github.com/AgentSuperPowers/superpowers/tree/main/skills/test-driven-development
---

# Test-Driven Development (TDD)

先写测试，看它失败，再写最少的代码让它通过。

> **来源**: 改编自 [Agent Superpowers - test-driven-development](https://github.com/AgentSuperPowers/superpowers/tree/main/skills/test-driven-development)
> **改编说明**: 原版面向 Claude Code，本版改为跨平台通用格式，适用于所有 AI 编程助手。

## 何时激活

- 实现新功能前
- 修复 Bug 前
- 重构代码前

**例外（需用户确认）：** 一次性原型、生成代码、纯配置文件

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

先写了代码再补测试？删掉，从测试开始重来。

## Red-Green-Refactor 循环

### 🔴 RED — 写失败测试

写一个最小的测试，展示期望行为。

**要求：**
- 测试一个行为
- 清晰的测试名称
- 用真实代码（非不得已不 mock）

```typescript
// ✅ Good: 清晰名称，测试真实行为
test('retries failed operations 3 times', async () => {
  let attempts = 0;
  const operation = () => {
    attempts++;
    if (attempts < 3) throw new Error('fail');
    return 'success';
  };
  const result = await retryOperation(operation);
  expect(result).toBe('success');
  expect(attempts).toBe(3);
});

// ❌ Bad: 模糊名称，测试 mock 而非代码
test('retry works', async () => {
  const mock = jest.fn()
    .mockRejectedValueOnce(new Error())
    .mockResolvedValueOnce('success');
  await retryOperation(mock);
  expect(mock).toHaveBeenCalledTimes(2);
});
```

### 验证 RED — 看它失败

**必须执行，不可跳过。**

```bash
npm test path/to/test.test.ts
# 或对应语言的测试命令
```

确认：
- 测试**失败**（不是报错）
- 失败信息符合预期
- 因为功能缺失而失败（不是拼写错误）

### 🟢 GREEN — 写最少的代码

写**最简单**的代码让测试通过。

```typescript
// ✅ Good: 刚好够通过
async function retryOperation<T>(fn: () => Promise<T>): Promise<T> {
  for (let i = 0; i < 3; i++) {
    try { return await fn(); }
    catch (e) { if (i === 2) throw e; }
  }
  throw new Error('unreachable');
}

// ❌ Bad: 过度设计
async function retryOperation<T>(
  fn: () => Promise<T>,
  options?: {
    maxRetries?: number;
    backoff?: 'linear' | 'exponential';  // YAGNI
  }
): Promise<T> { /* ... */ }
```

### 验证 GREEN — 看它通过

**必须执行。**

确认：
- 测试通过
- 其他测试仍然通过
- 输出干净（无 error、warning）

### 🔵 REFACTOR — 清理

只在 GREEN 之后：
- 消除重复
- 改善命名
- 提取 helper

保持测试绿色。不增加新行为。

### 重复

下一个失败测试，下一个功能。

## Bug 修复流程

```
发现 Bug → 先写失败测试复现它 → 按 TDD 循环修复
```

**绝不** 不写测试就修 Bug。测试证明修复有效，并防止回归。

## 常见借口 vs 现实

| 借口 | 现实 |
|------|------|
| "太简单了不需要测试" | 简单代码也会坏。写测试只要 30 秒 |
| "我先写代码再补测试" | 后补的测试立即通过，证明不了什么 |
| "手动测试过了" | 手动 ≠ 系统化，无法重复运行 |
| "删掉 X 小时的工作太浪费" | 沉没成本谬误。保留未验证的代码才是技术债 |
| "TDD 会拖慢速度" | TDD 比调试快。务实 = 先测试 |
| "这次例外一下" | 没有例外 |

## 红旗 — 停下来，从头开始

- 先写了代码再补测试
- 测试立即通过
- 解释不了测试为什么失败
- 在想"就这一次"
- 在想"保留作参考"

**以上都意味着：删除代码，从 TDD 重新开始。**

## 完成前 Checklist

- [ ] 每个新函数/方法都有测试
- [ ] 每个测试都先看到失败再实现
- [ ] 每个测试因预期原因失败（功能缺失，非拼写错误）
- [ ] 写了最少的代码让测试通过
- [ ] 所有测试通过
- [ ] 输出干净（无 error、warning）
- [ ] 测试用真实代码（mock 仅在不得已时）
- [ ] 边界和错误情况已覆盖

全部打勾？继续。否则回到 RED。

## 卡住时怎么办

| 问题 | 解决 |
|------|------|
| 不知道怎么测 | 先写期望的 API。先写断言。问用户。 |
| 测试太复杂 | 设计太复杂。简化接口。 |
| 必须 mock 一切 | 代码耦合太高。用依赖注入。 |
| 测试 setup 太大 | 提取 helper。还是复杂？简化设计。 |

## 测试反模式

添加 mock 或测试工具时，参考 @testing-anti-patterns.md 避免常见陷阱：
- 测试 mock 行为而非真实行为
- 给生产类添加仅测试用的方法
- 不理解依赖就 mock

## 与其他 Skills 的关系

| Skill | 关系 |
|-------|------|
| systematic-debugging | 调试 Phase 4 引用本 Skill 创建失败测试 |
| verification-before-completion | TDD 是验证的基础，完成前需通过验证门控 |
| planning-with-files | 测试失败记录到 findings.md |
| auto-learning | TDD 过程中发现的模式可记录到 learnings |
| security-guidance | 安全相关代码也需 TDD |

## 设计理念

- **测试优先**：测试定义行为，代码实现行为
- **最小实现**：YAGNI — 没有测试要求的功能不写
- **跨平台**：适用于所有语言和框架
- **零妥协**：没有"这次例外"的空间
