#!/bin/bash
# Token 统计图片自动发送到 QQ
# 每小时整点后 1 分钟执行

set -e

TRACKER_DIR="/home/admin/.openclaw/workspace/token-tracker"
QQ_USER="7F1FE43ECAFBDC53C5B8B5CA484BE5E2"

echo "📊 Token 统计图片发送任务 - $(date '+%Y-%m-%d %H:%M:%S')"

# 获取最新生成的图片
LATEST_IMAGE=$(ls -t "$TRACKER_DIR/stats-images"/*.png 2>/dev/null | head -1)

if [ -z "$LATEST_IMAGE" ] || [ ! -f "$LATEST_IMAGE" ]; then
  echo "❌ 未找到图片"
  exit 1
fi

echo "📷 找到图片：$LATEST_IMAGE"

# 复制图片到 qqbot downloads 目录（确保 qqbot 可以访问）
QQBOT_DIR="/home/admin/.openclaw/qqbot/downloads"
mkdir -p "$QQBOT_DIR"
cp "$LATEST_IMAGE" "$QQBOT_DIR/"
IMAGE_NAME=$(basename "$LATEST_IMAGE")
COPIED_IMAGE="$QQBOT_DIR/$IMAGE_NAME"

echo "✅ 图片已复制到：$COPIED_IMAGE"

# 创建发送任务标记文件
echo "$COPIED_IMAGE" > /tmp/qqbot-send-image.txt
echo "$QQ_USER" >> /tmp/qqbot-send-image.txt
echo "$(date '+%Y-%m-%d %H:%M:%S')" >> /tmp/qqbot-send-image.txt

echo "✅ 发送标记已创建，等待 qqbot 处理..."
