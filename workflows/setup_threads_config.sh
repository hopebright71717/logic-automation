#!/bin/bash
# Threads Bot 安全配置脚本
# 用途：在 Logic 机上创建配置文件
# 
# 参数说明：
#   $1: Threads/IG 用户名
#   $2: Threads/IG 密码
#   $3: OpenAI API Key

if [ $# -ne 3 ]; then
    echo "❌ 使用方式错误"
    echo "❌ Usage error"
    echo ""
    echo "正确使用："
    echo "bash setup_threads_config.sh <username> <password> <openai_key>"
    exit 1
fi

USERNAME="$1"
PASSWORD="$2"
OPENAI_KEY="$3"

echo "🔐 配置 Threads Bot 账号信息..."
echo "🔐 Configuring Threads Bot credentials..."

# 创建配置目录
mkdir -p ~/logic-automation/threads-bot/config

# 创建 .env 文件
cat > ~/logic-automation/threads-bot/config/.env << EOF
# ========================================
# Threads 自动化机器人配置
# ⚠️ 此文件包含敏感信息，不会上传到 GitHub
# ========================================

## 账号信息
THREADS_USERNAME=$USERNAME
THREADS_PASSWORD=$PASSWORD

# IG 和 Threads 使用同一账号
IG_USERNAME=$USERNAME
IG_PASSWORD=$PASSWORD

## OpenAI API
OPENAI_API_KEY=$OPENAI_KEY
MODEL=gpt-4o-mini

## 发文设置
POST_TIME=11:00
AUTO_APPROVE=false  # 需要审核

## 互动设置（保守模式）
DAILY_LIKES_MIN=5
DAILY_LIKES_MAX=15
REPLY_COUNT=2
LIKE_THRESHOLD=1.5

## 安全设置
MIN_INTERVAL=600   # 10分钟
MAX_INTERVAL=3600  # 1小时
RANDOM_DELAY=true

## 风格设置
STYLE_ANALYSIS_POSTS=30
LEARNING_MODE=true
EOF

# 设置权限（只有所有者可读写）
chmod 600 ~/logic-automation/threads-bot/config/.env

echo ""
echo "✅ 配置文件已创建"
echo "✅ Configuration file created"
echo ""
echo "📁 位置：~/logic-automation/threads-bot/config/.env"
echo "📁 Location: ~/logic-automation/threads-bot/config/.env"
echo ""
echo "🔒 权限：600（只有您可以读写）"
echo "🔒 Permissions: 600 (only you can read/write)"
echo ""
echo "⚠️  此文件不会上传到 GitHub（已在 .gitignore 中）"
echo "⚠️  This file will NOT be uploaded to GitHub (.gitignore)"

