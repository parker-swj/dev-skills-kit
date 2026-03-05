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
| 数据库迁移 | 迁移前后数据一致性校验 |
| 基础设施代码 (IaC) | dry-run + plan 输出审查 |

> 跳过 TDD 时必须在 `findings.md` 中记录原因和替代验证方式。

### 5.2 Expert Mode 快捷通道

当用户在请求中已给出以下信息中的 **3 项以上**时，自动进入 Expert Mode：
- 技术栈选择、具体实现方案、接口设计、数据结构

**Expert Mode 行为**：跳过苏格拉底式逐一提问 → 直接确认理解 → 补充遗漏点 → 进入 writing-plans

### 5.3 遗留代码库适配

- **不要求全局绿色基线**，改为局部基线
- **渐进式引入测试**：新代码必须有测试，旧代码先写 characterization test

### 5.4 灾难恢复

- 同一问题 3 次修复失败 → 暂停并请求人工介入（3-Strike Protocol）
- 关键操作前 → 创建 `git tag` 作为安全回滚点
- 上下文过大 → 主动保存状态到 `process.md` 当前步骤的关键记录

### 5.5 防遗忘防护（Anti-Context-Decay）

<EXTREMELY-IMPORTANT>
**无论上下文多长都必须执行：**
1. **完成前必须验证**（verification-before-completion）
2. **重大决策前重新读取 process.md / task_plan.md**
3. **每 2 次搜索/浏览后保存发现到 findings.md**
4. **3 次失败后停止并请求人工介入**
</EXTREMELY-IMPORTANT>

**大任务会话分割**：Large 任务在设计完成、执行完成等自然断点主动分割会话，在 process.md 的「会话分割记录」节记录断点。

---
