# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EnofLaw (enoflaw-frontend-demo) — a Vue 3 frontend for a common law study platform targeting legal students, practitioners, and researchers. Currently frontend-only with mock data in Pinia stores; no backend is implemented yet.

## Build & Run

All commands run from `frontend-demo/`:

```bash
npm install        # install dependencies
npm run dev        # start Vite dev server
npm run build      # production build
npm run preview    # preview production build
```

## Tech Stack

- **Framework:** Vue 3.4 (Composition API) + Vue Router 4 + Pinia
- **UI:** Element Plus 2.5 + Element Plus Icons
- **Styling:** SCSS with shared variables (`src/styles/variables.scss`), global styles in `src/styles/global.scss`
- **Build:** Vite 5 with `@` path alias → `src/`
- **Key libs:** Marked (markdown), Mermaid (diagrams), pdfjs-dist (PDF), vuedraggable, D3.js

## Architecture

```
frontend-demo/src/
├── main.js              # app entry, registers Element Plus + Pinia + Router
├── App.vue              # root layout (sidebar + topbar + router-view)
├── router/index.js      # 10 routes (dashboard, cases, vocabulary, notes, flashcards, study-sets, files, mindmap, ai-assistant)
├── stores/index.js      # all Pinia stores in one file (useMainStore, useCasesStore, useVocabStore, useStudySetsStore, useAIStore)
├── services/ai.js       # AI chat service (OpenAI-compatible API via hiapi.online, model: gpt-4o-mini)
├── components/layout/   # Sidebar.vue, TopBar.vue
├── views/               # page-level components, one per route
└── styles/              # global.scss, variables.scss
```

Key patterns:
- All Pinia stores are co-located in a single `stores/index.js` file
- Case data (content, metadata, annotations) is currently mocked inside `useCasesStore`
- AI service uses a hardcoded API key — must be moved to env vars before production
- Vite config injects `variables.scss` globally via `css.preprocessorOptions`

## Routing

| Path | View | Description |
|------|------|-------------|
| `/` | Dashboard | Learning progress overview |
| `/cases` | CaseLibrary | Browse/filter legal cases |
| `/cases/:id` | CaseReader | Read case with annotations |
| `/vocabulary` | Vocabulary | Vocabulary deck management |
| `/flashcards` | Flashcards | Spaced repetition review |
| `/notes` | Notes | Note-taking |
| `/study-sets` | StudySets | Grouped learning materials |
| `/files` | FileLibrary | Document management |
| `/mindmap/:id?` | MindMap | Visual concept mapping |
| `/ai-assistant` | AIAssistant | Chat with AI legal assistant |

## Language

The UI is in Chinese (zh-CN). Code comments and documentation are also primarily in Chinese.
