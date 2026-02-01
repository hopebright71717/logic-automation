# Logic 雙機協作系統 — 快速開始指南

**建立時間**：2026-02-01  
**狀態**：✅ 已建立並測試

---

## 🎯 系統概述

這是一個**雙機協作的自動化工作系統**：

```
開發機（這台 Mac）          Logic 機（M1 Pro MacBook）
     Antigravity                    24/7 運行
         ↓                              ↓
    生成任務/檔案                   自動監控執行
         ↓                              ↓
    寫入 iCloud ──────────────→ iCloud 同步
    ~/Library/Mobile Documents/     自動抓取
    com~apple~CloudDocs/            ↓
    Logic-Inbox/                執行並記錄
                                    ↓
                                Dashboard
                                成本追蹤
```

---

## 📦 目前狀態

### ✅ 已完成（開發機）

1. **iCloud 同步目錄**：
   - 路徑：`~/Library/Mobile Documents/com~apple~CloudDocs/Logic-Inbox/`
   - 用途：Antigravity 發送任務到這裡

2. **部署包**：
   - 位置：`~/Desktop/Logic-Deploy-Package/`
   - 內容：完整的 Logic 系統 + 安裝腳本

3. **發送工具**：
   - `send_to_logic.sh`：發送單一指令
   - `send_files_to_logic.sh`：發送整個專案

### ⏳ 待完成（Logic 機）

需要您在 **M1 Pro MacBook** 上執行：

1. 複製 `Logic-Deploy-Package` 到 Logic 機
2. 執行安裝腳本
3. 啟動監控服務

---

## 🚀 部署步驟

### 步驟 1：傳輸部署包到 Logic 機

選擇以下任一方式：

#### 方式 A：AirDrop（最簡單）
1. 開啟 Finder
2. 找到 `~/Desktop/Logic-Deploy-Package/`
3. 右鍵 → 共享 → AirDrop
4. 傳送到 M1 Pro MacBook

#### 方式 B：隨身碟
1. 複製 `Logic-Deploy-Package` 到隨身碟
2. 插入 Logic 機
3. 複製到 Logic 機的桌面

#### 方式 C：本地網路（如果在同一網路）
```bash
# 在 Logic 機上啟動檔案共享
# 系統偏好設定 → 共享 → 檔案共享

# 在開發機上
scp -r ~/Desktop/Logic-Deploy-Package username@logic-mac-ip:~/Desktop/
```

---

### 步驟 2：在 Logic 機上安裝

在 **M1 Pro MacBook** 的終端機執行：

```bash
cd ~/Desktop/Logic-Deploy-Package
chmod +x install_on_logic_machine.sh
./install_on_logic_machine.sh
```

這會：
- 建立 `~/Logic/` 目錄結構
- 安裝所有系統檔案
- 設定 iCloud 監控目錄

---

### 步驟 3：啟動 Logic 服務

#### 3.1 啟動監控（必須）

```bash
cd ~/Logic
./start_monitor.sh
```

這會在背景持續監控 iCloud，自動執行任務。

#### 3.2 啟動儀表板（選用）

```bash
cd ~/Logic/system
./start_dashboard.sh
```

然後在瀏覽器開啟：`http://localhost:8888`

---

## 💡 使用方式

### 📤 從開發機發送任務

#### 方式 1：發送簡單指令

```bash
cd /Users/xuziling/Documents/vibecodeinggggggg/logic
./send_to_logic.sh "測試任務" "echo Hello from Logic"
```

#### 方式 2：發送複雜指令

```bash
./send_to_logic.sh "分析資料" "python3 /path/to/script.py && echo 完成"
```

#### 方式 3：發送整個專案

```bash
./send_files_to_logic.sh "處理專案" /path/to/project/
```

專案會被打包並發送，Logic 機會自動解壓並執行 `run.sh`。

---

## 📊 監控進度

### 在 Logic 機上

1. **查看即時日誌**：
```bash
tail -f ~/Logic/monitor.log
```

2. **查看儀表板**：
   - 開啟瀏覽器：`http://localhost:8888`
   - 會顯示當前任務、成本、輸出等

3. **查看完成的任務**：
```bash
ls -lh ~/Logic/archive/
```

