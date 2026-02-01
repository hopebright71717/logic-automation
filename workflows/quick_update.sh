#!/bin/bash
# Logic 快速更新指令
# 用於開發階段頻繁更新時使用

echo "🚀 立即更新 Logic 系統..."
echo ""

cd ~/logic-automation || exit 1

echo "📥 拉取最新版本..."
git pull origin main

if [ $? -eq 0 ]; then
    echo "✅ 更新成功"
    echo ""
    echo "🚀 部署中..."
    bash workflows/deploy.sh
    
    echo ""
    echo "🔄 重啟服務..."
    pkill -f "monitor_service.sh" 2>/dev/null
    sleep 2
    cd ~/Logic
    nohup bash system/monitor_service.sh > monitor.log 2>&1 &
    
    echo "✅ 系統已更新並重啟"
    NEW_VERSION=$(cat ~/logic-automation/VERSION)
    echo "📦 當前版本：$NEW_VERSION"
else
    echo "❌ 更新失敗"
    exit 1
fi
