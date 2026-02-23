import { createRouter, createWebHistory } from 'vue-router'
import Dashboard from '@/views/Dashboard.vue'
import CaseLibrary from '@/views/CaseLibrary.vue'
import CaseReader from '@/views/CaseReader.vue'
import Vocabulary from '@/views/Vocabulary.vue'
import Flashcards from '@/views/Flashcards.vue'
import StudySets from '@/views/StudySets.vue'
import MindMap from '@/views/MindMap.vue'
import AIAssistant from '@/views/AIAssistant.vue'
import Notes from '@/views/Notes.vue'
import FileLibrary from '@/views/FileLibrary.vue'

const routes = [
  {
    path: '/',
    name: 'Dashboard',
    component: Dashboard,
    meta: { title: '仪表盘', icon: 'HomeFilled' }
  },
  {
    path: '/cases',
    name: 'CaseLibrary',
    component: CaseLibrary,
    meta: { title: '案例库', icon: 'Document' }
  },
  {
    path: '/cases/:id',
    name: 'CaseReader',
    component: CaseReader,
    meta: { title: '案例阅读', icon: 'Reading' }
  },
  {
    path: '/vocabulary',
    name: 'Vocabulary',
    component: Vocabulary,
    meta: { title: '单词库', icon: 'Collection' }
  },
  {
    path: '/notes',
    name: 'Notes',
    component: Notes,
    meta: { title: '笔记库', icon: 'Notebook' }
  },
  {
    path: '/flashcards',
    name: 'Flashcards',
    component: Flashcards,
    meta: { title: '闪卡复习', icon: 'Memo' }
  },
  {
    path: '/study-sets',
    name: 'StudySets',
    component: StudySets,
    meta: { title: '学习集', icon: 'FolderOpened' }
  },
  {
    path: '/files',
    name: 'FileLibrary',
    component: FileLibrary,
    meta: { title: '文件库', icon: 'Folder' }
  },
  {
    path: '/mindmap/:id?',
    name: 'MindMap',
    component: MindMap,
    meta: { title: '思维导图', icon: 'Share' }
  },
  {
    path: '/ai-assistant',
    name: 'AIAssistant',
    component: AIAssistant,
    meta: { title: 'AI助手', icon: 'ChatDotRound' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
