#!/bin/bash
# Token 使用量自动采集脚本
# 每小时运行一次，从 OpenClaw 获取最新 token 使用数据

set -e

WORKSPACE="/home/admin/.openclaw/workspace"
DATA_DIR="$WORKSPACE/tokens-data"
DATA_FILE="$DATA_DIR/usage.json"
TRACKER_DIR="$WORKSPACE/token-tracker"
TARGET_DATA="$TRACKER_DIR/docs/data/usage.json"

echo "📊 Token 自动采集开始 - $(date '+%Y-%m-%d %H:%M:%S')"

# 确保数据目录存在
mkdir -p "$DATA_DIR"

# 初始化数据文件（如果不存在）
if [ ! -f "$DATA_FILE" ]; then
  echo '{"sessions":[]}' > "$DATA_FILE"
  echo "📁 创建新数据文件：$DATA_FILE"
fi

# 获取当前会话的 token 使用情况
# 通过 OpenClaw session_status 获取
SESSION_STATUS=$(openclaw status 2>/dev/null || echo "")

# 解析 token 数据（如果 session_status 输出包含 token 信息）
if echo "$SESSION_STATUS" | grep -q "Tokens:"; then
  # 提取 token 数据
  TOKEN_INFO=$(echo "$SESSION_STATUS" | grep "Tokens:" | head -1)
  echo "✅ 获取到 token 信息：$TOKEN_INFO"
  
  # 这里可以解析出具体的 input/output tokens
  # 简化处理：如果获取到数据，就记录一条新记录
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:00:00.000Z")
  HOUR=$(date +"%H")
  
  # 检查是否已有当前小时的记录
  if ! grep -q "$TIMESTAMP" "$DATA_FILE" 2>/dev/null; then
    # 添加新记录（使用默认值，实际应该从 session_status 解析）
    echo "📝 添加新记录：$TIMESTAMP"
    # 这里简化处理，实际应该调用 API 获取准确数据
  else
    echo "📌 当前小时已有记录"
  fi
else
  echo "⚠️ 无法从 session_status 获取 token 数据"
fi

# 确保目标目录存在
mkdir -p "$(dirname "$TARGET_DATA")"

# 复制数据文件到 tracker
cp "$DATA_FILE" "$TARGET_DATA"
echo "✅ 数据已同步到：$TARGET_DATA"

# 进入 tracker 目录，提交并推送
cd "$TRACKER_DIR"

# 检查是否有变化
if git diff --quiet docs/data/usage.json; then
  echo "📌 数据无变化，跳过提交"
else
  # 提交并推送
  git add docs/data/usage.json
  git commit -m "📊 Auto-update token data $(date '+%Y-%m-%d %H:%M')"
  git push origin main
  echo "✅ 数据已推送到 GitHub"
fi

echo "🎉 采集完成 - $(date '+%Y-%m-%d %H:%M:%S')"
