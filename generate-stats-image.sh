#!/bin/bash
# Token 统计图片生成脚本
# 生成当前 token 使用情况的统计图片

set -e

TRACKER_DIR="/home/admin/.openclaw/workspace/token-tracker"
DATA_FILE="$TRACKER_DIR/docs/data/usage.json"
OUTPUT_DIR="$TRACKER_DIR/stats-images"
OUTPUT_FILE="$OUTPUT_DIR/token-stats-$(date +%Y%m%d-%H%M).png"

echo "📊 生成 Token 统计图片 - $(date '+%Y-%m-%d %H:%M:%S')"

# 确保输出目录存在
mkdir -p "$OUTPUT_DIR"

# 读取数据文件
if [ ! -f "$DATA_FILE" ]; then
  echo "❌ 数据文件不存在：$DATA_FILE"
  exit 1
fi

# 使用 Node.js 生成统计图片
node << 'EOF'
const fs = require('fs');
const { createCanvas } = require('canvas');

// 读取数据
const data = JSON.parse(fs.readFileSync('/home/admin/.openclaw/workspace/token-tracker/docs/data/usage.json', 'utf-8'));
const sessions = data.sessions || [];

// 统计数据
let totalInput = 0;
let totalOutput = 0;
const byModel = {};
const byDate = {};

sessions.forEach(s => {
  totalInput += s.input || 0;
  totalOutput += s.output || 0;
  
  const model = s.model || 'unknown';
  if (!byModel[model]) {
    byModel[model] = { input: 0, output: 0 };
  }
  byModel[model].input += s.input || 0;
  byModel[model].output += s.output || 0;
  
  const date = s.timestamp.split('T')[0];
  if (!byDate[date]) {
    byDate[date] = { input: 0, output: 0, count: 0 };
  }
  byDate[date].input += s.input || 0;
  byDate[date].output += s.output || 0;
  byDate[date].count += 1;
});

const totalTokens = totalInput + totalOutput;

// 创建画布 (800x600)
const canvas = createCanvas(800, 600);
const ctx = canvas.getContext('2d');

// 背景渐变
const gradient = ctx.createLinearGradient(0, 0, 0, 600);
gradient.addColorStop(0, '#667eea');
gradient.addColorStop(1, '#764ba2');
ctx.fillStyle = gradient;
ctx.fillRect(0, 0, 800, 600);

// 标题
ctx.fillStyle = '#ffffff';
ctx.font = 'bold 36px Arial';
ctx.textAlign = 'center';
ctx.fillText('📊 Token 使用统计', 400, 60);

// 统计卡片背景
ctx.fillStyle = 'rgba(255, 255, 255, 0.95)';
ctx.roundRect(50, 100, 700, 450, 20);
ctx.fill();

// 统计数字
ctx.fillStyle = '#667eea';
ctx.font = 'bold 48px Arial';
ctx.textAlign = 'center';

// 总会话数
ctx.fillText(`${sessions.length}`, 150, 180);
ctx.fillStyle = '#666';
ctx.font = '18px Arial';
ctx.fillText('总会话数', 150, 210);

// 总输入
ctx.fillStyle = '#667eea';
ctx.font = 'bold 32px Arial';
ctx.fillText(`${totalInput.toLocaleString()}`, 350, 180);
ctx.fillStyle = '#666';
ctx.font = '18px Arial';
ctx.fillText('总输入 Tokens', 350, 210);

// 总输出
ctx.fillStyle = '#667eea';
ctx.font = 'bold 32px Arial';
ctx.fillText(`${totalOutput.toLocaleString()}`, 550, 180);
ctx.fillStyle = '#666';
ctx.font = '18px Arial';
ctx.fillText('总输出 Tokens', 550, 210);

// 总计
ctx.fillStyle = '#764ba2';
ctx.font = 'bold 48px Arial';
ctx.fillText(`${totalTokens.toLocaleString()}`, 400, 280);
ctx.fillStyle = '#666';
ctx.font = '18px Arial';
ctx.fillText('总计 Tokens', 400, 310);

// 按日期统计
ctx.fillStyle = '#333';
ctx.font = 'bold 24px Arial';
ctx.textAlign = 'left';
ctx.fillText('📅 每日使用:', 100, 370);

const dates = Object.keys(byDate).sort();
ctx.font = '16px Arial';
let y = 410;
dates.slice(-5).forEach(date => {
  const d = byDate[date];
  ctx.fillStyle = '#667eea';
  ctx.fillText(`${date}:`, 100, y);
  ctx.fillStyle = '#666';
  ctx.fillText(`${(d.input + d.output).toLocaleString()} tokens (${d.count}次)`, 250, y);
  y += 30;
});

// 最后更新时间
ctx.fillStyle = '#999';
ctx.font = '14px Arial';
ctx.textAlign = 'center';
const lastSession = sessions[sessions.length - 1];
if (lastSession) {
  ctx.fillText(`最后更新：${new Date(lastSession.timestamp).toLocaleString('zh-CN')}`, 400, 560);
}

// 保存文件
const outputPath = process.argv[2] || '/tmp/token-stats.png';
const buffer = canvas.toBuffer('image/png');
fs.writeFileSync(outputPath, buffer);
console.log(`✅ 图片已生成：${outputPath}`);
EOF

echo "🎉 图片生成完成"
echo "$OUTPUT_FILE"
