import express from 'express';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = 6000;

// 数据文件路径
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

// 读取数据
function readData() {
  try {
    const content = readFileSync(DATA_FILE, 'utf-8');
    return JSON.parse(content);
  } catch (e) {
    return { sessions: [] };
  }
}

// 写入数据
function writeData(data) {
  writeFileSync(DATA_FILE, JSON.stringify(data, null, 2));
}

// API: 获取所有数据
app.get('/api/usage', (req, res) => {
  const data = readData();
  res.json(data);
});

// API: 添加会话记录
app.post('/api/usage', express.json(), (req, res) => {
  const data = readData();
  const newRecord = {
    id: Date.now().toString(),
    timestamp: new Date().toISOString(),
    ...req.body
  };
  data.sessions.push(newRecord);
  writeData(data);
  res.json({ success: true, id: newRecord.id });
});

// API: 获取统计数据
app.get('/api/stats', (req, res) => {
  const data = readData();
  const sessions = data.sessions || [];
  
  // 按日期分组统计
  const byDate = {};
  const byModel = {};
  let totalIn = 0;
  let totalOut = 0;
  
  sessions.forEach(s => {
    const date = s.timestamp.split('T')[0];
    const model = s.model || 'unknown';
    
    if (!byDate[date]) {
      byDate[date] = { input: 0, output: 0, count: 0 };
    }
    byDate[date].input += s.input || 0;
    byDate[date].output += s.output || 0;
    byDate[date].count += 1;
    
    if (!byModel[model]) {
      byModel[model] = { input: 0, output: 0, count: 0 };
    }
    byModel[model].input += s.input || 0;
    byModel[model].output += s.output || 0;
    byModel[model].count += 1;
    
    totalIn += s.input || 0;
    totalOut += s.output || 0;
  });
  
  res.json({
    total: {
      input: totalIn,
      output: totalOut,
      sessions: sessions.length
    },
    byDate,
    byModel
  });
});

// 静态文件
app.use(express.static(join(__dirname, 'public')));

// 首页
app.get('/', (req, res) => {
  res.sendFile(join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`📊 Token Tracker 已启动！`);
  console.log(`🌐 访问地址：http://localhost:${PORT}`);
  console.log(`📁 数据目录：${DATA_DIR}`);
});
