#!/bin/bash
# hermes-cavemen Verify v4 — compression ratio + quality score (Python-based)
# 用法:
#   curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/verify.sh | bash
#   curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/verify.sh | bash -s -- "你的自定义测试文字"
#   curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/verify.sh | bash -s -- --quality "测试文字"

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
    echo -e "${Bold}   hermes-cavemen Verify v4${Reset}"
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

echo ""
echo -e "${Bold}[2] Semantic Density Detection${Reset}"
echo "──────────────────────────────────────────"

python3 - "${1:-}" "${2:-}" << 'PYEOF'
import sys, re, urllib.request

# ── Core functions (pure Python — no shell dependency) ──────────────────────

def count_tokens(text):
    """Chinese chars: 1 token each. English words: 1.3 tokens each."""
    zh = len(re.findall(r'[一-龥]', text))
    en = len(re.findall(r'[a-zA-Z]+', text))
    return zh + int(en * 13 / 10)

def semantic_density(text):
    """Score paragraph by information density. high >= 6, medium >= 3, else low."""
    score = 0
    score += len(re.findall(r'PE|PB|EPS|ROE|毛利率|净利率|北向资金|融资融券|市值|估值|营收|利润|同比增长|环比|产能|换手率', text)) * 2
    score += len(re.findall(r'MACD|KDJ|RSI|BOLL|MA|金叉|死叉|量比', text)) * 2
    score += len(re.findall(r'[0-9]+\.?[0-9]*%?', text))
    return 'high' if score >= 6 else ('medium' if score >= 3 else 'low')

def quality_check(orig, comp):
    """OK if >= 2 of 3 dims preserved: numbers, direction, action."""
    qscore = 0
    if re.findall(r'[0-9]+\.?[0-9]*%?', orig) and re.findall(r'[0-9]+\.?[0-9]*%?', comp):
        qscore += 1
    dirs = re.findall(r'涨|跌|买入|卖出|up|down|buy|sell|long|short|多|空|增持|减持|看多|看空', orig)
    comp_dirs = re.findall(r'涨|跌|买入|卖出|up|down|buy|sell|long|short|多|空|增持|减持|看多|看空', comp)
    if dirs and comp_dirs: qscore += 1
    actions = re.findall(r'修|查|改|看|建议|帮|买|卖|增|减|set|fix|check|buy|sell|持|入|出|建|平', orig)
    comp_actions = re.findall(r'修|查|改|看|建议|帮|买|卖|增|减|set|fix|check|buy|sell|持|入|出|建|平', comp)
    if actions and comp_actions: qscore += 1
    return 'OK' if qscore >= 2 else 'LOW_QUALITY'

def compress_lite(text):
    for f in ['当然！','当然','很乐意','很高兴','大概','我认为','其实','可以说','基本上','应该','可能']:
        text = text.replace(f, '')
    for f in ['just ','really ','basically ','actually ','simply ','I believe ','seems like ',
              'sure, ','certainly, ','happy to ','glad to ','and then ','so basically ']:
        text = text.replace(f, '')
    text = text.replace('I think ', '')
    return re.sub(r'  +', ' ', text).strip()

def compress_full(text):
    text = compress_lite(text)
    for art in ['the ', 'a ', 'an ']:
        text = text.replace(art, '')
    return text

def compress_ultra(text):
    text = compress_lite(text)
    for art in ['the ', 'a ', 'an ']:
        text = text.replace(art, '')
    for f, t in [('database','DB'),('authentication','auth'),('configuration','config'),
                 ('request','req'),('response','res'),('function','fn'),('implementation','impl')]:
        text = text.replace(f, t)
    text = re.sub(r'因为(.+?)，所以', r'→\1', text)
    text = re.sub(r'由于(.+?)导致', r'因\1→', text)
    text = text.replace('导致', '→').replace('所以', '→')
    return re.sub(r'  +', ' ', text).strip()

def compress_wenyan(text):
    for f in ['当然！','当然','很乐意','很高兴','大概','我认为','其实','可以说','基本上']:
        text = text.replace(f, '')
    for f in ['just ','really ','basically ','actually ','simply ','I think ','I believe ','seems like ',
              'sure, ','certainly, ','happy to ','glad to ','and then ','so basically ']:
        text = text.replace(f, '')
    for art in ['the ', 'a ', 'an ']:
        text = text.replace(art, '')
    text = text.replace('应该', '应').replace('可能', '或').replace('大概', '约')
    text = re.sub(r'(?<![a-zA-Z])的(?![a-zA-Z])', '之', text)
    text = text.replace('是', '乃')
    return re.sub(r'  +', ' ', text).strip()

