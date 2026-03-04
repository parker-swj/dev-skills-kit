#!/bin/bash
# install.sh — 将 AI Agent Skills 配置安装到目标项目
# 用法：./install.sh [目标项目路径]
# 示例：./install.sh ~/my-project
#       ./install.sh .   （安装到当前目录）
#
# 安装内容：
#   - .agent/skills/   精选 SKILL.md 文件（从 github-source/ 摘取，相对路径引用）
#   - .agent/workflows/ 工作流（save-to-kb 等）
#   - AGENTS.md 片段   追加到目标项目的 AGENTS.md（不覆盖）
#
# github-source/ 保留在本仓库，不复制到目标项目。

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/github-source"
TARGET="${1:-}"

# ── 参数检查 ────────────────────────────────────────────
if [ -z "$TARGET" ]; then
    echo "用法：$0 <目标项目路径>"
    echo "示例：$0 ~/my-project"
    exit 1
fi

if [ ! -d "$TARGET" ]; then
    echo "❌ 目标目录不存在：$TARGET"
    exit 1
fi

TARGET="$(cd "$TARGET" && pwd)"  # 转为绝对路径

# ── 自动拉取上游源码（如果 github-source/ 不存在）──────
if [ ! -d "$SOURCE_DIR" ]; then
    echo "📡 未检测到 github-source/，正在自动拉取上游源码..."
    bash "$SCRIPT_DIR/update-sources.sh"
    echo ""
fi

echo "🚀 安装 AI Agent Skills 配置"
echo "   来源：$SCRIPT_DIR"
echo "   目标：$TARGET"
echo ""

# ── 精选 Skills 列表 ─────────────────────────────────────
# 格式：["目标名称"]="源相对路径"（相对于 github-source/）
declare -A SKILLS=(
    # Superpowers 方法论
    ["brainstorming"]="superpowers/skills/brainstorming"
    ["writing-plans"]="superpowers/skills/writing-plans"
    ["executing-plans"]="superpowers/skills/executing-plans"
    ["test-driven-development"]="superpowers/skills/test-driven-development"
    ["systematic-debugging"]="superpowers/skills/systematic-debugging"
    ["verification-before-completion"]="superpowers/skills/verification-before-completion"
    ["requesting-code-review"]="superpowers/skills/requesting-code-review"
    ["receiving-code-review"]="superpowers/skills/receiving-code-review"
    ["dispatching-parallel-agents"]="superpowers/skills/dispatching-parallel-agents"
    ["finishing-a-development-branch"]="superpowers/skills/finishing-a-development-branch"
    ["writing-skills"]="superpowers/skills/writing-skills"
    ["using-git-worktrees"]="superpowers/skills/using-git-worktrees"
    ["using-superpowers"]="superpowers/skills/using-superpowers"
    # everything-claude-code 核心
    ["continuous-learning-v2"]="everything-claude-code/skills/continuous-learning-v2"
    # 技术栈（按需启用，默认全部安装，在 AGENTS.md 中按需取消注释）
    ["python-patterns"]="everything-claude-code/skills/python-patterns"
    ["python-testing"]="everything-claude-code/skills/python-testing"
    ["golang-patterns"]="everything-claude-code/skills/golang-patterns"
    ["golang-testing"]="everything-claude-code/skills/golang-testing"
    ["frontend-patterns"]="everything-claude-code/skills/frontend-patterns"
    ["coding-standards"]="everything-claude-code/skills/coding-standards"
    ["springboot-patterns"]="everything-claude-code/skills/springboot-patterns"
    ["java-coding-standards"]="everything-claude-code/skills/java-coding-standards"
    ["api-design"]="everything-claude-code/skills/api-design"
    ["database-migrations"]="everything-claude-code/skills/database-migrations"
    ["docker-patterns"]="everything-claude-code/skills/docker-patterns"
    ["deployment-patterns"]="everything-claude-code/skills/deployment-patterns"
    ["e2e-testing"]="everything-claude-code/skills/e2e-testing"
    ["security-review"]="everything-claude-code/skills/security-review"
    ["security-scan"]="everything-claude-code/skills/security-scan"
    ["backend-patterns"]="everything-claude-code/skills/backend-patterns"
)

# ── 复制精选 SKILL.md 到 .agent/skills/ ─────────────────
echo "📦 复制精选 Skills..."
INSTALLED=0
SKIPPED=0
for NAME in "${!SKILLS[@]}"; do
    SRC="$SOURCE_DIR/${SKILLS[$NAME]}/SKILL.md"
    DST="$TARGET/.agent/skills/$NAME/SKILL.md"

    if [ ! -f "$SRC" ]; then
        echo "   ⚠️  [$NAME] 源文件不存在，跳过：$SRC"
        (( SKIPPED++ )) || true
        continue
    fi

    mkdir -p "$(dirname "$DST")"
    cp "$SRC" "$DST"
    (( INSTALLED++ )) || true
done
echo "   ✅ 安装 $INSTALLED 个 Skills（跳过 $SKIPPED 个）"
echo ""

# ── 复制 .agent/workflows/ ──────────────────────────────
echo "📁 复制 .agent/workflows/ ..."
mkdir -p "$TARGET/.agent/workflows"
cp -r "$SCRIPT_DIR/.agent/workflows/." "$TARGET/.agent/workflows/"
echo "   ✅ 完成"
echo ""

# ── 构建 AGENTS 配置文件 ────────────────────────────────
if [ -x "$SCRIPT_DIR/.agent/builder/build.sh" ]; then
    echo "🔨 构建最新版本的 AGENTS 配置文件..."
    bash "$SCRIPT_DIR/.agent/builder/build.sh" > /dev/null
    echo "   ✅ 完成"
    echo ""
