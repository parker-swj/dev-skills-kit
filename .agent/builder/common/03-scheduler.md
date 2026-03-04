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

**⚠️ Large 升级信号（命中任一条即升级为 large，不论文件数量或预估工时）：**

| 信号 | 说明 | 举例 |
|------|------|------|
| **引入新外部依赖** | 新增的依赖库带来架构层面的改变 | 引入 client-go、新 ORM 框架、消息队列 SDK |
| **引入全新能力/子系统** | 不是对现有功能的增强，而是从零构建全新子系统 | k8s ConfigMap 访问、OAuth2 认证、事件总线 |
| **多个交叉关注点** | 改动涉及 ≥ 3 个正交关注点，彼此有耦合 | 客户端 → 定时同步 → 本地缓存 → 降级容错 → 可观测指标 |
| **跨模块影响** | 改动波及多个现有模块的初始化、配置或接口 | settings、server 启动、新模块、metrics、依赖管理 |

> **注意**：文件数量和工时是**表层指标**，容易误判。架构级信号才是区分 medium 和 large 的关键。
> 例如：「接入 k8s ConfigMap 作为配置源」表面上可能只改 5 个文件、预估 4 小时，但它同时命中了全部 4 条升级信号，必须按 large 处理。

### 各等级激活的 Skills

#### Trivial（直接做 → 验证）

```
激活：verification-before-completion（改完验证即可）
跳过：其他全部
```

#### Small（外科手术模式）

```
激活：
  ├─ systematic-debugging             → 遇到 bug 时（view_file 读取 `.agent/skills/systematic-debugging/SKILL.md`）
  ├─ verification-before-completion   → 改完验证（规则已内嵌，无需读取）
  ├─ test-driven-development（灵活版）→ 有现成测试就更新，没有不强求
  └─ 技术栈 patterns（参考）          → view_file 读取对应 SKILL.md

跳过：brainstorming, writing-plans, code-review, planning-with-files
```

#### Medium（标准模式）

```
激活：
  ├─ brainstorming（精简版）          → view_file 读取 SKILL.md，但遵守 Expert Mode 规则
  ├─ writing-plans                    → view_file 读取 SKILL.md
  ├─ executing-plans                  → 分批执行 + 人工检查点
  ├─ planning-with-files              → 创建 3 个文件（规则已内嵌）
  ├─ test-driven-development          → 标准 RED-GREEN-REFACTOR
  ├─ requesting-code-review           → 完成后自审（见第 6 节）
  ├─ finishing-a-development-branch   → view_file 读取 SKILL.md
  ├─ systematic-debugging             → 随时待命
  ├─ verification-before-completion   → 强制验证
  ├─ security-guidance                → 编写/审查代码时执行安全检查（view_file 读取 SKILL.md）
  └─ 技术栈 patterns + auto-learning（见 3.3 节）

跳过：using-git-worktrees（可选）、OpenSpec
```

#### Large（完整模式）

激活：全部 skills（通过 view_file 按需读取对应 SKILL.md）

<EXTREMELY-IMPORTANT>
**Large 模式 Step 2 — OpenSpec 检测（阶段 1 · brainstorming 之后，必须执行）：**

在完成 brainstorming（Step 1）后、进入 writing-plans 之前，你**必须**执行以下检测：

1. **检查项目根目录是否存在 `openspec/` 文件夹**（使用 `list_dir` 或 `find` 等工具）
2. 根据检测结果走对应分支——**不得跳过检测直接进入 writing-plans**：

   - **存在 `openspec/` 目录** → **必须**走 OpenSpec 分支（下方 Path A）
   - **不存在 `openspec/` 目录** → 走 writing-plans 分支（下方 Path B）
</EXTREMELY-IMPORTANT>

##### 阶段 1：设计 & 归档

```
Step 1. brainstorming               → 苏格拉底式探索，对齐目标和方案

Step 2. 固化设计（执行上方 OpenSpec 检测后二选一）：

  Path A — openspec/ 目录存在：
    /opsx:new <change-name>-<YYYYMMDDHHMM>   → 建变更目录
    （命名规则：功能名 + 时间戳，例如 /opsx:new add-auth-202602251554）
    /opsx:ff                       → 将 brainstorming 结论固化为文档链：
                                      proposal（Why）→ specs（What）
                                      → design（How）→ tasks（实施清单）
    （复杂需求用 /opsx:continue 逐步生成，可逐步审查）
    ✅ tasks.md 即后续执行清单，跳过 writing-plans

  Path B — openspec/ 目录不存在：
    writing-plans                  → 生成 task_plan.md 作为执行清单

Step 3. using-git-worktrees（可选） → 隔离工作区
```

##### 阶段 2：执行

```
  ├─ executing-plans                  → 按 tasks.md / task_plan.md 分批执行
  ├─ planning-with-files              → 跨天防失忆（3 文件）
  ├─ test-driven-development          → 严格执行 RED-GREEN-REFACTOR
  ├─ security-guidance                → 全程安全检查
  └─ 全部技术栈 patterns
```

##### 阶段 3：验收归档

```
  ├─ requesting-code-review           → 完成后双阶段自审（见第 6 节）
  ├─ auto-learning                    → 自动提取经验到 docs/learnings/
  ├─ finishing-a-development-branch   → 标准收尾
  └─ [openspec/ 目录存在时]
      /opsx:verify                    → 验证实现与 artifacts 一致性（完整性/正确性/一致性）
      /opsx:archive                   → 归档（sync specs → 移入 archive/YYYY-MM-DD-<name>/）
```

```
安全措施：
  ├─ 关键操作前 git tag               → 灾难恢复点
  └─ 上下文过大时主动保存状态到 task_plan.md + progress.md
```

> **OpenSpec artifacts 对应关系：**
> `proposal` = Why · `specs/` = What · `design.md` = How · `tasks.md` = 执行清单
