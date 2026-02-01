# Logic 系統 — Telegram 測試指令集

**用途**：透過 Telegram 發送給 Logic 機的 clawdbot，逐步測試和安裝 Logic 系統  
**建立時間**：2026-02-01

---

## 📋 使用方式

1. 開啟 Telegram 與 clawdbot 的對話
2. 按照順序複製以下指令，逐條發送
3. 等待每條指令完成後再發送下一條
4. 觀察輸出，檢查是否有錯誤

---

## 🧪 測試指令（按順序執行）

### ✅ 步驟 1：檢查環境

```bash
# 檢查系統資訊
uname -a && echo "---" && hostname && echo "---" && whoami
```

**預期結果**：顯示 macOS、主機名稱、使用者名稱

---

### ✅ 步驟 2：檢查部署包是否存在

```bash
# 檢查桌面是否有部署包
ls -lh ~/Desktop/ | grep Logic
```

**預期結果**：應該看到 `Logic-Deploy-Package` 目錄

---

### ✅ 步驟 3：檢查 iCloud 目錄

```bash
# 檢查 iCloud 是否正常同步
ls -la ~/Library/Mobile\ Documents/com~apple~CloudDocs/ | grep Logic
```

**預期結果**：應該看到 `Logic-Inbox` 目錄（如果沒有會自動建立）

---

### ✅ 步驟 4：執行安裝腳本

```bash
# 進入部署包目錄並執行安裝
cd ~/Desktop/Logic-Deploy-Package/logic && chmod +x install_on_logic_machine.sh && ./install_on_logic_machine.sh
```

**注意**：這個指令會要求確認，請在 TG 回覆「y」

**預期結果**：
- 顯示安裝進度
- 最後顯示「✅ Logic 系統安裝完成！」
- 列出目錄結構

---

### ✅ 步驟 5：確認安裝結果

```bash
# 檢查 Logic 目錄是否建立
ls -lh ~/Logic/
```

**預期結果**：應該看到 `inbox/`, `workspace/`, `archive/`, `system/` 四個目錄

---

### ✅ 步驟 6：檢查系統檔案

```bash
# 檢查系統檔案是否完整
ls -lh ~/Logic/system/ | head -20
```

**預期結果**：應該看到監控腳本、儀表板、成本追蹤等檔案

---

### ✅ 步驟 7：啟動監控服務

```bash
# 啟動 Logic 監控服務
cd ~/Logic && chmod +x start_monitor.sh && ./start_monitor.sh
```

**預期結果**：
- 顯示「🚀 啟動 Logic 監控服務...」
- 顯示「✅ 監控服務已啟動（PID: xxxxx）」

---

### ✅ 步驟 8：檢查監控服務是否運行

```bash
# 檢查監控進程
ps aux | grep monitor_service | grep -v grep
```

**預期結果**：應該看到一行包含 `monitor_service.sh` 的進程

---

### ✅ 步驟 9：查看監控日誌

```bash
# 查看監控日誌（最後 20 行）
tail -20 ~/Logic/monitor.log
```

**預期結果**：
- 顯示監控服務啟動訊息
- 顯示監控設定資訊
- 可能顯示「按 Ctrl+C 停止監控」

---

### ✅ 步驟 10：建立測試任務（手動）

```bash
# 建立一個簡單的測試任務
mkdir -p /tmp/test_logic_task && cd /tmp/test_logic_task && cat > run.sh << 'EOF'
#!/bin/bash
echo "=========================================="
echo "測試任務開始"
echo "時間: $(date)"
echo "主機: $(hostname)"
echo "=========================================="
echo ""
echo "✅ Logic 系統運作正常！"
echo ""
echo "=========================================="
echo "測試任務完成"
echo "=========================================="
EOF
chmod +x run.sh && tar -czf ~/Library/Mobile\ Documents/com~apple~CloudDocs/Logic-Inbox/test-$(date '+%Y%m%d-%H%M%S').task run.sh
echo "✅ 測試任務已發送到 iCloud"
```

**預期結果**：顯示「✅ 測試任務已發送到 iCloud」

---

### ✅ 步驟 11：等待 10 秒後檢查執行結果

```bash
# 等待 10 秒讓監控服務處理任務
sleep 10 && echo "檢查任務執行狀態..." && ls -lth ~/Logic/archive/ | head -5
```

**預期結果**：
- 應該看到新的歸檔目錄（以 `test-` 開頭）
- 顯示任務執行時間

---

