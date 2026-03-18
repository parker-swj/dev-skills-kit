#!/bin/bash
# install.sh — 将 AI Agent Skills 配置安装到目标项目
# 用法：./install.sh [-f|--force] [目标项目路径]
# 示例：./install.sh ~/my-project
#       ./install.sh .   （安装到当前目录）
#       ./install.sh -f ~/my-project  （强制覆盖，不提示）
#
# 安装内容：
#   - .agent/skills/     精选 SKILL.md 文件（从 github-source/ 摘取，相对路径引用）
#   - .agent/workflows/  工作流（go, reset, learn 等）
#   - .agent/templates/  process.md 模板（small/medium/large）
#   - 各平台 /go 命令入口（.cursor/commands/, .claude/commands/ 等）
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
    
    if [ ! -d "$src_dir" ]; then
        return 0
    fi
    
    mkdir -p "$dst_dir"
    while IFS= read -r -d '' src_file; do
        local rel="${src_file#$src_dir/}"
        safe_cp "$src_file" "$dst_dir/$rel" "$label_prefix/$rel"
    done < <(find "$src_dir" -type f -print0 | sort -z)
}

# 标记区块安全补丁：只修改标记包裹的内容，保留用户其余内容
# 用法：safe_patch_markers <源文件> <目标文件> [标记名称]
safe_patch_markers() {
    local src="$1"
    local dst="$2"
    local marker_name="${3:-dev-skills-kit}"
    local marker_begin="<!-- ${marker_name}: begin -->"
    local marker_end="<!-- ${marker_name}: end -->"

    mkdir -p "$(dirname "$dst")"

    if [ ! -f "$dst" ]; then
        # 首次安装：创建文件，用标记包裹
        {
            echo "$marker_begin"
            cat "$src"
            echo "$marker_end"
        } > "$dst"
        return 0
    fi

    if grep -q "$marker_begin" "$dst"; then
        # 已有标记：替换区块内容
        local tmpfile
        tmpfile="$(mktemp)"
        awk -v marker_begin="$marker_begin" \
            -v marker_end="$marker_end" \
            -v newcontent="$src" \
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
            ' "$dst" > "$tmpfile"
        mv "$tmpfile" "$dst"
    else
        # 无标记：追加到末尾（用标记包裹）
        {
            echo ""
            echo "$marker_begin"
            cat "$src"
            echo "$marker_end"
        } >> "$dst"
    fi
}

