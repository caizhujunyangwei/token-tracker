#!/usr/bin/env node
/**
 * Token 统计图片自动发送监听器
 * 监控 /tmp/qqbot-send-image.txt 文件，有新图片时自动发送到 QQ
 */

const { readFileSync, writeFileSync, existsSync, watch } = require('fs');
const { execSync } = require('child_process');
const { join } = require('path');

const MARKER_FILE = '/tmp/qqbot-send-image.txt';
const PROCESSED_FILE = '/tmp/qqbot-send-image.last';

console.log('📸 Token 图片发送监听器启动...');

function getMarkerInfo() {
  if (!existsSync(MARKER_FILE)) return null;
  try {
    const lines = readFileSync(MARKER_FILE, 'utf-8').trim().split('\n');
    if (lines.length >= 3) {
      return {
        imagePath: lines[0],
        userId: lines[1],
        timestamp: lines[2]
      };
    }
  } catch (e) {
    console.error('读取标记文件失败:', e.message);
  }
  return null;
}

function getLastProcessed() {
  if (!existsSync(PROCESSED_FILE)) return null;
  try {
    return readFileSync(PROCESSED_FILE, 'utf-8').trim();
  } catch (e) {
    return null;
  }
}

function setLastProcessed(timestamp) {
  writeFileSync(PROCESSED_FILE, timestamp);
}

function sendImage(imagePath, userId) {
  try {
    console.log(`📨 发送图片：${imagePath} 到用户 ${userId}`);
    
    const messageCmd = `openclaw message send --channel qqbot --target ${userId} --message "📊 Token 使用统计已更新！\\n\\n⏰ 更新时间：$(date '+%Y-%m-%d %H:%M')" --media "${imagePath}"`;
    
    execSync(messageCmd, { stdio: 'inherit' });
    console.log('✅ 图片发送成功！');
    return true;
  } catch (e) {
    console.error('❌ 图片发送失败:', e.message);
    return false;
  }
}

function checkAndSend() {
  const info = getMarkerInfo();
  if (!info) return;
  
  const lastProcessed = getLastProcessed();
  if (lastProcessed === info.timestamp) {
    // 已经处理过这个标记
    return;
  }
  
  console.log(`🆕 检测到新图片任务：${info.imagePath}`);
  
  const success = sendImage(info.imagePath, info.userId);
  if (success) {
    setLastProcessed(info.timestamp);
  }
}

// 初始检查
checkAndSend();

// 监听文件变化
watch('/tmp', (eventType, filename) => {
  if (filename === 'qqbot-send-image.txt') {
    console.log('📁 检测到标记文件变化');
    setTimeout(checkAndSend, 500); // 稍等确保文件写入完成
  }
});

// 每分钟检查一次（防止文件监听失效）
setInterval(checkAndSend, 60000);

console.log('✅ 监听器运行中，等待图片发送任务...');
