## 4. 场景分级调度器

<EXTREMELY-IMPORTANT>
接到任何任务后，**先评估复杂度等级**，再决定激活哪些 skills。
不要把 trivial/small 任务升级为 medium/large。流程过度本身就是浪费。
</EXTREMELY-IMPORTANT>

### 判定规则

| 等级 | 判定条件 | 典型场景 |
|------|----------|----------|
| **trivial** | 改动 ≤ 1 个文件，无逻辑变更 | 改变量名、修 typo、调格式、改配置值 |
| **small** | 改动 ≤ 3 个文件，预计 < 30 分钟 | 修 bug、添加字段、调整样式 |
| **medium** | 涉及 3+ 文件，预计 1-4 小时 | 新增 API 端点、实现业务模块 |
| **large** | 涉及核心模块，预计 > 1 天，**或**命中下方任一升级信号 | 重写认证、数据库迁移、微服务拆分 |

**⚠️ Large 升级信号（命中任一条即升级为 large）：**
- 引入新外部依赖（架构层面改变）
- 引入全新能力/子系统（从零构建）
- 多个交叉关注点（≥ 3 个正交关注点有耦合）
- 跨模块影响（波及多个现有模块的初始化、配置或接口）

> 文件数量和工时是表层指标。架构级信号才是区分 medium 和 large 的关键。

### 各等级激活 Skills 与流程

#### Trivial — 直接做，不创建 process.md

```
激活：verification-before-completion
流程：直接修改 → 验证 → 完成
```

#### Small — 基于 `process-small.md` 模板，3 步

```
激活：systematic-debugging, verification-before-completion, TDD（灵活版）, 技术栈 patterns
跳过：brainstorming, writing-plans, code-review
```

#### Medium — 基于 `process-medium.md` 模板，7 步

```
激活：brainstorming（精简版，遵守 Expert Mode）, writing-plans, executing-plans,
      TDD, requesting-code-review, finishing-a-development-branch,
      systematic-debugging, verification-before-completion, security-guidance,
      技术栈 patterns + auto-learning
跳过：using-git-worktrees（可选）、OpenSpec
```

#### Large — 基于 `process-large.md` 模板，11 步

```
激活：全部 skills（通过 view_file 按需读取对应 SKILL.md）
强制会话分割：在 process.md 的「会话分割记录」节记录断点
```

<EXTREMELY-IMPORTANT>
**Large Step 3 — OpenSpec 检测（brainstorming 之后，必须执行）：**

1. 检查项目根目录是否存在 `openspec/` 文件夹
2. **存在** → 走 OpenSpec 分支（Step 4 的 Path A）
3. **不存在** → 走 writing-plans 分支（Step 4 的 Path B）
4. **不得跳过检测**直接进入 writing-plans
</EXTREMELY-IMPORTANT>
