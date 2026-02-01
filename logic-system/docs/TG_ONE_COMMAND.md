# Logic 系統 — Telegram 一鍵安裝指令

**建立時間**：2026-02-01  
**用途**：透過 Telegram 讓 clawdbot 自動執行完整安裝流程

---

## 🎯 使用方式

### 步驟 1：在 Telegram 發送以下指令

複製以下**完整指令**，貼到 Telegram 發送給 clawdbot：

```bash
# Logic 系統自動安裝
SCRIPT_PATH=~/Library/Mobile\ Documents/com~apple~CloudDocs/Logic-Inbox/auto_install.sh && \
if [ -f "$SCRIPT_PATH" ]; then \
  echo "✅ 找到安裝腳本，開始執行..." && \
  bash "$SCRIPT_PATH"; \
else \
  echo "❌ 找不到安裝腳本！" && \
  echo "請確認檔案已同步到 iCloud：" && \
  echo "$SCRIPT_PATH" && \
  ls -la ~/Library/Mobile\ Documents/com~apple~CloudDocs/Logic-Inbox/; \
fi
```

---

### 步驟 2：觀察輸出

腳本會自動執行以下 10 個步驟：

1. ✅ 檢查系統環境
2. ✅ 檢查部署包
3. ✅ 檢查 iCloud
4. ⚠️  **安裝 Logic 系統**（可能需要確認）
5. ✅ 驗證安裝
6. ✅ 啟動監控服務
7. ✅ 建立測試任務
8. ✅ 等待任務執行（15 秒）
9. ✅ 檢查執行結果
10. ✅ 系統狀態總覽

---

### 步驟 3：需要確認時

如果看到以下訊息：

```
╔════════════════════════════════════════╗
║  🚨 需要人工確認                       ║
╚════════════════════════════════════════╝

是否要刪除舊版本並重新安裝？這會清除所有歷史資料！

⚠️  警告：此操作不可逆！

請回覆：繼續 (或輸入 y)
```

**在 Telegram 回覆**：`繼續` 或 `y`

腳本會自動繼續執行。

---

## 📊 預期輸出

### 成功安裝的標誌

如果看到以下輸出，表示安裝成功：

```
╔════════════════════════════════════════╗
║     ✅ 安裝與測試完成！                 ║
╚════════════════════════════════════════╝

下一步：
  1. 開啟瀏覽器：http://localhost:8888（查看儀表板）
  2. 從開發機發送任務測試
  3. 查看監控日誌：tail -f ~/Logic/monitor.log

🎉 Logic 系統已準備就緒！
```

### 關鍵檢查點

1. **監控服務**：應該顯示「✅ 運行中」
2. **測試任務**：應該顯示「✅ Logic 系統運作正常！」
3. **完成任務數**：至少 1 個

---

## 🔧 故障排除

### 如果找不到安裝腳本

```bash
# 檢查 iCloud 目錄
ls -la ~/Library/Mobile\ Documents/com~apple~CloudDocs/Logic-Inbox/
```

**可能原因**：
- iCloud 尚未同步完成（等待 30 秒再試）
- 檔案名稱不正確

### 如果監控服務未啟動

```bash
# 手動啟動
cd ~/Logic && bash system/monitor_service.sh > monitor.log 2>&1 &
```

### 如果測試任務沒有執行

```bash
# 查看監控日誌
tail -50 ~/Logic/monitor.log
```

---

## 🎬 完整流程示意

```
你在 TG 發送指令
  ↓
clawdbot 讀取 iCloud 中的 auto_install.sh
  ↓
自動執行 10 個步驟
  ↓
在步驟 4（安裝）可能需要你確認
  ↓
你回覆「繼續」
  ↓
繼續自動執行
  ↓
顯示完成報告
  ↓
✅ 系統準備就緒！
```

---

## 💡 提示

- **一次性執行**：只需發送一次指令，腳本會自動完成所有步驟
- **耐心等待**：整個流程大約需要 1-2 分鐘
- **查看輸出**：仔細閱讀每個步驟的輸出，確認無錯誤
- **保存日誌**：如果有問題，複製完整輸出給我

---

## ✅ 驗證安裝

安裝完成後，執行以下指令驗證：

```bash
# 檢查系統狀態
ps aux | grep monitor_service | grep -v grep && \
echo "✅ 監控服務運行中" && \
ls -lh ~/Logic/ && \
echo "✅ 目錄結構正確" && \
ls ~/Logic/archive/ && \
echo "✅ 測試任務已完成"
```

---

**準備好了嗎？複製步驟 1 的指令到 Telegram 發送吧！** 🚀
