#!/bin/bash
# Token 定时任务健康检查
# 每小时 5 分检查上一次是否成功发送，失败则重试

set -e

TRACKER_DIR="/home/admin/.openclaw/workspace/token-tracker"
QQ_USER="7F1FE43ECAFBDC53C5B8B5CA484BE5E2"
QQBOT_DIR="/home/admin/.openclaw/qqbot/downloads"
LOG_FILE="/tmp/token-update-check.log"

echo "🔍 Token 任务健康检查 - $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"

# 获取最近 10 分钟内的图片
RECENT_IMAGE=$(find "$TRACKER_DIR/stats-images" -name "*.png" -mmin -10 -type f 2>/dev/null | sort -r | head -1)

if [ -z "$RECENT_IMAGE" ]; then
  echo "⚠️ 未找到最近 10 分钟内的图片" >> "$LOG_FILE"
  exit 0
fi

IMAGE_NAME=$(basename "$RECENT_IMAGE")
COPIED_IMAGE="$QQBOT_DIR/$IMAGE_NAME"

# 检查是否已复制并发送
if [ ! -f "$COPIED_IMAGE" ]; then
  echo "⚠️ 图片未复制到 qqbot 目录，执行发送..." >> "$LOG_FILE"
  bash "$TRACKER_DIR/send-stats-to-qq.sh" >> "$LOG_FILE" 2>&1
else
  # 检查 QQ 是否已收到（通过检查最近消息）
  # 简化处理：如果图片存在但未在 5 分钟内发送，则重发
  IMAGE_AGE=$(( ($(date +%s) - $(stat -c %Y "$COPIED_IMAGE")) / 60 ))
  
  if [ $IMAGE_AGE -gt 5 ]; then
    echo "⚠️ 图片已生成超过 5 分钟但未发送，重试..." >> "$LOG_FILE"
    bash "$TRACKER_DIR/send-stats-to-qq.sh" >> "$LOG_FILE" 2>&1
  else
    echo "✅ 图片已在 $IMAGE_AGE 分钟内发送" >> "$LOG_FILE"
  fi
fi

echo "✅ 健康检查完成" >> "$LOG_FILE"
