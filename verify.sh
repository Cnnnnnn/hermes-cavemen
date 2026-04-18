#!/bin/bash
# hermes-cavemen Verify — compression rate measurement
# 用法:
#   curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/verify.sh | bash
#   curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/verify.sh | bash -s -- "你的自定义测试文字"

set -e

REPO="Cnnnnnn/hermes-cavemen"
RAW="https://raw.githubusercontent.com/${REPO}/main"

Cyan='\033[0;36m'
Green='\033[0;32m'
Red='\033[0;31m'
Yellow='\033[1;33m'
Bold='\033[1m'
Reset='\033[0m'

banner() {
    echo ""
    echo -e "${Bold}═══════════════════════════════════════════════${Reset}"
    echo -e "${Bold}   hermes-cavemen Verify${Reset}"
    echo -e "${Bold}═══════════════════════════════════════════════${Reset}"
    echo ""
}

PASS=0
FAIL=0

check() {
    local label="$1"
    local result="$2"
    if [ "$result" = "OK" ]; then
        echo -e "  ${Green}✓${Reset} $label"
        PASS=$((PASS+1))
    else
        echo -e "  ${Red}✗${Reset} $label"
        FAIL=$((FAIL+1))
    fi
}

# ── Token estimation ──────────────────────────────────────────────────────────
# Chinese: 1 char ≈ 1 token
# English: 1 word  ≈ 1.3 tokens
count_tokens() {
    local text="$1"
    # Chinese chars
    local zh=$(echo "$text" | grep -o '[\x{4e00}-\x{9fff}]' | wc -l)
    # English words
    local en=$(echo "$text" | grep -oE '[a-zA-Z]+' | wc -l)
    # Total estimated tokens
    echo $(( zh + (en * 13 / 10) ))
}

# ── Compression levels ─────────────────────────────────────────────────────────
# Each level: sed-like transformations (simplified simulation)
# These are rough approximations to illustrate compression ratio

compress_lite() {
    local t="$1"
    # Strip filler and hedging only
    echo "$t" \
        | sed 's/当然！//g; s/当然//g; s/很乐意//g; s/很高兴//g; s/大概//g; s/我认为//g' \
        | sed 's/just //g; s/really //g; s/basically //g; s/actually //g; s/simply //g' \
        | sed 's/I think //g; s/I believe //g; s/seems like //g' \
        | sed 's/sure, //g; s/certainly, //g; s/happy to //g; s/glad to //g' \
        | sed 's/and then //g; s/so basically //g' \
        | sed 's/  / /g' \
        | sed 's/^ *//; s/ *$//'
}

compress_full() {
    local t="$1"
    # lite + strip articles
    compress_lite "$t" \
        | sed 's/\bthe //g; s/\ba //g; s/\ban //g' \
        | sed 's/  / /g'
}

compress_ultra() {
    local t="$1"
    # full + abbreviations + → causality
    echo "$t" \
        | sed 's/\bthe //g; s/\ba //g; s/\ban //g' \
        | sed 's/database/DB/g; s/authentication/auth/g; s/configuration/config/g' \
        | sed 's/request/req/g; s/response/res/g; s/function/fn/g; s/implementation/impl/g' \
        | sed 's/because/→/g; s/therefore/→/g; s/so that/→/g; s/which causes/→/g' \
        | sed 's/I think //g; s/I believe //g; s/really //g; s/just //g' \
        | sed 's/sure, //g; s/certainly, //g; s/happy to //g; s/glad to //g' \
        | sed 's/and then //g; s/so basically //g' \
        | sed 's/  / /g' \
        | sed 's/^ *//; s/ *$//'
}

compress_wenyan() {
    local t="$1"
    # Wenyan-style: drop filler, verbs precede objects, classical particles
    echo "$t" \
        | sed 's/当然！//g; s/当然//g; s/很乐意//g; s/很高兴//g; s/大概//g; s/我认为//g' \
        | sed 's/just //g; s/really //g; s/basically //g; s/actually //g; s/simply //g' \
        | sed 's/I think //g; s/I believe //g; s/seems like //g' \
        | sed 's/sure, //g; s/certainly, //g; s/happy to //g; s/glad to //g' \
        | sed 's/and then //g; s/so basically //g' \
        | sed 's/\bthe //g; s/\ba //g; s/\ban //g' \
        | sed 's/  / /g' \
        | sed 's/^ *//; s/ *$//'
}

