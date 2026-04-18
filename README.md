# Hermite Caveman

> 🪨 why use many token when few token do trick

A Hermes Agent / OpenClaw adaptation of [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman). Reduces output tokens ~75% while preserving full technical accuracy.

---

## Before / After

| Normal (87 tokens) | Terse — full (24 tokens) |
|--------------------|-------------------------|
| "当然！我很高兴帮你解决这个问题。你遇到的问题很可能是由于认证中间件没有正确验证 token 过期时间导致的。让我看一下并建议一个修复方案。" | "认证中间件 bug。Token 过期检查用了 < 而不是 <=。修：" |

**Same fix. 75% less words. Brain still big.**

---

## Installation

### Option A — Merge into existing SOUL.md (recommended)

Copy the `## Terse Mode` section from [`SOUL.md`](SOUL.md) and append it to your existing `SOUL.md`. Your existing content stays intact.

### Option B — Full replacement

Replace your `SOUL.md` entirely with [`SOUL.md`](SOUL.md) from this repo.

> ⚠️ This overwrites all existing content. Back up first.

---

## Intensity Levels

| Level | Style | Example |
|-------|-------|---------|
| `lite` | Drop filler/hedging only. Full sentences, articles kept. | "Your component re-renders because you create a new object reference each render. Wrap in useMemo." |
| `full` | Classic caveman. Fragments OK, articles dropped. **← Default** | "New object ref each render. Inline object prop = new ref = re-render. useMemo." |
| `ultra` | Max compression. Abbreviations + `→` for causality. | "Inline obj prop → new ref → re-render. `useMemo`." |
| `wenyan` | 文言文. Classical Chinese terseness. | "物出新參照，致重繪。useMemo Wrap之。" |

**Switch:** `/terse lite|full|ultra|wenyan`
**Exit:** `normal mode` / `正常模式`

---

## Auto-Clarity

Terse pauses automatically for:
- Security warnings and irreversible action confirmations
- Destructive operations (DELETE / DROP / truncate)
- User asks for detail: `解释一下` / `详细点` / `展开`
- Multi-step sequences where fragment order risks misread

Resumes after the clear part is done.

---

## Level Persistence

Each `/terse xxx` command writes the preference to `MEMORY.md`. On every new session, Hermite reads `MEMORY.md` for `terse_level` and applies it automatically. No need to re-set after restart.

---

## Implementation: Original vs Hermite

| Dimension | Original caveman | Hermite Caveman |
|-----------|-----------------|-----------------|
| Target platform | Claude Code | Hermes / OpenClaw |
| Activation | Hook system + flag file | SOUL.md rules injection |
| Persistence | `~/.claude/.caveman-active` flag file | `MEMORY.md` |
| Multi-platform sync | CI auto-syncs to 8+ platforms | Single platform, no sync needed |
| Statusline badge | `[CAVEMAN]` in Claude Code UI | Not available |
| Wenyan sub-levels | lite / full / ultra | lite / full / ultra |

**Why the differences?** Hermes / OpenClaw does not expose Claude Code's Hook API, flag file mechanism, statusline, or plugin installation system. Hermite Caveman achieves equivalent behavior through SOUL.md rules injection, which Hermes reads on every session start.

**What is identical:** Core compression rules, intensity levels, auto-clarity conditions, code/commit/PR boundaries, activation/deactivation commands, and ~75% token reduction.

---

## Project Structure

```
hermite-caveman/
├── README.md       ← This file
├── SOUL.md         ← Complete Terse Mode rules
├── SKILL.md        ← Skill format (optional)
└── LICENSE         ← MIT
```

---

Credit: Based on [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) (37.6k stars, MIT License).
