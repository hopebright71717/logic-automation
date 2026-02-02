# Clawdbot 双语设置指南

## 🎯 目标

让 Clawdbot 在 Telegram 回复时自动显示**中英双语**。

---

## ⚡ 快速设置

**在 Logic 机执行**：

```bash
bash ~/logic-automation/workflows/setup_bilingual.sh
```

**完成！** 之后 Clawdbot 的每次回复都会包含中文翻译。

---

## 📊 回复格式

### 之前（只有英文）：
```
Service started successfully.
```

### 之后（中英双语）：
```
Service started successfully.
---中文---
服務已成功啟動。
```

---

## 🔧 手动设置（如果脚本失败）

```bash
clawdbot config set agents.defaults.systemPrompt "You are a helpful assistant. ALWAYS respond in BOTH English and Traditional Chinese. Format: English first, then '---中文---', then Chinese translation."
```

**然后重启**：
```bash
pkill -f clawdbot
```

---

## ✅ 验证

**在 Telegram 发送测试指令**：
```bash
echo "测试"
```

**应该看到**：
```
测试
---中文---
測試
```

---

## 💡 注意事项

- 设置后需要**重启 Clawdbot** 才会生效
- Clawdbot 会自动重启（有守护进程）
- 等待约 2 秒后就能测试
