#!/bin/bash
# Logic 系統自動更新腳本
# 定期執行以從 GitHub 拉取更新

set -e

REPO_DIR="${REPO_DIR:-$HOME/logic-automation}"
LOGIC_DIR="${LOGIC_DIR:-$HOME/Logic}"

echo "🔄 檢查 Logic 系統更新..."
echo ""

# 檢查 repo 是否存在
if [ ! -d "$REPO_DIR" ]; then
    echo "❌ 找不到 repository：$REPO_DIR"
    echo "   請先執行："
    echo "   cd ~ && git clone https://github.com/YOUR_USERNAME/logic-automation.git"
    exit 1
fi

# 進入 repo 目錄
cd "$REPO_DIR"

# 獲取當前版本
CURRENT_VERSION=$(cat VERSION 2>/dev/null || echo "unknown")
echo "📌 當前版本：$CURRENT_VERSION"

# 檢查更新
git fetch origin main 2>&1 | grep -v "^$" || true

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "✅ 已是最新版本"
    exit 0
fi

echo "🎉 發現新版本！"
echo ""

# 拉取更新
echo "📥 拉取更新..."
git pull origin main

# 獲取新版本
NEW_VERSION=$(cat VERSION 2>/dev/null || echo "unknown")
echo "📦 新版本：$NEW_VERSION"
echo ""

# 執行部署
echo "🚀 部署更新..."
bash workflows/deploy.sh

echo ""
echo "╔════════════════════════════════════════╗"
echo "║   ✅ 更新完成！                         ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "📊 版本變化：$CURRENT_VERSION → $NEW_VERSION"
echo ""

# 重啟監控服務
echo "🔄 重啟監控服務..."
pkill -f "monitor_service.sh" 2>/dev/null || true
sleep 2
cd "$LOGIC_DIR"
nohup bash system/monitor_service.sh > monitor.log 2>&1 &
echo "✅ 監控服務已重啟"
echo ""

echo "🎉 Logic 系統已更新到最新版本！"
