#!/bin/bash
# 超快速更新脚本 - 专为对话中频繁更新设计
# 用途：立即更新，无需等待

echo "⚡ 快速更新中..."

cd ~/logic-automation

# 静默拉取
git pull -q 2>&1 | grep -v "Already up to date" || true

# 快速部署（只更新必要文件）
rsync -a --quiet logic-system/ ~/Logic/system/
rsync -a --quiet workflows/ ~/Logic/workflows/

echo "✅ 更新完成！"
echo "Updated at $(date '+%H:%M:%S')"
