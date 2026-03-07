# Token Recorder Skill

自动记录 OpenClaw 会话的 Token 使用情况到 Token Tracker。

## 功能

- 在会话结束时自动记录 token 使用数据
- 发送到 Token Tracker Web 服务
- 支持自定义 Tracker 服务器地址

## 配置

在 `TOOLS.md` 中添加：

```markdown
### Token Tracker

- Tracker URL: http://localhost:6000
- Auto Record: true
```

## 使用

无需手动调用，会话结束时自动记录。

## 数据格式

```json
{
  "sessionId": "xxx",
  "model": "dashscope/qwen3.5-plus",
  "inputTokens": 1000,
  "outputTokens": 200,
  "channel": "webchat",
  "duration": 300
}
```