# JSON 深合并：将源 JSON 的键值合并到目标 JSON，不覆盖用户已有键值
# 对于数组类型的值，合并去重；对于对象类型，递归合并
# 用法：safe_merge_json <源JSON文件> <目标JSON文件>
safe_merge_json() {
    local src="$1"
    local dst="$2"

    mkdir -p "$(dirname "$dst")"

    if [ ! -f "$dst" ]; then
        cp "$src" "$dst"
        return 0
    fi

    # 使用 python3 进行深度合并
    local tmpfile
    tmpfile="$(mktemp)"
    if python3 -c "
import json, sys

def deep_merge(base, override):
    '''将 override 合并到 base，base 的已有值优先保留'''
    result = dict(base)
    for key, val in override.items():
        if key not in result:
            result[key] = val
        elif isinstance(result[key], dict) and isinstance(val, dict):
            result[key] = deep_merge(result[key], val)
        elif isinstance(result[key], list) and isinstance(val, list):
            # 数组合并去重
            for item in val:
                if item not in result[key]:
                    result[key].append(item)
        # else: 保留用户的值
    return result

with open(sys.argv[1]) as f:
    user_data = json.load(f)
with open(sys.argv[2]) as f:
    kit_data = json.load(f)

merged = deep_merge(user_data, kit_data)
with open(sys.argv[3], 'w') as f:
    json.dump(merged, f, indent=4, ensure_ascii=False)
    f.write('\n')
" "$dst" "$src" "$tmpfile" 2>/dev/null; then
        mv "$tmpfile" "$dst"
    else
        # python3 不可用或解析失败，回退到 safe_cp
        rm -f "$tmpfile"
        echo "   ⚠️  JSON 合并失败，回退到安全复制"
        safe_cp "$src" "$dst" "$(basename "$dst")"
    fi
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
    # 技术栈（按需启用，默认全部安装）
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

# ── 复制 .agent/templates/ ──────────────────────────────
echo "📁 复制 .agent/templates/ (process.md 模板) ..."
safe_cp_dir "$SCRIPT_DIR/.agent/templates" "$TARGET/.agent/templates" ".agent/templates"
echo "   ✅ 完成"
echo ""

# ── 复制各大平台 /go 命令入口 ────────────────────────────
echo "📁 复制各大平台配置 ..."

# Cursor commands（Cursor 通过 .cursor/commands/ 识别 slash commands）
safe_cp_dir "$SCRIPT_DIR/.agent/workflows" "$TARGET/.cursor/commands" ".cursor/commands"

# Codex 全局 Slash Commands（Codex 仅识别全局 Prompts）
CODEX_GLOBAL_PROMPTS="${CODEX_HOME:-$HOME/.codex}/prompts"
safe_cp_dir "$SCRIPT_DIR/.agent/workflows" "$CODEX_GLOBAL_PROMPTS" "\$HOME/.codex/prompts"

# Claude commands
safe_cp_dir "$SCRIPT_DIR/.agent/workflows" "$TARGET/.claude/commands" ".claude/commands"

# OpenCode commands
safe_cp_dir "$SCRIPT_DIR/.agent/workflows" "$TARGET/.opencode/commands" ".opencode/commands"

# Gemini CLI commands
safe_cp_dir "$SCRIPT_DIR/.gemini/commands" "$TARGET/.gemini/commands" ".gemini/commands"
# Gemini settings.json 是共享文件，用 JSON 深合并保护用户设置
safe_merge_json "$SCRIPT_DIR/.gemini/settings.json" "$TARGET/.gemini/settings.json"
echo "   ✅ .gemini/settings.json（JSON 合并）"

echo "   ✅ 完成"
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

# 在目标项目初始化 openspec（安装 AI 工具指令文件到 .openspec/）
if command -v openspec &> /dev/null; then
    echo "🔧 在目标项目初始化 OpenSpec (多平台支持)..."
    
    # 使用逗号分隔的 --tools 参数一次性初始化所有平台
    OPENSPEC_TOOLS="antigravity,cursor,codex,opencode,gemini"
    if ( cd "$TARGET" && openspec init --tools "$OPENSPEC_TOOLS" >/dev/null 2>&1 ); then
        echo "   ✅ OpenSpec 多平台支持配置完成 ($OPENSPEC_TOOLS)"
    else
        echo "   ⚠️  OpenSpec 初始化可能失败，请手动执行："
        echo "      cd $TARGET && openspec init --tools $OPENSPEC_TOOLS"
    fi
    echo ""
fi

# ── 更新目标项目 .gitignore ──────────────────────────────
# install.sh 会在目标项目创建若干 AI 工具运行时目录（.gemini/ 等），
# 这些目录包含会话缓存、知识库等个人数据，不应提交到 git 仓库。
# 以下逻辑将这些条目安全地追加到目标项目的 .gitignore（已有则跳过）。

TARGET_GITIGNORE="$TARGET/.gitignore"

# 定义需要添加到用户项目 .gitignore 的条目
# 这些目录/文件由 install.sh 生成，属于个人开发环境配置，
# 多人协作时不应提交到 git，每位开发者应独立运行 install.sh 安装。
# 格式："条目|说明注释"
GITIGNORE_ENTRIES=(
    # ── AI 工具运行时目录（install.sh 安装，个人环境）──
    ".agent/|# AI Agent Skills/Workflows/Templates（由 install.sh 安装，勿提交）"
    ".cursor/|# Cursor 拦截规则（由 install.sh 安装，勿提交）"
    ".claude/|# Claude Code 命令（由 install.sh 安装，勿提交）"
    ".codex/|# Codex 项目级配置（由 install.sh 安装，勿提交）"
    ".opencode/|# OpenCode 拦截配置（由 install.sh 安装，勿提交）"
    ".openspec/|# OpenSpec 运行时缓存（openspec init 生成，勿提交）"
    ".gemini/|# Gemini CLI 命令与运行时缓存（由 install.sh 安装，勿提交）"
    "git-worktrees/|# Git Worktree 并发工作区缓存（由 /concurrency 生成，勿提交）"
    # ── AI 任务临时文件（运行时生成）──
    "task_plan.md|# AI 任务规划草稿（planning-with-files skill 生成，任务结束后可删除）"
    "findings.md|# AI 调研发现草稿（process.md 附属，任务结束后可删除）"
    "process.md|# AI 任务导航清单（基于模板生成，任务结束后归档或删除）"
)

echo "📄 更新目标项目 .gitignore ..."

# 若 .gitignore 不存在则创建
if [ ! -f "$TARGET_GITIGNORE" ]; then
    touch "$TARGET_GITIGNORE"
    echo "   📝 已创建 .gitignore"
fi

GITIGNORE_ADDED=0
GITIGNORE_SKIPPED=0

for ENTRY_DEF in "${GITIGNORE_ENTRIES[@]}"; do
    ENTRY="${ENTRY_DEF%%|*}"          # 实际忽略规则，如 .gemini/
    COMMENT="${ENTRY_DEF##*|}"        # 人类可读注释

    # 检查条目是否已存在（精确行匹配，忽略行首尾空白）
    if grep -qxF "$ENTRY" "$TARGET_GITIGNORE" 2>/dev/null; then
        echo "   ⏭️  已存在，跳过：$ENTRY"
        (( GITIGNORE_SKIPPED++ )) || true
    else
        # 追加注释 + 条目（如果文件末尾没有换行，先补一个）
        if [ -s "$TARGET_GITIGNORE" ] && [ "$(tail -c1 "$TARGET_GITIGNORE" | wc -l)" -eq 0 ]; then
            echo "" >> "$TARGET_GITIGNORE"
        fi
        echo "$COMMENT" >> "$TARGET_GITIGNORE"
        echo "$ENTRY" >> "$TARGET_GITIGNORE"
        echo "   ✅ 已添加：$ENTRY"
        (( GITIGNORE_ADDED++ )) || true
    fi
done

if [ "$GITIGNORE_ADDED" -eq 0 ]; then
    echo "   ℹ️  .gitignore 无需更改（所有条目均已存在）"
fi
echo ""

# ── 完成提示 ────────────────────────────────────────────
echo "✅ 安装完成！"
echo ""
echo "📝 接下来："
echo "   在 AI 对话中发送 /go 即可激活规则并进入工作状态"
echo ""
echo "🔄 更新上游 Skills（在 dev-skills-kit 仓库执行）："
echo "   cd $SCRIPT_DIR && ./update-sources.sh && ./install.sh $TARGET"
