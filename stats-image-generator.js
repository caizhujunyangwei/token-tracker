/**
 * Token 统计图片生成器
 * 生成 token 使用统计图片并返回图片路径
 */

import { createCanvas } from 'canvas';
import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'fs';
import { join } from 'path';

const TRACKER_DIR = '/home/admin/.openclaw/workspace/token-tracker';
const DATA_FILE = join(TRACKER_DIR, 'docs/data/usage.json');
const OUTPUT_DIR = join(TRACKER_DIR, 'stats-images');

// 确保输出目录存在
if (!existsSync(OUTPUT_DIR)) {
  mkdirSync(OUTPUT_DIR, { recursive: true });
}

/**
 * 生成 Token 统计图片
 * @returns {string} 生成的图片路径
 */
export function generateStatsImage() {
  try {
    // 读取数据
    const data = JSON.parse(readFileSync(DATA_FILE, 'utf-8'));
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
    const lastSession = sessions[sessions.length - 1];

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
    if (ctx.roundRect) {
      ctx.roundRect(50, 100, 700, 450, 20);
    } else {
      ctx.fillRect(50, 100, 700, 450);
    }
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
    if (lastSession) {
      ctx.fillStyle = '#999';
      ctx.font = '14px Arial';
      ctx.textAlign = 'center';
      ctx.fillText(`最后更新：${new Date(lastSession.timestamp).toLocaleString('zh-CN')}`, 400, 560);
    }

    // 生成文件名
    const timestamp = new Date();
    const filename = `token-stats-${timestamp.getFullYear()}${String(timestamp.getMonth() + 1).padStart(2, '0')}${String(timestamp.getDate()).padStart(2, '0')}-${String(timestamp.getHours()).padStart(2, '0')}${String(timestamp.getMinutes()).padStart(2, '0')}.png`;
    const outputPath = join(OUTPUT_DIR, filename);

    // 保存文件
    const buffer = canvas.toBuffer('image/png');
    writeFileSync(outputPath, buffer);
    
    console.log(`✅ 图片已生成：${outputPath}`);
    return outputPath;
  } catch (e) {
    console.error('❌ 图片生成失败:', e.message);
    return null;
  }
}

// 如果是直接运行
if (process.argv[1] && process.argv[1].includes('stats-image-generator.js')) {
  const imagePath = generateStatsImage();
  if (imagePath) {
    console.log(`📸 图片路径：${imagePath}`);
  }
}

export default { generateStatsImage };
