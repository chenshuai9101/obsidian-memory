#!/bin/bash
# init-obsidian-vault.sh
# 第一次初始化：将牧云野现有记忆导入Obsidian Vault
# 运行方式: bash init-obsidian-vault.sh

VAULT="$HOME/ObsidianVault"
WORKSPACE="$HOME/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"

echo "🚀 初始化Obsidian Vault - 导入牧云野现有记忆"
echo "================================================"
echo ""

# ── 1. 确保目录结构存在 ──
echo "📁 检查目录结构..."
for dir in "日记" "工作记录" "项目" "知识库" "归档"; do
  mkdir -p "$VAULT/$dir"
done
echo "✅ 目录结构就绪"

# ── 2. 导入每日记忆到 日记/ ──
echo ""
echo "📝 导入每日记忆..."
IMPORT_COUNT=0
for f in "$MEMORY_DIR"/2026-*.md; do
  if [ -f "$f" ]; then
    filename=$(basename "$f")
    date_part="${filename%.md}"
    
    # Convert to Obsidian daily note format
    target="$VAULT/日记/$date_part.md"
    
    # If it doesn't already exist, copy
    if [ ! -f "$target" ]; then
      # Add YAML frontmatter
      {
        echo "---"
        echo "created: $date_part"
        echo "tags: [daily, memory]"
        echo "---"
        echo ""
        cat "$f"
      } > "$target"
      echo "  ✅ 导入: 日记/$date_part.md ($(wc -c < "$f") bytes)"
      ((IMPORT_COUNT++))
    else
      echo "  ⏭️ 跳过 (已存在): 日记/$date_part.md"
    fi
  fi
done
echo "  共导入 $IMPORT_COUNT 篇日记"

# ── 3. 导入MEMORY.md到 工作记录/ ──
echo ""
echo "📖 导入长期记忆..."
if [ -f "$WORKSPACE/MEMORY.md" ]; then
  target="$VAULT/工作记录/长期记忆.md"
  {
    echo "---"
    echo "created: 2026-04-24"
    echo "tags: [memory, long-term]"
    echo "aliases: [MEMORY.md, 长期记忆]"
    echo "---"
    echo ""
    cat "$WORKSPACE/MEMORY.md"
  } > "$target"
  echo "✅ 导入: 工作记录/长期记忆.md ($(wc -c < "$WORKSPACE/MEMORY.md") bytes)"
fi

# ── 4. 导入HEARTBEAT.md ──
if [ -f "$WORKSPACE/HEARTBEAT.md" ]; then
  target="$VAULT/工作记录/Heartbeat检查清单.md"
  {
    echo "---"
    echo "created: 2026-04-24"
    echo "tags: [heartbeat, routine]"
    echo "---"
    echo ""
    cat "$WORKSPACE/HEARTBEAT.md"
  } > "$target"
  echo "✅ 导入: 工作记录/Heartbeat检查清单.md"
fi

# ── 5. 导入SOUL.md (身份描述) ──
if [ -f "$WORKSPACE/SOUL.md" ]; then
  target="$VAULT/知识库/牧云野的身份定义.md"
  {
    echo "---"
    echo "created: 2026-04-24"
    echo "tags: [identity, core]"
    echo "aliases: [SOUL.md, 身份定义, 牧云野]"
    echo "---"
    echo ""
    cat "$WORKSPACE/SOUL.md"
  } > "$target"
  echo "✅ 导入: 知识库/牧云野的身份定义.md"
fi

# ── 6. 导入分析报告 ──
if [ -f "$WORKSPACE/skill-complaints-analysis.md" ]; then
  target="$VAULT/工作记录/Skill用户抱怨分析报告.md"
  {
    echo "---"
    echo "created: 2026-04-24"
    echo "tags: [analysis, skill, complaints]"
    echo "---"
    echo ""
    cat "$WORKSPACE/skill-complaints-analysis.md"
  } > "$target"
  echo "✅ 导入: 工作记录/Skill用户抱怨分析报告.md"
fi

# ── 7. 创建项目笔记索引 ──
echo ""
echo "🏗️ 创建项目笔记索引..."
cat > "$VAULT/项目/项目索引.md" << 'EOF'
---
created: 2026-04-24
tags: [project, index]
---

# 项目索引

## 活跃项目

| 项目 | 状态 | 最近更新 |
|------|------|---------|
| [[Skill P0修复计划]] | 🔴 进行中 | 2026-04-24 |
| [[ECharts商业化]] | 🟢 已完成 | 2026-04-22 |
| [[Obsidian记忆系统]] | 🟡 进行中 | 2026-04-24 |
| [[LangChain Light]] | 🟢 已发布 | 2026-04-23 |
| [[AutoGen Light]] | 🟢 已发布 | 2026-04-23 |

## 历史项目

- [[GitHub Skill仓库创建]] - 2026-04-22
EOF
echo "✅ 创建: 项目/项目索引.md"

# ── 8. 创建技能修复记录 ──
cat > "$VAULT/工作记录/技能修复记录.md" << 'EOF'
---
created: 2026-04-24
tags: [修复, P0, 兼容性]
---

# 技能修复记录

## P0修复 (2026-04-24)

基于 [[Skill用户抱怨分析报告]]，完成全部10个skill的 v1.1.0 修复：

### 修复内容
1. **安装兼容性保护** — 多平台安装方式
2. **JSON结构化输出健壮性** — 自动修复指南
3. **边界声明** — not_for + triggers
4. **Quick Start** — 快速上手示例
5. **README统一模板** — 兼容矩阵

### 完成仓库
- [[../echarts-viz|echarts-viz]] ✅
- [[../memory-enhancer|memory-enhancer]] ✅
- [[../skill-factory|skill-factory]] ✅
- [[../policy-analyzer|policy-analyzer]] ✅
- [[../legal-case-search|legal-case-search]] ✅
- [[../multi-platform-content-creator|multi-platform-content-creator]] ✅
- [[../viral-video-script|viral-video-script]] ✅
- [[../article-to-ppt-pro|article-to-ppt-pro]] ✅
- [[../summarize|summarize]] ✅
- [[../cost-optimizer-assistant|cost-optimizer-assistant]] ✅
EOF
echo "✅ 创建: 工作记录/技能修复记录.md"

# ── 9. 统计 ──
echo ""
echo "================================================"
echo "📊 Vault统计"
echo "================================================"
echo "  总文件: $(find "$VAULT" -name "*.md" -type f | wc -l)"
echo "  日记:   $(find "$VAULT/日记" -name "*.md" -type f | wc -l)"
echo "  工作:   $(find "$VAULT/工作记录" -name "*.md" -type f | wc -l)"
echo "  项目:   $(find "$VAULT/项目" -name "*.md" -type f | wc -l)"
echo "  知识:   $(find "$VAULT/知识库" -name "*.md" -type f | wc -l)"
echo "  归档:   $(find "$VAULT/归档" -name "*.md" -type f | wc -l)"

echo ""
echo "🎯 初始化完成！"
echo "下一步: 打开Obsidian → 管理仓库 → 打开本地仓库 → 选择 ~/ObsidianVault"
echo "        然后你就能看到牧云野的所有记忆了！"
