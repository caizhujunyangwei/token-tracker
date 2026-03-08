#!/bin/bash
# Token 统计图片自动发送到 QQ
# 每小时整点后执行，直接发送图片

set -e

TRACKER_DIR="/home/admin/.openclaw/workspace/token-tracker"
QQ_USER="7F1FE43ECAFBDC53C5B8B5CA484BE5E2"
QQBOT_DIR="/home/admin/.openclaw/qqbot/downloads"

echo "📊 Token 统计图片发送任务 - $(date '+%Y-%m-%d %H:%M:%S')"

# 获取最新生成的图片
LATEST_IMAGE=$(ls -t "$TRACKER_DIR/stats-images"/*.png 2>/dev/null | head -1)

if [ -z "$LATEST_IMAGE" ] || [ ! -f "$LATEST_IMAGE" ]; then
  echo "❌ 未找到图片"
  exit 1
fi

echo "📷 找到图片：$LATEST_IMAGE"

# 复制图片到 qqbot downloads 目录
mkdir -p "$QQBOT_DIR"
cp "$LATEST_IMAGE" "$QQBOT_DIR/"
IMAGE_NAME=$(basename "$LATEST_IMAGE")
COPIED_IMAGE="$QQBOT_DIR/$IMAGE_NAME"

echo "✅ 图片已复制到：$COPIED_IMAGE"

# 直接调用 openclaw message 发送
echo "📨 发送图片到 QQ..."
openclaw message send \
  --channel qqbot \
  --target "$QQ_USER" \
  --message "📊 Token 使用统计已更新！\n\n⏰ 更新时间：$(date '+%Y-%m-%d %H:%M')\n📈 数据已同步到 GitHub Pages\n🌐 https://caizhujunyangwei.github.io/token-tracker/" \
  --media "$COPIED_IMAGE"

if [ $? -eq 0 ]; then
  echo "✅ 图片发送成功！"
else
  echo "❌ 图片发送失败！"
  exit 1
fi
