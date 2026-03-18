#!/bin/bash
# regenerate-diagrams.sh — 重新生成 docs/images/ 中的所有 SVG 图表
# 用法：./docs/mermaid-src/regenerate-diagrams.sh
#
# 依赖：npm install -g @mermaid-js/mermaid-cli

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SRC_DIR="$SCRIPT_DIR"
OUT_DIR="$PROJECT_ROOT/docs/images"
PUPPETEER_CONFIG="$SRC_DIR/puppeteer-config.json"

echo "🎨 重新生成 Mermaid 图表..."
echo "   源文件：$SRC_DIR"
echo "   输出到：$OUT_DIR"
echo ""

mkdir -p "$OUT_DIR"

GENERATED=0
FAILED=0

for f in "$SRC_DIR"/*.mmd; do
    [ -f "$f" ] || continue
    name=$(basename "$f" .mmd)
    echo -n "   📊 $name.svg ... "
    if mmdc -i "$f" -o "$OUT_DIR/${name}.svg" -t dark -b transparent --width 1200 -p "$PUPPETEER_CONFIG" 2>/dev/null; then
        echo "✅"
        (( GENERATED++ )) || true
    else
        echo "❌"
        (( FAILED++ )) || true
    fi
done

echo ""
echo "✅ 完成：生成 $GENERATED 张，失败 $FAILED 张"
