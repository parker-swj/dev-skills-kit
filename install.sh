#!/bin/bash
# install.sh — 将 AI Agent Skills 配置安装到目标项目
# 用法：./install.sh [-f|--force] [目标项目路径]
# 示例：./install.sh ~/my-project
#       ./install.sh .   （安装到当前目录）
#       ./install.sh -f ~/my-project  （强制覆盖，不提示）
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

# ── 解析选项 ─────────────────────────────────────────────
FORCE=false
OVERWRITE_ALL=false
SKIP_ALL=false

while [[ "${1:-}" == -* ]]; do
    case "$1" in
        -f|--force) FORCE=true; shift ;;
        *) echo "未知选项：$1"; exit 1 ;;
    esac
done

TARGET="${1:-}"

# ── 参数检查 ────────────────────────────────────────────
if [ -z "$TARGET" ]; then
    echo "用法：$0 [-f|--force] <目标项目路径>"
    echo "示例：$0 ~/my-project"
    echo "  -f, --force  强制覆盖所有已存在的文件，不提示"
    exit 1
fi

if [ ! -d "$TARGET" ]; then
    echo "❌ 目标目录不存在：$TARGET"
    exit 1
fi

TARGET="$(cd "$TARGET" && pwd)"  # 转为绝对路径

# ── 安全复制工具函数 ─────────────────────────────────────

# 安全复制单文件：如果目标已存在且内容不同，提示用户选择
safe_cp() {
    local src="$1"
    local dst="$2"
    local label="${3:-$dst}"

    if [ ! -f "$dst" ]; then
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        return 0
    fi

    # 文件已存在，检查内容是否相同
    if diff -q "$src" "$dst" > /dev/null 2>&1; then
        return 0  # 内容相同，静默跳过
    fi

    # 内容不同，需要用户决定
    if $FORCE || $OVERWRITE_ALL; then
        cp "$src" "$dst"
        return 0
    fi

    if $SKIP_ALL; then
        echo "      ⏭️  跳过（内容不同）：$label"
        return 0
    fi

    echo ""
    echo "   ⚠️  文件已存在且内容不同：$label"
    while true; do
        read -rp "      覆盖？[y]是 / [n]否 / [d]查看差异 / [a]全部覆盖 / [s]全部跳过: " choice
        case "$choice" in
            y|Y)
                cp "$src" "$dst"
                echo "      ✅ 已覆盖"
                return 0
                ;;
            n|N)
                echo "      ⏭️  已跳过"
                return 0
                ;;
            d|D)
                echo "      ── 差异对比 (现有 ← → 新版) ──"
                diff --color=auto "$dst" "$src" || true
                echo "      ── 差异对比结束 ──"
                ;;
            a|A)
                OVERWRITE_ALL=true
                cp "$src" "$dst"
                echo "      ✅ 已覆盖（后续冲突文件将全部覆盖）"
                return 0
                ;;
            s|S)
                SKIP_ALL=true
                echo "      ⏭️  已跳过（后续冲突文件将全部跳过）"
                return 0
                ;;
            *)
                echo "      请输入 y / n / d / a / s"
                ;;
        esac
    done
}

# 安全复制目录中所有文件（使用 process substitution 避免子 shell 变量丢失）
safe_cp_dir() {
    local src_dir="$1"
    local dst_dir="$2"
    local label_prefix="${3:-$dst_dir}"
    mkdir -p "$dst_dir"
    while IFS= read -r -d '' src_file; do
        local rel="${src_file#$src_dir/}"
        safe_cp "$src_file" "$dst_dir/$rel" "$label_prefix/$rel"
    done < <(find "$src_dir" -type f -print0 | sort -z)
}

# ── 自动拉取上游源码（如果 github-source/ 不存在）──────
if [ ! -d "$SOURCE_DIR" ]; then
    echo "📡 未检测到 github-source/，正在自动拉取上游源码..."
    bash "$SCRIPT_DIR/update-sources.sh"
    echo ""
fi

echo "🚀 安装 AI Agent Skills 配置"
echo "   来源：$SCRIPT_DIR"
echo "   目标：$TARGET"
if $FORCE; then
    echo "   模式：强制覆盖（--force）"
fi
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
    ["backend-patterns"]="everything-claude-code/skills/backend-patterns"
    # Anthropic 官方 Claude Code Plugins
    ["frontend-design"]="claude-code/plugins/frontend-design/skills/frontend-design"
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
    safe_cp "$SRC" "$DST" ".agent/skills/$NAME/SKILL.md"
    (( INSTALLED++ )) || true
done
echo "   ✅ 处理 $INSTALLED 个 Skills（跳过 $SKIPPED 个源缺失）"
echo ""

