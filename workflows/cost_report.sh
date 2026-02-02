#!/bin/bash
# Logic 成本詳細報表
# 顯示完整的成本計算過程和公式

SYSTEM_DIR="$HOME/Logic/system"
TODAY_FILE="$SYSTEM_DIR/cost_today.json"
MONTH_FILE="$SYSTEM_DIR/cost_month.json"
BUDGET_FILE="$SYSTEM_DIR/cost/budget_config.json"

# 匯率
EXCHANGE_RATE=30

echo "╔════════════════════════════════════════════════════════╗"
echo "║          Logic 系統成本詳細報表                         ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "📅 報表時間：$(date '+%Y-%m-%d %H:%M:%S')"
echo "💱 匯率設定：1 USD = $EXCHANGE_RATE TWD"
echo ""

# 讀取今日成本
if [ -f "$TODAY_FILE" ]; then
    TODAY_USD=$(cat "$TODAY_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('total_usd', 0))" 2>/dev/null || echo "0")
    TODAY_CALLS=$(cat "$TODAY_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('calls_count', 0))" 2>/dev/null || echo "0")
    TODAY_TOKENS=$(cat "$TODAY_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('total_tokens', 0))" 2>/dev/null || echo "0")
else
    TODAY_USD=0
    TODAY_CALLS=0
    TODAY_TOKENS=0
fi

# 計算今日台幣
TODAY_TWD=$(python3 -c "print(round($TODAY_USD * $EXCHANGE_RATE, 2))")

# 讀取本月成本
if [ -f "$MONTH_FILE" ]; then
    MONTH_USD=$(cat "$MONTH_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('total_usd', 0))" 2>/dev/null || echo "0")
    MONTH_CALLS=$(cat "$MONTH_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('calls_count', 0))" 2>/dev/null || echo "0")
    MONTH_TOKENS=$(cat "$MONTH_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('total_tokens', 0))" 2>/dev/null || echo "0")
else
    MONTH_USD=0
    MONTH_CALLS=0
    MONTH_TOKENS=0
fi

# 計算本月台幣
MONTH_TWD=$(python3 -c "print(round($MONTH_USD * $EXCHANGE_RATE, 2))")

# 讀取預算設定
if [ -f "$BUDGET_FILE" ]; then
    DAILY_LIMIT=$(cat "$BUDGET_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin)['budgets']['daily']['hard_limit'])" 2>/dev/null || echo "2.5")
    MONTHLY_LIMIT=$(cat "$BUDGET_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin)['budgets']['monthly']['hard_limit'])" 2>/dev/null || echo "60")
else
    DAILY_LIMIT=2.5
    MONTHLY_LIMIT=60
fi

# 計算預算台幣
DAILY_LIMIT_TWD=$(python3 -c "print(round($DAILY_LIMIT * $EXCHANGE_RATE, 2))")
MONTHLY_LIMIT_TWD=$(python3 -c "print(round($MONTHLY_LIMIT * $EXCHANGE_RATE, 2))")

# 計算使用百分比
DAILY_PERCENT=$(python3 -c "print(round($TODAY_USD / $DAILY_LIMIT * 100, 2))")
MONTHLY_PERCENT=$(python3 -c "print(round($MONTH_USD / $MONTHLY_LIMIT * 100, 2))")

# 計算剩餘預算
DAILY_REMAINING_USD=$(python3 -c "print(round($DAILY_LIMIT - $TODAY_USD, 4))")
DAILY_REMAINING_TWD=$(python3 -c "print(round($DAILY_REMAINING_USD * $EXCHANGE_RATE, 2))")
MONTHLY_REMAINING_USD=$(python3 -c "print(round($MONTHLY_LIMIT - $MONTH_USD, 4))")
MONTHLY_REMAINING_TWD=$(python3 -c "print(round($MONTHLY_REMAINING_USD * $EXCHANGE_RATE, 2))")

echo "════════════════════════════════════════════════════════"
echo "📊 今日成本統計（$(date '+%Y-%m-%d')）"
echo "════════════════════════════════════════════════════════"
echo ""
echo "💰 實際使用："
echo "   美金：\$$TODAY_USD USD"
echo "   公式：\$$TODAY_USD × $EXCHANGE_RATE = NT\$ $TODAY_TWD"
echo "   台幣：NT\$ $TODAY_TWD"
echo ""
echo "📈 使用詳情："
echo "   API 呼叫次數：$TODAY_CALLS 次"
echo "   Token 消耗：$(printf "%'d" $TODAY_TOKENS) tokens"
echo ""
echo "📊 預算狀況："
echo "   每日上限：\$$DAILY_LIMIT USD（NT\$ $DAILY_LIMIT_TWD）"
echo "   已使用：$DAILY_PERCENT%"
echo "   剩餘預算：\$$DAILY_REMAINING_USD USD（NT\$ $DAILY_REMAINING_TWD）"
echo ""

