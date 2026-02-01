#!/bin/bash
# Logic 系統啟動腳本
# 用途：開機自動啟動或手動重啟所有服務

LOGIC_DIR="$HOME/Logic"
LOG_DIR="$LOGIC_DIR/logs"

# 建立日誌目錄
mkdir -p "$LOG_DIR"

echo "🚀 啟動 Logic 系統服務..."
echo "時間：$(date)" | tee -a "$LOG_DIR/startup.log"

# 檢查 Logic 目錄
if [ ! -d "$LOGIC_DIR" ]; then
    echo "❌ Logic 目錄不存在：$LOGIC_DIR" | tee -a "$LOG_DIR/startup.log"
    exit 1
fi

# 停止現有服務（避免重複）
echo "🛑 停止現有服務..." | tee -a "$LOG_DIR/startup.log"
pkill -f "monitor_service.sh" 2>/dev/null
pkill -f "dashboard/server.py" 2>/dev/null
sleep 2

# 啟動監控服務
echo "📡 啟動監控服務..." | tee -a "$LOG_DIR/startup.log"
cd "$LOGIC_DIR"
nohup bash system/monitor_service.sh > "$LOG_DIR/monitor.log" 2>&1 &
MONITOR_PID=$!
echo "   ✅ 監控服務已啟動（PID: $MONITOR_PID）" | tee -a "$LOG_DIR/startup.log"

# 等待一下讓監控服務初始化
sleep 2

# 啟動儀表板
echo "📊 啟動儀表板..." | tee -a "$LOG_DIR/startup.log"
cd "$LOGIC_DIR/system"
nohup python3 dashboard/server.py > "$LOG_DIR/dashboard.log" 2>&1 &
DASHBOARD_PID=$!
echo "   ✅ 儀表板已啟動（PID: $DASHBOARD_PID）" | tee -a "$LOG_DIR/startup.log"

# 等待服務啟動
sleep 3

# 驗證服務
echo "" | tee -a "$LOG_DIR/startup.log"
echo "🔍 驗證服務狀態..." | tee -a "$LOG_DIR/startup.log"

MONITOR_RUNNING=$(ps -p $MONITOR_PID > /dev/null 2>&1 && echo "yes" || echo "no")
DASHBOARD_RUNNING=$(ps -p $DASHBOARD_PID > /dev/null 2>&1 && echo "yes" || echo "no")

if [ "$MONITOR_RUNNING" = "yes" ]; then
    echo "   ✅ 監控服務：運行中" | tee -a "$LOG_DIR/startup.log"
else
    echo "   ❌ 監控服務：啟動失敗" | tee -a "$LOG_DIR/startup.log"
fi

if [ "$DASHBOARD_RUNNING" = "yes" ]; then
    echo "   ✅ 儀表板：運行中（http://localhost:8888）" | tee -a "$LOG_DIR/startup.log"
else
    echo "   ❌ 儀表板：啟動失敗" | tee -a "$LOG_DIR/startup.log"
fi

echo "" | tee -a "$LOG_DIR/startup.log"
echo "╔════════════════════════════════════════╗" | tee -a "$LOG_DIR/startup.log"
echo "║   🎉 Logic 系統啟動完成！               ║" | tee -a "$LOG_DIR/startup.log"
echo "╚════════════════════════════════════════╝" | tee -a "$LOG_DIR/startup.log"
echo "" | tee -a "$LOG_DIR/startup.log"
echo "📊 儀表板：http://localhost:8888" | tee -a "$LOG_DIR/startup.log"
echo "📝 啟動日誌：$LOG_DIR/startup.log" | tee -a "$LOG_DIR/startup.log"
echo "📡 監控日誌：$LOG_DIR/monitor.log" | tee -a "$LOG_DIR/startup.log"
echo "🖥️  儀表板日誌：$LOG_DIR/dashboard.log" | tee -a "$LOG_DIR/startup.log"
echo "" | tee -a "$LOG_DIR/startup.log"
