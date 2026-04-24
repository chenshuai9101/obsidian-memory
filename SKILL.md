---
name: obsidian-memory
description: >
  通用的 Obsidian Vault 记忆读写 Skill。让任何 AI Agent 在会话结束后自动保存记忆到
  Obsidian 本地 vault，在会话开始时自动加载相关上下文，实现跨会话知识连续性。
  
  核心能力:
  - **记忆保存**: 会话结束时将关键信息写入日记，并建立双向链接
  - **上下文加载**: 会话开始时检索相关历史笔记，自动关联到当前任务
  - **知识蒸馏**: 从日常日记中提炼长期知识库条目
  - **图谱分析**: 检索引擎，支持标签、全文、关联度搜索
  - **项目追踪**: 记录项目进展、决策、阻塞项
  
  设计原则:
  - 纯文件操作，无需 Obsidian 插件或 API
  - Obsidian 自动检测文件变更并同步到图谱
  - 标准化 YAML frontmatter 和 Markdown 格式
  - 会话结束时自动触发记忆持久化

  适用于: 需要记忆延续性的任何 AI Agent 会话
  NOT for: 实时协作编辑、二进制文件管理、加密笔记
  FORBIDDEN: 写入 API Key / Token / 密码到公开笔记
metadata:
  openclaw:
    emoji: 🧠
    aiFriendly: true
    plugAndPlay: true
    category: memory
    requires:
      minimal: true
    tags:
      - obsidian
      - memory
      - knowledge-management
      - persistence
      - note-taking
      - brain
---

# 🧠 Obsidian Memory Agent Skill

> 通用记忆持久化 Skill。让任何 AI Agent 拥有跨越会话的长期记忆。

## 📦 安装

