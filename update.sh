#!/bin/bash
# hermes-cavemen Self-Update
# 用法: curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/update.sh | bash

set -e

REPO="Cnnnnnn/hermes-cavemen"
RAW="https://raw.githubusercontent.com/${REPO}/main"

echo "[hermes-cavemen] Checking for updates..."

# 获取远程 VERSION
REMOTE_VERSION=$(curl -s "${RAW}/VERSION" | head -1 | tr -d '[:space:]')
LOCAL_VERSION=""

# 查找本地 SOUL.md 中的版本标注（如果有）
if [ -f "$HOME/.hermes/SOUL.md" ] && grep -q "hermes-cavemen" "$HOME/.hermes/SOUL.md"; then
    LOCAL_VERSION=$(grep "^## Terse Mode" -A 5 "$HOME/.hermes/SOUL.md" 2>/dev/null | grep -oP 'v?\d+\.\d+\.\d+' | head -1 || echo "unknown")
elif [ -f "$HOME/.openclaw/SOUL.md" ] && grep -q "hermes-cavemen" "$HOME/.openclaw/SOUL.md"; then
    LOCAL_VERSION=$(grep "^## Terse Mode" -A 5 "$HOME/.openclaw/SOUL.md" 2>/dev/null | grep -oP 'v?\d+\.\d+\.\d+' | head -1 || echo "unknown")
fi

echo "[hermes-cavemen] Local version: ${LOCAL_VERSION:-none}"
echo "[hermes-cavemen] Remote version: ${REMOTE_VERSION}"

if [ "${LOCAL_VERSION:-none}" = "${REMOTE_VERSION}" ]; then
    echo "[hermes-cavemen] Already up to date ✓"
    exit 0
fi

echo "[hermes-cavemen] Update available: ${LOCAL_VERSION:-none} → ${REMOTE_VERSION}"
echo "[hermes-cavemen] Downloading latest SOUL.md..."

# 下载新版本
curl -s "${RAW}/SOUL.md" -o /tmp/SOUL_md_update_new

# 检测平台
if [ -n "$HERMES_CONFIG_DIR" ]; then
    SOUL_DIR="$HERMES_CONFIG_DIR"
elif [ -d "$HOME/.hermes" ]; then
    SOUL_DIR="$HOME/.hermes"
elif [ -d "$HOME/.openclaw" ]; then
    SOUL_DIR="$HOME/.openclaw"
else
    SOUL_DIR="$HOME/.hermes"
fi

SOUL_TARGET="${SOUL_DIR}/SOUL.md"

# 备份
if [ -f "$SOUL_TARGET" ]; then
    cp "$SOUL_TARGET" "${SOUL_TARGET}.bak.$(date +%Y%m%d%H%M%S)"
    echo "[hermes-cavemen] Backed up current SOUL.md"
fi

# 替换 Terse Mode section
if [ -f "$SOUL_TARGET" ]; then
    # 删除旧的 Terse Mode section
    python3 -c "
import sys, re
with open('$SOUL_TARGET') as f:
    content = f.read()
# Remove everything from '## Terse Mode' to end, or just the section if it's standalone
pattern = r'\n## Terse Mode.*'
content = re.sub(pattern, '', content, flags=re.DOTALL)
with open('$SOUL_TARGET', 'w') as f:
    f.write(content.strip())
    f.write('\n')
"
    # 追加新版本
    cat /tmp/SOUL_md_update_new >> "$SOUL_TARGET"
    echo "[hermes-cavemen] Updated SOUL.md"
else
    cp /tmp/SOUL_md_update_new "$SOUL_TARGET"
    echo "[hermes-cavemen] Created new SOUL.md"
fi

# 更新 install.sh 如果存在
if [ -f "${SOUL_DIR}/install.sh" ]; then
    curl -s "${RAW}/install.sh" -o "${SOUL_DIR}/install.sh"
    echo "[hermes-cavemen] Updated install.sh"
fi

echo ""
echo "[hermes-cavemen] ✓ Updated to v${REMOTE_VERSION}. Restart your AI session to apply."
