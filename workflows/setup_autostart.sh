#!/bin/bash
# macOS LaunchAgent 安裝腳本
# 用途：設定 Logic 系統開機自動啟動

PLIST_NAME="com.logic.services"
PLIST_FILE="$HOME/Library/LaunchAgents/$PLIST_NAME.plist"
START_SCRIPT="$HOME/Logic/workflows/start_services.sh"

echo "📦 安裝 Logic 開機自啟動..."

# 檢查啟動腳本是否存在
if [ ! -f "$START_SCRIPT" ]; then
    echo "❌ 找不到啟動腳本：$START_SCRIPT"
    exit 1
fi

# 建立 LaunchAgents 目錄
mkdir -p "$HOME/Library/LaunchAgents"

# 創建 plist 配置
cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$PLIST_NAME</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$START_SCRIPT</string>
    </array>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    
    <key>StandardOutPath</key>
    <string>$HOME/Logic/logs/launchd.out.log</string>
    
    <key>StandardErrorPath</key>
    <string>$HOME/Logic/logs/launchd.err.log</string>
    
    <key>WorkingDirectory</key>
    <string>$HOME/Logic</string>
    
    <key>ThrottleInterval</key>
    <integer>10</integer>
</dict>
</plist>
EOF

echo "✅ 配置檔案已建立：$PLIST_FILE"

# 載入服務
launchctl unload "$PLIST_FILE" 2>/dev/null
launchctl load "$PLIST_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Logic 開機自啟動已啟用"
    echo ""
    echo "📋 管理指令："
    echo "   停止：launchctl unload $PLIST_FILE"
    echo "   啟動：launchctl load $PLIST_FILE"
    echo "   重啟：launchctl kickstart -k gui/\$(id -u)/$PLIST_NAME"
    echo ""
    echo "🎉 下次開機時，Logic 系統會自動啟動！"
else
    echo "❌ 啟動失敗"
    exit 1
fi
