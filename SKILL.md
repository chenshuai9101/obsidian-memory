---
name: obsidian-memory
metadata:
  author: 牧云野
  version: "1.0.0"
description: >
  牧云野的持久化记忆系统v2。通过Obsidian本地vault实现永久记忆、知识关联和智能检索。
  自动将工作记录、决策、项目进展写入Obsidian并建立双向链接。
  
  核心能力:
  - **自动记忆写入**: 将每轮会话的关键信息写入Obsidian日记和工作记录
  - **双向链接建立**: 自动关联相关概念、项目、话题
  - **智能检索**: 通过标签和图谱快速检索历史知识
  - **知识沉淀**: 从日常记录中提炼长期知识库条目
  - **记忆桥接**: 新会话开始时自动加载相关上下文
  
  适用于: 每轮会话结束时的记忆保存、新会话开始时的上下文加载、项目进展追踪、决策记录
  NOT for: 文件系统操作(使用shell skill)、复杂数据库查询
  FORBIDDEN: 写入个人隐私凭证、覆盖已有笔记不备份
license: Proprietary
---

# 牧云野 Obsidian 记忆系统

## ⚡ Quick Start

每轮会话结束时自动调用：
```json
{
  "operation": "save_session_memory",
  "content": "本轮会话的文本摘要",
  "tags": ["项目标签"],
  "links": [["关联笔记名", "关联原因"]]
}
```

新会话开始时自动调用：
```json
{
  "operation": "load_relevant_context",
  "current_task": "当前任务描述"
}
```

## 📂 目录结构

```
~/ObsidianVault/
├── 日记/                  # 自动写入：每日会话记录
│   └── 2026-04-24.md      # 格式: YYYY-MM-DD.md
├── 工作记录/               # 自动写入：项目进展、修复记录
│   ├── 技能修复记录.md
│   └── 用户反馈分析.md
├── 项目/                   # 手动或半自动：项目级笔记
│   ├── ECharts商业化.md
│   └── Skill优化计划.md
├── 知识库/                 # 提炼：从日常记录中沉淀的长期知识
│   ├── 结构化输出兼容性.md
│   └── JSON解析修复策略.md
├── 归档/                   # 已完成项目
└── _attachments/           # 自动：附件存放
```

## 🔧 核心操作

### 操作1: 保存会话记忆 `save_session_memory`

**何时调用**: 每轮会话结束时（用户主动要求或会话自然结束）

```json
{
  "operation": "save_session_memory",
  "content": "今日与用户讨论的内容摘要，包含决策、发现、问题等",
  "tags": ["标签1", "标签2"],
  "links": [
    ["笔记名称", "关联原因（例如: 该项目继续推进）"],
    ["另一个笔记", "关联原因"]
  ],
  "importance": "high|medium|low",
  "generate_summary": true
}
```

**写入流程**:
1. 检查 `日记/YYYY-MM-DD.md` 是否存在
2. 如果存在，追加内容到末尾（用 `---` 分隔不同的会话段落）
3. 如果不存在，创建新文件，添加YAML frontmatter和日期标题
4. 解析 `links` 中的关联笔记，检查目标笔记是否存在
5. 如果目标笔记存在，在目标笔记中添加反向链接段落
6. 如果 `importance=high`，同时在 `工作记录/` 创建独立的详细笔记
7. 更新 `知识库/` 中的相关长期条目（如果内容有新的沉淀价值）

---

### 操作2: 加载相关上下文 `load_relevant_context`

**何时调用**: 会话开始时，或用户问"之前聊过什么"

```json
{
  "operation": "load_relevant_context",
  "current_task": "当前任务描述",
  "lookback_days": 7,
  "max_notes": 10
}
```

**输出格式**:
```json
{
  "status": "success",
  "context": [
    {
      "title": "笔记标题",
      "path": "目录/文件名.md",
      "summary": "内容摘要（前200字）",
      "relevance": 0.95,
      "date": "2026-04-22",
      "tags": ["标签列表"],
      "links_to": ["关联笔记列表"]
    }
  ],
  "summary": "综合摘要：今日之前的整体脉络"
}
```

---

### 操作3: 创建知识库条目 `create_knowledge_entry`

```json
{
  "operation": "create_knowledge_entry",
  "title": "知识点标题",
  "content": "知识点详细内容，使用Markdown格式",
  "tags": ["标签"],
  "links": [["关联笔记", "原因"]],
  "category": "长期知识|方法论|经验总结|技术方案"
}
```

---

### 操作4: 更新项目笔记 `update_project_note`

```json
{
  "operation": "update_project_note",
  "project": "项目名称",
  "status": "进行中|已完成|暂停",
  "progress_updates": ["今日进展1", "今日进展2"],
  "blockers": ["阻塞项1"],
  "next_steps": ["下一步1"],
  "decisions": [
    {"decision": "决策内容", "rationale": "决策理由"}
  ]
}
```

---

### 操作5: 图谱分析 `graph_analysis`

```json
{
  "operation": "graph_analysis",
  "focus": "分析中心点（可选）",
  "depth": 2
}
```

**输出**: 以指定笔记为中心的知识图谱结构，包含关联层级和连接密度分析。帮助我理解哪些话题是最核心的知识节点。

---

## ⚙️ 自动触发规则

### 会话结束时
自动执行 `save_session_memory`，包含:
- 本轮所有重要决策
- 创建/修改的Skill清单
- 遇到的问题和解决方案
- 用户偏好信息
- tags自动从当前任务推导

### 会话开始时
自动执行 `load_relevant_context`，包含:
- 当前任务相关的历史记录
- 最近7天的重要事件
- 标签匹配的关联笔记

### 每日复盘（Heartbeat期间）
- 检查 `日记/昨天.md` 是否有待归档的条目
- 检查是否有 `importance=high` 的笔记需要提炼为知识库
- 检查项目笔记是否需要更新状态

---

## 📝 Markdown规范

为确保Obsidian正确解析，所有写入内容严格遵循：

```markdown
---
created: YYYY-MM-DD
tags: [tag1, tag2]
aliases: []
---

# 标题

正文内容...

## 关键决策

- 决策1: 理由

## 关联
- [[关联笔记1]] - 关联原因
- [[关联笔记2]] - 关联原因
```

### 链接格式
- 内部链接: `[[笔记名]]` 或 `[[笔记名|显示文字]]`
- 标签: `#标签名`
- 外部链接: `[显示文字](url)`

---

## 🔐 安全约束

- 不写入任何API Key、Token、密码
- 不覆盖已有笔记（追加模式）
- 不发起到外部的网络请求
- 仅在 `~/ObsidianVault/` 目录操作

---

## 📊 输出示例

### 记忆保存成功
```
✅ 已保存今日会话记忆
   📝 日记/2026-04-24.md (追加 856 字)
   🔗 关联笔记: 3个 (技能修复记录.md, 用户反馈分析.md, Obsidian记忆系统.md)
   🏷️ 标签: [#skill修复, #Obsidian, #记忆系统]
```

### 上下文加载
```
📖 加载了 5 条相关记录
   1. 2026-04-23 技能修复记录 (关联度 0.95)
   2. 2026-04-23 用户抱怨分析报告 (关联度 0.88)
   3. 2026-04-22 ECharts商业化 (关联度 0.72)
   📊 综合: 本周重点是Skill P0修复和Obsidian集成
```