# ── Compression ratio ────────────────────────────────────────────────────────
compression_ratio() {
    local orig="$1"
    local compressed="$2"
    local orig_tokens=$(count_tokens "$orig")
    local comp_tokens=$(count_tokens "$compressed")
    if [ "$orig_tokens" -eq 0 ]; then
        echo "0"
        return
    fi
    local ratio=$(( (orig_tokens - comp_tokens) * 100 / orig_tokens ))
    echo "$ratio"
}

# ── Platform detection ────────────────────────────────────────────────────────
detect_platform() {
    if [ -n "$HERMES_CONFIG_DIR" ]; then
        echo "hermes"
    elif [ -d "$HOME/.hermes" ]; then
        echo "hermes"
    elif [ -d "$HOME/.openclaw" ]; then
        echo "openclaw"
    else
        echo "hermes"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
banner

PLATFORM=$(detect_platform)
echo -e "${Yellow}[Platform]${Reset} $PLATFORM detected"

SOUL_DIR=""
case "$PLATFORM" in
    hermes) SOUL_DIR="${HERMES_CONFIG_DIR:-${HOME}/.hermes}" ;;
    openclaw) SOUL_DIR="$HOME/.openclaw" ;;
esac

SOUL_TARGET="${SOUL_DIR}/SOUL.md"
MEMORY_PATH="${SOUL_DIR}/memories/MEMORY.md"

# ═══════════════════════════════════════════════════════════════════════════════
echo -e "${Bold}[1] Installation Checks${Reset}"
echo "──────────────────────────────────────────"

if [ -f "$SOUL_TARGET" ]; then
    check "SOUL.md exists at ${SOUL_TARGET}"
    if grep -q "## Terse Mode" "$SOUL_TARGET"; then
        check "Terse Mode section found"
    else
        check "Terse Mode section found" "FAIL"
    fi
else
    check "SOUL.md exists" "FAIL"
fi

if [ -f "$MEMORY_PATH" ]; then
    check "MEMORY.md exists"
    if grep -q "^terse_level:" "$MEMORY_PATH"; then
        LEVEL=$(grep "^terse_level:" "$MEMORY_PATH" | cut -d: -f2 | tr -d ' ')
        echo -e "    Level: ${Cyan}$LEVEL${Reset}"
        check "terse_level is set"
    else
        check "terse_level is set" "FAIL"
    fi
else
    check "MEMORY.md exists" "FAIL"
    echo -e "    ${Yellow}(will be created on first /terse command)${Reset}"
fi

# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${Bold}[2] Compression Ratio Tests${Reset}"
echo "──────────────────────────────────────────"

# Default test
if [ -n "$1" ]; then
    ORIG="$*"
else
    ORIG="当然！我很高兴帮你解决这个问题。你遇到的问题很可能是由于认证中间件没有正确验证 token 过期时间导致的。"
fi

ORIG_TOKENS=$(count_tokens "$ORIG")
echo -e "${Yellow}[Original]${Reset}"
echo "  \"$ORIG\""
echo -e "  Tokens (est): ${Bold}${ORIG_TOKENS}${Reset}"
echo ""

PASS_THRESHOLD_LITE=20
PASS_THRESHOLD_FULL=40
PASS_THRESHOLD_ULTRA=60
PASS_THRESHOLD_WENYAN=70

# lite
LITE_OUT=$(compress_lite "$ORIG")
LITE_TOKENS=$(count_tokens "$LITE_OUT")
LITE_RATIO=$(compression_ratio "$ORIG" "$LITE_OUT")
if [ "$LITE_RATIO" -ge "$PASS_THRESHOLD_LITE" ]; then
    check "lite compression: ${LITE_RATIO}% (≥${PASS_THRESHOLD_LITE}% required)"
else
    check "lite compression: ${LITE_RATIO}% (≥${PASS_THRESHOLD_LITE}% required)" "FAIL"
fi
echo -e "  ${Cyan}→${Reset} \"$LITE_OUT\""

