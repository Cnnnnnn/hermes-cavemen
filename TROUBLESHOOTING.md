# Troubleshooting

常见问题与解决方案。

---

## 安装后 Terse Mode 不生效

**症状：** 重启 AI 后输出仍然是正常模式。

**排查步骤：**

1. 确认 SOUL.md 写入成功：
   ```bash
   grep "## Terse Mode" ~/.hermes/SOUL.md
   ```
   如果没有输出，说明安装失败，重新运行：
   ```bash
   curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/install.sh | bash
   ```

2. 确认 MEMORY.md 有 terse_level：
   ```bash
   grep "terse_level" ~/.hermes/memories/MEMORY.md
   ```
   应该输出 `terse_level: full`

3. 确认 AI 读取的是正确的 SOUL.md 路径。不同部署方式路径可能不同，常见路径：
   - `~/.hermes/SOUL.md`
   - `~/.openclaw/SOUL.md`
   - `${HERMES_CONFIG_DIR}/SOUL.md`

---

## SOUL.md 已有其他内容，合并冲突

**症状：** 安装脚本提示 "already has Terse Mode" 但实际没有生效。

**原因：** 可能是旧的 Terse Mode section 存在但格式不完整。

**解决：**
```bash
# 手动移除旧的 Terse Mode section
python3 -c "
import re
with open('$HOME/.hermes/SOUL.md') as f:
    content = f.read()
# Remove any Terse Mode section
content = re.sub(r'\n## Terse Mode.*', '', content, flags=re.DOTALL)
with open('$HOME/.hermes/SOUL.md', 'w') as f:
    f.write(content.strip() + '\n')
"
# 重新安装
curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/install.sh | bash
```

---

## MEMORY.md 持久化不生效

**症状：** 切换级别后（`/terse ultra`），新会话级别没有保留。

**排查：**
```bash
cat ~/.hermes/memories/MEMORY.md | grep terse_level
```

如果文件不存在或 terse_level 丢失，手动写入：
```bash
echo "terse_level: full" >> ~/.hermes/memories/MEMORY.md
```

---

## 切换级别命令没有反应

**正确命令格式：**
```
/terse ultra
/terse wenyan
/terse full
/terse lite
```

**注意：** 斜杠 `/` 是命令前缀，需要 AI 支持 slash commands 的平台才有效。如果 AI 没有响应 slash 命令，尝试直接说：
- "切换到 ultra 模式"
- "我想用 wenyan 模式"
- "normal mode"

---

## 不知道自己当前是什么级别

在任意对话中问 AI：
```
/terse
```
或者直接说："我现在是什么模式？"

---

## 卸载不干净

**症状：** 卸载后 Terse Mode 仍然激活。

**手动清理：**
```bash
# 1. 从 SOUL.md 移除 Terse Mode section
python3 -c "
import re
with open('$HOME/.hermes/SOUL.md') as f:
    content = f.read()
content = re.sub(r'\n## Terse Mode.*', '', content, flags=re.DOTALL)
with open('$HOME/.hermes/SOUL.md', 'w') as f:
    f.write(content.strip() + '\n')
"

# 2. 清除 MEMORY.md
python3 -c "
with open('$HOME/.hermes/memories/MEMORY.md') as f:
    lines = f.readlines()
with open('$HOME/.hermes/memories/MEMORY.md', 'w') as f:
    for line in lines:
        if not line.strip().startswith('terse_level:'):
            f.write(line)
"
```

---

## AI 输出仍然是长句，不是 terse 风格

**可能原因：**
1. Terse Mode section 没有被正确加载（检查 SOUL.md）
2. 当前会话是旧会话（关闭重开）
3. AI 没有遵循 SOUL.md 规则

**尝试：**
```bash
# 完全重新安装
curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/install.sh | bash
# 然后重启 AI 对话
```

---

## install.sh 下载失败

**症状：** `curl: failed to connect` 或 `Connection refused`

**替代方案：**
```bash
# 手动下载
wget https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/install.sh -O install.sh
bash install.sh

# 或用 Git clone
git clone https://github.com/Cnnnnnn/hermes-cavemen.git ~/hermes-cavemen
cd ~/hermes-cavemen
bash install.sh
```

---

## 报告问题

遇到以上没有覆盖的问题，请到：
https://github.com/Cnnnnnn/hermes-cavemen/issues

提供：
- Hermes/OpenClaw 版本
- 安装方式（脚本/手动）
- SOUL.md 前 20 行内容（`head -20 ~/.hermes/SOUL.md`）
- MEMORY.md 内容（`cat ~/.hermes/memories/MEMORY.md`）