### 在開發機（iPad）

使用 Jump Desktop 連線到 Logic 機：
1. 連線到 M1 Pro MacBook
2. 開啟瀏覽器
3. 前往 `http://localhost:8888`

---

## 🔧 管理指令

### Logic 機上的管理

```bash
# 啟動監控
./start_monitor.sh

# 停止監控
./stop_monitor.sh

# 查看監控狀態
ps aux | grep monitor_service

# 查看完成的任務
ls -lh ~/Logic/archive/

# 清理歸檔（30 天前）
find ~/Logic/archive/ -mtime +30 -exec rm -rf {} \;
```

---

## 📁 目錄結構說明

### 開發機

```
~/Library/Mobile Documents/com~apple~CloudDocs/Logic-Inbox/
  ├── task-20260201-170000.task  # 等待 Logic 機抓取
  └── ...

~/Documents/vibecodeinggggggg/logic/
  ├── send_to_logic.sh           # 發送工具
  ├── send_files_to_logic.sh     # 專案發送工具
  └── ...
```

### Logic 機

```
~/Logic/
  ├── inbox/          # 從 iCloud 搬來的任務
  ├── workspace/      # 執行中的任務
  ├── archive/        # 完成的任務（含日誌）
  └── system/         # Logic 系統檔案
      ├── dashboard/
      ├── cost/
      ├── monitor_service.sh
      └── ...

~/Library/Mobile Documents/com~apple~CloudDocs/Logic-Inbox/
  # iCloud 同步目錄（自動清空）
```

---

## 🎬 完整工作流程範例

### 範例：讓 Logic 執行資料分析

#### 1. 準備腳本（開發機）

建立 `analyze.py`：
```python
print("開始分析資料...")
# 你的程式碼
print("分析完成！")
```

#### 2. 發送到 Logic

```bash
./send_to_logic.sh "資料分析" "python3 analyze.py"
```

#### 3. 自動流程

1. **10 秒內**：Logic 機監控到新任務
2. **自動執行**：解壓縮、執行 `run.sh`
3. **記錄成本**：如果有 API 呼叫，自動記錄
4. **更新儀表板**：即時顯示進度
5. **歸檔結果**：執行完成後移到 `archive/`

#### 4. 查看結果

在 Logic 機：
```bash
# 找到最新的歸檔
ls -lt ~/Logic/archive/ | head -5

# 查看輸出
cat ~/Logic/archive/資料分析-20260201-170530/output.log
```

或在儀表板查看：`http://localhost:8888`

---

## ⚙️ 進階設定

### 開機自動啟動（Logic 機）

建立 LaunchAgent：

```bash
# 在 Logic 機上執行
cat > ~/Library/LaunchAgents/com.logic.monitor.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.logic.monitor</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/YOUR_USERNAME/Logic/start_monitor.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

# 載入
launchctl load ~/Library/LaunchAgents/com.logic.monitor.plist
```

記得將 `YOUR_USERNAME` 改成實際使用者名稱。

---

## 🐛 故障排除

### 問題：任務沒有被執行

**檢查**：
1. Logic 機的監控服務是否在運行？
   ```bash
   ps aux | grep monitor_service
   ```

2. iCloud 是否正常同步？
   ```bash
   ls -la ~/Library/Mobile\ Documents/com~apple~CloudDocs/Logic-Inbox/
   ```

3. 查看監控日誌：
   ```bash
   tail -50 ~/Logic/monitor.log
   ```

### 問題：儀表板無法開啟

**解決**：
```bash
# 重新啟動儀表板
cd ~/Logic/system
./stop_monitor.sh
./start_dashboard.sh
```

### 問題：iCloud 同步很慢

**說明**：首次同步可能需要幾分鐘，之後通常在 10 秒內完成。

**加速方式**：
- 確保兩台 Mac 都連上 Wi-Fi
- 檢查 iCloud 設定是否正常

---

## 📝 待辦事項

- [ ] 在 Logic 機上執行安裝腳本
- [ ] 啟動監控服務
- [ ] 測試發送第一個任務
- [ ] 確認儀表板可正常開啟
- [ ] （選用）設定開機自動啟動

---

**準備好了嗎？開始部署 Logic 系統吧！** 🚀
