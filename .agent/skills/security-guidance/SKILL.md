---
name: security-guidance
description: 安全编码指导。在编写或审查代码时自动检测常见安全漏洞模式（命令注入、XSS、反序列化等），提供安全编码建议。
version: 1.0.0
source: https://github.com/anthropics/claude-code/tree/main/plugins/security-guidance
---

# Security Guidance — 安全编码指导 Skill

在编写或审查代码时，自动识别常见安全漏洞模式并提供修复指导。

> **来源**: 改编自 [Anthropic Claude Code Plugins - security-guidance](https://github.com/anthropics/claude-code/tree/main/plugins/security-guidance)
> **原作者**: David Dworken (Anthropic)
> **改编说明**: 原版使用 Python Hook 在文件编辑前拦截检查，本版改编为跨平台的 SKILL.md 被动检测模式。

## 何时激活

- 编写或修改涉及以下场景的代码时**自动执行安全检查**
- 进行 Code Review 时
- 新建关键文件（CI/CD 配置、认证模块、数据处理等）时

## 安全检查清单

编写代码时，**必须**对以下安全模式保持警惕：

---

### 1. 🔴 GitHub Actions 工作流注入

**触发条件**：编辑 `.github/workflows/*.yml` 或 `.github/workflows/*.yaml` 文件

**风险**：在 `run:` 命令中直接使用不受信任的输入（如 issue 标题、PR 描述、commit 消息）会导致命令注入。

**❌ 不安全的写法**：
```yaml
run: echo "${{ github.event.issue.title }}"
```

**✅ 安全的写法**：
```yaml
env:
  TITLE: ${{ github.event.issue.title }}
run: echo "$TITLE"
```

**高危输入源**（必须通过环境变量引用）：
- `github.event.issue.title` / `github.event.issue.body`
- `github.event.pull_request.title` / `github.event.pull_request.body`
- `github.event.comment.body`
- `github.event.review.body` / `github.event.review_comment.body`
- `github.event.commits.*.message`
- `github.event.head_commit.message`
- `github.event.head_commit.author.email` / `github.event.head_commit.author.name`
- `github.event.pull_request.head.ref` / `github.event.pull_request.head.label`
- `github.head_ref`

> 📖 参考：[GitHub Actions 注入防护指南](https://github.blog/security/vulnerability-research/how-to-catch-github-actions-workflow-injections-before-attackers-do/)

---

### 2. 🔴 命令注入 — child_process.exec

**触发条件**：代码中使用 `child_process.exec()`、`exec()`、`execSync()`

**风险**：`exec()` 通过 shell 执行命令，用户输入可能导致命令注入。

**❌ 不安全**：
```javascript
const { exec } = require('child_process');
exec(`command ${userInput}`);
```

**✅ 安全**：
```javascript
const { execFile } = require('child_process');
execFile('command', [userInput]);  // 不经过 shell，防止注入
```

**要点**：
- `execFile` 替代 `exec`（不经过 shell）
- 参数用数组传递，不拼接字符串
- 仅在确实需要 shell 特性且输入可信时才用 `exec()`

---

### 3. 🔴 代码注入 — new Function / eval

**触发条件**：代码中使用 `new Function()` 或 `eval()`

**风险**：执行任意代码，可能导致远程代码执行（RCE）。

**✅ 替代方案**：
- 数据解析 → 用 `JSON.parse()`
- 模板渲染 → 用模板引擎
- 动态逻辑 → 用策略模式或映射表

> 仅在**确实需要动态求值**且输入**完全可信**时才使用。

---

### 4. 🔴 XSS 攻击 — dangerouslySetInnerHTML / innerHTML / document.write

**触发条件**：代码中使用以下 API：
- `dangerouslySetInnerHTML`（React）
- `.innerHTML =`
- `document.write()`

**风险**：未经净化的 HTML 内容可导致 XSS。

**✅ 安全做法**：

| 场景 | 安全方案 |
|------|---------|
| 纯文本 | `textContent` |
| 需要 HTML | 使用 DOMPurify 等净化库 |
| DOM 操作 | `createElement()` + `appendChild()` |
| React 富文本 | 使用 `react-markdown` 等安全组件 |

---

### 5. 🟡 反序列化 — pickle

**触发条件**：Python 代码中使用 `pickle`

**风险**：`pickle.load()` 处理不受信任的数据可导致任意代码执行。

**✅ 替代方案**：
- 结构化数据 → `json` / `msgpack`
- ML 模型 → `safetensors` / ONNX
- 仅在数据源**完全可信**时才用 pickle

---

### 6. 🟡 系统命令注入 — os.system (Python)

**触发条件**：Python 代码中使用 `os.system()` 或 `from os import system`

**风险**：通过 shell 执行命令，参数拼接可能导致注入。

**✅ 安全替代**：
```python
import subprocess
subprocess.run(['command', arg1, arg2], check=True)  # 不经过 shell
```

---

### 7. 🟡 SQL 注入

**触发条件**：拼接 SQL 查询字符串

**❌ 不安全**：
```python
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
```

**✅ 安全**：
```python
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
```

---

### 8. 🟡 敏感信息泄露

**触发条件**：代码中硬编码以下信息：
- API 密钥 / Token
- 数据库密码
- 私钥

**✅ 安全做法**：
- 使用环境变量 (`os.environ`, `process.env`)
- 使用 `.env` 文件 + `.gitignore`
- 使用密钥管理服务（Vault、AWS Secrets Manager 等）

---

## 执行方式

本 Skill 以**被动检测 + 主动提醒**的方式工作：

1. **编写代码时**：在写入文件前，自动对比上述安全模式
2. **发现匹配时**：在代码注释或输出中标记警告（⚠️ 前缀）
3. **提供修复建议**：给出安全替代方案
4. **不阻断工作流**：仅提醒，不阻止（用户可决定是否修复）

> 对于使用 Claude Code 的用户，原版插件通过 Hooks 机制在文件编辑前自动检查。
> 本 Skill 改为跨平台的被动检测方式，适用于所有 AI 编程助手。

## 安全审查 Checklist

对于 Code Review 场景，使用以下完整清单：

- [ ] **输入验证**：所有用户输入都经过验证和净化？
- [ ] **输出编码**：HTML 输出使用了适当的编码/转义？
- [ ] **认证授权**：敏感操作都有权限检查？
- [ ] **密钥管理**：无硬编码密钥？使用了安全的密钥存储？
- [ ] **依赖安全**：第三方库版本是否有已知漏洞？
- [ ] **错误处理**：异常信息不暴露内部细节？
- [ ] **日志安全**：日志不记录敏感信息？
- [ ] **HTTPS**：所有外部通信使用 HTTPS？
- [ ] **CORS**：跨域策略配置正确？
- [ ] **CSP**：内容安全策略是否设置？

## 与其他 Skills 的关系

| Skill | 关系 |
|-------|------|
| auto-learning | 安全修复模式可以记录到 learnings |
| planning-with-files | 安全审查结果记录到 findings.md |
| frontend-design | 前端代码要同时兼顾美观性和安全性 |

## 设计理念

- **预防优于修复**：在代码编写阶段就识别安全问题
- **教育性**：不仅指出问题，还解释原因和安全替代方案
- **实用性**：聚焦最常见、最危险的安全模式
- **跨平台**：适用于所有 AI 编程助手（Claude Code / Cursor / Gemini CLI / OpenCode 等）
- **不阻断**：提醒而非阻止，尊重开发者判断
