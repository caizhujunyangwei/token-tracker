/**
 * Token 自动记录器
 * 集成到 OpenClaw，每次会话后自动记录 token 使用
 */

import { writeFileSync, existsSync, mkdirSync, readFileSync } from 'fs';
import { join } from 'path';
import { execSync } from 'child_process';

const DATA_DIR = '/home/admin/.openclaw/workspace/tokens-data';
const DATA_FILE = join(DATA_DIR, 'usage.json');
const TRACKER_DIR = '/home/admin/.openclaw/workspace/token-tracker';
const TARGET_DATA = join(TRACKER_DIR, 'docs/data/usage.json');

// 确保数据目录存在
if (!existsSync(DATA_DIR)) {
  mkdirSync(DATA_DIR, { recursive: true });
}

// 初始化数据文件
if (!existsSync(DATA_FILE)) {
  writeFileSync(DATA_FILE, JSON.stringify({ sessions: [] }, null, 2));
}

/**
 * 记录一次会话的 token 使用
 * @param {Object} sessionData - 会话数据
 */
export function recordSession(sessionData) {
  try {
    const data = JSON.parse(readFileSync(DATA_FILE, 'utf-8'));
    
    const record = {
      id: sessionData.sessionId || Date.now().toString(),
      timestamp: new Date().toISOString(),
      model: sessionData.model || 'bailian/qwen3.5-plus',
      input: sessionData.inputTokens || 0,
      output: sessionData.outputTokens || 0,
      channel: sessionData.channel || 'qqbot',
      duration: sessionData.duration || 0
    };
    
    data.sessions.push(record);
    writeFileSync(DATA_FILE, JSON.stringify(data, null, 2));
    
    console.log(`📊 Token 记录已保存：${record.input + record.output} tokens`);
    return true;
  } catch (e) {
    console.error('❌ Token 记录失败:', e.message);
    return false;
  }
}

/**
 * 同步数据到 GitHub
 */
export function syncToGitHub() {
  try {
    // 确保目标目录存在
    const targetDir = join(TRACKER_DIR, 'docs/data');
    if (!existsSync(targetDir)) {
      mkdirSync(targetDir, { recursive: true });
    }
    
    // 复制数据文件
    const currentData = readFileSync(DATA_FILE, 'utf-8');
    writeFileSync(TARGET_DATA, currentData);
    
    console.log('✅ 数据已同步到 tracker 目录');
    
    // Git 提交（可选，由 update-data.sh 处理）
    return true;
  } catch (e) {
    console.error('❌ 同步失败:', e.message);
    return false;
  }
}

/**
 * 获取最近的 token 使用记录
 * @param {number} limit - 返回记录数量
 */
export function getRecentSessions(limit = 10) {
  try {
    const data = JSON.parse(readFileSync(DATA_FILE, 'utf-8'));
    return data.sessions.slice(-limit);
  } catch (e) {
    return [];
  }
}

// 如果是直接运行，执行一次同步
if (process.argv[1] && process.argv[1].includes('auto-recorder.js')) {
  console.log('📊 Token 自动记录器启动');
  syncToGitHub();
  
  // 触发 update-data.sh
  try {
    execSync('cd /home/admin/.openclaw/workspace/token-tracker && ./update-data.sh', { 
      stdio: 'inherit',
      cwd: TRACKER_DIR
    });
  } catch (e) {
    console.error('执行 update-data.sh 失败:', e.message);
  }
}

export default { recordSession, syncToGitHub, getRecentSessions };