fi

echo "📁 复制各大平台专属配置及拦截规则 ..."
mkdir -p "$TARGET/.cursor/rules"
cp -r "$SCRIPT_DIR/.cursor/rules/." "$TARGET/.cursor/rules/"
# Codex 全局 Slash Commands (Codex 仅识别全局 Prompts)
CODEX_GLOBAL_PROMPTS="${CODEX_HOME:-$HOME/.codex}/prompts"
mkdir -p "$CODEX_GLOBAL_PROMPTS"
cp -r "$SCRIPT_DIR/.agent/workflows/." "$CODEX_GLOBAL_PROMPTS/"

# Codex 项目级拦截配置
mkdir -p "$TARGET/.codex"
cp -r "$SCRIPT_DIR/.codex/." "$TARGET/.codex/"
mkdir -p "$TARGET/.claude/commands"
cp -r "$SCRIPT_DIR/.agent/workflows/." "$TARGET/.claude/commands/"
mkdir -p "$TARGET/.opencode"
cp -r "$SCRIPT_DIR/.opencode/." "$TARGET/.opencode/"
cp "$SCRIPT_DIR/.agent/AGENTS.cursor.md" "$TARGET/.agent/"
cp "$SCRIPT_DIR/.agent/AGENTS.codex.md" "$TARGET/.agent/"
cp "$SCRIPT_DIR/.agent/AGENTS.opencode.md" "$TARGET/.agent/"
echo "   ✅ 完成"
echo ""

# ── 追加根目录 AGENTS.md（Antigravity 降级版）─────────────────────
TARGET_AGENTS="$TARGET/AGENTS.md"

echo "📄 处理根目录 AGENTS.md (Antigravity 版) ..."
if [ ! -f "$TARGET_AGENTS" ]; then
    cp "$SCRIPT_DIR/AGENTS.md" "$TARGET_AGENTS"
    echo "   ✅ 已创建 AGENTS.md"
else
    MARKER="<!-- dev-skills-kit: begin -->"
    if grep -q "$MARKER" "$TARGET_AGENTS"; then
        echo "   ℹ️  AGENTS.md 中已包含 dev-skills-kit 配置，跳过"
        echo "      如需更新，删除 '<!-- dev-skills-kit: begin/end -->' 区块后重新运行"
    else
        echo "" >> "$TARGET_AGENTS"
        echo "<!-- dev-skills-kit: begin -->" >> "$TARGET_AGENTS"
        cat "$SCRIPT_DIR/AGENTS.md" >> "$TARGET_AGENTS"
        echo "<!-- dev-skills-kit: end -->" >> "$TARGET_AGENTS"
        echo "   ✅ 已追加到现有 AGENTS.md"
    fi
fi
echo ""



# ── OpenSpec 安装 ───────────────────────────────────────
echo "🔍 检查 OpenSpec..."
if command -v openspec &> /dev/null; then
    echo "   ✅ OpenSpec 已安装：$(openspec --version 2>/dev/null || echo '版本未知')"
else
    echo "   📦 未检测到 openspec，正在全局安装 @fission-ai/openspec ..."
    if npm install -g @fission-ai/openspec; then
        echo "   ✅ OpenSpec 安装成功"
    else
        echo "   ⚠️  OpenSpec 安装失败（可能需要 sudo 或网络问题），请手动执行："
        echo "      npm install -g @fission-ai/openspec"
    fi
fi
echo ""

# 在目标项目初始化 openspec
if command -v openspec &> /dev/null; then
    echo "🔧 在目标项目初始化 OpenSpec (多平台支持)..."
    
    # 初始化 Antigravity 支持
    if ( cd "$TARGET" && openspec init --tools antigravity 2>&1 >/dev/null ); then
        echo "   ✅ OpenSpec Antigravity 支持配置完成"
    else
        echo "   ⚠️  OpenSpec Antigravity 初始化可能失败，可稍后手动检查"
    fi

    # 初始化 Cursor 支持
    if ( cd "$TARGET" && openspec init --tools cursor 2>&1 >/dev/null ); then
        echo "   ✅ OpenSpec Cursor 支持配置完成"
    else
        echo "   ⚠️  OpenSpec Cursor 初始化可能失败，可稍后手动检查"
    fi

    # 初始化 Codex 支持
    if ( cd "$TARGET" && openspec init --tools codex 2>&1 >/dev/null ); then
        echo "   ✅ OpenSpec Codex 支持配置完成"
    else
        echo "   ⚠️  OpenSpec Codex 初始化可能失败，可稍后手动检查"
    fi

    # 初始化 OpenCode 支持
    if ( cd "$TARGET" && openspec init --tools opencode 2>&1 >/dev/null ); then
        echo "   ✅ OpenSpec OpenCode 支持配置完成"
    else
        echo "   ⚠️  OpenSpec OpenCode 初始化可能失败，可稍后手动检查"
    fi
    echo ""
fi

# ── 完成提示 ────────────────────────────────────────────
echo "✅ 安装完成！"
echo ""
echo "📝 接下来："
echo "   1. 打开 $TARGET/AGENTS.md"
echo "   2. 在第 3.4 节取消注释你项目所需的技术栈 Skills"
echo ""
echo "🔄 更新上游 Skills（在 dev-skills-kit 仓库执行）："
echo "   cd $SCRIPT_DIR && ./update-sources.sh && ./install.sh $TARGET"