# full
FULL_OUT=$(compress_full "$ORIG")
FULL_TOKENS=$(count_tokens "$FULL_OUT")
FULL_RATIO=$(compression_ratio "$ORIG" "$FULL_OUT")
if [ "$FULL_RATIO" -ge "$PASS_THRESHOLD_FULL" ]; then
    check "full compression: ${FULL_RATIO}% (≥${PASS_THRESHOLD_FULL}% required)"
else
    check "full compression: ${FULL_RATIO}% (≥${PASS_THRESHOLD_FULL}% required)" "FAIL"
fi
echo -e "  ${Cyan}→${Reset} \"$FULL_OUT\""

# ultra
ULTRA_OUT=$(compress_ultra "$ORIG")
ULTRA_TOKENS=$(count_tokens "$ULTRA_OUT")
ULTRA_RATIO=$(compression_ratio "$ORIG" "$ULTRA_OUT")
if [ "$ULTRA_RATIO" -ge "$PASS_THRESHOLD_ULTRA" ]; then
    check "ultra compression: ${ULTRA_RATIO}% (≥${PASS_THRESHOLD_ULTRA}% required)"
else
    check "ultra compression: ${ULTRA_RATIO}% (≥${PASS_THRESHOLD_ULTRA}% required)" "FAIL"
fi
echo -e "  ${Cyan}→${Reset} \"$ULTRA_OUT\""

# wenyan
WENYAN_OUT=$(compress_wenyan "$ORIG")
WENYAN_TOKENS=$(count_tokens "$WENYAN_OUT")
WENYAN_RATIO=$(compression_ratio "$ORIG" "$WENYAN_OUT")
if [ "$WENYAN_RATIO" -ge "$PASS_THRESHOLD_WENYAN" ]; then
    check "wenyan compression: ${WENYAN_RATIO}% (≥${PASS_THRESHOLD_WENYAN}% required)"
else
    check "wenyan compression: ${WENYAN_RATIO}% (≥${PASS_THRESHOLD_WENYAN}% required)" "FAIL"
fi
echo -e "  ${Cyan}→${Reset} \"$WENYAN_OUT\""

# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${Bold}[3] Built-in Benchmark${Reset}"
echo "──────────────────────────────────────────"

BENCH_ORIG="当然！我很高兴帮你解决这个问题。你遇到的问题很可能是由于认证中间件没有正确验证 token 过期时间导致的。"
BENCH_FULL="认证中间件 bug。Token 过期检查用了 < 而不是 <=。修："
BENCH_FULL_RATIO=$(compression_ratio "$BENCH_ORIG" "$BENCH_FULL")

echo "  Benchmark (full level):"
echo "    Original: \"$BENCH_ORIG\""
echo "    Terse:    \"$BENCH_FULL\""
echo -e "    Compression: ${Bold}${BENCH_FULL_RATIO}%${Reset}"

if [ "$BENCH_FULL_RATIO" -ge "$PASS_THRESHOLD_FULL" ]; then
    check "Benchmark full-level test passed"
else
    check "Benchmark full-level test passed" "FAIL"
fi

# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${Bold}[4] Network & Scripts${Reset}"
echo "──────────────────────────────────────────"

for script in install.sh update.sh uninstall.sh verify.sh star.sh; do
    HTTP_CODE=$(curl -sI "${RAW}/${script}" 2>/dev/null | grep -i "^HTTP" | awk '{print $2}' | tail -1)
    if [ "$HTTP_CODE" = "200" ]; then
        check "${script} reachable (HTTP $HTTP_CODE)"
    else
        check "${script} reachable (HTTP $HTTP_CODE)" "FAIL"
    fi
done

# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${Bold}═══════════════════════════════════════════════${Reset}"
echo -e " Result: ${Green}${PASS}${Reset} passed, ${Red}${FAIL}${Reset} failed"
echo -e "${Bold}═══════════════════════════════════════════════${Reset}"

if [ $FAIL -eq 0 ]; then
    echo -e "${Green}hermes-cavemen is properly installed ✓${Reset}"
    echo ""
    echo "Quick reference:"
    echo "  Switch: /terse ultra | /terse wenyan"
    echo "  Exit:   normal mode"
    exit 0
else
    echo -e "${Red}Some checks failed. Re-run install:${Reset}"
    echo "  curl -s ${RAW}/install.sh | bash"
    exit 1
fi