# 顏色判斷
if (( $(echo "$DAILY_PERCENT >= 90" | bc -l) )); then
    echo "   ⚠️  狀態：🔴 警告！已使用 $DAILY_PERCENT%，接近上限"
elif (( $(echo "$DAILY_PERCENT >= 60" | bc -l) )); then
    echo "   ⚠️  狀態：🟡 注意！已使用 $DAILY_PERCENT%"
else
    echo "   ✅ 狀態：🟢 正常（已使用 $DAILY_PERCENT%）"
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "📈 本月成本統計（$(date '+%Y-%m')）"
echo "════════════════════════════════════════════════════════"
echo ""
echo "💰 實際使用："
echo "   美金：\$$MONTH_USD USD"
echo "   公式：\$$MONTH_USD × $EXCHANGE_RATE = NT\$ $MONTH_TWD"
echo "   台幣：NT\$ $MONTH_TWD"
echo ""
echo "📈 使用詳情："
echo "   API 呼叫次數：$MONTH_CALLS 次"
echo "   Token 消耗：$(printf "%'d" $MONTH_TOKENS) tokens"
echo ""
echo "📊 預算狀況："
echo "   每月上限：\$$MONTHLY_LIMIT USD（NT\$ $MONTHLY_LIMIT_TWD）"
echo "   已使用：$MONTHLY_PERCENT%"
echo "   剩餘預算：\$$MONTHLY_REMAINING_USD USD（NT\$ $MONTHLY_REMAINING_TWD）"
echo ""

# 顏色判斷
if (( $(echo "$MONTHLY_PERCENT >= 90" | bc -l) )); then
    echo "   ⚠️  狀態：🔴 警告！已使用 $MONTHLY_PERCENT%，接近上限"
elif (( $(echo "$MONTHLY_PERCENT >= 60" | bc -l) )); then
    echo "   ⚠️  狀態：🟡 注意！已使用 $MONTHLY_PERCENT%"
else
    echo "   ✅ 狀態：🟢 正常（已使用 $MONTHLY_PERCENT%）"
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "🏆 最貴指令排行 TOP 10"
echo "════════════════════════════════════════════════════════"
echo ""

# 讀取成本排行
RANK_FILE="$SYSTEM_DIR/cost_rank.csv"
if [ -f "$RANK_FILE" ]; then
    echo "排名 | 指令 | 模型 | 呼叫次數 | 美金 | 台幣"
    echo "----|------|------|---------|------|------"
    
    tail -n +2 "$RANK_FILE" | head -10 | while IFS=, read -r command model calls tokens usd twd avg_tokens last_used; do
        RANK=$((RANK+1))
        TWD_CALC=$(python3 -c "print(round($usd * $EXCHANGE_RATE, 2))")
        printf "%-3s | %-30s | %-15s | %-8s | \$%-6s | NT\$ %-6s\n" \
            "$RANK" \
            "$(echo $command | cut -c1-30)" \
            "$(echo $model | cut -c1-15)" \
            "$calls" \
            "$usd" \
            "$TWD_CALC"
    done
else
    echo "   ⚠️  尚無成本記錄"
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "💡 成本建議"
echo "════════════════════════════════════════════════════════"
echo ""

# 計算平均每次呼叫成本
if [ "$TODAY_CALLS" -gt 0 ]; then
    AVG_COST=$(python3 -c "print(round($TODAY_USD / $TODAY_CALLS, 6))")
    echo "   📊 今日平均每次 API 呼叫：\$$AVG_COST USD"
fi

# 計算本月燃燒率（移除前导零）
DAY_OF_MONTH=$(date '+%-d')  # %-d 会移除前导零
if [ "$DAY_OF_MONTH" -gt 0 ]; then
    BURN_RATE=$(python3 -c "print(round($MONTH_USD / $DAY_OF_MONTH, 4))")
    BURN_RATE_TWD=$(python3 -c "print(round($BURN_RATE * $EXCHANGE_RATE, 2))")
    echo "   🔥 本月平均每日燃燒率：\$$BURN_RATE USD（NT\$ $BURN_RATE_TWD）"
    
    # 預估本月總成本（同样移除前导零）
    DAYS_IN_MONTH=$(date -v1d -v+1m -v-1d '+%-d' 2>/dev/null || echo "30")
    EST_MONTH=$(python3 -c "print(round($BURN_RATE * $DAYS_IN_MONTH, 2))")
    EST_MONTH_TWD=$(python3 -c "print(round($EST_MONTH * $EXCHANGE_RATE, 2))")
    echo "   📅 預估本月總成本：\$$EST_MONTH USD（NT\$ $EST_MONTH_TWD）"
fi

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                  報表結束                               ║"
echo "╚════════════════════════════════════════════════════════╝"
