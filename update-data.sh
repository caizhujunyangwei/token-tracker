#!/bin/bash
# Token 数据自动更新脚本
# 每小时运行一次，同步最新 token 使用数据到 GitHub

set -e

WORKSPACE="/home/admin/.openclaw/workspace"
TOKEN_DATA="$WORKSPACE/tokens-data/usage.json"
TRACKER_DIR="$WORKSPACE/token-tracker"
TARGET_DATA="$TRACKER_DIR/docs/data/usage.json"

echo "📊 Token 数据更新开始 - $(date '+%Y-%m-%d %H:%M:%S')"

# 检查源数据文件是否存在
if [ ! -f "$TOKEN_DATA" ]; then
  echo "❌ 源数据文件不存在：$TOKEN_DATA"
  exit 1
fi

# 确保目标目录存在
mkdir -p "$(dirname "$TARGET_DATA")"

# 复制数据文件
cp "$TOKEN_DATA" "$TARGET_DATA"
echo "✅ 数据已复制到：$TARGET_DATA"

# 进入 tracker 目录
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

echo "🎉 更新完成 - $(date '+%Y-%m-%d %H:%M:%S')"
