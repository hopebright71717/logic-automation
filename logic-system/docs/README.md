# Logic 自動化工作系統 — 使用說明

**專案版本**：1.0.0  
**最後更新**：2026-02-01  
**作者**：建立於 macOS，使用 Telegram + Jump Desktop

---

## 📖 目錄

1. [系統概述](#系統概述)
2. [安裝與設定](#安裝與設定)
3. [啟動儀表板](#啟動儀表板)
4. [使用成本追蹤](#使用成本追蹤)
5. [更新系統狀態](#更新系統狀態)
6. [自動化規則](#自動化規則)
7. [API 預算設定](#api-預算設定)
8. [常見問題](#常見問題)

---

## 系統概述

Logic 是一個全自動化工作系統，整合了：
- 📊 **可視化儀表板**（localhost 網頁）
- 💰 **API 成本追蹤與治理**（每月上限 2000 TWD / 65 USD）
- 🤖 **自動化工作流程**（低風險任務自動完成）

### 核心功能

| 功能 | 說明 |
|------|------|
| **即時狀態** | 看到當前任務、進度、心跳時間 |
| **今日輸出** | 自動記錄今天新增/更新的檔案 |
| **錯誤警告** | 最新 10 條錯誤或警告 |
| **成本追蹤** | 今日/本月 API 成本、剩餘預算、燃燒率 |
| **成本排行** | 最耗費 API 的指令 TOP 10 |

---

## 安裝與設定

### 前置需求

- Python 3.7+（已內建於 macOS）
- 網頁瀏覽器（Safari、Chrome、Firefox 皆可）

### 專案結構

```
/logic/
  /dashboard/           # 儀表板網頁
    index.html          # 主頁面
    dashboard.css       # 樣式
    dashboard.js        # 前端邏輯
    server.py           # 本地伺服器（localhost:8888）
  /logs/                # 任務紀錄
  /cost/                # API 成本紀錄
    cost_tracker.py     # 成本追蹤核心模組
    raw_calls.jsonl     # 原始 API 呼叫紀錄
  /docs/                # 文件
    autonomy_rules.md   # 自動化規則
    README.md           # 本文件
  status.json           # 系統狀態（機器可讀）
  cost_today.json       # 今日成本彙總
  cost_month.json       # 本月成本彙總
  cost_rank.csv         # 指令成本排行
  daily_log.md          # 每日工作紀錄（人可讀）
  update_status.py      # 狀態更新工具
```

---

## 啟動儀表板

### 步驟 1：啟動本地伺服器

在終端機中執行：

```bash
cd /Users/xuziling/Documents/vibecodeinggggggg/logic/dashboard
python3 server.py
```

你會看到：

```
============================================================
🚀 Logic 儀表板已啟動！
============================================================

📊 儀表板網址：http://localhost:8888
📁 服務目錄：/Users/xuziling/Documents/vibecodeinggggggg/logic/dashboard

💡 在 iPad Jump Desktop 中，直接開啟上述網址即可查看
⏱  自動刷新：每 5 秒

按 Ctrl+C 停止伺服器

============================================================
```

### 步驟 2：在 iPad Jump Desktop 中開啟

1. 開啟 iPad 上的 **Jump Desktop**
2. 連線到你的 Mac
3. 開啟瀏覽器
4. 前往：`http://localhost:8888`

### 步驟 3：查看儀表板

儀表板會顯示：
- ✅ 當前任務狀態
- ✅ 今日 API 成本與本月累積
- ✅ 成本排行 TOP 5
- ✅ 今日輸出檔案清單
- ✅ 最近 10 條錯誤/警告

**自動刷新**：每 5 秒自動更新，無需手動重新整理。

---

## 使用成本追蹤

### 記錄 API 呼叫

每次使用 API（例如 GPT-4、GPT-3.5）時，記錄使用量：

```bash
cd /Users/xuziling/Documents/vibecodeinggggggg/logic/cost
python3 cost_tracker.py log <task_id> <command> <model> <prompt_tokens> <completion_tokens>
```

**範例**：

```bash
python3 cost_tracker.py log "task_001" "分析程式碼" "gpt-4o" 1500 500
```

輸出：

```
✅ Logged: $0.0100 USD / $0.30 TWD
```

### 查看成本摘要

```bash
python3 cost_tracker.py summary
```

輸出範例：

```
=== 今日成本 ===
  總額：$0.1234 USD / $3.70 TWD
  呼叫次數：15
  總 tokens：45,000

=== 本月成本 ===
  總額：$5.6789 USD / $170.37 TWD
  預算：$65.00 USD
  剩餘：$59.32 USD
  燃燒率：$0.1893 USD/day
```

### 檢查預算警報

```bash
python3 cost_tracker.py alerts
```

可能的輸出：

```
⚠️ 今日成本已達 $2.15 USD（軟上限 $2），建議降級模型
ℹ️ 本月成本已達 $32.50 USD（50.0% of $65）
```

---

## 更新系統狀態

使用 `update_status.py` 更新儀表板顯示的狀態。

### 更新當前任務

```bash
python3 update_status.py task "正在分析程式碼" running 50
```

- `"正在分析程式碼"`：任務名稱
- `running`：狀態（idle、running、completed、error）
- `50`：進度（0-100）

### 新增輸出檔案

```bash
python3 update_status.py output "/logic/daily_log.md"
```

### 記錄錯誤

```bash
python3 update_status.py error "找不到檔案 config.json"
```

### 記錄警告

```bash
python3 update_status.py warning "API 成本接近每日上限"
```

### 更新心跳

```bash
python3 update_status.py heartbeat
```

---

## 自動化規則

詳細規則請參閱：[`docs/autonomy_rules.md`](autonomy_rules.md)

### 可自動執行任務（不需確認）

✅ 建立/更新 Markdown、JSON、YAML 檔案  
✅ 整理、歸檔檔案（不刪除）  
✅ 生成報告、統計  
✅ 更新狀態、日誌  
✅ 預估成本 < 0.5 USD 的任務

### 需要確認任務

⚠️ 需要 `sudo` 權限  
⚠️ 涉及付款、訂閱、auto-recharge  
⚠️ **預估單次 API 成本 > 1.0 USD**  
⚠️ 刪除檔案或不可逆操作  
⚠️ 批次操作 > 20 個項目

### 成本門檻

| 門檻 | 條件 | 動作 |
|------|------|------|
| 日常運作 | < 2 USD/day | ✅ 正常運作 |
| 日軟上限 | ≥ 2 USD/day | ⚠️ 降級到便宜模型 |
| 日硬上限 | ≥ 3 USD/day | 🛑 停用非必要 API |
| 月軟上限 | ≥ 50 USD/month | ⚠️ 限制每日額度 |
| 月硬上限 | ≥ 65 USD/month | 🛑 完全停用 API |

---

## API 預算設定

### OpenAI 平台設定（重要）

1. 前往：[OpenAI Platform → Settings → Organization → Limits](https://platform.openai.com/settings/organization/limits)

2. 點擊：**Edit budget**

3. 設定每月預算：**60~65 USD**（對應 TWD 2000 左右）

4. 啟用警報：
   - ✅ 50% 警報
   - ✅ 80% 警報
   - ✅ 100% 警報

5. **不要開啟 Auto Recharge**（除非你接受自動扣款）

### 本地預算保護（雙重保護）

即使 OpenAI 平台設定了預算，本系統也會在本地進行二級保護：

- 💰 **每日軟上限**：2 USD（超過會降級模型）
- 🚫 **每日硬上限**：3 USD（停用非必要 API）
- 💰 **每月軟上限**：50 USD（限制額度）
- 🚫 **每月硬上限**：65 USD（完全停用 API）

---

## 常見問題

### Q1：如何在 iPad 上查看儀表板？

**A**：
1. 確保 Mac 上的伺服器正在運行（`python3 server.py`）
2. 在 iPad 上開啟 **Jump Desktop** 並連線到 Mac
3. 在 Mac 的瀏覽器中開啟：`http://localhost:8888`

### Q2：儀表板不會自動刷新？

**A**：儀表板每 5 秒會自動重新載入資料。如果沒有更新：
- 檢查 `status.json`、`cost_today.json`、`cost_month.json` 是否存在
- 開啟瀏覽器開發者工具（F12）查看 Console 是否有錯誤

### Q3：如何手動新增測試資料？

**A**：使用成本追蹤工具：

```bash
# 記錄一次 API 呼叫
python3 cost/cost_tracker.py log "test" "測試指令" "gpt-4o" 1000 500

# 更新任務狀態
python3 update_status.py task "測試任務" running 75

# 新增輸出
python3 update_status.py output "/logic/test.md"
```

### Q4：成本追蹤是實際花費還是估算？

**A**：目前使用 **token 估算**，根據 OpenAI 官方單價計算。未來可升級為實際 API 查詢。

### Q5：如何重置今日/本月成本？

**A**：系統會在每天 00:00 和每月 1 日自動重置。如需手動重置：

```bash
# 重置今日成本
echo '{"date":"2026-02-01","total_usd":0,"total_twd":0,"total_tokens":0,"by_model":{},"calls_count":0}' > cost_today.json

# 重置本月成本
echo '{"month":"2026-02","total_usd":0,"total_twd":0,"budget_usd":65,"budget_twd":1950,"remaining_usd":65}' > cost_month.json
```

### Q6：Bot 回覆格式是什麼？

**A**：建議 Telegram bot 使用以下格式回覆：

```
[STATE] 正在更新今日工作紀錄
[OUTPUT] /logic/daily_log.md
[COST] 本次：$0.002 USD / $0.06 TWD | 今日：$0.15 USD
[NEXT] 將生成成本排行報告
```

只有在「需要確認清單」中的任務才會在 `[NEXT]` 詢問。

---

## 🎯 驗收標準

✅ **打開 iPad Jump Desktop 能看到儀表板**  
✅ **看得到今日/本月 API 成本**  
✅ **看得到成本排行 TOP 指令**  
✅ **不用翻 Telegram 聊天就知道目前狀態**  
✅ **Bot 對低風險任務可連續自動完成**

---

## 📞 支援

如有問題，請參考：
- 自動化規則：[`docs/autonomy_rules.md`](autonomy_rules.md)
- 每日紀錄：[`daily_log.md`](../daily_log.md)

---

*Logic 自動化工作系統 — 讓工作自己完成，你只看結果* 🚀
