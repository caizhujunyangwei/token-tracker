# Token Tracker 📊

OpenClaw Token 使用追踪系统，带漂亮的 Web 仪表盘！

## 功能特点

- 📈 **实时统计** - 总会话数、Token 使用量一目了然
- 📅 **每日趋势** - 查看每天的 Token 使用情况
- 🤖 **模型分析** - 了解各个模型的使用分布
- 📋 **历史记录** - 详细的会话记录列表
- 🎨 **漂亮界面** - 渐变色设计，图表美观

## 快速开始

### 安装

```bash
cd token-tracker
npm install
```

### 启动

```bash
node server.js
```

### 访问

打开浏览器访问：`http://localhost:6000`

## 项目结构

```
token-tracker/
├── server.js          # Web 服务器
├── recorder.js        # Token 记录模块
├── package.json       # 项目配置
├── README.md          # 说明文档
├── public/
│   └── index.html     # Web 仪表盘
├── data/
│   └── usage.json     # 数据存储（运行时生成）
└── skills/
    └── token-recorder/
        └── SKILL.md   # OpenClaw skill
```

## API

### GET /api/usage
获取所有会话记录

### GET /api/stats
获取统计数据（按日期、按模型分组）

### POST /api/usage
添加新的会话记录

## 集成 OpenClaw

将 `skills/token-recorder` 复制到 OpenClaw 的 skills 目录，即可自动记录每次会话的 token 使用。

## 技术栈

- **后端**: Node.js + Express
- **前端**: HTML + Chart.js
- **存储**: JSON 文件（无需数据库）

## 作者

杨哥 & 胖子 🐼

## License

MIT
