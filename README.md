# WeLaw - 普通法学习平台

<p align="center">
  <img src="https://img.shields.io/badge/Vue-3.x-4FC08D?style=flat-square&logo=vue.js" alt="Vue3">
  <img src="https://img.shields.io/badge/Spring%20Boot-3.x-6DB33F?style=flat-square&logo=spring" alt="Spring Boot">
  <img src="https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat-square&logo=mysql" alt="MySQL">
  <img src="https://img.shields.io/badge/Element%20Plus-2.x-409EFF?style=flat-square" alt="Element Plus">
</p>

[English](#enoflaw---common-law-learning-platform) | 中文

---

## 📖 项目简介

WeLaw是一款专为普通法学习者设计的综合性学习平台，融合MarginNote的案例标注与思维导图功能、Zetero的知识库管理功能、Anki的间隔重复记忆系统，飞书云文档的markdown文本编辑功能以及AI智能分析能力，为普通法学习者提供一站式学习解决方案。

## ✨ 核心功能

### 📚 案例管理模块
- **案例导入**：支持PDF、TXT格式导入，URL抓取，剪贴板粘贴，OCR扫描识别
- **智能元数据提取**：自动识别案例标题、法院名称、判决日期、当事人信息
- **案例库管理**：卡片式布局，支持列表/卡片视图切换，多维度筛选排序
- **案例阅读器**：三栏布局（目录+正文+批注），支持PDF渲染和纯文本阅读
- **多维度标注系统**：高亮、下划线、删除线、区域标注、评论标注，支持多色选择
- **AI智能分析**：自动提取案例要素（争议焦点、法律规则、案件事实、判决结果）
- **案例关联对比**：基于关键词、引用关系、AI语义相似度进行案例关联

### 🌍 法律英语学习模块
- **划词翻译**：阅读时选中文字即可查看翻译和释义
- **词汇库管理**：个人词汇本，支持分类和标签
- **闪卡学习系统**：基于艾宾浩斯遗忘曲线的间隔重复算法
- **多维度复习**：拼写测试、选择题、例句填空
- **学习统计**：学习进度追踪，掌握程度分析

### 📝 知识库管理模块
- **个人笔记系统**：富文本/Markdown即时渲染编辑，支持双向链接
- **多级文件夹管理**：无限层级嵌套，拖拽排序
- **多标签分类**：支持标签颜色和层级
- **学习集功能**：案例、笔记、词汇、思维导图整合学习
- **思维导图**：无限画布，多种布局，节点关联原文
- **综合笔记**：学习集级别的知识整合

### 🤖 AI集成模块
- **多模型支持**：OpenAI GPT-4/GPT-3.5、Anthropic Claude、Google Gemini
- **智能查询**：基于本地案例库的智能问答
- **内容生成**：案例摘要、法律概念解释、测验生成
- **隐私保护**：数据本地处理，仅发送摘要作为上下文

## 🛠️ 技术栈

### 前端技术栈
| 技术 | 版本 | 用途 |
|------|------|------|
| Vue 3 | 3.x | 前端框架，Composition API |
| Element Plus | 2.x | UI组件库 |
| Pinia | 2.x | 状态管理 |
| Vue Router | 4.x | 路由管理 |
| Axios | 1.x | HTTP客户端 |
| Marked | 最新 | Markdown渲染 |

### 后端技术栈
| 技术 | 版本 | 用途 |
|------|------|------|
| Spring Boot | 3.x | 后端框架 |
| MyBatis | 3.x | ORM框架 |
| PageHelper | 最新 | 分页插件 |
| MySQL | 8.0 | 主数据库 |
| JWT | 0.12.x | 身份认证 |

## 📁 项目结构

```
LawofEnglishStudy/
├── frontend-demo/          # 前端项目
│   ├── src/
│   │   ├── components/     # 组件
│   │   ├── views/          # 页面视图
│   │   ├── router/         # 路由配置
│   │   ├── stores/         # 状态管理
│   │   └── styles/         # 样式文件
│   ├── package.json
│   └── vite.config.js
├── database/               # 数据库脚本
│   ├── schema.sql          # 数据库结构
│   └── seed_data.sql       # 初始数据
├── documents/              # 项目文档
│   ├── init/               # 初始化文档
│   ├── detailed_design.md  # 详细设计文档
│   └── update.md           # 更新日志

```

## 🚀 快速开始

### 环境要求
- Node.js 18+
- Java 17+
- MySQL 8.0+

### 前端启动（目前只做了前端）
```bash
cd frontend-demo
npm install
npm run dev
```

### 后端启动
```bash
# 配置数据库连接后
mvn spring-boot:run
```

### 数据库初始化
```bash
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed_data.sql
```

## 🎯 目标用户

| 用户类型 | 特征描述 | 核心需求 |
|----------|----------|----------|
| 法学院学生 | 正在学习普通法课程，需要大量阅读案例 | 案例整理、标注、复习 |
| 法律从业者 | 需要持续学习新案例，准备执业考试 | 案例检索、对比分析、知识更新 |
| 法学研究者 | 进行专题研究，需要系统整理文献 | 知识库构建、关联分析、论文写作辅助 |
| 法律英语爱好者 | 希望提升法律英语能力 | 词汇学习、翻译工具、例句积累 |


## 🤝 贡献指南

欢迎提交Issue和Pull Request！

## 📄 许可证

本项目采用 MIT 许可证。

## 📧 联系方式

如有问题或建议，欢迎通过以下方式联系我们：
- 邮箱：summer551223@gmail.com
- 项目主页：https://github.com/sumMer-ok/WeLaw

---

## ⚖️ 知识产权声明

> **知识产权声明**：本程序完全开源免费，仅用于法律共同体人群进行学习交流使用，不用于任何商业用途。未经授权，不得将本程序或其任何部分用于商业目的或进行商业性传播。使用者应遵守相关法律法规，尊重原作者的知识产权，在学习使用过程中不得侵犯任何第三方的合法权益。

---

<p align="center">Made with ❤️ for Common Law Learners</p>

---

# WeLaw - Common Law Learning Platform

<p align="center">
  <img src="https://img.shields.io/badge/Vue-3.x-4FC08D?style=flat-square&logo=vue.js" alt="Vue3">
  <img src="https://img.shields.io/badge/Spring%20Boot-3.x-6DB33F?style=flat-square&logo=spring" alt="Spring Boot">
  <img src="https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat-square&logo=mysql" alt="MySQL">
  <img src="https://img.shields.io/badge/Element%20Plus-2.x-409EFF?style=flat-square" alt="Element Plus">
</p>

中文 | [English](#WeLaw---common-law-learning-platform)

---

## 📖 Introduction

WeLaw is a comprehensive learning platform designed specifically for Common Law learners. It integrates MarginNote's case annotation and mind mapping features, Notion's knowledge base management, Anki's spaced repetition system, and AI-powered intelligent analysis to provide a one-stop learning solution for Common Law students.

## ✨ Core Features

### 📚 Case Management Module
- **Case Import**: Support PDF, TXT import, URL scraping, clipboard paste, OCR scanning
- **Smart Metadata Extraction**: Auto-identify case title, court name, judgment date, parties info
- **Case Library Management**: Card layout, list/card view switching, multi-dimensional filtering
- **Case Reader**: Three-column layout (outline + content + annotations), PDF rendering support
- **Multi-dimensional Annotation**: Highlight, underline, strikethrough, area annotation, comment annotation with color selection
- **AI Intelligent Analysis**: Auto-extract case elements (dispute focus, legal rules, facts, judgment results)
- **Case Association & Comparison**: Based on keywords, citation relationships, AI semantic similarity

### 🌍 Legal English Learning Module
- **Instant Translation**: Select text while reading to view translation and definitions
- **Vocabulary Management**: Personal vocabulary book with categories and tags
- **Flashcard System**: Spaced repetition algorithm based on Ebbinghaus forgetting curve
- **Multi-dimensional Review**: Spelling test, multiple choice, sentence completion
- **Learning Statistics**: Track learning progress and mastery level analysis

### 📝 Knowledge Base Module
- **Personal Notes**: Rich text/Markdown instant rendering editor with bidirectional linking
- **Multi-level Folder Management**: Unlimited nested hierarchy, drag-and-drop sorting
- **Multi-tag Classification**: Support tag colors and hierarchy
- **Study Sets**: Integrate cases, notes, vocabulary, mind maps for learning
- **Mind Mapping**: Infinite canvas, multiple layouts, node linking to original text
- **Comprehensive Notes**: Knowledge integration at study set level

### 🤖 AI Integration Module
- **Multi-model Support**: OpenAI GPT-4/GPT-3.5, Anthropic Claude, Google Gemini
- **Intelligent Query**: Smart Q&A based on local case database
- **Content Generation**: Case summaries, legal concept explanations, quiz generation
- **Privacy Protection**: Local data processing, only sending summaries as context

## 🛠️ Tech Stack

### Frontend Tech Stack
| Technology | Version | Purpose |
|------------|---------|---------|
| Vue 3 | 3.x | Frontend framework, Composition API |
| Element Plus | 2.x | UI component library |
| Pinia | 2.x | State management |
| Vue Router | 4.x | Route management |
| Axios | 1.x | HTTP client |
| Marked | Latest | Markdown rendering |

### Backend Tech Stack
| Technology | Version | Purpose |
|------------|---------|---------|
| Spring Boot | 3.x | Backend framework |
| MyBatis | 3.x | ORM framework |
| PageHelper | Latest | Pagination plugin |
| MySQL | 8.0 | Primary database |
| JWT | 0.12.x | Authentication |

## 📁 Project Structure

```
LawofEnglishStudy/
├── frontend-demo/          # Frontend project
│   ├── src/
│   │   ├── components/     # Components
│   │   ├── views/          # Page views
│   │   ├── router/         # Route configuration
│   │   ├── stores/         # State management
│   │   └── styles/         # Style files
│   ├── package.json
│   └── vite.config.js
├── database/               # Database scripts
│   ├── schema.sql          # Database schema
│   └── seed_data.sql       # Initial data
├── documents/              # Project documentation
│   ├── init/               # Initialization docs
│   ├── detailed_design.md  # Detailed design doc
│   └── update.md           # Update log

```

## 🚀 Quick Start

### Requirements
- Node.js 18+
- Java 17+
- MySQL 8.0+

### Frontend Setup
```bash
cd frontend-demo
npm install
npm run dev
```

### Backend Setup
```bash
# After configuring database connection
mvn spring-boot:run
```

### Database Initialization
```bash
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed_data.sql
```

## 🎯 Target Users

| User Type | Description | Core Needs |
|-----------|-------------|------------|
| Law Students | Studying Common Law courses, need extensive case reading | Case organization, annotation, review |
| Legal Practitioners | Continuous learning of new cases, preparing for bar exams | Case retrieval, comparative analysis, knowledge updates |
| Law Researchers | Thematic research, systematic literature organization | Knowledge base building, correlation analysis, thesis writing assistance |
| Legal English Enthusiasts | Want to improve legal English proficiency | Vocabulary learning, translation tools, sentence accumulation |


## 🤝 Contributing

Issues and Pull Requests are welcome!

## 📄 License

This project is licensed under the MIT License.

## 📧 Contact

For questions or suggestions, please contact us:
- Email: summer551223@gmail.com
- Project Homepage: https://github.com/sumMer-ok/WeLaw

---

## ⚖️ Intellectual Property Statement

> **Intellectual Property Statement**: This program is completely open-source and free, intended solely for learning and communication purposes within the legal community. It is not to be used for any commercial purposes. Without authorization, no part of this program may be used for commercial purposes or distributed commercially. Users should comply with relevant laws and regulations, respect the original author's intellectual property rights, and must not infringe upon the legitimate rights and interests of any third party during the learning and usage process.

---

<p align="center">Made with ❤️ for Common Law Learners</p>
