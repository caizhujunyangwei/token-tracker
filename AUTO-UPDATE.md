# Token Tracker 自动更新配置

## ✅ 已完成的配置

### 1. 定时任务（Cron）
- **频率**: 每小时整点执行（`0 * * * *`）
- **脚本**: `/home/admin/.openclaw/workspace/token-tracker/hourly-update.sh`
- **日志**: `/tmp/token-update.log`

### 2. 自动更新流程
```
每小时整点 → hourly-update.sh → 复制数据 → Git 提交 → 推送到 GitHub → GitHub Actions 部署
```

### 3. 脚本说明

#### `hourly-update.sh`
- 每小时自动执行
- 复制最新 token 数据到 `docs/data/usage.json`
- 自动 commit 并 push 到 GitHub
- 触发 GitHub Actions 部署到 Pages

#### `auto-recorder.js`
- Node.js 模块
- 可在代码中调用 `recordSession()` 自动记录
- 集成到 OpenClaw 会话流程

#### `update-data.sh`
- 旧版更新脚本（保留兼容）
- 可手动执行测试

### 4. 数据文件位置
- **源数据**: `/home/admin/.openclaw/workspace/tokens-data/usage.json`
- **同步数据**: `/home/admin/.openclaw/workspace/token-tracker/docs/data/usage.json`

### 5. GitHub Pages
- **访问地址**: https://caizhujunyangwei.github.io/token-tracker/
- **自动部署**: 数据更新后自动触发

## 🔧 手动测试

```bash
# 手动执行一次更新
cd /home/admin/.openclaw/workspace/token-tracker
./hourly-update.sh

# 查看日志
tail -f /tmp/token-update.log

# 查看 crontab
crontab -l
```

## 📊 数据格式

```json
{
  "sessions": [
    {
      "id": "1741460400000",
      "timestamp": "2026-03-08T14:00:00.000Z",
      "model": "bailian/qwen3.5-plus",
      "input": 45000,
      "output": 520,
      "channel": "qqbot",
      "duration": 200
    }
  ]
}
```

## ⚠️ 注意事项

1. 确保 GitHub token 有效（secrets.GITHUB_TOKEN）
2. 确保 cron 服务正常运行
3. 定期检查日志 `/tmp/token-update.log`
4. 数据源文件需要其他机制自动填充（如 OpenClaw 插件）

## 🚀 后续优化

- 集成到 OpenClaw 会话结束钩子，自动记录每次会话
- 添加数据清理（保留最近 N 天）
- 添加异常告警（更新失败时通知）

---
最后更新：2026-03-08
