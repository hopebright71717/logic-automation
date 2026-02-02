#!/bin/bash
# Clawdbot 双语配置脚本
# 用途：让 Clawdbot 自动输出中英文双语回复

echo "🔧 配置 Clawdbot 双语输出..."

# 设置 Clawdbot 的 system prompt
clawdbot config set agents.defaults.systemPrompt "You are a helpful assistant. 

CRITICAL RULES:
1. ALWAYS respond in BOTH English and Traditional Chinese (繁體中文)
2. Format: First show the English response, then add '---中文---' separator, then show the Chinese translation
3. Keep responses concise and clear
4. For command outputs, translate the meaning, not just the text

Example:
Service started successfully.
---中文---
服務已成功啟動。"

if [ $? -eq 0 ]; then
    echo "✅ Clawdbot 雙語設定完成"
    echo "✅ Clawdbot bilingual mode configured"
    echo ""
    echo "📝 重啟 Clawdbot 以應用設定..."
    echo "📝 Restarting Clawdbot to apply settings..."
    
    # 重启 Clawdbot
    pkill -f clawdbot
    sleep 2
    
    echo "✅ 完成！Clawdbot 現在會自動輸出中英文"
    echo "✅ Done! Clawdbot will now output in both languages"
else
    echo "❌ 配置失敗，請檢查 Clawdbot 是否正確安裝"
    echo "❌ Configuration failed, please check if Clawdbot is installed correctly"
    exit 1
fi
