# Hermite Cavemen

[English](#english) | [中文](#中文)

---

## ⚡ Quick Start

**One line to install:**

```bash
# Option A: curl into SOUL.md (recommended)
curl -s https://raw.githubusercontent.com/Cnnnnnn/Hermes-cavemen/main/SOUL.md >> ~/.hermes/SOUL.md

# Option B: clone the repo
git clone https://github.com/Cnnnnnn/Hermes-cavemen.git ~/Hermes-cavemen
```

That's it. Terse Mode (`full`) activates automatically on every new session. No restart needed.

**Verify:**
```
/sklls_list | grep terse
```
Should show `terse — Hermite Caveman` in the list.

**Switch levels:**
```
/terse ultra     # max compression
/terse wenyan    # 文言文
/normal mode     # exit
```

---

# English

## What is this

A Hermes Agent / OpenClaw adaptation of [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman). Reduces output tokens ~75% while preserving full technical accuracy.

**Terse Mode is ON by default.** No plugin install needed — just copy rules into `SOUL.md`.

## Before / After

![Terse Mode Demo](demo.png)

| Normal (87 tokens) | Terse — full (24 tokens) |
|--------------------|-------------------------|
| "当然！我很高兴帮你解决这个问题。你遇到的问题很可能是由于认证中间件没有正确验证 token 过期时间导致的。让我看一下并建议一个修复方案。" | "认证中间件 bug。Token 过期检查用了 < 而不是 <=。修：" |

Same fix. 75% less words. Brain still big.

## Installation

### Option A — Merge (recommended)

Copy the `## Terse Mode` section from [`SOUL.md`](SOUL.md) and append it to your existing `SOUL.md`. Your existing content stays intact.

### Option B — Replace

Replace your `SOUL.md` entirely with [`SOUL.md`](SOUL.md) from this repo.

> ⚠️ This overwrites all existing content. Back up first.

## Intensity Levels

| Level | Style | Example |
|-------|-------|---------|
| `lite` | Drop filler/hedging only. Full sentences, articles kept. | "Your component re-renders because you create a new object reference each render. Wrap in useMemo." |
| `full` | Classic caveman. Fragments OK, articles dropped. **← Default** | "New object ref each render. Inline object prop = new ref = re-render. useMemo." |
| `ultra` | Max compression. Abbreviations + `→` for causality. | "Inline obj prop → new ref → re-render. `useMemo`." |
| `wenyan` | 文言文. Classical Chinese terseness. | "物出新參照，致重繪。useMemo Wrap之。" |

**Switch:** `/terse lite|full|ultra|wenyan`
**Exit:** `normal mode` / `正常模式`

## Auto-Clarity

Terse pauses automatically for:

- Security warnings and irreversible action confirmations
- Destructive operations (DELETE / DROP / truncate)
- User asks for detail: `解释一下` / `详细点` / `展开`
- Multi-step sequences where fragment order risks misread

Resumes after the clear part is done.

## Level Persistence

Each `/terse xxx` command writes the preference to `MEMORY.md`. On every new session, Hermite reads `MEMORY.md` for `terse_level` and applies it automatically. No need to re-set after restart.

## Implementation: Original vs Hermite

| Dimension | Original caveman | Hermite Cavemen |
|-----------|-----------------|-----------------|
| Target platform | Claude Code | Hermes / OpenClaw |
| Activation | Hook system + flag file | SOUL.md rules injection |
| Persistence | `~/.claude/.caveman-active` flag file | `MEMORY.md` |
| Multi-platform sync | CI auto-syncs to 8+ platforms | Single platform, no sync needed |
| Statusline badge | `[CAVEMAN]` in Claude Code UI | Not available |
| Wenyan sub-levels | lite / full / ultra | lite / full / ultra |

**Why the differences?** Hermes / OpenClaw does not expose Claude Code's Hook API, flag file mechanism, statusline, or plugin system. Hermite Cavemen achieves equivalent behavior through SOUL.md rules injection, which Hermes reads on every session start.

**What is identical:** Core compression rules, intensity levels, auto-clarity conditions, code/commit/PR boundaries, activation/deactivation commands, ~75% token reduction.

## Project Structure

```
hermes-cavemen/
├── README.md       ← Bilingual (this file)
├── SOUL.md         ← Complete Terse Mode rules
├── SKILL.md        ← Skill format (optional)
├── CHANGELOG.md    ← Version history
├── VERSION         ← Current version
└── LICENSE         ← MIT
```

Credit: Based on [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) (37.6k stars, MIT License).

---

# 中文

## ⚡ 快速安装

**一行安装：**

```bash
# 方式 A：curl 追加到 SOUL.md（推荐）
curl -s https://raw.githubusercontent.com/Cnnnnnn/Hermes-cavemen/main/SOUL.md >> ~/.hermes/SOUL.md

# 方式 B：clone 仓库
git clone https://github.com/Cnnnnnn/Hermes-cavemen.git ~/Hermes-cavemen
```

搞定。Terse Mode（`full` 级别）自动激活，无需重启。

**验证安装：**
```
/sklls_list | grep terse
```
输出中有 `terse — Hermite Caveman` 即为成功。

**切换级别：**
```
/terse ultra     # 极致压缩
/terse wenyan    # 文言文
/normal mode     # 退出
```

## 是什么

Hermes Agent / OpenClaw 版本的 [caveman](https://github.com/JuliusBrussee/caveman)。压缩输出约 75%，同时保留全部技术准确性。

**Terse Mode 默认开启。** 无需手动激活。

## 安装方式

### 方式 A — 合并到现有 SOUL.md（推荐）

复制 [`SOUL.md`](SOUL.md) 中的 `## Terse Mode` 部分，追加到现有 `SOUL.md` 文件末尾。原有内容保持不变。

### 方式 B — 完全替换

直接用本仓库的 [`SOUL.md`](SOUL.md) 整体替换。

> ⚠️ 会覆盖原有所有内容，请先备份。

## 级别

| 级别 | 风格 | 示例 |
|------|------|------|
| `lite` | 仅删除 filler/hedging，保留冠词和完整句子。 | "Your component re-renders because you create a new object reference each render. Wrap in useMemo." |
| `full` | 经典 caveman 风格，允许碎片化句子。**← 默认** | "New object ref each render. Inline object prop = new ref = re-render. useMemo." |
| `ultra` | 极致压缩。缩写 + `→` 表示因果。 | "Inline obj prop → new ref → re-render. `useMemo`." |
| `wenyan` | 文言文风格。 | "物出新參照，致重繪。useMemo Wrap之。" |

**切换：** `/terse lite|full|ultra|wenyan`
**退出：** `正常模式` / `normal mode`

## 自动退出情况

以下情况 Terse Mode 自动暂停，恢复正常输出：

- 安全警告 / 不可逆操作确认
- 破坏性操作（DELETE / DROP / truncate）
- 用户要求详细解释：`解释一下` / `详细点` / `展开`
- 多步骤指令可能产生误解时

明确部分完成后自动恢复。

## 级别持久化

每次执行 `/terse xxx` 时，偏好会写入 `MEMORY.md`。新会话启动时自动读取并应用，无需重复设置。

## 实现机制：原版 vs Hermite Cavemen

| 维度 | 原版 caveman | Hermite Cavemen |
|------|-------------|-----------------|
| 目标平台 | Claude Code | Hermes / OpenClaw |
| 激活机制 | Hook 系统 + flag 文件 | SOUL.md 规则注入 |
| 持久化 | `~/.claude/.caveman-active` | `MEMORY.md` |
| 多平台同步 | CI 自动同步到 8+ 平台 | 单平台，无需同步 |
| 状态栏显示 | Claude Code UI 中的 `[CAVEMAN]` | 不支持 |
| Wenyan 子级别 | lite / full / ultra | lite / full / ultra |

**差异原因：** Hermes / OpenClaw 不提供 Claude Code 的 Hook API、flag 文件机制、状态栏和插件系统。Hermite Cavemen 通过 SOUL.md 规则注入实现等效行为——Hermes 每次启动读取 SOUL.md，规则自动生效。

**完全一致的部分：** 核心压缩规则、强度级别、Auto-Clarity 条件、代码/commit/PR 边界、激活/退出指令、约 75% 的 token 压缩率。

## 项目结构

```
hermes-cavemen/
├── README.md       ← 双语版（本文件）
├── SOUL.md         ← 完整 Terse Mode 规则
├── SKILL.md        ← Skill 格式（可选）
├── CHANGELOG.md    ← 版本历史
├── VERSION         ← 当前版本
└── LICENSE         ← MIT
```

致谢：基于 [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman)（37.6k stars，MIT License）。
