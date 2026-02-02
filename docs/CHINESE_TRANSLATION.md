# 如何讓 Clawdbot 回覆包含中文翻譯

## 🎯 目標

讓 Clawdbot 在每次回覆後，自動附上**中文翻譯**，讓您更容易理解系統在做什麼。

---

## ✅ 解決方案

### 方法 1：修改 Clawdbot System Prompt（推薦）

在 Logic 機終端執行：

```bash
# 中文說明：設定 Clawdbot 使用中英雙語回覆
clawdbot config set agents.defaults.systemPrompt "You are a helpful assistant. IMPORTANT: Always provide responses in both English and Traditional Chinese (繁體中文). Format: First the English response, then add a separator '---中文翻譯---' followed by the Traditional Chinese translation."
```

**中文說明**：
- 這個指令告訴 Clawdbot：「每次回覆都要用**英文+繁體中文**」
- 格式：英文 → 分隔線 → 中文翻譯

---

### 方法 2：在每個腳本加入中文輸出（我來做）

我會修改所有腳本，讓它們自動輸出：
- ✅ 英文原文
- ✅ 中文說明

**範例**（修改後的輸出）：

```bash
✅ Service started successfully
===中文翻譯===
✅ 服務已成功啟動
```

---

## 🚀 立即執行

### 步驟 1：設定 Clawdbot 雙語模式

**在 Logic 機終端執行**：

```bash
clawdbot config set agents.defaults.systemPrompt "You are a helpful assistant. Always respond in both English and Traditional Chinese. Format: [English response] then '---中文---' then [Chinese translation]"
```

**📝 中文說明**：
- `clawdbot config set`：設定 Clawdbot 配置
- `systemPrompt`：系統提示詞（告訴 AI 如何回應）
- 效果：每次都會顯示英文+中文

---

### 步驟 2：重啟 Clawdbot（讓設定生效）

**在 Telegram 執行**：

```bash
pkill -f clawdbot && sleep 2 && echo "Clawdbot 已重啟 / Clawdbot restarted"
```

**📝 中文說明**：
- `pkill -f clawdbot`：停止 Clawdbot
- `sleep 2`：等待 2 秒
- Clawdbot 會自動重啟（因為有自動守護）

---

## 💡 未來所有回覆格式

### 之前（只有英文）：
```
Process started successfully.
```

### 之後（英文+中文）：
```
Process started successfully.
---中文---
進程已成功啟動。
```

---

## 📋 我給您的指令說明格式

從現在開始，我會這樣給您指令：

```bash
# 指令
cd ~/Logic && bash system/monitor_service.sh

# 📝 中文說明
# 進入 Logic 目錄並啟動監控服務
# cd ~/Logic：切換到 Logic 目錄
# bash system/monitor_service.sh：執行監控服務腳本
```

---

## ✅ 立即生效

執行上面的步驟 1 和步驟 2，之後 Clawdbot 就會自動雙語回覆了！🎉
