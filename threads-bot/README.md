# Threads Bot 使用指南

## 🎯 快速开始

### 1. 安装依赖

**在 Logic 机执行**：
```bash
cd ~/logic-automation/threads-bot
pip3 install -r requirements.txt
```

---

### 2. 配置账号信息

**复制配置模板**：
```bash
cp config/.env.example config/.env
```

**编辑配置**：
```bash
nano config/.env
```

**填入**：
- Threads 账号密码
- IG 账号密码（用于学习风格）
- OpenAI API Key
- 其他设置

---

### 3. 测试运行

```bash
python3 main.py
```

---

## 📋 功能说明

### 自动发文
- 每天 11:00 自动生成并发布
- 可设置需要审核

### 自动点赞
- 每天 10-30 次随机点赞
- 目标：热门和相关贴文

### 自动回复
- 每天回复 3 篇热门贴文
- 点赞数超过平均值 50%

---

## 🔧 常用命令

### 启动机器人
```bash
python3 main.py
```

### 后台运行
```bash
nohup python3 main.py > logs/bot.log 2>&1 &
```

### 查看日志
```bash
tail -f logs/bot.log
```

### 停止机器人
```bash
pkill -f "python3 main.py"
```

---

## ⚙️ 配置说明

详见 `config/.env.example`

关键设置：
- `AUTO_APPROVE`: 自动发布还是需要审核
- `DAILY_LIKES_MIN/MAX`: 每天点赞数量范围
- `REPLY_COUNT`: 每天回复数量

---

## 🚀 部署到 Logic 机

### 使用 systemd（推荐）

创建服务文件：
```bash
sudo nano /etc/systemd/system/threads-bot.service
```

内容：
```ini
[Unit]
Description=Threads Automation Bot
After=network.target

[Service]
Type=simple
User=xuziling
WorkingDirectory=/Users/xuziling/Logic/threads-bot
ExecStart=/usr/bin/python3 main.py
Restart=always

[Install]
WantedBy=multi-user.target
```

启动：
```bash
sudo systemctl enable threads-bot
sudo systemctl start threads-bot
```

---

## 📊 监控

### 查看状态
```bash
systemctl status threads-bot
```

### 查看日志
```bash
journalctl -u threads-bot -f
```
