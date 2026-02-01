# 解決速率限制問題 🚀

## 問題根源

❌ **現狀**：
- 每個指令都通過 Clawdbot 執行
- 每次消耗大量 API tokens
- 頻繁遇到速率限制（200K tokens/分鐘）

✅ **解決方案**：
- 讓服務**自動啟動**
- 無需通過 Clawdbot 手動管理
- **完全免費、零 API 消耗**

---

## 🎯 一次性設定（之後永久解決）

### 步驟 1：手動啟動一次（不需 Clawdbot）

**直接在 Logic 機的終端機執行**：

```bash
bash ~/Logic/workflows/start_services.sh
```

這會啟動：
- ✅ 監控服務
- ✅ 儀表板

### 步驟 2：設定開機自動啟動（可選）

```bash
bash ~/Logic/workflows/setup_autostart.sh
```

**完成後**：
- ✅ 每次開機自動啟動所有服務
- ✅ 崩潰自動重啟
- ✅ 永遠不需要手動啟動

---

## 🔄 其他減少 API 消耗的方法

### 方法 1：使用 SSH 直接連線

**不通過 Clawdbot**，直接在 Logic 機執行命令：

```bash
# 在開發機執行
ssh xuziling@LOGIC_MACHINE_IP "bash ~/Logic/workflows/start_services.sh"
```

### 方法 2：使用簡化的別名

在 Logic 機的 `~/.zshrc` 加入：

```bash
alias logic-start="bash ~/Logic/workflows/start_services.sh"
alias logic-stop="pkill -f monitor_service && pkill -f dashboard"
alias logic-status="bash ~/Logic/workflows/health_check.sh"
```

然後在 Telegram 只需執行：
```bash
logic-start
```

### 方法 3：定時任務確保服務運行

在 Logic 機設定 cron：

```bash
# 每 5 分鐘檢查服務，如果停止就重啟
*/5 * * * * pgrep -f monitor_service > /dev/null || bash ~/Logic/workflows/start_services.sh
```

---

## 💡 最佳實踐

### ✅ 推薦做法（零 API 消耗）

1. **設定開機自啟動**：一次設定，永久生效
2. **直接 SSH 連線**：需要手動操作時使用
3. **定時任務守護**：確保服務永遠運行

### ❌ 避免做法（消耗 API）

1. 通過 Clawdbot 執行複雜指令
2. 連續執行多個命令
3. 頻繁重啟服務

---

## 🎯 立即行動

**現在執行**（不需 Clawdbot，直接在 Logic 機終端）：

```bash
# 1. 啟動所有服務
bash ~/Logic/workflows/start_services.sh

# 2. （可選）設定開機自啟動
bash ~/Logic/workflows/setup_autostart.sh
```

**完成後永遠不會再遇到速率限制！** 🎉
