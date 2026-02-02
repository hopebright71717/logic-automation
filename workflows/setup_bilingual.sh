#!/bin/bash
# Clawdbot 双语配置脚本
# 用途：让命令输出自动添加中文说明

echo "🔧 設置雙語輸出包裝器..."
echo "🔧 Setting up bilingual output wrapper..."

# 创建包装脚本目录
mkdir -p ~/Logic/scripts

# 创建双语包装函数
cat > ~/Logic/scripts/bilingual_helper.sh << 'EOF'
#!/bin/bash
# 双语输出辅助函数

add_translation() {
    local output="$1"
    echo "$output"
    echo "---中文---"
    
    # 简单的翻译规则
    case "$output" in
        *"started"*|*"Started"*)
            echo "已啟動"
            ;;
        *"stopped"*|*"Stopped"*)
            echo "已停止"
            ;;
        *"success"*|*"Success"*)
            echo "成功"
            ;;
        *"failed"*|*"Failed"*|*"error"*|*"Error"*)
            echo "失敗"
            ;;
        *"running"*|*"Running"*)
            echo "運行中"
            ;;
        *)
            echo "完成"
            ;;
    esac
}
EOF

chmod +x ~/Logic/scripts/bilingual_helper.sh

echo "✅ 雙語輔助腳本已創建"
echo "✅ Bilingual helper script created"
echo ""
echo "📝 位置：~/Logic/scripts/bilingual_helper.sh"
echo "📝 Location: ~/Logic/scripts/bilingual_helper.sh"
