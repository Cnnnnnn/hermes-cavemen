#!/bin/bash
# hermes-cavemen Verify — test if Terse Mode is actually working
# 用法: curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/verify.sh | bash

set -e

REPO="Cnnnnnn/hermes-cavemen"
RAW="https://raw.githubusercontent.com/${REPO}/main"

echo "========================================"
echo " hermes-cavemen Verify"
echo "========================================"

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
MEMORY_PATH="${SOUL_DIR}/memories/MEMORY.md"
PASS=0
FAIL=0

check() {
    local label="$1"
    local result="$2"
    if [ "$result" = "OK" ]; then
        echo "  ✓ $label"
        PASS=$((PASS+1))
    else
        echo "  ✗ $label"
        FAIL=$((FAIL+1))
    fi
}

echo ""
echo "[1] Checking SOUL.md..."

if [ -f "$SOUL_TARGET" ]; then
    check "SOUL.md exists at ${SOUL_TARGET}"
    if grep -q "## Terse Mode" "$SOUL_TARGET"; then
        check "Terse Mode section found in SOUL.md"
    else
        check "Terse Mode section found in SOUL.md" "FAIL"
    fi
else
    check "SOUL.md exists at ${SOUL_TARGET}" "FAIL"
fi

echo ""
echo "[2] Checking MEMORY.md..."

if [ -f "$MEMORY_PATH" ]; then
    check "MEMORY.md exists at ${MEMORY_PATH}"
    if grep -q "^terse_level:" "$MEMORY_PATH"; then
        LEVEL=$(grep "^terse_level:" "$MEMORY_PATH" | cut -d: -f2 | tr -d ' ')
        check "terse_level is set: $LEVEL"
    else
        check "terse_level is set" "FAIL"
    fi
else
    check "MEMORY.md exists at ${MEMORY_PATH}" "FAIL"
    echo "  (MEMORY.md will be created on first /terse command)"
fi

echo ""
echo "[3] Checking install.sh..."

if curl -sI "${RAW}/install.sh" | grep -q "200"; then
    check "install.sh is reachable on GitHub"
else
    check "install.sh is reachable on GitHub" "FAIL"
fi

echo ""
echo "[4] Simulated Terse output test"
echo "----------------------------------------"
echo " Normal output:"
NORMAL="当然！我很高兴帮你解决这个问题。你遇到的问题很可能是由于认证中间件没有正确验证 token 过期时间导致的。让我看一下并建议一个修复方案。"
echo "  \"$NORMAL\""
echo "  Token count: ${#NORMAL}"

echo ""
echo " Expected Terse output (full level):"
TERSE="认证中间件 bug。Token 过期检查用了 < 而不是 <=。修："
echo "  \"$TERSE\""
echo "  Token count: ${#TERSE}"

SAVED=$(( ${#NORMAL} - ${#TERSE} ))
RATIO=$(awk "BEGIN {printf \"%.0f\", (${#NORMAL}-${#TERSE})*100/${#NORMAL}}")
echo ""
echo "  → $SAVED chars saved ($RATIO% reduction)"

echo ""
echo "========================================"
echo " Result: $PASS passed, $FAIL failed"
if [ $FAIL -eq 0 ]; then
    echo " hermes-cavemen is properly installed ✓"
    echo "========================================"
    exit 0
else
    echo " Some checks failed — run install.sh to fix"
    echo "========================================"
    echo " curl -s ${RAW}/install.sh | bash"
    exit 1
fi
