#!/bin/bash
# Token 数据每小时自动更新
# 每小时整点执行，采集最新数据并推送到 GitHub

set -e

echo "⏰ Token 定时更新任务启动 - $(date '+%Y-%m-%d %H:%M:%S')"

TRACKER_DIR="/home/admin/.openclaw/workspace/token-tracker"
DATA_FILE="/home/admin/.openclaw/workspace/tokens-data/usage.json"
TARGET_DATA="$TRACKER_DIR/docs/data/usage.json"

# 1. 确保数据文件存在
if [ ! -f "$DATA_FILE" ]; then
  echo '{"sessions":[]}' > "$DATA_FILE"
  echo "📁 创建数据文件"
fi

# 2. 复制数据到 tracker 目录
mkdir -p "$(dirname "$TARGET_DATA")"
cp "$DATA_FILE" "$TARGET_DATA"
echo "✅ 数据已同步"

# 3. 提交并推送到 GitHub
cd "$TRACKER_DIR"

if git diff --quiet docs/data/usage.json 2>/dev/null; then
  echo "📌 数据无变化"
else
  git add docs/data/usage.json
  git commit -m "📊 Auto-update token data $(date '+%Y-%m-%d %H:%M')"
  git push origin main
  echo "✅ 已推送到 GitHub"
fi

echo "🎉 定时更新完成 - $(date '+%Y-%m-%d %H:%M:%S')"
