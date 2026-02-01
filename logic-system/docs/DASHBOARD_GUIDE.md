# Logic 儀表板使用指南

**更新時間**：2026-02-02  
**網址**：http://localhost:8888

---

## 🖥️ 如何訪問儀表板

### 方法 1：在 Logic 機上直接訪問

1. **確保儀表板服務已啟動**

在 TG 執行：
```bash
ps aux | grep "dashboard/server.py" | grep -v grep || (cd ~/Logic/system && nohup python3 dashboard/server.py > /tmp/dashboard.log 2>&1 & && echo "✅ 儀表板已啟動")
```

2. **在 Logic 機的瀏覽器訪問**

```bash
open http://localhost:8888
```

### 方法 2：透過 iPad + Jump Desktop

1. **iPad 開啟 Jump Desktop**
2. **連線到 Logic 機（M1 Pro MacBook）**
3. **在 Logic 機的瀏覽器中訪問**：`http://localhost:8888`

### 方法 3：透過 SSH 端口轉發（進階）

如果您想在其他設備上訪問儀表板：

```bash
# 在您的設備上執行
ssh -L 8888:localhost:8888 xuziling@LOGIC_MACHINE_IP

# 然後在瀏覽器訪問
open http://localhost:8888
```

---

## 📊 儀表板功能

### 1. 即時狀態顯示

- 🔄 **當前狀態**：系統正在做什麼
- 📝 **當前任務**：最新執行的任務
- ⏰ **最後更新時間**：心跳時間

### 2. 成本追蹤

#### 今日成本
- 💵 **美金（USD）**：實際花費
- 💰 **台幣（TWD）**：換算後金額（匯率 1:30）
- 📊 **呼叫次數**：API 呼叫總數
- 🔢 **Token 使用量**：總消耗 tokens

#### 本月成本
- 📈 **總成本**：USD 和 TWD
- 💳 **預算**：$60 USD / $1800 TWD
- 📉 **剩餘預算**：還能花多少
- 🔥 **燃燒率**：每日平均花費
- 📅 **預估**：按當前速度能撐多久

### 3. 成本排行

**TOP 10 最耗費的指令**：
- 指令名稱
- 使用模型
- 呼叫次數
- 總成本（USD / TWD）
- 平均 tokens
- 最後使用時間

### 4. 自動刷新

儀表板每 **5 秒**自動刷新一次，無需手動更新。

---

## 💰 成本顯示說明

### 只顯示實際 API 費用

✅ **會記錄的**：
- OpenAI GPT-4o-mini
- OpenAI GPT-4o
- Claude 3.5 Sonnet
- 任何雲端 API 模型

❌ **不會記錄的**（本地模型）：
- Ollama 模型
- LLaMA 本地部署
- 任何包含 "local"、"ollama"、"llama" 等關鍵字的模型
- 免費模型

### 台幣換算

- 匯率固定為 **1 USD = 30 TWD**
- 所有成本同時顯示美金和台幣
- 儀表板和 CLI 工具都支持

---

## 🔧 常用操作

### 啟動儀表板

```bash
cd ~/Logic/system && nohup python3 dashboard/server.py > /tmp/dashboard.log 2>&1 &
```

### 停止儀表板

```bash
pkill -f "dashboard/server.py"
```

### 重啟儀表板

```bash
pkill -f "dashboard/server.py" && sleep 2 && cd ~/Logic/system && nohup python3 dashboard/server.py > /tmp/dashboard.log 2>&1 &
```

### 檢查儀表板狀態

```bash
ps aux | grep "dashboard/server.py" | grep -v grep && echo "✅ 儀表板運行中" || echo "❌ 儀表板未運行"
```

### 查看儀表板日誌

```bash
tail -f /tmp/dashboard.log
```

---

## 🎯 儀表板截圖說明

![Logic 儀表板](dashboard_preview.png)

*儀表板包含三個主要區塊：*
1. **頂部**：系統即時狀態
2. **中間左**：今日成本統計
3. **中間右**：本月成本統計
4. **底部**：成本排行榜

---

## 🔍 故障排除

### 問題：無法訪問 http://localhost:8888

**解決方案**：

1. 檢查服務是否運行
```bash
ps aux | grep dashboard
```

2. 檢查端口是否被占用
```bash
lsof -i :8888
```

3. 查看日誌
```bash
tail -20 /tmp/dashboard.log
```

4. 重啟服務
```bash
pkill -f dashboard && sleep 2 && cd ~/Logic/system && python3 dashboard/server.py
```

### 問題：儀表板顯示空白或數據不更新

**解決方案**：

1. 檢查數據檔案
```bash
cat ~/Logic/system/status.json
cat ~/Logic/system/cost_today.json
```

2. 強制刷新瀏覽器（Cmd+Shift+R）

3. 檢查成本追蹤是否正常
```bash
python3 ~/Logic/system/cost/cost_tracker.py summary
```

---

## 📱 iPad 使用技巧

### Jump Desktop 最佳設定

1. **解析度**：設定為 Logic 機原生解析度
2. **觸控模式**：啟用「直接觸控」
3. **快捷鍵**：設定刷新快捷鍵

### 瀏覽器建議

- **Safari**：最佳兼容性
- **Chrome**：也完全支持
- 建議啟用**全螢幕模式**

---

## 💡 進階功能

### 自訂刷新頻率

修改 `dashboard.js` 中的刷新間隔：

```javascript
// 預設 5 秒，可改為 10 秒
setInterval(updateDashboard, 10000);
```

### 自訂匯率

修改 `cost_tracker.py` 中的匯率：

```python
# 預設 30，可改為實際匯率
USD_TO_TWD = 31.5
```

---

## 🎯 下一步

- ✅ 儀表板已運行在 `http://localhost:8888`
- ✅ 成本只記錄實際 API 費用
- ✅ 支持台幣顯示（匯率 1:30）
- ✅ 每 5 秒自動刷新

**享受您的 Logic 系統！** 🚀
