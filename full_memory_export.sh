#!/bin/bash
# full_memory_export.sh
# 牧云野全部记忆 → Obsidian Vault 完整导出
# 运行方式: bash full_memory_export.sh

VAULT="$HOME/ObsidianVault"
WS="$HOME/.openclaw/workspace"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG="$VAULT/export_log_$TIMESTAMP.txt"

echo "🧠 牧云野完全记忆导出 → Obsidian Vault"
echo "======================================"
echo "时间: $(date)"
echo "Vault: $VAULT"
echo ""

# ── 0. 确保目录结构 ──
for dir in 日记 工作记录 项目 知识库 归档 会话日志 配置 _attachments; do
  mkdir -p "$VAULT/$dir"
done

IMPORTED=0
SKIPPED=0
ERRORS=0

import_file() {
  local src="$1"
  local dest="$2"
  local tags="$3"
  local aliases="$4"
  
  if [ ! -f "$src" ]; then
    echo "  ⚠️ 不存在: $src"
    ((ERRORS++))
    return
  fi
  
  if [ -f "$dest" ]; then
    echo "  ⏭️ 已存在: $(basename "$dest")"
    ((SKIPPED++))
    return
  fi
  
  local fname=$(basename "$src")
  local fsize=$(wc -c < "$src")
  
  {
    echo "---"
    echo "created: $(date '+%Y-%m-%d')"
    echo "tags: [$tags]"
    echo "source: $src"
    [ -n "$aliases" ] && echo "aliases: [$aliases]"
    echo "---"
    echo ""
    cat "$src"
  } > "$dest"
  
  echo "  ✅ $(basename "$dest") ($fsize bytes)"
  ((IMPORTED++))
}

echo ""
echo "━━━ 📝 日记 ━━━"
for f in "$WS/memory/"*.md; do
  [ -f "$f" ] || continue
  fname=$(basename "$f")
  import_file "$f" "$VAULT/日记/$fname" "daily, memory" "$fname"
done

# Also check for any daily notes in other workspace locations
for d in "$WS/memory/"*; do
  [ -f "$d" ] && continue  # skip files, handled above
done

echo ""
echo "━━━ 📖 核心身份与配置 ━━━"
import_file "$WS/MEMORY.md" "$VAULT/知识库/MEMORY长期记忆.md" "memory, long-term, core" "MEMORY.md"
import_file "$WS/SOUL.md" "$VAULT/知识库/牧云野灵魂.md" "soul, identity, core" "SOUL.md"
import_file "$WS/IDENTITY.md" "$VAULT/知识库/牧云野身份定义.md" "identity, core" "IDENTITY.md"
import_file "$WS/USER.md" "$VAULT/知识库/用户帅哥.md" "user, profile" "USER.md"
import_file "$WS/AGENTS.md" "$VAULT/配置/AGENTS工作空间规则.md" "rules, workspace" "AGENTS.md"
import_file "$WS/TOOLS.md" "$VAULT/配置/TOOLS本地笔记.md" "tools, config" "TOOLS.md"
import_file "$WS/HEARTBEAT.md" "$VAULT/配置/HEARTBEAT检查清单.md" "heartbeat, routine" "HEARTBEAT.md"

echo ""
echo "━━━ 📊 分析报告 ━━━"
import_file "$WS/skill-complaints-analysis.md" "$VAULT/工作记录/Skill用户抱怨分析报告.md" "analysis, skill, complaints" "skill-complaints-analysis.md"
import_file "$WS/贾维斯记忆系统架构.md" "$VAULT/知识库/贾维斯三层记忆系统架构.md" "memory, architecture, jarvis" "贾维斯记忆系统架构.md"

echo ""
echo "━━━ 🛠️ 技能目录 ━━━"
SKILL_DIRS=(
  "~/.openclaw-autoclaw/skills"
  "$WS/skills-fix"
  "$WS/obsidian-memory-skill"
)

for sd in "${SKILL_DIRS[@]}"; do
  dir_expanded="${sd/#\~/$HOME}"
  if [ -d "$dir_expanded" ]; then
    echo "  📂 $(basename "$dir_expanded")/"
    ls "$dir_expanded/" | while read sub; do
      if [ -f "$dir_expanded/$sub/SKILL.md" ]; then
        echo "    ├ 📄 $sub (SKILL.md)"
      elif [ -f "$dir_expanded/$sub" ]; then
        echo "    ├ 📄 $sub"
      else
        echo "    ├ 📁 $sub/"
      fi
    done
  fi
