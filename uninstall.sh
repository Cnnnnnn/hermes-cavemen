#!/bin/bash
# hermes-cavemen Uninstall
# 用法: curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/uninstall.sh | bash

set -e

REPO="Cnnnnnn/hermes-cavemen"
RAW="https://raw.githubusercontent.com/${REPO}/main"

echo "[hermes-cavemen] Uninstalling..."

# 检测平台
if [ -n "$HERMES_CONFIG_DIR" ]; then
    SOUL_DIR="$HERMES_CONFIG_DIR"
elif [ -d "$HOME/.hermes" ]; then
    SOUL_DIR="$HOME/.hermes"
elif [ -d "$HOME/.openclaw" ]; then
    SOUL_DIR="$HOME/.openclaw"
else
    echo "[hermes-cavemen] ERROR: Cannot find Hermes or OpenClaw config directory."
    echo "[hermes-cavemen] Tried: \$HERMES_CONFIG_DIR, ~/.hermes, ~/.openclaw"
    exit 1
fi

SOUL_TARGET="${SOUL_DIR}/SOUL.md"
MEMORY_PATH="${SOUL_DIR}/memories/MEMORY.md"

if [ ! -f "$SOUL_TARGET" ]; then
    echo "[hermes-cavemen] SOUL.md not found — nothing to uninstall."
    exit 0
fi

if ! grep -q "## Terse Mode" "$SOUL_TARGET" 2>/dev/null; then
    echo "[hermes-cavemen] Terse Mode section not found in SOUL.md — nothing to uninstall."
    exit 0
fi

# 备份
cp "$SOUL_TARGET" "${SOUL_TARGET}.bak.$(date +%Y%m%d%H%M%S)"
echo "[hermes-cavemen] Backed up SOUL.md"

# 移除 Terse Mode section
python3 -c "
import re
with open('$SOUL_TARGET') as f:
    content = f.read()
# Remove Terse Mode section
pattern = r'\n## Terse Mode.*'
new_content = re.sub(pattern, '', content, flags=re.DOTALL)
with open('$SOUL_TARGET', 'w') as f:
    f.write(new_content.strip())
    f.write('\n')
"

# 清除 MEMORY.md 里的 terse_level
if [ -f "$MEMORY_PATH" ]; then
    python3 -c "
with open('$MEMORY_PATH') as f:
    lines = f.readlines()
with open('$MEMORY_PATH', 'w') as f:
    for line in lines:
        if not line.strip().startswith('terse_level:'):
            f.write(line)
"
    echo "[hermes-cavemen] Cleared terse_level from MEMORY.md"
fi

echo ""
echo "[hermes-cavemen] ✓ Uninstalled. Restart your AI session — Terse Mode is gone."
echo "[hermes-cavemen] Backup of SOUL.md remains at: ${SOUL_TARGET}.bak.*"
