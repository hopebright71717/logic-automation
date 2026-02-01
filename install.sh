#!/bin/bash
# Logic 系統一鍵安裝腳本
# 用途：首次安裝或重新部署 Logic 系統

echo "╔════════════════════════════════════════╗"
echo "║   Logic 系統一鍵安裝                    ║"
echo "╚════════════════════════════════════════╝"
echo ""

REPO_URL="https://github.com/hopebright71717/logic-automation.git"
LOGIC_DIR="$HOME/logic-automation"

# 檢查是否已安裝
if [ -d "$LOGIC_DIR" ]; then
    echo "⚠️  偵測到現有安裝"
    echo "📍 位置：$LOGIC_DIR"
    echo ""
    echo "請選擇："
    echo "  1) 更新現有安裝"
    echo "  2) 刪除並重新安裝"
    echo "  3) 取消"
    echo ""
    
    # 自動選擇更新（非互動模式）
    echo "🔄 自動執行：更新現有安裝"
    cd "$LOGIC_DIR"
    git pull origin main
    bash workflows/deploy.sh
else
    # 首次安裝
    echo "📥 步驟 1/3：下載 Logic 系統..."
    cd ~
    git clone "$REPO_URL"
    
    if [ $? -ne 0 ]; then
        echo "❌ 下載失敗"
        exit 1
    fi
    echo "✅ 下載完成"
    echo ""
    
    echo "🚀 步驟 2/3：部署系統..."
    cd "$LOGIC_DIR"
    bash workflows/deploy.sh
    
    if [ $? -ne 0 ]; then
        echo "❌ 部署失敗"
        exit 1
    fi
    echo ""
fi

echo "✅ 步驟 3/3：驗證系統..."
bash workflows/health_check.sh

echo ""
echo "╔════════════════════════════════════════╗"
echo "║   🎉 安裝完成！                         ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "🚀 下一步："
echo "   1. 查看儀表板：open http://localhost:8888"
echo "   2. 查看成本：python3 ~/Logic/system/cost/cost_tracker.py summary"
echo "   3. 發送任務測試：在開發機執行 send_to_logic.sh"
echo ""
