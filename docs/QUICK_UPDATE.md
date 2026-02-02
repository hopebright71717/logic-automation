# Logic 快速更新指南

## ⚡ 超快速更新（对话中使用）

### 方法 1：一键命令（最快！）

**在 Logic 机终端执行**：
```bash
u
```

**说明**：
- 只需输入 `u` 然后回车
- 3 秒内完成更新
- 不打断思绪

---

### 方法 2：完整路径

```bash
bash ~/logic-automation/workflows/instant_update.sh
```

---

## 🔧 设置别名（首次执行一次）

**在 Logic 机执行**：

```bash
echo 'alias u="bash ~/logic-automation/workflows/instant_update.sh"' >> ~/.zshrc && source ~/.zshrc
```

**完成后，以后只需输入 `u` 就能更新！**

---

## 📊 更新方式对比

| 方式 | 命令 | 耗时 | 适用场景 |
|------|------|------|----------|
| **超快速** | `u` | 3 秒 | 对话中频繁更新 |
| 快速更新 | `bash ~/Logic/workflows/quick_update.sh` | 10 秒 | 一般更新 |
| 完整部署 | `bash ~/logic-automation/workflows/deploy.sh` | 30 秒 | 首次部署/重大更新 |
| 自动更新 | （监控服务） | 10 分钟 | 无需操作 |

---

## 🎯 使用建议

### 对话中更新（推荐用超快速）

```
您：「老师，加个 xxx 功能」
Antigravity：「好的！」（修改代码并推送 GitHub）

您在 Logic 机执行：u
→ 3 秒完成

继续对话，不打断思绪 ✅
```

### 重大更新（用完整部署）

```bash
bash ~/logic-automation/workflows/deploy.sh
```

---

## 💡 快捷键建议

如果经常更新，可以设置更短的别名：

```bash
# 编辑 ~/.zshrc
alias u="bash ~/logic-automation/workflows/instant_update.sh"
alias update="bash ~/Logic/workflows/quick_update.sh"
alias deploy="bash ~/logic-automation/workflows/deploy.sh"
```