# ── 复制本地维护的 Skills ────────────────────────────────
# 这些 Skills 不来自 github-source/，而是本项目自行维护的
# （原创、改编自上游无原生 SKILL.md 的插件、或来自其他格式的上游）
echo "📦 复制本地维护的 Skills..."
LOCAL_SKILLS_DIR="$SCRIPT_DIR/.agent/skills"
LOCAL_INSTALLED=0
if [ -d "$LOCAL_SKILLS_DIR" ]; then
    for SKILL_DIR in "$LOCAL_SKILLS_DIR"/*/; do
        [ -d "$SKILL_DIR" ] || continue
        SKILL_NAME="$(basename "$SKILL_DIR")"
        if [ -f "$SKILL_DIR/SKILL.md" ]; then
            DST="$TARGET/.agent/skills/$SKILL_NAME/SKILL.md"
            mkdir -p "$(dirname "$DST")"
            safe_cp "$SKILL_DIR/SKILL.md" "$DST" ".agent/skills/$SKILL_NAME/SKILL.md"
            (( LOCAL_INSTALLED++ )) || true
        fi
    done
fi
echo "   ✅ 处理 $LOCAL_INSTALLED 个本地 Skills"
echo ""

# ── 复制 .agent/workflows/ ──────────────────────────────
echo "📁 复制 .agent/workflows/ ..."
safe_cp_dir "$SCRIPT_DIR/.agent/workflows" "$TARGET/.agent/workflows" ".agent/workflows"
echo "   ✅ 完成"
echo ""

# ── 构建 AGENTS 配置文件（到临时目录，避免修改仓库文件）────
BUILD_TMPDIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_TMPDIR"' EXIT

if [ -x "$SCRIPT_DIR/.agent/builder/build.sh" ]; then
    echo "🔨 构建最新版本的 AGENTS 配置文件..."
    bash "$SCRIPT_DIR/.agent/builder/build.sh" "$BUILD_TMPDIR" > /dev/null
    echo "   ✅ 完成"
    echo ""
fi

# 构建输出目录存在时优先使用构建后的最新文件，否则回退到仓库已有文件
agents_src() {
    local filename="$1"
    if [ -f "$BUILD_TMPDIR/$filename" ]; then
        echo "$BUILD_TMPDIR/$filename"
    else
        echo "$SCRIPT_DIR/$filename"
    fi
}

echo "📁 复制各大平台专属配置及拦截规则 ..."

# Cursor 拦截规则
safe_cp_dir "$SCRIPT_DIR/.cursor/rules" "$TARGET/.cursor/rules" ".cursor/rules"

# Codex 全局 Slash Commands (Codex 仅识别全局 Prompts)
CODEX_GLOBAL_PROMPTS="${CODEX_HOME:-$HOME/.codex}/prompts"
safe_cp_dir "$SCRIPT_DIR/.agent/workflows" "$CODEX_GLOBAL_PROMPTS" "\$HOME/.codex/prompts"

# Codex 项目级拦截配置
safe_cp_dir "$SCRIPT_DIR/.codex" "$TARGET/.codex" ".codex"

# Claude commands
safe_cp_dir "$SCRIPT_DIR/.agent/workflows" "$TARGET/.claude/commands" ".claude/commands"

# OpenCode 拦截配置
safe_cp_dir "$SCRIPT_DIR/.opencode" "$TARGET/.opencode" ".opencode"

# 各平台专属高级配置（从构建输出目录读取）
safe_cp "$(agents_src AGENTS.cursor.md)" "$TARGET/.agent/AGENTS.cursor.md" ".agent/AGENTS.cursor.md"
safe_cp "$(agents_src AGENTS.codex.md)" "$TARGET/.agent/AGENTS.codex.md" ".agent/AGENTS.codex.md"
safe_cp "$(agents_src AGENTS.opencode.md)" "$TARGET/.agent/AGENTS.opencode.md" ".agent/AGENTS.opencode.md"

echo "   ✅ 完成"
echo ""

# ── 追加根目录 AGENTS.md（Antigravity 降级版）─────────────────────
TARGET_AGENTS="$TARGET/AGENTS.md"
MARKER_BEGIN="<!-- dev-skills-kit: begin -->"
MARKER_END="<!-- dev-skills-kit: end -->"
AGENTS_SRC="$(agents_src AGENTS.md)"

echo "📄 处理根目录 AGENTS.md (Antigravity 版) ..."
if [ ! -f "$TARGET_AGENTS" ]; then
    # 首次安装：创建文件，用标记包裹以便后续更新
    {
        echo "$MARKER_BEGIN"
        cat "$AGENTS_SRC"
        echo "$MARKER_END"
    } > "$TARGET_AGENTS"
    echo "   ✅ 已创建 AGENTS.md"
else
    if grep -q "$MARKER_BEGIN" "$TARGET_AGENTS"; then
        # 已有标记：替换区块内容为最新版本
        # 创建临时文件以安全替换
        TMPFILE="$(mktemp)"
        # 使用 awk 进行精确的区块替换
        awk -v marker_begin="$MARKER_BEGIN" \
            -v marker_end="$MARKER_END" \
            -v newcontent="$AGENTS_SRC" \
            '
            $0 == marker_begin { 
                print marker_begin
                while ((getline line < newcontent) > 0) print line
                close(newcontent)
                skip = 1
                next
            }
            $0 == marker_end {
                print marker_end
                skip = 0
                next
            }
            !skip { print }
            ' "$TARGET_AGENTS" > "$TMPFILE"
        mv "$TMPFILE" "$TARGET_AGENTS"
        echo "   ✅ 已更新 AGENTS.md 中的 dev-skills-kit 配置区块"
    else
        # 无标记：追加到末尾（用标记包裹）
        {
            echo ""
            echo "$MARKER_BEGIN"
            cat "$AGENTS_SRC"
            echo "$MARKER_END"
        } >> "$TARGET_AGENTS"
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