### ✅ 步驟 12：查看任務執行結果

```bash
# 查看最新任務的輸出
LATEST_TASK=$(ls -t ~/Logic/archive/ | head -1) && echo "最新任務: $LATEST_TASK" && echo "---" && cat ~/Logic/archive/$LATEST_TASK/output.log
```

**預期結果**：
- 顯示「測試任務開始」
- 顯示「✅ Logic 系統運作正常！」
- 顯示「測試任務完成」

---

### ✅ 步驟 13：啟動儀表板（選用）

```bash
# 啟動儀表板
cd ~/Logic/system && chmod +x start_dashboard.sh && nohup ./start_dashboard.sh > /tmp/dashboard.log 2>&1 &
sleep 2 && echo "儀表板已啟動" && tail -10 /tmp/dashboard.log
```

**預期結果**：顯示「🚀 Logic 儀表板已啟動！」和網址 `http://localhost:8888`

---

### ✅ 步驟 14：測試成本追蹤

```bash
# 測試成本追蹤系統
cd ~/Logic/system/cost && python3 cost_tracker.py summary
```

**預期結果**：
- 顯示今日成本
- 顯示本月成本
- 顯示預算資訊

---

### ✅ 步驟 15：查看系統狀態

```bash
# 查看完整系統狀態
echo "=== 監控服務 ===" && ps aux | grep monitor_service | grep -v grep && echo "" && echo "=== 最近任務 ===" && ls -lt ~/Logic/archive/ | head -3 && echo "" && echo "=== iCloud 狀態 ===" && ls -la ~/Library/Mobile\ Documents/com~apple~CloudDocs/Logic-Inbox/ && echo "" && echo "✅ 系統檢查完成"
```

**預期結果**：
- 顯示監控服務運行中
- 顯示最近執行的任務
- 顯示 iCloud 目錄狀態

---

## 🐛 故障排查指令

### 如果監控服務沒有運行：

```bash
# 重新啟動監控
cd ~/Logic && ./stop_monitor.sh && sleep 2 && ./start_monitor.sh && sleep 2 && ps aux | grep monitor_service | grep -v grep
```

---

### 如果任務沒有被執行：

```bash
# 檢查監控日誌錯誤
tail -50 ~/Logic/monitor.log | grep -i error
```

---

### 如果 iCloud 沒有同步：

```bash
# 檢查 iCloud 狀態
ls -la ~/Library/Mobile\ Documents/com~apple~CloudDocs/Logic-Inbox/ && echo "---" && brctl log --wait --shorten
```

---

### 如果需要完全重新安裝：

```bash
# 清理並重新安裝
rm -rf ~/Logic && cd ~/Desktop/Logic-Deploy-Package/logic && ./install_on_logic_machine.sh
```

---

## ✅ 成功標準

如果看到以下結果，表示系統運作正常：

1. ✅ `~/Logic/` 目錄已建立
2. ✅ 監控服務在運行（`ps aux | grep monitor_service`）
3. ✅ 測試任務成功執行並歸檔
4. ✅ 任務輸出日誌顯示「✅ Logic 系統運作正常！」
5. ✅ 儀表板可以啟動（選用）

---

## 📊 最終驗證指令

```bash
# 完整系統檢查
echo "╔════════════════════════════════════════╗" && \
echo "║   Logic 系統狀態檢查                   ║" && \
echo "╚════════════════════════════════════════╝" && \
echo "" && \
echo "📁 目錄結構:" && \
ls -lh ~/Logic/ && \
echo "" && \
echo "🔄 監控服務:" && \
(ps aux | grep monitor_service | grep -v grep && echo "✅ 運行中" || echo "❌ 未運行") && \
echo "" && \
echo "📦 完成任務數:" && \
ls ~/Logic/archive/ 2>/dev/null | wc -l && \
echo "" && \
echo "☁️  iCloud 同步:" && \
(ls ~/Library/Mobile\ Documents/com~apple~CloudDocs/Logic-Inbox/ >/dev/null 2>&1 && echo "✅ 正常" || echo "❌ 異常") && \
echo "" && \
echo "✅ 檢查完成！"
```

---

## 💡 提示

- **逐條執行**：不要一次發送多條指令
- **等待完成**：每條指令執行完再發下一條
- **記錄錯誤**：如果有錯誤，複製錯誤訊息告知
- **耐心等待**：某些指令（如安裝）可能需要幾秒鐘

---

**準備好了嗎？開始從步驟 1 發送指令吧！** 🚀