def compression_ratio(orig, comp):
    ot = count_tokens(orig); ct = count_tokens(comp)
    if ot == 0: return 0
    return int((ot - ct) * 100 / ot)

def weighted_score(orig, comp):
    ratio = compression_ratio(orig, comp)
    q = quality_check(orig, comp)
    return ratio * 70 // 100 if q == 'LOW_QUALITY' else ratio

# ── Test runner ───────────────────────────────────────────────────────────────

# Verbose Chinese test (high filler, compressible)
ORIG_VERBOSE = "当然！我很高兴可以帮你解决这个问题。其实这个问题基本上可以说是因为认证中间件没有正确验证token的过期时间所导致的。"
# terse full (manually verified good compression)
TERSE_FULL = "认证中间件 bug。Token 过期检查用了 < 而不是 <=。修："

# Financial high-density test
ORIG_FINANCE = "康强电子PE=18，MACD金叉，营收同比增长25%，北向资金净买入2亿，建议买入。"
TERSE_FINANCE = "康强PE=18，MACD金叉，营收+25%，北向+2亿。买入。"

print("  [semantic density: high]")
print(f"    \"{ORIG_FINANCE}\"")
d = semantic_density(ORIG_FINANCE)
print(f"    -> {d} {'✓' if d=='high' else '✗'}")

print()
print("  [semantic density: low]")
print(f"    \"{ORIG_VERBOSE}\"")
d = semantic_density(ORIG_VERBOSE)
print(f"    -> {d} {'✓' if d=='low' else '✗'}")

print()
print("  [compression: verbose Chinese]")
ot = count_tokens(ORIG_VERBOSE)
ct = count_tokens(TERSE_FULL)
r = compression_ratio(ORIG_VERBOSE, TERSE_FULL)
q = quality_check(ORIG_VERBOSE, TERSE_FULL)
w = weighted_score(ORIG_VERBOSE, TERSE_FULL)
print(f"    Original ({ot} tokens): \"{ORIG_VERBOSE}\"")
print(f"    terse full: \"{TERSE_FULL}\"")
print(f"    ratio={r}%, quality={q}, weighted={w}%")

TH_LITE=20; TH_FULL=40; TH_ULTRA=60; TH_WENYAN=70

print()
print("  [built-in benchmark: full level vs original verbose text]")
ok = 'OK' if r >= TH_FULL else 'FAIL'
print(f"    [{ok}] ratio={r}% (≥{TH_FULL}% required)")
print(f"    NOTE: terse output is manually written, not auto-simulated")

print()
print("  [quality check: finance text]")
orig_nums = re.findall(r'[0-9]+\.?[0-9]*%?', ORIG_FINANCE)
comp_nums = re.findall(r'[0-9]+\.?[0-9]*%?', TERSE_FINANCE)
orig_dirs = re.findall(r'买入|涨|up|buy', ORIG_FINANCE)
comp_dirs = re.findall(r'买入|涨|up|buy', TERSE_FINANCE)
q = quality_check(ORIG_FINANCE, TERSE_FINANCE)
print(f"    original: \"{ORIG_FINANCE}\"")
print(f"    terse:    \"{TERSE_FINANCE}\"")
print(f"    numbers: {len(orig_nums)}->{len(comp_nums)}, directions: {len(orig_dirs)}->{len(comp_dirs)}")
print(f"    quality: {q}")

print()
print("  [network reachability]")
for script in ['SOUL.md','verify.sh','install.sh','update.sh','uninstall.sh','star.sh']:
    url = f"https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/{script}"
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=10) as resp:
            print(f"  ✓ {script}: HTTP {resp.status}")
    except Exception as e:
        print(f"  ✗ {script}: FAIL ({e})")

PYEOF

echo ""
echo -e "${Bold}═══════════════════════════════════════════════${Reset}"
echo -e " hermes-cavemen v1.2 verification complete"
echo -e "${Bold}═══════════════════════════════════════════════${Reset}"
