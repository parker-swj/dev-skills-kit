#!/bin/bash
# update-sources.sh — 更新 github-source/ 下的上游 Skills 到最新版本
# 用法：./update-sources.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/github-source"

declare -A REPOS=(
    ["superpowers"]="https://github.com/obra/superpowers"
    ["everything-claude-code"]="https://github.com/affaan-m/everything-claude-code"
    ["planning-with-files"]="https://github.com/OthmanAdi/planning-with-files"
    ["OpenSpec"]="https://github.com/Fission-AI/OpenSpec"
    ["claude-code"]="https://github.com/anthropics/claude-code"
)

echo "🔄 开始更新 Skills 上游源码..."
echo ""

for NAME in "${!REPOS[@]}"; do
    URL="${REPOS[$NAME]}"
    DIR="$SOURCE_DIR/$NAME"

    echo "📦 [$NAME] $URL"

    if [ -d "$DIR" ]; then
        # 目录已存在：删除旧版本，重新 clone
        echo "   → 删除旧版本..."
        rm -rf "$DIR"
    fi

    echo "   → Clone 最新版本..."
    git clone --depth=1 "$URL" "$DIR"

    # 删除内嵌 .git，保持为普通目录（便于外层 git 管理）
    rm -rf "$DIR/.git"

    # 清理上游仓库中 install.sh 不需要的大文件目录
    if [ "$NAME" = "claude-code" ]; then
        # claude-code 仓库很大，只保留 plugins/ 中需要的 skills
        # 保留: plugins/frontend-design/skills/
        # 其余全部删除
        echo "   🧹 claude-code: 只保留 plugins/ 中的 skills..."
        # 先把有用的目录移到临时位置
        TMP_KEEP="$(mktemp -d)"
        if [ -d "$DIR/plugins/frontend-design/skills" ]; then
            mkdir -p "$TMP_KEEP/plugins/frontend-design"
            mv "$DIR/plugins/frontend-design/skills" "$TMP_KEEP/plugins/frontend-design/skills"
        fi
        # 删除 clone 下来的所有内容
        find "$DIR" -mindepth 1 -maxdepth 1 -not -name '.git' -exec rm -rf {} +
        # 把有用的目录移回来
        if [ -d "$TMP_KEEP/plugins" ]; then
            mv "$TMP_KEEP/plugins" "$DIR/plugins"
        fi
        rm -rf "$TMP_KEEP"
    else
        # 其他仓库：只删除无用的大目录，保留 skills/ 等核心内容
        for JUNK in "$DIR/assets" "$DIR/docs" "$DIR/tests" "$DIR/plugins" "$DIR/examples"; do
            if [ -d "$JUNK" ]; then
                rm -rf "$JUNK"
                echo "   🗑️  已清理 $(basename "$JUNK")/"
            fi
        done
    fi

    echo "   ✅ 完成"
    echo ""
done

echo "✅ 所有上游源码已更新完毕"
echo ""
echo "💡 提示：更新完成后，执行以下命令提交到你的仓库："
echo "   git add github-source/"
echo "   git commit -m 'chore: update upstream skills sources'"
echo "   git push"
