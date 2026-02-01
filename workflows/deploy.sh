#!/bin/bash
# Logic 系統部署腳本
# 在 Logic 機上執行此腳本以部署系統

set -e

echo "╔════════════════════════════════════════╗"
echo "║   Logic 系統部署程式                    ║"
echo "╚════════════════════════════════════════╝"
echo ""

# 檢查是否在正確的目錄
if [ ! -f "VERSION" ]; then
    echo "❌ 錯誤：請在 logic-automation 目錄中執行此腳本"
    exit 1
fi

VERSION=$(cat VERSION)
echo "📦 版本：$VERSION"
echo ""

# 設定目標目錄
LOGIC_DIR="$HOME/Logic"
SYSTEM_DIR="$LOGIC_DIR/system"

#建立目錄結構
echo "📁 建立目錄結構..."
mkdir -p "$LOGIC_DIR"/{inbox,workspace,archive,system}
mkdir -p "$SYSTEM_DIR"/{dashboard,cost,docs}
echo "✅ 目錄已建立"
echo ""

# 複製系統檔案
echo "📦 部署系統檔案..."
rsync -av --exclude='*.log' --exclude='*.tmp' logic-system/ "$SYSTEM_DIR/"
echo "✅ 系統檔案已部署"
echo ""

# 設定執行權限
echo "🔐 設定執行權限..."
chmod +x "$SYSTEM_DIR"/*.sh 2>/dev/null || true
chmod +x "$SYSTEM_DIR"/dashboard/*.py 2>/dev/null || true
chmod +x "$SYSTEM_DIR"/cost/*.py 2>/dev/null || true
echo "✅ 權限已設定"
echo ""

# 複製工作流程腳本
echo "⚙️ 安裝自動化工作流程..."
cp -r workflows "$LOGIC_DIR/"
chmod +x "$LOGIC_DIR"/workflows/*.sh
echo "✅ 工作流程已安裝"
echo ""

# 初始化配置檔案（如果不存在）
echo "⚙️ 初始化配置..."
if [ ! -f "$SYSTEM_DIR/status.json" ]; then
    cat > "$SYSTEM_DIR/status.json" << 'EOFSTATUS'
{
  "current_task": "待命中",
  "status": "idle",
  "last_update": "系統初始化",
  "heartbeat": "$(date -Iseconds)"
}
EOFSTATUS
    echo "✅ status.json 已建立"
fi

if [ ! -f "$SYSTEM_DIR/cost_today.json" ]; then
    cat > "$SYSTEM_DIR/cost_today.json" << 'EOFCOST'
{
  "total_usd": 0,
  "tasks": []
}
EOFCOST
    echo "✅ cost_today.json 已建立"
fi

# 複製預算配置
if [ -f "configs/budget_config.json" ]; then
    mkdir -p "$SYSTEM_DIR/cost"
    cp configs/budget_config.json "$SYSTEM_DIR/cost/"
    echo "✅ 預算配置已複製"
fi

echo ""
echo "╔════════════════════════════════════════╗"
echo "║   部署完成！                            ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "📍 系統安裝位置：$LOGIC_DIR"
echo "📊 儀表板：http://localhost:8888"
echo ""
echo "🚀 下一步："
echo "   1. 啟動監控服務："
echo "      cd $LOGIC_DIR"
echo "      nohup bash system/monitor_service.sh > monitor.log 2>&1 &"
echo ""
echo "   2. 啟動儀表板（選用）："
echo "      cd $SYSTEM_DIR"
echo "      nohup python3 dashboard/server.py > /tmp/dashboard.log 2>&1 &"
echo ""
echo "   3. 查看狀態："
echo "      bash $LOGIC_DIR/workflows/health_check.sh"
echo ""