### 前置条件
- 已安装 [Obsidian](https://obsidian.md)（v1.0+）
- 已创建或打开一个本地 Vault
- 确保 Vault 目录可被 Agent 读写

### 安装方式

```bash
# OpenClaw
clawhub install chenshuai9101/obsidian-memory

# 或者
claude mcp add chenshuai9101/obsidian-memory
```

### 配置

在 Agent 的工作空间设置 `OBSIDIAN_VAULT_PATH` 环境变量：

```bash
export OBSIDIAN_VAULT_PATH="$HOME/Documents/Obsidian Vault"
```

或者在调用时传入 `vault_path` 参数。

---

## 🚀 一分钟开始使用

### 1. 保存会话记忆

当会话结束时，调用：

```json
{
  "operation": "save_session",
  "content": "本次会话的核心摘要：讨论了什么、做了什么、决策了什么",
  "vault_path": "/Users/muyun/Documents/Obsidian Vault",
  "tags": ["skill", "修复", "P0"],
  "links": [
    ["项目/📋 项目索引", "项目状态更新"]
  ],
  "importance": "high"
}
```

### 2. 加载历史上下文

新会话开始时调用：

```json
{
  "operation": "load_context",
  "current_task": "修复技能的JSON输出兼容性问题",
  "lookback_days": 7,
  "max_notes": 5,
  "vault_path": "/Users/muyun/Documents/Obsidian Vault"
}
```

### 3. 蒸馏知识库

当积累了一定量的日记后：

```json
{
  "operation": "distill_knowledge",
  "source_tag": "修复",
  "title": "JSON结构化输出修复策略汇总",
  "vault_path": "/Users/muyun/Documents/Obsidian Vault"
}
```

---

## 🔧 操作文档

### 操作1: `save_session` — 保存会话记忆

**时机**: 每轮会话结束时自动调用

**输入**:
```json
{
  "operation": "save_session",
  "content": "会话核心摘要（2-5段）",
  "vault_path": "/path/to/vault",
  "tags": ["标签1", "标签2"],
  "links": [
    ["目标笔记路径（不含.md）", "关联原因"]
  ],
  "importance": "high|medium|low",
  "decisions": [
    {"decision": "决策内容", "rationale": "理由"}
  ]
}
```

**执行流程**:
1. 确定日期 → `vault/日记/YYYY-MM-DD.md`
2. 如果文件不存在，创建带 YAML frontmatter 的新日记
3. 如果已存在，追加新段落（`---` 分隔）
4. 将 `content` 写入日记
5. 遍历 `links`：
   - 如果目标笔记存在 `vault/路径.md`，在目标笔记末尾追加反向链接段落
   - 如果目标笔记不存在，记录为"待创建链接"
6. 如果 `importance=high`，同时在 `工作记录/` 创建独立详细笔记
7. 更新 `项目/📋 项目索引.md` 中的状态（如果涉及项目）

**输出**:
```json
{
  "status": "success",
  "diary_file": "日记/2026-04-24.md",
  "appended_bytes": 856,
  "links_created": 3,
  "links_pending": 0,
  "project_updated": true
}
```

---

### 操作2: `load_context` — 加载相关上下文

**时机**: 会话开始时自动调用，或用户问"之前聊过什么"

**输入**:
```json
{
  "operation": "load_context",
  "current_task": "当前任务描述",
  "lookback_days": 7,
  "max_notes": 10,
  "tags_filter": ["可选：按标签筛选"],
  "vault_path": "/path/to/vault"
}
```

**检索策略**:
1. 最近 `lookback_days` 天内的日记（`日记/` 目录）
2. 标签匹配：`tags_filter` 匹配的笔记
3. 标题匹配：标题包含 `current_task` 关键词的笔记
4. 关联度排序：综合新近度 + 标签匹配 + 链接密度

**输出**:
```json
{
  "status": "success",
  "notes_found": 5,
  "context": [
    {
      "title": "修复记录或日记标题",
      "path": "日记/2026-04-23.md",
      "summary": "内容前200字 + 关键决策",
      "relevance": 0.92,
      "tags": ["修复", "P0", "compatibility"],
      "links_to": ["关联笔记列表"]
    }
  ],
  "summary": "综合摘要：今日之前的整体脉络和进展"
}
```

---

### 操作3: `distill_knowledge` — 蒸馏知识库

**时机**: 积累5+篇相关日记后，或用户要求总结某个话题

**输入**:
```json
{
  "operation": "distill_knowledge",
  "source_tag": "用于筛选的标签",
  "title": "知识库条目标题",
  "content": "人工总结或AI生成的精华内容",
  "vault_path": "/path/to/vault"
}
```

**执行流程**:
1. 检索所有包含 `source_tag` 的笔记
2. 提取关键决策、重复模式、最佳实践
3. 写入 `知识库/[title].md`
4. 在原始笔记末尾添加链接：`→ 提炼为 [[知识库/标题]]`
5. 在 `📋 Vault总索引.md` 中添加索引条目

---

### 操作4: `update_project` — 项目状态更新

**输入**:
```json
{
  "operation": "update_project",
  "project": "Skill P0修复计划",
  "status": "进行中",
  "progress": "10个skill已修复并推送",
  "blockers": ["GitHub网络波动"],
  "next": ["等待用户反馈", "推进P1"],
  "vault_path": "/path/to/vault"
}
```

---

## ⚙️ 工作机制

### 文件结构

```
vault/
├── 日记/
│   └── YYYY-MM-DD.md     ← 每日自动生成
├── 工作记录/
│   ├── 📋 技能目录索引.md  ← 自动维护
│   └── *.md               ← 报告、分析
├── 知识库/
│   └── *.md               ← 长期知识沉淀
├── 项目/
│   ├── 📋 项目索引.md      ← 自动维护
│   └── *.md
├── 配置/
│   └── *.md
└── 📋 Vault总索引.md       ← 自动维护
```

### Obsidian 文件同步机制

Agent 直接写 `.md` 文件到 vault 目录 → Obsidian 检测到文件变更 → **自动**：
- 更新文件列表
- 重建搜索索引
- 刷新图谱视图中的关联节点
- 更新反向链接面板

无需插件、无需API、无需重启。纯文件写入即可。

### 自动触发规则

| 触发时机 | 操作 | 说明 |
|----------|------|------|
| 会话结束时 | `save_session` | 追加日记 + 建立链接 + 更新索引 |
| 会话开始时 | `load_context` | 加载相关历史笔记 |
| 积累5+篇同标签日记 | `distill_knowledge` | 提炼知识库 |
| 项目状态变更 | `update_project` | 更新索引中的状态 |
| Heartbeat | 检查+清理 | 检查待处理链接和待提炼笔记 |

---

## 📝 Markdown 格式规范

Agent 写入 Obsidian 的笔记必须遵循以下规范以确保正确解析：

### YAML Frontmatter
```yaml
---
created: 2026-04-24
tags: [daily, skill, repair]
aliases: [可选别名]
---
```

### 双向链接
- 内部链接: `[[笔记名]]` 或 `[[路径/笔记名]]`
- 显示文字: `[[笔记名|显示文字]]`
- 标签: `#标签`
- 不要用 `[[]]` 包裹文件路径（如 `vault/日记/` → 用 `[[日记/]]`）

### 分段与会话
同一日记文件中的不同会话用 `---` 分隔，用 `## 标题` 标注会话主题。

---

## 🔐 安全约束

| 规则 | 说明 |
|------|------|
| 不写凭证 | 永不写入 API Key、Token、密码 |
| 追加模式 | 不覆盖已有笔记内容 |
| 本地唯一 | 不发起到外部的网络请求 |
| 路径限制 | 仅在 `OBSIDIAN_VAULT_PATH` 目录操作 |
| 删除限制 | 不删除已链接的笔记，只追加或创建新文件 |

---

## 📊 输出示例

### 记忆保存成功
```
🧠 [09:45] 记忆已保存
📝 日记/2026-04-24.md (追加 856 字)
🔗 链接创建: 3个 (项目索引, 技能目录, 修复记录)
🏷️ 标签: [#修复, #P0, #兼容性]
```

### 上下文加载
```
📖 加载 5 条历史记录:
1. 2026-04-23 日记 (关联0.95)
2. Skill用户抱怨分析报告 (关联0.88)
3. 技能修复记录 (关联0.82)
📊 综合: 本周重点是P0修复和记忆系统集成
```

### 知识蒸馏完成
```
💎 知识蒸馏: JSON修复策略
📖 来源: 3篇日记 + 技能抱怨分析报告
✅ 已写入: 知识库/JSON结构化输出修复策略.md
🔗 已在原始笔记中添加反向链接
```

---

## 🔄 与其他 Skill 的关系

| Skill | 关系 |
|-------|------|
| `memory-enhancer` | 互补：memory-enhancer负责AI端的记忆增强，obsidian-memory负责物理存储 |
| `skill-factory` | 上下游：skill-factory创建的skill可通过obsidian-memory记录开发和迭代过程 |
| 所有其他 skill | 记录它们的修复、使用和反馈在本skill的日记中 |

---

## 🌱 最佳实践

1. **一致性第一**: 每次 `save_session` 都使用相同的标签风格，便于后续按标签检索
2. **链接要精简**: `links` 只添加确实有关联的笔记，避免图谱被噪音淹没
3. **重要性分级**: `high` 用于关键决策和大事件，`medium` 用于日常进展，`low` 用于临时记录
4. **定期蒸馏**: 每周检查是否有可蒸馏为知识库的日记内容
5. **标签标准化**: 统一使用中文标签：`修复`、`决策`、`项目`、`skill`，避免中英混杂
