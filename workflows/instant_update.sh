#!/bin/bash
# 手动添加中文说明的包装脚本
# 用途：为每个脚本输出添加中文翻译

echo "⚡ 快速更新中..."
echo "---中文---"
echo "正在更新系統..."
echo ""

cd ~/logic-automation
git pull -q 2>&1 | grep -v "Already up to date" || true
rsync -a --quiet logic-system/ ~/Logic/system/
rsync -a --quiet workflows/ ~/Logic/workflows/

echo ""
echo "✅ 更新完成！"
echo "---中文---"  
echo "✅ 更新成功！"
echo "Updated at $(date '+%H:%M:%S')"