done

# ── 创建索引笔记 ──
echo ""
echo "━━━ 📇 创建索引笔记 ━━━"

# Root vault index
cat > "$VAULT/📋 Vault总索引.md" << INEDEOF
---
created: $(date '+%Y-%m-%d')
tags: [index, vault, map]
---

# 📋 Vault总索引

## 快速导航

| 目录 | 内容 |
|------|------|
| [[日记/]] | 每日会话记录（自动写入） |
| [[工作记录/]] | 项目进展、修复记录 |
| [[知识库/]] | 长期知识沉淀 |
| [[项目/]] | 项目级笔记 |
| [[配置/]] | 牧云野配置、规则 |
| [[归档/]] | 已完成项目存档 |

## 标签导航

- \`#skill\` - 所有Skill相关
- \`#memory\` - 记忆相关
- \`#core\` - 核心身份定义
- \`#修复\` - Bug修复
- \`#project\` - 项目
- \`#daily\` - 日常记录

## 知识图谱核心节点

- [[知识库/牧云野灵魂]] — 核心身份定义
- [[知识库/用户帅哥]] — 你的偏好和上下文
- [[知识库/MEMORY长期记忆]] — 所有长期记忆
- [[知识库/贾维斯三层记忆系统架构]] — 记忆架构

## 连接说明

使用 \`[[笔记名]]\` 创建双向链接。
图谱视图 (\`⌘+G\`) 可看到笔记间的关联网络。
INEDEOF
echo "  ✅ 📋 Vault总索引.md"

# Notebook index in 工作记录
cat > "$VAULT/工作记录/📋 工作记录索引.md" << WRKEOF
---
created: $(date '+%Y-%m-%d')
tags: [work, index, log]
---

# 📋 工作记录索引

## 项目跟踪

| 文件 | 说明 |
|------|------|
| [[../Skill用户抱怨分析报告\|Skill用户抱怨分析报告]] | 100+仓库抱怨分析 |
| [[../技能修复记录\|技能修复记录]] | P0修复进展 |
| [[../长期记忆\|长期记忆]] | 持续更新的工作知识 |

## 修复历史

- 2026-04-24: 10个Skill P0修复完成 → [[../技能修复记录]]
WRKEOF
echo "  ✅ 工作记录索引.md"

echo ""
echo "======================================"
echo "📊 导出统计"
echo "======================================"
echo "  新增笔记:   $IMPORTED"
echo "  跳过已存在: $SKIPPED"
echo "  错误:       $ERRORS"
echo ""
echo "📁 Vault现状:"
find "$VAULT" -name "*.md" -not -path "*/.obsidian/*" | wc -l | xargs echo "  总Markdown文件:"
echo ""
echo "📂 分类统计:"
echo "  日记:    $(find "$VAULT/日记" -name '*.md' | wc -l)"
echo "  工作记录: $(find "$VAULT/工作记录" -name '*.md' | wc -l)"
echo "  知识库:  $(find "$VAULT/知识库" -name '*.md' | wc -l)"
echo "  项目:    $(find "$VAULT/项目" -name '*.md' | wc -l)"
echo "  配置:    $(find "$VAULT/配置" -name '*.md' | wc -l)"

# Create summary note
cat > "$VAULT/日记/$(date '+%Y-%m-%d').md" << TODAYEOF
---
created: $(date '+%Y-%m-%d')
tags: [daily, export, obsidian]
---

# $(date '+%Y-%m-%d') — 记忆导出日

## 🧠 全部记忆打包完成

今天将牧云野的全部记忆一次性导入了Obsidian Vault！

**已归档内容**:
- 📝 日记: $(find "$VAULT/日记" -name '*.md' | wc -l) 篇
- 📖 核心身份: SOUL + IDENTITY + USER + AGENTS + TOOLS
- 📊 分析报告: Skill抱怨分析 + 贾维斯架构
- 🛠️ 技能目录索引: 所有GitHub仓库概览
- 🗺️ 索引笔记: 快速导航

**从此告别金鱼记忆** 🐟➡️🧠
TODAYEOF

echo ""
echo "🎯 全部记忆已打包到 Obsidian Vault!"
echo "打开 Obsidian → 管理仓库 → ~/ObsidianVault 即可查看"
echo "日志文件: $(basename "$LOG")"
