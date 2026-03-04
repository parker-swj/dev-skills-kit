---

## 5. 缺陷补丁规则

以下规则**覆盖** Superpowers 中对应的教条规则，提供适合企业实际场景的灵活性。

### 5.1 TDD 灵活化

以下场景允许跳过"先写测试"，但必须有替代验证：

| 场景 | 替代验证方式 |
|------|------------|
| UI / 前端样式 | 截图对比 或 手动验证 + 记录到 findings.md |
| 配置文件修改 | 运行应用验证配置生效 |
| 一次性脚本 / 原型 | smoke test + 输出验证 |
| ML 训练脚本 | 指标对比（loss/accuracy 变化） |
| 数据库迁移 | 迁移前后数据一致性校验 |
| 基础设施代码 (IaC) | dry-run + plan 输出审查 |

> 跳过 TDD 时必须在 `findings.md` 中记录原因和替代验证方式。

### 5.2 Expert Mode 快捷通道

当用户在请求中已给出以下信息中的 **3 项以上**时，自动进入 Expert Mode：
- 技术栈选择
- 具体实现方案
- 接口设计
- 数据结构

**Expert Mode 行为**：
- ❌ 跳过苏格拉底式逐一提问
- ✅ 直接确认理解 → 补充遗漏点（如有） → 进入 writing-plans
- ✅ 将确认浓缩为一次性呈现，而非分段审批

### 5.3 遗留代码库适配

当项目现有测试不通过或无测试时：

1. **不要求全局绿色基线**，改为局部基线
2. **渐进式引入测试**：新代码必须有测试，旧代码先写 characterization test
3. **Worktree 创建时**：基线验证改为运行相关子集测试 或 确认构建成功即可

### 5.4 灾难恢复

- 同一问题 3 次修复失败 → 暂停并请求人工介入（与 planning-with-files 的 3-Strike Protocol 对齐）
- 关键操作前 → 创建 `git tag` 作为安全回滚点
- 上下文过大 → 主动保存状态到 `task_plan.md` 和 `progress.md`

### 5.5 防遗忘防护（Anti-Context-Decay）

> **背景**：即使在 Claude Code + Superpowers 原生环境中，AI 也会在长会话中遗忘或跳过 skill 指令
> （参见 [superpowers#528](https://github.com/obra/superpowers/issues/528)：跳过代码审查、
> [#485](https://github.com/obra/superpowers/issues/485)：无视"禁止并行"指令）。
> Gemini/Antigravity 的上下文窗口在 30-50% 容量时即开始性能下降。
> 以下防护措施用于对抗此问题。

#### 规则 1：关键指令重复强化

以下规则**无论上下文多长都必须执行**，在此再次强调：

<EXTREMELY-IMPORTANT>
1. **完成前必须验证**（verification-before-completion）——不验证不算完成
2. **每次重大决策前重新读取 task_plan.md**——防止偏离计划
3. **每 2 次搜索/浏览操作后保存发现到 findings.md**——防止信息丢失
4. **3 次失败后停止并请求人工介入**——不要无限循环
</EXTREMELY-IMPORTANT>

#### 规则 2：定期上下文刷新

在 medium/large 任务中，每完成一个**计划阶段**后执行：

```
1. 重新读取 task_plan.md      → 刷新目标和剩余任务
2. 更新 progress.md           → 记录刚完成的内容
3. 检查当前阶段是否有遗漏     → 对照计划逐项确认
```

> 这比依赖上下文记忆的方式更可靠——即使 Agent 遗忘了之前的会话内容，
> 只要 `/go` 读取 `progress.md` 就能完全恢复到正确阶段。

#### 规则 3：大任务会话分割

当任务达到 **large** 等级时，按以下节点主动分割会话：

```
会话 1: brainstorming → writing-plans → 保存计划到 task_plan.md
         ↓ （用户开新会话）
会话 2: 读取 task_plan.md → executing-plans（任务 1-N）→ 更新 progress.md
         ↓ （如果未完成，用户开新会话）
会话 3: 读取 progress.md 确认阶段 → 继续执行 → 代码审查 → finishing-branch
```

**会话分割时机判断**：
- 上下文中已有 > 5 轮深度讨论（brainstorming / debugging）
- 已经完成了一个完整的阶段转换（设计 → 实现 / 实现 → 审查）
- 感觉到回答质量下降或开始遗漏之前讨论过的细节

---
