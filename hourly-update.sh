#!/bin/bash
# Token 数据每小时自动更新 + 发送统计图片到 QQ
# 每小时整点执行

set -e

echo "⏰ Token 定时更新任务启动 - $(date '+%Y-%m-%d %H:%M:%S')"

TRACKER_DIR="/home/admin/.openclaw/workspace/token-tracker"
DATA_FILE="/home/admin/.openclaw/workspace/tokens-data/usage.json"
TARGET_DATA="$TRACKER_DIR/docs/data/usage.json"
QQ_USER="7F1FE43ECAFBDC53C5B8B5CA484BE5E2"

# 1. 确保数据文件存在
if [ ! -f "$DATA_FILE" ]; then
  echo '{"sessions":[]}' > "$DATA_FILE"
fi

# 2. 复制数据到 tracker 目录
mkdir -p "$(dirname "$TARGET_DATA")"
cp "$DATA_FILE" "$TARGET_DATA"
echo "✅ 数据已同步"

# 3. 提交并推送到 GitHub
cd "$TRACKER_DIR"

HAS_CHANGES=false
if ! git diff --quiet docs/data/usage.json 2>/dev/null; then
  git add docs/data/usage.json
  git commit -m "📊 Auto-update token data $(date '+%Y-%m-%d %H:%M')"
  git push origin main
  HAS_CHANGES=true
  echo "✅ 已推送到 GitHub"
else
  echo "📌 数据无变化"
fi

# 4. 生成统计图片（每次都生成，便于查看最新数据）
echo "📸 生成统计图片..."
node "$TRACKER_DIR/stats-image-generator.js"

# 5. 获取最新图片
LATEST_IMAGE=$(ls -t "$TRACKER_DIR/stats-images"/*.png 2>/dev/null | head -1)

if [ -n "$LATEST_IMAGE" ] && [ -f "$LATEST_IMAGE" ]; then
  echo "📷 图片已生成：$LATEST_IMAGE"
  
  # 标记有待发送的图片（由主进程处理发送）
  echo "$LATEST_IMAGE" > /tmp/pending-token-stats-image.txt
  echo "$QQ_USER" >> /tmp/pending-token-stats-image.txt
  echo "$(date '+%Y-%m-%d %H:%M')" >> /tmp/pending-token-stats-image.txt
  
  echo "✅ 图片待发送标记已创建"
fi

# 5. 触发发送图片到 QQ
echo "📨 准备发送图片到 QQ..."
bash "$TRACKER_DIR/send-stats-to-qq.sh"

echo "🎉 定时更新完成 - $(date '+%Y-%m-%d %H:%M:%S')"
