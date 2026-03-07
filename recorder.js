/**
 * Token 使用记录器
 * 集成到 OpenClaw，自动记录每次会话的 token 使用
 */

import { writeFileSync, existsSync, mkdirSync, readFileSync } from 'fs';
import { join } from 'path';

const DATA_DIR = '/home/admin/.openclaw/workspace/tokens-data';
const DATA_FILE = join(DATA_DIR, 'usage.json');

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
      model: sessionData.model || 'unknown',
      input: sessionData.inputTokens || 0,
      output: sessionData.outputTokens || 0,
      channel: sessionData.channel || 'webchat',
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

export default { recordSession, getRecentSessions };
