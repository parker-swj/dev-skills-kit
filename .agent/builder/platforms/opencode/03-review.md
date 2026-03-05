## 6. 代码审查

OpenCode 可利用 subagents 机制（如 `@code-reviewer`）进行审查，或直接执行**自审**：

- **Medium**（process.md Step 5）：单阶段自审 — 代码质量（DRY/YAGNI/错误处理/命名）+ 安全检查
- **Large**（process.md Step 8）：双阶段自审 — 先规格合规（对照 task_plan.md 逐项）→ 再代码质量 + 安全

> 审查结果分级：🔴 Critical（立即修复）/ 🟠 Important（继续前修复）/ 🟡 Minor（记录到 findings.md）

---


