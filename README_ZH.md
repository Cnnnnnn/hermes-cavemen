# Hermite Caveman — Terse Mode

> 🪨 why use many token when few token do trick

[English](../README.md) | 中文

---

## 是什么

Hermes Agent / OpenClaw 版本的 [caveman](https://github.com/JuliusBrussee/caveman)。压缩输出约 75%，同时保留全部技术准确性。

Terse Mode **默认开启**，无需手动激活。

---

## 安装方式

### 方式 A — 合并到现有 SOUL.md（推荐）

复制 [`SOUL.md`](SOUL.md) 中的 `## Terse Mode` 部分，追加到现有 `SOUL.md` 文件末尾。原有内容保持不变。

### 方式 B — 完全替换

直接用本仓库的 [`SOUL.md`](SOUL.md) 整体替换。

> ⚠️ 会覆盖原有所有内容，请先备份。

---

## 级别

| 级别 | 风格 | 示例 |
|------|------|------|
| `lite` | 仅删除 filler/hedging，保留冠词和完整句子。 | "Your component re-renders because you create a new object reference each render. Wrap in useMemo." |
| `full` | 经典 caveman 风格，允许碎片化句子。**← 默认** | "New object ref each render. Inline object prop = new ref = re-render. useMemo." |
| `ultra` | 极致压缩。缩写 + `→` 表示因果。 | "Inline obj prop → new ref → re-render. `useMemo`." |
| `wenyan` | 文言文风格。 | "物出新參照，致重繪。useMemo Wrap之。" |

**切换：** `/terse lite|full|ultra|wenyan`
**退出：** `正常模式` / `normal mode`

---

## 自动退出情况

以下情况 Terse Mode 自动暂停，恢复正常输出：

- 安全警告 / 不可逆操作确认
- 破坏性操作（DELETE / DROP / truncate）
- 用户要求详细解释：`解释一下` / `详细点` / `展开`
- 多步骤指令可能产生误解时

明确部分完成后自动恢复。

---

## 级别持久化

每次执行 `/terse xxx` 时，偏好会写入 `MEMORY.md`。新会话启动时自动读取并应用，无需重复设置。

---

## 实现机制：原版 vs Hermite Caveman

| 维度 | 原版 caveman | Hermite Caveman |
|------|-------------|-----------------|
| 目标平台 | Claude Code | Hermes / OpenClaw |
| 激活机制 | Hook 系统 + flag 文件 | SOUL.md 规则注入 |
| 持久化 | `~/.claude/.caveman-active` | `MEMORY.md` |
| 多平台同步 | CI 自动同步到 8+ 平台 | 单平台，无需同步 |
| 状态栏显示 | Claude Code UI 中的 `[CAVEMAN]` | 不支持 |
| Wenyan 子级别 | lite / full / ultra | lite / full / ultra |

**差异原因：** Hermes / OpenClaw 不提供 Claude Code 的 Hook API、flag 文件机制、状态栏和插件安装系统。Hermite Caveman 通过 SOUL.md 规则注入实现等效行为——Hermes 每次启动读取 SOUL.md，规则自动生效。

**完全一致的部分：** 核心压缩规则、强度级别、Auto-Clarity 条件、代码/commit/PR 边界、激活/退出指令、约 75% 的 token 压缩率。

---

## 项目结构

```
hermite-caveman/
├── README.md       ← 英文版
├── README_ZH.md    ← 中文版
├── SOUL.md         ← 完整 Terse Mode 规则
├── SKILL.md        ← Skill 格式（可选）
└── LICENSE         ← MIT
```

---

致谢：基于 [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman)（37.6k stars，MIT License）。
