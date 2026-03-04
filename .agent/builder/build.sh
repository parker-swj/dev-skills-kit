#!/bin/bash
# build.sh — 根据模板生成各个平台的 AGENTS 配置文件

set -e

BUILDER_DIR="$(cd "$(dirname "$0")" && pwd)"
COMMON_DIR="$BUILDER_DIR/common"
PLATFORMS_DIR="$BUILDER_DIR/platforms"
AGENT_DIR="$(dirname "$BUILDER_DIR")"
ROOT_DIR="$(dirname "$AGENT_DIR")"

echo "🔨 开始构建 AGENTS 配置文件..."

build_platform() {
    local platform=$1
    local output_file=$2

    echo "  -> 生成 $output_file"
    
    cat \
        "$PLATFORMS_DIR/$platform/00-prologue.md" \
        "$COMMON_DIR/01-header.md" \
        "$PLATFORMS_DIR/$platform/01-subagent-note.md" \
        "$COMMON_DIR/02-planning.md" \
        "$COMMON_DIR/03-scheduler.md" \
        "$PLATFORMS_DIR/$platform/02-large-note.md" \
        "$COMMON_DIR/04-defect-rules.md" \
        "$PLATFORMS_DIR/$platform/03-review.md" \
        "$PLATFORMS_DIR/$platform/04-not-used.md" \
        "$PLATFORMS_DIR/$platform/05-appendix-table.md" \
        "$COMMON_DIR/05-appendix-structure.md" \
        > "$output_file"
        
    # 去除多余的重复空行以对齐旧版格式
    sed -i -z 's/\n\n\n/\n\n/g' "$output_file"
}

# 构建各个环境
build_platform "cursor" "$AGENT_DIR/AGENTS.cursor.md"
build_platform "codex" "$AGENT_DIR/AGENTS.codex.md"
build_platform "opencode" "$AGENT_DIR/AGENTS.opencode.md"
build_platform "antigravity" "$ROOT_DIR/AGENTS.md"

echo "✅ 构建完成！"
