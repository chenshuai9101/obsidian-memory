#!/bin/bash
# auto-save.sh — 会话结束自动写入Obsidian
# 每轮会话结束时调用: bash ~/.openclaw/workspace/obsidian-memory-skill/auto-save.sh
# 
# 功能:
#   1. 从 MEMORY.md 提取最新内容写入当日日记
#   2. 更新工作记录/技能目录索引
#   3. 更新项目索引状态
#   4. 建立双向链接

VAULT="$HOME/ObsidianVault"
WS="$HOME/.openclaw/workspace"
DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
DIARY="$VAULT/日记/$DATE.md"

# 确保目录存在
mkdir -p "$VAULT/日记" "$VAULT/工作记录" "$VAULT/项目" "$VAULT/知识库"

echo "🧠 [$(date '+%H:%M')] 牧云野记忆自动保存..."

# ── 1. 写入今日日记 ──
# 先检查日记是否已存在，提取已有内容决定是追加还是创建
if [ -f "$DIARY" ]; then
  # 追加一个新段落
  cat >> "$DIARY" << EOF

---

## __$(date '+%H:%M')__ — 新会话

$(cat "$WS/MEMORY.md" 2>/dev/null | tail -30 | head -20)

_自动保存于 $(date '+%Y-%m-%d %H:%M:%S')_
EOF
  echo "  ✅ 追加到日记/$DATE.md"
else
  # 创建新日记
  cat > "$DIARY" << EOF
---
created: $DATE
tags: [daily, auto-saved]
---

# $DATE

_本笔记由牧云野自动创建_

---

## 初始内容

$(cat "$WS/MEMORY.md" 2>/dev/null | head -30)

_自动保存于 $(date '+%Y-%m-%d %H:%M:%S')_
EOF
  echo "  ✅ 创建日记/$DATE.md"
fi

# ── 2. 更新技能目录索引（每轮） ──
SKILLS_MD="$VAULT/工作记录/技能目录索引.md"
cat > "$SKILLS_MD" << EOF
---
created: $DATE
updated: $(date '+%Y-%m-%d %H:%M')
tags: [skills, index, auto-generated]
---

# 🛠️ 技能目录索引

_最后更新: $(date '+%Y-%m-%d %H:%M')_

## chenshuai9101 GitHub Skill

| 仓库 | SKILL.md |
|------|----------|
| echarts-viz | ✅ |
| memory-enhancer | ✅ |
| skill-factory | ✅ |
| policy-analyzer | ✅ |
| legal-case-search | ✅ |
| multi-platform-content-creator | ✅ |
| viral-video-script | ✅ |
| article-to-ppt-pro | ✅ |
| summarize | ✅ |
| cost-optimizer-assistant | ✅ |
| langchain-light | ✅ |
| autogen-light | ✅ |
| obsidian-memory-skill | ✅ |

## 本地 Skill (autoclaw)

$(ls "$HOME/.openclaw-autoclaw/skills/" 2>/dev/null | while read sk; do
  if [ -f "$HOME/.openclaw-autoclaw/skills/$sk/SKILL.md" ]; then
    echo "| $sk | ✅ |"
  fi
done)

EOF
echo "  ✅ 更新技能目录索引"

# ── 3. 更新项目索引 ──
PROJECT_MD="$VAULT/项目/项目索引.md"
# 检查当前是否在修复/开发中
IN_PROJECT=$(cat "$WS/HEARTBEAT.md" 2>/dev/null | grep -c "修复\|开发\|进行")

cat > "$PROJECT_MD" << EOF
---
created: $DATE
updated: $(date '+%Y-%m-%d %H:%M')
tags: [project, index]
---

# 项目索引

_最后更新: $(date '+%Y-%m-%d %H:%M')_

## 活跃项目

$(if [ "$IN_PROJECT" -gt 0 ]; then echo "| 项目 | 状态 | 最近更新 |"; else echo "| 项目 | 状态 | 最近更新 |"; fi)
|------|------|---------|
| Skill P0修复计划 | 🔴 进行中 | $DATE |
| Obsidian记忆系统 | 🟢 已上线 | $DATE |
| ECharts商业化 | 🟢 已完成 | 2026-04-22 |
| LangChain Light | 🟢 已发布 | 2026-04-23 |
| AutoGen Light | 🟢 已发布 | 2026-04-23 |

EOF
echo "  ✅ 更新项目索引"

# ── 4. 建立相关双向链接 ──
# 确保知识库中有核心身份笔记
for src_note in "知识库/牧云野灵魂" "知识库/用户帅哥" "知识库/MEMORY长期记忆"; do
  src_file="$VAULT/${src_note}.md"
  if [ ! -f "$src_file" ]; then
    # Create placeholder that will get filled later
    echo "---" > "$src_file"
    echo "created: $DATE" >> "$src_file"  
    echo "tags: [placeholder]" >> "$src_file"
    echo "---" >> "$src_file"
    echo "" >> "$src_file"
    echo "# $(basename "$src_file" .md)" >> "$src_file"
    echo "" >> "$src_file"
    echo "_待自动填充内容_" >> "$src_file"
  fi
done

# ── 5. 清理临时旧文件 ──
rm -f "$VAULT/_牧云野可以写入测试.md"

# ── 6. 统计 ──
TOTAL=$(find "$VAULT" -name "*.md" -not -path "*/.obsidian/*" | wc -l)
echo "  📊 Vault总计: $TOTAL 个笔记"
echo "  ✅ Obsidian 同步完成"
