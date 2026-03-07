# Token Tracker 📊

OpenClaw Token 使用追踪系统，带漂亮的 Web 仪表盘！

## 🌐 在线访问

**GitHub Pages:** https://caizhujunyangwei.github.io/token-tracker

数据每小时自动更新！

## 功能特点

- 📈 **实时统计** - 总会话数、Token 使用量一目了然
- 📅 **每日趋势** - 查看每天的 Token 使用情况
- 🤖 **模型分析** - 了解各个模型的使用分布
- 📋 **历史记录** - 详细的会话记录列表
- 🎨 **漂亮界面** - 渐变色设计，图表美观
- ⏰ **自动更新** - GitHub Actions 每小时自动同步数据

## 项目结构

```
token-tracker/
├── public/
│   └── index.html     # Web 仪表盘（部署到 GitHub Pages）
├── data/
│   └── usage.json     # Token 数据（由 Actions 自动更新）
├── server.js          # 本地开发服务器
├── recorder.js        # Token 记录模块
├── package.json       # 项目配置
├── README.md          # 说明文档
└── .github/
    └── workflows/
        └── update-data.yml  # 每小时自动更新数据的 Actions
```

## 本地开发

```bash
cd token-tracker
npm install
npm start
```

访问：`http://localhost:8899`

## 自动部署

- **前端**: GitHub Pages 自动部署 `public/` 目录
- **数据**: GitHub Actions 每小时从服务器拉取最新数据

## 集成 OpenClaw

将 `skills/token-recorder` 复制到 OpenClaw 的 skills 目录，即可自动记录每次会话的 token 使用。

## 技术栈

- **前端**: HTML + Chart.js
- **后端**: Node.js + Express（仅用于本地开发）
- **部署**: GitHub Pages + GitHub Actions
- **存储**: JSON 文件

## 作者

杨哥 & 胖子 🐼

## License

MIT
