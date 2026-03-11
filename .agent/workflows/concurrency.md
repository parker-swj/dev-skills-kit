---
description: 评估 OpenSpec 变更并使用 git worktree 创建可并发的独立的开发环境
argument-hint: [可选：指定特定的 changes 目录路径，默认探测当前项目下的 openspec/changes/]
---

$ARGUMENTS

# /concurrency — OpenSpec 变更并发工作流

> **使用场景**：当项目中设计了多个 OpenSpec 变更（changes）等待开发时，通过此命令评估它们之间的依赖关系。对于可以并行独立的变更，自动使用 `git worktree` 创建隔离的开发目录。这样可以让你在同一底座下开启多个完全解耦的 Git 工作树进行开发，避免串行阻塞。

## 步骤

### 1. 扫描与获取变更列表

1. 寻找当前项目的 `openspec/changes/` 目录（如果未在根目录下，尝试查找）。
2. 列出目录下所有的变更（过滤掉如 `archive`、`IMPLEMENTATION_ORDER.md` 等非实际需求目录的条目）。
3. 使用 `view_file` 工具读取相关信息，包括每个需求目录下的 `proposal.md`、`tasks.md`、`design.md` 以及可能存在的依赖说明文件（如 `IMPLEMENTATION_ORDER.md`）。

### 2. 分析依赖关系与评估并发性

1. 根据读取到的上下文信息（重点留意文档中如 `dependsOn` 或依赖链路的明确声明），梳理各个变更之间的前置依赖关系。
2. 将变更分层：
   - **可完全并发**：没有任何前置依赖阻塞的、平级的变更需求。
   - **需串行等待**：依赖其他尚未实施变更的需求。
3. **输出报告**：向用户展示「并发评估报告」，清晰列出哪些需求适合创建独立的并发工作区、哪些存在冲突或需要等待。

**⏳ 阻塞点：向用户展示分析结果，等待用户明确回复确认或继续后，再执行后续工作区创建操作。**

### 3. 创建 Git Worktree 并发工作区

用户确认后，对分析得到的**可并发变更**，依次执行以下建立工作区动作。使用 `run_command` 执行相关终端命令。

1. **环境准备**：
   - 确认并在项目根目录创建 `.worktrees/` 目录存放各并发工作区（如果不存在则 `mkdir -p .worktrees`）。
   - 需要确保 `.worktrees/` 已经被添加到当前项目根目录的 `.gitignore` 中以防代码仓库污染（若未忽略则帮助追加）。

2. **核心分支创建与分离绑定**：
   针对每一个可并发变更（设其名称为 `<change-name>`），执行：
   - 基于当前开发基准分支（通常为 `main` 或当前所在的开发主干），分配新分支。
   - 分支命名规范规定为：`concurrency/<change-name>`
   - 执行 `git worktree add .worktrees/concurrency-<change-name> -b concurrency/<change-name>`
   *(注意：如果关联分支已存在，可以省略 `-b` 等根据实际执行返回状态变通。)*

3. **同步 AI 工具与运行环境依赖**（重要）：
   由于 `.gitignore` 会忽略诸多 AI 开发工具的本地配置文件，使用 `git worktree` 时，这些隐藏文件**不会**被带入新目录，导致 AI 的技能与规则在新建目录中失效。
   因此，新目录创建后，立即**将根目录下的依赖项手工复制给每个新分支的归属目录**。
   建议使用类似下方的遍历命令复制相关配置到 `.worktrees/concurrency-<change-name>`（视实际使用情况处理不存在的文件目录而不报错）：
   ```bash
   cp -r .agent .cursor .opencode .gemini .claude .codex .openspec AGENTS.md .worktrees/concurrency-<change-name>/ 2>/dev/null || true
   ```

### 4. 总结与开发者人工指引

完成环境配置后，向用户输出环境说明以及后续的人工操作指南。

```markdown
✅ **并发工作区已创建完成**

你可以同时打开多个编辑器在各自独立的目录开发：
- `cd .worktrees/concurrency-<change-name>`

**后续手工合并开发流程指南**：
1. 分别在各个工作树下开展 TDD、修改代码等工作。
2. 独立针对各自的 `concurrency/<change-name>` 分支进行 `git commit`。
3. 这些并行特性实现完成后，**用户请手动**从主根目录将特性分支合并回主线。
4. 合并结束不再需要时，可以通过在主目录执行 `git worktree remove .worktrees/concurrency-<change-name>` 和 `git branch -d concurrency/<change-name>` 来安全地进行销毁清理。
```

<EXTREMELY-IMPORTANT>
- 此脚本的核心职能仅在于分析后利用 git 工作树提供纯净的独立并行空间；不要在该流程中自作主张直接去实现那些变更里的具体代码，也不要越俎代庖进行自动化合并（由于这些合并往往需要人为解冲突）。
</EXTREMELY-IMPORTANT>
