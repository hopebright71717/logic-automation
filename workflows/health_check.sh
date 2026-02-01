#!/bin/bash
# Logic 系統健康檢查腳本

LOGIC_DIR="${LOGIC_DIR:-$HOME/Logic}"
SYSTEM_DIR="$LOGIC_DIR/system"

echo "╔════════════════════════════════════════╗"
echo "║   Logic 系統健康檢查                    ║"
echo "╚════════════════════════════════════════╝"
echo ""

# 檢查目錄存在
echo "📁 檢查目錄結構..."
for dir in "$LOGIC_DIR" "$LOGIC_DIR/inbox" "$LOGIC_DIR/workspace" "$LOGIC_DIR/archive" "$SYSTEM_DIR"; do
    if [ -d "$dir" ]; then
        echo "   ✅ $dir"
    else
        echo "   ❌ $dir （不存在）"
    fi
done
echo ""

# 檢查監控服務
echo "🔄 檢查監控服務..."
if ps aux | grep "[m]onitor_service.sh" > /dev/null; then
    PID=$(ps aux | grep "[m]onitor_service.sh" | awk '{print $2}')
    echo "   ✅ 監控服務運行中（PID: $PID）"
else
    echo "   ❌ 監控服務未運行"
fi
echo ""

# 檢查儀表板服務
echo "🖥️  檢查儀表板服務..."
if ps aux | grep "[d]ashboard/server.py" > /dev/null; then
    PID=$(ps aux | grep "[d]ashboard/server.py" | awk '{print $2}')
    echo "   ✅ 儀表板運行中（PID: $PID）"
    echo "   🌐 網址：http://localhost:8888"
else
    echo "   ⚠️  儀表板未運行"
fi
echo ""

# 檢查任務統計
echo "📊 任務統計..."
if [ -d "$LOGIC_DIR/archive" ]; then
    TOTAL_TASKS=$(ls "$LOGIC_DIR/archive" 2>/dev/null | wc -l | xargs)
    echo "   📦 完成任務數：$TOTAL_TASKS"
else
    echo "   ⚠️  無法統計任務"
fi

if [ -d "$LOGIC_DIR/inbox" ]; then
    PENDING=$(ls "$LOGIC_DIR/inbox" 2>/dev/null | wc -l | xargs)
    echo "   📥 待處理任務：$PENDING"
fi
echo ""

# 檢查成本資料
echo "💰 成本追蹤..."
if [ -f "$SYSTEM_DIR/cost_today.json" ]; then
    TODAY_COST=$(cat "$SYSTEM_DIR/cost_today.json" | python3 -c "import sys, json; print (json.load(sys.stdin).get('total_usd', 0))" 2>/dev/null || echo "N/A")
    echo "   📊 今日成本：\$$TODAY_COST"
else
    echo "   ⚠️  無成本資料"
fi
echo ""

# 檢查預算配置
echo "⚙️  預算配置..."
if [ -f "$SYSTEM_DIR/cost/budget_config.json" ]; then
    DAILY_LIMIT=$(cat "$SYSTEM_DIR/cost/budget_config.json" | python3 -c "import sys, json; print(json.load(sys.stdin)['budgets']['daily']['hard_limit'])" 2>/dev/null || echo "N/A")
    echo "   💵 每日上限：\$$DAILY_LIMIT"
else
    echo "   ⚠️  無預算配置"
fi
echo ""

# 檢查版本
echo "📦 版本資訊..."
if [ -f "$HOME/logic-automation/VERSION" ]; then
    VERSION=$(cat "$HOME/logic-automation/VERSION")
    echo "   📌 當前版本：$VERSION"
else
    echo "   ⚠️  找不到版本資訊"
fi
echo ""

echo "╔════════════════════════════════════════╗"
echo "║   健康檢查完成                          ║"
echo "╚════════════════════════════════════════╝"
