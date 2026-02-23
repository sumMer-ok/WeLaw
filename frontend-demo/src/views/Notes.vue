<template>
  <div class="notes-page">
    <!-- 左侧：文件夹导航 -->
    <aside class="folder-sidebar" :class="{ 'collapsed': folderSidebarCollapsed }">
      <div class="sidebar-header">
        <h3 class="sidebar-title">
          <el-icon><Folder /></el-icon>
          <span v-show="!folderSidebarCollapsed">笔记库</span>
        </h3>
        <el-button text size="small" @click="createFolder" v-show="!folderSidebarCollapsed">
          <el-icon><Plus /></el-icon>
        </el-button>
      </div>

      <!-- 文件夹树 -->
      <div class="folder-tree" v-show="!folderSidebarCollapsed">
        <div
          v-for="folder in folderTree"
          :key="folder.id"
          class="folder-item"
          :class="{ 
            'active': selectedFolderId === folder.id,
            'editing': editingFolderId === folder.id 
          }"
          :style="{ paddingLeft: (folder.level * 16 + 12) + 'px' }"
          @click="selectFolder(folder.id)"
        >
          <el-icon 
            class="expand-icon"
            v-if="folder.children?.length"
            @click.stop="toggleFolder(folder)"
          >
            <ArrowDown v-if="!folder.collapsed" />
            <ArrowRight v-else />
          </el-icon>
          <span v-else class="expand-placeholder"></span>

          <el-icon class="folder-icon">
            <FolderOpened v-if="selectedFolderId === folder.id || !folder.collapsed" />
            <Folder v-else />
          </el-icon>

          <el-input
            v-if="editingFolderId === folder.id"
            v-model="editingFolderName"
            size="small"
            @blur="saveFolderName"
            @keyup.enter="saveFolderName"
            @keyup.esc="cancelEditFolder"
            ref="folderInput"
          />

          <span v-else class="folder-name">{{ folder.name }}</span>
          <span class="note-count">{{ folder.noteCount || 0 }}</span>

          <div class="folder-actions" v-show="selectedFolderId === folder.id && editingFolderId !== folder.id">
            <el-button text size="small" @click.stop="startEditFolder(folder)">
              <el-icon><Edit /></el-icon>
            </el-button>
            <el-button text size="small" @click.stop="deleteFolder(folder)">
              <el-icon><Delete /></el-icon>
            </el-button>
          </div>
        </div>
      </div>

      <!-- 标签区域 -->
      <div class="tags-section" v-show="!folderSidebarCollapsed">
        <h4 class="section-title">
          <el-icon><CollectionTag /></el-icon>
          标签
        </h4>
        <div class="tags-list">
          <el-tag
            v-for="tag in tags"
            :key="tag.id"
            :color="tag.color"
            class="tag-item"
            :class="{ 'active': selectedTagId === tag.id }"
            @click="selectTag(tag.id)"
            size="small"
          >
            {{ tag.name }}
          </el-tag>
        </div>
      </div>

      <button class="collapse-btn" @click="folderSidebarCollapsed = !folderSidebarCollapsed">
        <el-icon><Fold v-if="!folderSidebarCollapsed" /><Expand v-else /></el-icon>
      </button>
    </aside>

    <!-- 中间：笔记列表 -->
    <div class="notes-list-panel" :class="{ 'expanded': !selectedNote }">
      <div class="list-header">
        <div class="list-title">
          <h3>{{ currentFolderName }}</h3>
          <span class="note-total">{{ filteredNotes.length }} 条笔记</span>
        </div>
        <div class="list-actions">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索笔记..."
            size="small"
            clearable
            class="search-input"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
          <el-button type="primary" size="small" @click="createNote">
            <el-icon><Plus /></el-icon>
            新建笔记
          </el-button>
        </div>
      </div>

      <div class="notes-list" ref="notesListRef">
        <div
          v-for="note in filteredNotes"
          :key="note.id"
          class="note-item"
          :class="{ 'active': selectedNote?.id === note.id }"
          @click="selectNote(note)"
        >
          <div class="note-header">
            <h4 class="note-title">{{ note.title || '无标题' }}</h4>
            <span class="note-time">{{ formatRelativeTime(note.updatedAt) }}</span>
          </div>
          <p class="note-excerpt">{{ getExcerpt(note.content) }}</p>
          <div class="note-meta">
            <div class="note-tags" v-if="note.tags?.length">
              <el-tag
                v-for="tag in getNoteTags(note.tags)"
                :key="tag.id"
                :color="tag.color"
                size="small"
                class="note-tag"
              >
                {{ tag.name }}
              </el-tag>
            </div>
            <div class="note-refs" v-if="note.caseRefs?.length || note.noteRefs?.length">
              <el-tooltip content="关联案例">
                <span class="ref-count" v-if="note.caseRefs?.length">
                  <el-icon><Document /></el-icon>
                  {{ note.caseRefs.length }}
                </span>
              </el-tooltip>
              <el-tooltip content="关联笔记">
                <span class="ref-count" v-if="note.noteRefs?.length">
                  <el-icon><Notebook /></el-icon>
                  {{ note.noteRefs.length }}
                </span>
              </el-tooltip>
            </div>
          </div>
        </div>

        <div v-if="filteredNotes.length === 0" class="empty-list">
          <el-icon class="empty-icon"><Document /></el-icon>
          <p>暂无笔记</p>
          <p class="empty-hint">点击右上角"新建笔记"按钮创建</p>
        </div>
      </div>
    </div>

    <!-- 右侧：笔记编辑器 -->
    <div class="note-editor-panel" v-if="selectedNote">
      <div class="editor-header">
        <div class="editor-nav">
          <el-button text @click="closeEditor">
            <el-icon><ArrowLeft /></el-icon>
            返回
          </el-button>
        </div>
        <div class="editor-title-area">
          <el-input
            v-model="selectedNote.title"
            placeholder="输入笔记标题..."
            class="title-input"
            @blur="saveNote"
          />
        </div>
        <div class="editor-actions">
          <el-tooltip content="分享">
            <el-button text @click="shareNote">
              <el-icon><Share /></el-icon>
            </el-button>
          </el-tooltip>
          <el-tooltip content="导出">
            <el-button text @click="exportNote">
              <el-icon><Download /></el-icon>
            </el-button>
          </el-tooltip>
          <el-dropdown @command="handleMoreAction">
            <el-button text>
              <el-icon><More /></el-icon>
            </el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="move">移动到...</el-dropdown-item>
                <el-dropdown-item command="tags">管理标签</el-dropdown-item>
                <el-dropdown-item command="history">历史版本</el-dropdown-item>
                <el-dropdown-item divided command="delete" class="danger">删除笔记</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>

      <!-- 编辑器工具栏 -->
      <div class="editor-toolbar">
        <div class="toolbar-group">
          <el-dropdown @command="(cmd) => formatBlock(cmd)">
            <el-button text size="small">
              <span class="toolbar-btn-text">正文</span>
              <el-icon><ArrowDown /></el-icon>
            </el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="p">正文</el-dropdown-item>
                <el-dropdown-item command="h1">标题 1</el-dropdown-item>
                <el-dropdown-item command="h2">标题 2</el-dropdown-item>
                <el-dropdown-item command="h3">标题 3</el-dropdown-item>
                <el-dropdown-item command="h4">标题 4</el-dropdown-item>
                <el-dropdown-item command="blockquote">引用</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
        <el-divider direction="vertical" />
        <div class="toolbar-group">
          <el-button text size="small" @click="formatText('bold')" :class="{ 'is-active': isBold }">
            <span style="font-weight: bold; font-size: 0.875rem;">B</span>
          </el-button>
          <el-button text size="small" @click="formatText('italic')" :class="{ 'is-active': isItalic }">
            <span style="font-style: italic; font-size: 0.875rem;">I</span>
          </el-button>
          <el-button text size="small" @click="formatText('underline')" :class="{ 'is-active': isUnderline }">
            <span style="text-decoration: underline; font-size: 0.875rem;">U</span>
          </el-button>
          <el-button text size="small" @click="formatText('strikeThrough')" :class="{ 'is-active': isStrikeThrough }">
            <el-icon><Delete /></el-icon>
          </el-button>
          <!-- 字体颜色 -->
          <el-dropdown @command="(color) => formatText('foreColor', color)" trigger="click">
            <el-button text size="small" :class="{ 'is-active': activeFontColor !== '#333' }">
              <span class="font-color-icon" :style="{ color: activeFontColor }">A</span>
            </el-button>
            <template #dropdown>
              <el-dropdown-menu class="color-dropdown-menu">
                <div class="color-palette">
                  <div
                    v-for="color in fontColors"
                    :key="color"
                    class="color-palette-item"
                    :style="{ background: color }"
                    @click="formatText('foreColor', color)"
                  ></div>
                </div>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
        <el-divider direction="vertical" />
        <div class="toolbar-group">
          <el-button text size="small" @click="formatText('insertUnorderedList')">
            <el-icon><List /></el-icon>
          </el-button>
          <el-button text size="small" @click="formatText('insertOrderedList')">
            <el-icon><Sort /></el-icon>
          </el-button>
          <el-button text size="small" @click="formatText('insertCheckbox')">
            <el-icon><Check /></el-icon>
          </el-button>
        </div>
        <el-divider direction="vertical" />
        <div class="toolbar-group">
          <el-button text size="small" @click="insertLink">
            <el-icon><Link /></el-icon>
          </el-button>
          <el-button text size="small" @click="insertImage">
            <el-icon><Picture /></el-icon>
          </el-button>
          <el-button text size="small" @click="insertTable">
            <el-icon><Grid /></el-icon>
          </el-button>
          <el-button text size="small" @click="insertCode">
            <el-icon><DocumentCopy /></el-icon>
          </el-button>
        </div>
        <el-divider direction="vertical" />
        <div class="toolbar-group">
          <el-button text size="small" @click="toggleCommentsPanel">
            <el-icon><ChatDotRound /></el-icon>
            <span class="comment-count" v-if="noteComments.length > 0">{{ noteComments.length }}</span>
          </el-button>
        </div>
      </div>

      <!-- 编辑器内容区 - 飞书风格即时渲染 -->
      <div class="editor-content-wrapper">
        <div class="editor-content" ref="editorContentRef">
          <!-- 可编辑区域 -->
          <div
            class="rich-editor"
            ref="editorRef"
            contenteditable="true"
            @input="onEditorInput"
            @mouseup="handleTextSelection"
            @mousedown="handleMouseDown"
            @keydown="handleEditorKeydown"
            v-html="editorContent"
          ></div>
        </div>

        <!-- 右侧评论面板 -->
        <div class="comments-panel" v-if="showCommentsPanel" :style="{ width: commentsPanelWidth + 'px' }">
          <div class="comments-header">
            <h4>评论 ({{ noteComments.length }})</h4>
            <el-button text @click="showCommentsPanel = false">
              <el-icon><Close /></el-icon>
            </el-button>
          </div>
          <div class="resize-handle" @mousedown="startResize"></div>
          
          <div class="comments-list" ref="commentsListRef">
            <div
              v-for="comment in noteComments"
              :key="comment.id"
              class="comment-card"
              :class="{ 'is-active': activeCommentId === comment.id }"
              :data-comment-id="comment.id"
            >
              <!-- 评论头部 - 引用原文 -->
              <div class="comment-header" @click="scrollToHighlight(comment.id)">
                <span style="font-size: 1.25rem; color: #909399;">"</span>
                <span class="quoted-text">{{ comment.selectedText }}</span>
              </div>
              
              <!-- 评论内容 -->
              <div class="comment-body">
                <div class="comment-author">
                  <el-avatar :size="24" :src="comment.avatar" />
                  <span class="author-name">{{ comment.author }}</span>
                  <span class="comment-time">{{ formatRelativeTime(comment.createdAt) }}</span>
                </div>
                <div class="comment-text">{{ comment.content }}</div>
                
                <!-- 评论图片 -->
                <div class="comment-images" v-if="comment.images?.length">
                  <img
                    v-for="(img, idx) in comment.images"
                    :key="idx"
                    :src="img"
                    class="comment-image"
                    @click="viewImage(img)"
                    @contextmenu.prevent="showImageContextMenu($event, img)"
                  />
                </div>
              </div>

              <!-- 评论操作 -->
              <div class="comment-actions">
                <el-button text size="small" @click="replyToComment(comment)">
                  <el-icon><ChatLineRound /></el-icon>
                  回复
                </el-button>
                <el-button text size="small" @click="editComment(comment)">
                  <el-icon><Edit /></el-icon>
                  编辑
                </el-button>
                <el-button text size="small" @click="deleteComment(comment)">
                  <el-icon><Delete /></el-icon>
                  删除
                </el-button>
              </div>

              <!-- 回复列表 -->
              <div class="replies-list" v-if="comment.replies?.length">
                <div
                  v-for="reply in comment.replies"
                  :key="reply.id"
                  class="reply-item"
                >
                  <div class="reply-author">
                    <el-avatar :size="20" :src="reply.avatar" />
                    <span class="author-name">{{ reply.author }}</span>
                    <span class="reply-time">{{ formatRelativeTime(reply.createdAt) }}</span>
                  </div>
                  <div class="reply-text">{{ reply.content }}</div>
                  <div class="reply-images" v-if="reply.images?.length">
                    <img
                      v-for="(img, idx) in reply.images"
                      :key="idx"
                      :src="img"
                      class="reply-image"
                      @click="viewImage(img)"
                    />
                  </div>
                  <div class="reply-actions">
                    <el-button text size="small" @click="editReply(comment, reply)">编辑</el-button>
                    <el-button text size="small" @click="deleteReply(comment, reply)">删除</el-button>
                  </div>
                </div>
              </div>
            </div>

            <!-- 空状态 -->
            <div v-if="noteComments.length === 0" class="empty-comments">
              <el-icon class="empty-icon"><ChatDotRound /></el-icon>
              <p>暂无评论</p>
              <p class="empty-hint">选中文本后点击"评论"按钮添加</p>
            </div>
          </div>

          <!-- 评论输入区域 -->
          <div
            v-if="showCommentInput"
            class="comment-input-area"
            @drop="handleImageDrop"
            @dragover.prevent
            @paste="handleImagePaste"
          >
            <div v-if="replyingTo" class="replying-to">
              <span>回复 {{ replyingTo.author }}</span>
              <el-button text size="small" @click="cancelReply">
                <el-icon><Close /></el-icon>
              </el-button>
            </div>
            <div v-if="selectedText" class="selected-text-hint">
              <span>引用: "{{ selectedText.substring(0, 50) }}{{ selectedText.length > 50 ? '...' : '' }}"</span>
              <el-button text size="small" @click="clearSelectedText">
                <el-icon><Close /></el-icon>
              </el-button>
            </div>
            <!-- 图片预览区域 -->
            <div v-if="newCommentImages.length" class="comment-images-preview">
              <div
                v-for="(img, index) in newCommentImages"
                :key="index"
                class="image-preview-item"
              >
                <img :src="img" alt="预览图片" />
                <el-button
                  class="remove-image-btn"
                  text
                  size="small"
                  @click="removeCommentImage(index)"
                >
                  <el-icon><Close /></el-icon>
                </el-button>
              </div>
            </div>
            <el-input
              v-model="newCommentContent"
              type="textarea"
              :rows="3"
              :placeholder="replyingTo ? '回复评论...（支持拖拽或粘贴图片）' : '添加评论...（支持拖拽或粘贴图片）'"
              @keydown="handleCommentKeydown"
            />
            <div class="input-actions">
              <div class="input-left">
                <el-button text @click="attachFile">
                  <el-icon><Paperclip /></el-icon>
                </el-button>
                <span class="image-hint">支持拖拽或粘贴图片</span>
              </div>
              <el-button type="primary" size="small" @click="submitComment">
                发送
              </el-button>
            </div>
          </div>
        </div>
      </div>

      <!-- 编辑器底部状态栏 -->
      <div class="editor-footer">
        <div class="footer-left">
          <span class="word-count">{{ wordCount }} 字</span>
          <el-divider direction="vertical" />
          <span class="save-status">{{ saveStatus }}</span>
        </div>
        <div class="footer-right">
          <span class="last-saved">最后保存: {{ formatTime(selectedNote.updatedAt) }}</span>
        </div>
      </div>
    </div>

    <!-- 空编辑器状态 -->
    <div class="empty-editor" v-else>
      <el-icon class="empty-icon"><EditPen /></el-icon>
      <p>选择或创建一个笔记开始编辑</p>
    </div>

    <!-- 选中文字工具栏 -->
    <div
      v-if="showAnnotationToolbar"
      class="annotation-toolbar"
      :style="toolbarPosition"
    >
      <div class="toolbar-content">
        <!-- 高亮 -->
        <div class="toolbar-item-wrapper" @mouseenter="showHighlightColors = true" @mouseleave="showHighlightColors = false">
          <div class="toolbar-item icon-only" @click="addHighlight(activeHighlightColor)">
            <div class="color-preview" :style="{ background: activeHighlightColor }"></div>
          </div>
          <div v-show="showHighlightColors" class="color-picker-dropdown">
            <div
              v-for="color in highlightColors"
              :key="color"
              class="color-dot"
              :class="{ active: activeHighlightColor === color }"
              :style="{ background: color }"
              @click.stop="addHighlight(color)"
            ></div>
          </div>
        </div>

        <!-- 字体颜色 -->
        <div class="toolbar-item-wrapper" @mouseenter="showFontColors = true" @mouseleave="showFontColors = false">
          <div class="toolbar-item icon-only" @click="addFontColor(activeFontColor)">
            <span class="font-color-preview" :style="{ color: activeFontColor }">A</span>
          </div>
          <div v-show="showFontColors" class="color-picker-dropdown">
            <div
              v-for="color in fontColors"
              :key="color"
              class="color-dot"
              :class="{ active: activeFontColor === color }"
              :style="{ background: color }"
              @click.stop="addFontColor(color)"
            ></div>
          </div>
        </div>

        <div class="toolbar-divider"></div>

        <!-- 评论 -->
        <el-tooltip content="评论" placement="top">
          <div class="toolbar-item icon-only" @click="addComment">
            <el-icon><ChatDotRound /></el-icon>
          </div>
        </el-tooltip>

        <!-- 加粗 -->
        <el-tooltip content="加粗" placement="top">
          <div class="toolbar-item icon-only" @click="formatSelection('bold')">
            <span style="font-weight: bold; font-size: 1rem;">B</span>
          </div>
        </el-tooltip>

        <!-- 斜体 -->
        <el-tooltip content="斜体" placement="top">
          <div class="toolbar-item icon-only" @click="formatSelection('italic')">
            <span style="font-style: italic; font-size: 1rem;">I</span>
          </div>
        </el-tooltip>

        <!-- 下划线（无颜色选择） -->
        <el-tooltip content="下划线" placement="top">
          <div class="toolbar-item icon-only" @click="formatSelection('underline')">
            <span style="text-decoration: underline; font-size: 1rem;">U</span>
          </div>
        </el-tooltip>

        <!-- 删除线 -->
        <el-tooltip content="删除线" placement="top">
          <div class="toolbar-item icon-only" @click="formatSelection('strikeThrough')">
            <span style="text-decoration: line-through; font-size: 1rem;">S</span>
          </div>
        </el-tooltip>

        <!-- 链接 -->
        <el-tooltip content="链接" placement="top">
          <div class="toolbar-item icon-only" @click="addLinkToSelection">
            <el-icon><Link /></el-icon>
          </div>
        </el-tooltip>

        <!-- 翻译 -->
        <el-tooltip content="翻译" placement="top">
          <div class="toolbar-item icon-only" @click="translateSelection">
            <el-icon><DocumentCopy /></el-icon>
          </div>
        </el-tooltip>
      </div>
    </div>



    <!-- 图片查看器 -->
    <div v-if="showImageViewer" class="image-viewer" @click="closeImageViewer">
      <img :src="viewingImage" @click.stop />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, nextTick, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Folder, FolderOpened, Plus, Edit, Delete, CollectionTag, Search,
  ArrowDown, ArrowRight, Fold, Expand, Document, Notebook, ArrowLeft,
  Share, Download, More, Close, ChatDotRound, ChatLineRound,
  Picture, EditPen, List, Sort,
  Check, Link, Grid, DocumentCopy, View, Hide, RefreshRight, ArrowUp,
  Paperclip
} from '@element-plus/icons-vue'

// ============ 状态管理 ============
const folderSidebarCollapsed = ref(false)
const selectedFolderId = ref('all')
const selectedTagId = ref(null)
const selectedNote = ref(null)
const searchKeyword = ref('')
const editingFolderId = ref(null)
const editingFolderName = ref('')
const saveStatus = ref('已保存')
const wordCount = ref(0)
const editorContent = ref('')
const editorRef = ref(null)

// 评论相关
const showCommentsPanel = ref(false)
const commentsPanelWidth = ref(320)
const noteComments = ref([])
const activeCommentId = ref(null)
const showCommentInput = ref(false)
const replyingTo = ref(null)

// 选中文字工具栏
const showAnnotationToolbar = ref(false)
const toolbarPosition = ref({ top: '0px', left: '0px' })
const selectedText = ref('')
const selectedRange = ref(null)
const showHighlightColors = ref(false)
const showFontColors = ref(false)
const activeHighlightColor = ref('#ffeb3b')
const activeFontColor = ref('#333333')
const highlightColors = ['#ffeb3b', '#ff9800', '#4caf50', '#2196f3', '#9c27b0', '#f44336']
const fontColors = ['#333333', '#f44336', '#ff9800', '#ffeb3b', '#4caf50', '#2196f3', '#9c27b0', '#9e9e9e']

// 评论输入
const newCommentContent = ref('')
const newCommentImages = ref([])

// 图片查看器
const showImageViewer = ref(false)
const viewingImage = ref('')

// 格式状态
const isBold = ref(false)
const isItalic = ref(false)
const isUnderline = ref(false)
const isStrikeThrough = ref(false)

// ============ 文件夹数据 ============
const folders = ref([
  { id: 'all', name: '全部笔记', parentId: null, icon: 'FolderOpened', color: null, noteCount: 12 },
  { id: '1', name: '合同法', parentId: null, icon: 'Folder', color: '#409EFF', noteCount: 5 },
  { id: '2', name: '侵权法', parentId: null, icon: 'Folder', color: '#67C23A', noteCount: 3 },
  { id: '3', name: '宪法', parentId: null, icon: 'Folder', color: '#E6A23C', noteCount: 2 },
  { id: '1-1', name: '合同违约', parentId: '1', icon: 'Folder', color: null, noteCount: 2 },
  { id: '1-2', name: '损害赔偿', parentId: '1', icon: 'Folder', color: null, noteCount: 3 },
  { id: '4', name: '学习笔记', parentId: null, icon: 'Folder', color: '#909399', noteCount: 2 },
  { id: '5', name: '待整理', parentId: null, icon: 'Folder', color: '#F56C6C', noteCount: 0 }
])

const folderTree = computed(() => {
  const buildTree = (parentId = null, level = 0) => {
    return folders.value
      .filter(f => f.parentId === parentId)
      .map(f => ({
        ...f,
        level,
        collapsed: false,
        children: buildTree(f.id, level + 1)
      }))
  }
  return buildTree()
})

// ============ 标签数据 ============
const tags = ref([
  { id: '1', name: '合同法', color: '#409EFF', usageCount: 5 },
  { id: '2', name: '案例笔记', color: '#67C23A', usageCount: 8 },
  { id: '3', name: '待复习', color: '#E6A23C', usageCount: 3 },
  { id: '4', name: '重要', color: '#F56C6C', usageCount: 2 },
  { id: '5', name: '英语术语', color: '#909399', usageCount: 4 }
])

// ============ 笔记数据 ============
const notes = ref([
  {
    id: '1',
    title: '合同法基本原则',
    content: '<h1>合同法基本原则</h1><p>合同当事人的法律地位平等，一方不得将自己的意志强加给另一方。</p><h2>1. 平等原则</h2><p>合同当事人的法律地位平等</p><h2>2. 自愿原则</h2><p>当事人依法享有自愿订立合同的权利</p><h2>3. 公平原则</h2><p>当事人应当遵循公平原则确定各方的权利和义务</p><blockquote><p>💡 <strong>关键要点</strong><br>诚实信用原则是合同法的"帝王条款"</p></blockquote><p>@Hadley v. Baxendale</p>',
    folderId: '1',
    tags: ['1', '2'],
    caseRefs: ['case-1'],
    noteRefs: [],
    wordCount: 156,
    createdAt: new Date('2026-02-20'),
    updatedAt: new Date('2026-02-21')
  },
  {
    id: '2',
    title: 'Hadley v. Baxendale 案例分析',
    content: '<h2>案情概要</h2><p>原告 Hadley 是一个磨坊主，被告 Baxendale 是一个运输商。原告的磨坊曲轴损坏，委托被告将曲轴运送到制造商处修理。被告延误了运输，导致原告的磨坊停工数日。</p><h2>判决要点</h2><p>损害赔偿的范围应当是：</p><ol><li>按照事物的通常进程自然产生的损失</li><li>当事人在订立合同时能够预见的损失</li></ol><pre><code>损害赔偿 = 预期利益 - 实际损失</code></pre><table><thead><tr><th>要素</th><th>本案</th><th>Hadley案</th></tr></thead><tbody><tr><td>违约类型</td><td>延迟交付</td><td>延迟交付</td></tr><tr><td>赔偿范围</td><td>预期利益</td><td>可预见损失</td></tr></tbody></table>',
    folderId: '1-2',
    tags: ['2', '4'],
    caseRefs: ['case-2'],
    noteRefs: ['1'],
    wordCount: 234,
    createdAt: new Date('2026-02-21'),
    updatedAt: new Date('2026-02-22')
  },
  {
    id: '3',
    title: '法律英语词汇 - 合同相关',
    content: '<h2>Contract Terms</h2><ul><li><strong>Breach of contract</strong> - 违约</li><li><strong>Material breach</strong> - 重大违约</li><li><strong>Minor breach</strong> - 轻微违约</li><li><strong>Anticipatory breach</strong> - 预期违约</li><li><strong>Damages</strong> - 损害赔偿</li><li><strong>Liquidated damages</strong> - 约定违约金</li><li><strong>Specific performance</strong> - 实际履行</li><li><strong>Injunction</strong> - 禁令救济</li></ul><blockquote><p>📌 记忆技巧：将术语放在具体案例语境中学习</p></blockquote>',
    folderId: '4',
    tags: ['5'],
    caseRefs: [],
    noteRefs: [],
    wordCount: 89,
    createdAt: new Date('2026-02-22'),
    updatedAt: new Date('2026-02-22')
  }
])

// 示例评论数据
const allComments = ref([
  {
    id: 'comment-1',
    noteId: '1',
    selectedText: '诚实信用原则是合同法的"帝王条款"',
    content: '这个表述非常准确，诚实信用原则确实是合同法的核心',
    author: '张三',
    avatar: '',
    createdAt: new Date('2026-02-21'),
    images: [],
    replies: []
  },
  {
    id: 'comment-2',
    noteId: '2',
    selectedText: '损害赔偿 = 预期利益 - 实际损失',
    content: '这个公式需要补充说明：还需要考虑可预见性规则的限制',
    author: '李四',
    avatar: '',
    createdAt: new Date('2026-02-22'),
    images: [],
    replies: [
      {
        id: 'reply-1',
        content: '同意，Hadley案确立的可预见性规则是关键',
        author: '王五',
        avatar: '',
        createdAt: new Date('2026-02-22'),
        images: []
      }
    ]
  }
])

// ============ 计算属性 ============
const currentFolderName = computed(() => {
  if (selectedTagId.value) {
    const tag = tags.value.find(t => t.id === selectedTagId.value)
    return tag ? `标签: ${tag.name}` : '标签筛选'
  }
  const folder = folders.value.find(f => f.id === selectedFolderId.value)
  return folder ? folder.name : '全部笔记'
})

const filteredNotes = computed(() => {
  let result = notes.value

  if (selectedFolderId.value && selectedFolderId.value !== 'all') {
    const folderIds = getFolderAndChildrenIds(selectedFolderId.value)
    result = result.filter(n => folderIds.includes(n.folderId))
  }

  if (selectedTagId.value) {
    result = result.filter(n => n.tags?.includes(selectedTagId.value))
  }

  if (searchKeyword.value) {
    const keyword = searchKeyword.value.toLowerCase()
    result = result.filter(n => 
      n.title?.toLowerCase().includes(keyword) ||
      n.content?.toLowerCase().includes(keyword)
    )
  }

  return result.sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt))
})

// ============ 方法 ============
function getFolderAndChildrenIds(folderId) {
  const ids = [folderId]
  const children = folders.value.filter(f => f.parentId === folderId)
  children.forEach(child => {
    ids.push(...getFolderAndChildrenIds(child.id))
  })
  return ids
}

function selectFolder(folderId) {
  selectedFolderId.value = folderId
  selectedTagId.value = null
  selectedNote.value = null
}

function selectTag(tagId) {
  selectedTagId.value = selectedTagId.value === tagId ? null : tagId
  selectedNote.value = null
}

function toggleFolder(folder) {
  folder.collapsed = !folder.collapsed
}

function selectNote(note) {
  selectedNote.value = note
  editorContent.value = note.content
  wordCount.value = note.wordCount || 0
  // 加载该笔记的评论
  noteComments.value = allComments.value.filter(c => c.noteId === note.id)
  // 恢复该笔记保存的颜色设置
  if (note.lastHighlightColor) {
    activeHighlightColor.value = note.lastHighlightColor
  } else {
    activeHighlightColor.value = '#ffeb3b'
  }
  if (note.lastUnderlineColor) {
    activeUnderlineColor.value = note.lastUnderlineColor
  } else {
    activeUnderlineColor.value = '#2196f3'
  }
}

function closeEditor() {
  selectedNote.value = null
}

function createNote() {
  const newNote = {
    id: 'note-' + Date.now(),
    title: '',
    content: '<p>开始输入笔记内容...</p>',
    folderId: selectedFolderId.value === 'all' ? null : selectedFolderId.value,
    tags: selectedTagId.value ? [selectedTagId.value] : [],
    caseRefs: [],
    noteRefs: [],
    wordCount: 0,
    createdAt: new Date(),
    updatedAt: new Date()
  }
  notes.value.unshift(newNote)
  selectNote(newNote)
}

function createFolder() {
  const newFolder = {
    id: 'folder-' + Date.now(),
    name: '新建文件夹',
    parentId: selectedFolderId.value === 'all' ? null : selectedFolderId.value,
    icon: 'Folder',
    color: null,
    noteCount: 0
  }
  folders.value.push(newFolder)
  editingFolderId.value = newFolder.id
  editingFolderName.value = newFolder.name
}

function startEditFolder(folder) {
  editingFolderId.value = folder.id
  editingFolderName.value = folder.name
}

function saveFolderName() {
  if (editingFolderId.value && editingFolderName.value.trim()) {
    const folder = folders.value.find(f => f.id === editingFolderId.value)
    if (folder) {
      folder.name = editingFolderName.value.trim()
    }
  }
  editingFolderId.value = null
  editingFolderName.value = ''
}

function cancelEditFolder() {
  if (editingFolderId.value?.startsWith('folder-')) {
    const index = folders.value.findIndex(f => f.id === editingFolderId.value)
    if (index > -1) {
      folders.value.splice(index, 1)
    }
  }
  editingFolderId.value = null
  editingFolderName.value = ''
}

function deleteFolder(folder) {
  ElMessageBox.confirm(`确定要删除文件夹"${folder.name}"吗？`, '删除文件夹', {
    confirmButtonText: '删除',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    const index = folders.value.findIndex(f => f.id === folder.id)
    if (index > -1) {
      folders.value.splice(index, 1)
      notes.value.forEach(note => {
        if (note.folderId === folder.id) {
          note.folderId = null
        }
      })
      ElMessage.success('文件夹已删除')
    }
  }).catch(() => {})
}

function getExcerpt(content) {
  if (!content) return ''
  // 移除 HTML 标签获取纯文本
  const plainText = content
    .replace(/<[^>]+>/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
  return plainText.slice(0, 100) + (plainText.length > 100 ? '...' : '')
}

function getNoteTags(tagIds) {
  return tags.value.filter(t => tagIds?.includes(t.id))
}

function formatRelativeTime(date) {
  const now = new Date()
  const diff = now - new Date(date)
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)

  if (minutes < 1) return '刚刚'
  if (minutes < 60) return `${minutes}分钟前`
  if (hours < 24) return `${hours}小时前`
  if (days < 7) return `${days}天前`
  return new Date(date).toLocaleDateString('zh-CN')
}

function formatTime(date) {
  return new Date(date).toLocaleString('zh-CN', {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function saveNote() {
  if (selectedNote.value) {
    selectedNote.value.updatedAt = new Date()
    saveStatus.value = '已保存'
  }
}

function onEditorInput() {
  if (selectedNote.value && editorRef.value) {
    selectedNote.value.content = editorRef.value.innerHTML
    selectedNote.value.updatedAt = new Date()
    selectedNote.value.wordCount = editorRef.value.innerText?.length || 0
    wordCount.value = selectedNote.value.wordCount
    saveStatus.value = '保存中...'
    setTimeout(() => {
      saveStatus.value = '已保存'
    }, 500)
  }
}

// ============ 编辑器工具栏功能 ============
function formatBlock(tag) {
  document.execCommand('formatBlock', false, tag)
  onEditorInput()
}

function formatText(command) {
  document.execCommand(command, false, null)
  onEditorInput()
  updateFormatStates()
}

function formatSelection(command) {
  document.execCommand(command, false, null)
  onEditorInput()
  showAnnotationToolbar.value = false
}

function insertLink() {
  const url = prompt('请输入链接地址：')
  if (url) {
    document.execCommand('createLink', false, url)
    onEditorInput()
  }
}

function insertImage() {
  const input = document.createElement('input')
  input.type = 'file'
  input.accept = 'image/*'
  input.onchange = (e) => {
    const file = e.target.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (event) => {
        document.execCommand('insertImage', false, event.target.result)
        onEditorInput()
      }
      reader.readAsDataURL(file)
    }
  }
  input.click()
}

function insertTable() {
  const html = `
    <table style="width:100%;border-collapse:collapse;margin:16px 0;">
      <thead>
        <tr>
          <th style="border:1px solid #ddd;padding:8px;">表头1</th>
          <th style="border:1px solid #ddd;padding:8px;">表头2</th>
          <th style="border:1px solid #ddd;padding:8px;">表头3</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td style="border:1px solid #ddd;padding:8px;">内容1</td>
          <td style="border:1px solid #ddd;padding:8px;">内容2</td>
          <td style="border:1px solid #ddd;padding:8px;">内容3</td>
        </tr>
      </tbody>
    </table>
  `
  document.execCommand('insertHTML', false, html)
  onEditorInput()
}

function insertCode() {
  const html = '<pre style="background:#f5f5f5;padding:16px;border-radius:4px;overflow-x:auto;"><code>// 在此输入代码</code></pre><p><br></p>'
  document.execCommand('insertHTML', false, html)
  onEditorInput()
}

function updateFormatStates() {
  isBold.value = document.queryCommandState('bold')
  isItalic.value = document.queryCommandState('italic')
  isUnderline.value = document.queryCommandState('underline')
  isStrikeThrough.value = document.queryCommandState('strikeThrough')
}

function handleEditorKeydown(e) {
  // Ctrl/Cmd + S 保存
  if ((e.ctrlKey || e.metaKey) && e.key === 's') {
    e.preventDefault()
    saveNote()
  }
}

// ============ 选中文字工具栏 ============
function handleMouseDown() {
  showAnnotationToolbar.value = false
}

function handleTextSelection() {
  const selection = window.getSelection()
  const text = selection.toString().trim()

  if (text && text.length > 0) {
    selectedText.value = text
    selectedRange.value = selection.getRangeAt(0)

    const range = selection.getRangeAt(0)
    const rect = range.getBoundingClientRect()
    toolbarPosition.value = {
      top: rect.top - 55 + 'px',
      left: Math.max(10, rect.left + rect.width / 2 - 150) + 'px'
    }

    showAnnotationToolbar.value = true
    updateFormatStates()
  } else {
    showAnnotationToolbar.value = false
  }
}

function addHighlight(color) {
  if (selectedRange.value) {
    const selection = window.getSelection()
    selection.removeAllRanges()
    selection.addRange(selectedRange.value)
    
    const span = document.createElement('span')
    span.style.backgroundColor = color
    span.style.padding = '2px 0'
    span.className = 'highlight-mark'
    
    try {
      selectedRange.value.surroundContents(span)
      onEditorInput()
    } catch (e) {
      // 跨元素选择时，使用另一种方式
      document.execCommand('hiliteColor', false, color)
      onEditorInput()
    }
  }
  // 保存颜色到当前笔记
  activeHighlightColor.value = color
  if (selectedNote.value) {
    selectedNote.value.lastHighlightColor = color
  }
  showAnnotationToolbar.value = false
  showHighlightColors.value = false
}

function addUnderline(color) {
  if (selectedRange.value) {
    const selection = window.getSelection()
    selection.removeAllRanges()
    selection.addRange(selectedRange.value)
    
    document.execCommand('underline', false, null)
    onEditorInput()
  }
  // 保存颜色到当前笔记
  activeUnderlineColor.value = color
  if (selectedNote.value) {
    selectedNote.value.lastUnderlineColor = color
  }
  showAnnotationToolbar.value = false
  showUnderlineColors.value = false
}

function addFontColor(color) {
  if (selectedRange.value) {
    const selection = window.getSelection()
    selection.removeAllRanges()
    selection.addRange(selectedRange.value)
    
    document.execCommand('foreColor', false, color)
    onEditorInput()
  }
  activeFontColor.value = color
  showAnnotationToolbar.value = false
  showFontColors.value = false
}

function addLinkToSelection() {
  const url = prompt('请输入链接地址：')
  if (url && selectedRange.value) {
    const selection = window.getSelection()
    selection.removeAllRanges()
    selection.addRange(selectedRange.value)
    document.execCommand('createLink', false, url)
    onEditorInput()
  }
  showAnnotationToolbar.value = false
}

function translateSelection() {
  if (selectedText.value) {
    ElMessage.info(`正在翻译: "${selectedText.value.substring(0, 30)}..."`)
    // 这里可以集成翻译API
  }
  showAnnotationToolbar.value = false
}

// ============ 评论功能 ============
function toggleCommentsPanel() {
  showCommentsPanel.value = !showCommentsPanel.value
}

function addComment() {
  if (selectedText.value) {
    showCommentInput.value = true
    showCommentsPanel.value = true
    newCommentContent.value = ''
    newCommentImages.value = []
    replyingTo.value = null
  }
}

function submitComment() {
  if (!newCommentContent.value.trim() && !newCommentImages.value.length) return

  if (replyingTo.value) {
    // 添加回复
    const reply = {
      id: 'reply-' + Date.now(),
      content: newCommentContent.value,
      author: '当前用户',
      avatar: '',
      createdAt: new Date(),
      images: [...newCommentImages.value]
    }
    
    if (!replyingTo.value.replies) {
      replyingTo.value.replies = []
    }
    replyingTo.value.replies.push(reply)
    
    ElMessage.success('回复已添加')
  } else {
    // 添加新评论
    const newComment = {
      id: 'comment-' + Date.now(),
      noteId: selectedNote.value.id,
      selectedText: selectedText.value,
      content: newCommentContent.value,
      author: '当前用户',
      avatar: '',
      createdAt: new Date(),
      images: [...newCommentImages.value],
      replies: []
    }

    allComments.value.push(newComment)
    noteComments.value.push(newComment)
    
    // 在原文中添加评论标记
    if (selectedRange.value) {
      const selection = window.getSelection()
      selection.removeAllRanges()
      selection.addRange(selectedRange.value)
      
      const span = document.createElement('span')
      span.className = 'comment-mark'
      span.dataset.commentId = newComment.id
      span.style.borderBottom = '2px solid #ffeb3b'
      span.style.cursor = 'pointer'
      
      try {
        selectedRange.value.surroundContents(span)
        onEditorInput()
      } catch (e) {
        console.log('无法添加评论标记')
      }
    }
    
    ElMessage.success('评论已添加')
  }

  // 重置输入
  newCommentContent.value = ''
  newCommentImages.value = []
  replyingTo.value = null
  showAnnotationToolbar.value = false
}

function handleCommentKeydown(e) {
  if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
    e.preventDefault()
    submitComment()
  }
}

function cancelReply() {
  replyingTo.value = null
}

function clearSelectedText() {
  selectedText.value = ''
  selectedRange.value = null
  showAnnotationToolbar.value = false
}

function attachFile() {
  const input = document.createElement('input')
  input.type = 'file'
  input.accept = 'image/*'
  input.onchange = (e) => {
    const files = Array.from(e.target.files).filter(f => f.type.startsWith('image/'))
    files.forEach(file => {
      const reader = new FileReader()
      reader.onload = (event) => {
        newCommentImages.value.push(event.target.result)
      }
      reader.readAsDataURL(file)
    })
  }
  input.click()
}

function handleImageDrop(e) {
  const files = Array.from(e.dataTransfer.files).filter(f => f.type.startsWith('image/'))
  files.forEach(file => {
    const reader = new FileReader()
    reader.onload = (event) => {
      newCommentImages.value.push(event.target.result)
    }
    reader.readAsDataURL(file)
  })
}

function handleImagePaste(e) {
  const items = e.clipboardData.items
  for (let item of items) {
    if (item.type.startsWith('image/')) {
      const file = item.getAsFile()
      const reader = new FileReader()
      reader.onload = (event) => {
        newCommentImages.value.push(event.target.result)
      }
      reader.readAsDataURL(file)
    }
  }
}

function removeCommentImage(index) {
  newCommentImages.value.splice(index, 1)
}

function replyToComment(comment) {
  replyingTo.value = comment
  showCommentInput.value = true
  showCommentsPanel.value = true
  newCommentContent.value = ''
  newCommentImages.value = []
}

function editComment(comment) {
  ElMessage.info('编辑评论功能开发中')
}

function deleteComment(comment) {
  ElMessageBox.confirm('确定要删除这条评论吗？', '删除评论', {
    confirmButtonText: '删除',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    const index = noteComments.value.findIndex(c => c.id === comment.id)
    if (index > -1) {
      noteComments.value.splice(index, 1)
      const allIndex = allComments.value.findIndex(c => c.id === comment.id)
      if (allIndex > -1) {
        allComments.value.splice(allIndex, 1)
      }
      ElMessage.success('评论已删除')
    }
  }).catch(() => {})
}

function scrollToHighlight(commentId) {
  activeCommentId.value = commentId
  const mark = editorRef.value?.querySelector(`[data-comment-id="${commentId}"]`)
  if (mark) {
    mark.scrollIntoView({ behavior: 'smooth', block: 'center' })
    mark.style.backgroundColor = '#ffeb3b'
    setTimeout(() => {
      mark.style.backgroundColor = ''
    }, 2000)
  }
}

function viewImage(img) {
  viewingImage.value = img
  showImageViewer.value = true
}

function closeImageViewer() {
  showImageViewer.value = false
}

function startResize(e) {
  const startX = e.clientX
  const startWidth = commentsPanelWidth.value

  const handleMouseMove = (e) => {
    const diff = startX - e.clientX
    commentsPanelWidth.value = Math.max(250, Math.min(500, startWidth + diff))
  }

  const handleMouseUp = () => {
    document.removeEventListener('mousemove', handleMouseMove)
    document.removeEventListener('mouseup', handleMouseUp)
  }

  document.addEventListener('mousemove', handleMouseMove)
  document.addEventListener('mouseup', handleMouseUp)
}

function shareNote() {
  ElMessage.success('分享链接已复制到剪贴板')
}

function exportNote() {
  ElMessage.success('笔记导出成功')
}

function handleMoreAction(command) {
  switch (command) {
    case 'delete':
      ElMessageBox.confirm('确定要删除这条笔记吗？', '删除笔记', {
        confirmButtonText: '删除',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        const index = notes.value.findIndex(n => n.id === selectedNote.value?.id)
        if (index > -1) {
          notes.value.splice(index, 1)
          selectedNote.value = null
          ElMessage.success('笔记已删除')
        }
      }).catch(() => {})
      break
    case 'move':
      ElMessage.info('移动功能开发中')
      break
    case 'tags':
      ElMessage.info('标签管理功能开发中')
      break
    case 'history':
      ElMessage.info('历史版本功能开发中')
      break
  }
}

onMounted(() => {
  // 初始化
})
</script>

<style lang="scss" scoped>
.notes-page {
  display: flex;
  height: 100vh;
  background: $bg-primary;
}

// 左侧文件夹侧边栏
.folder-sidebar {
  width: 220px;
  background: white;
  border-right: 1px solid $border-light;
  display: flex;
  flex-direction: column;
  transition: width 0.3s ease;
  position: relative;

  &.collapsed {
    width: 48px;

    .sidebar-header,
    .folder-tree,
    .tags-section {
      opacity: 0;
      pointer-events: none;
    }
  }

  .sidebar-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: $spacing-md;
    border-bottom: 1px solid $border-light;

    .sidebar-title {
      display: flex;
      align-items: center;
      gap: $spacing-sm;
      margin: 0;
      font-size: 1rem;
      font-weight: 600;
      color: $text-primary;

      .el-icon {
        font-size: 1.25rem;
        color: $primary;
      }
    }
  }

  .folder-tree {
    flex: 1;
    overflow-y: auto;
    padding: $spacing-sm 0;

    .folder-item {
      display: flex;
      align-items: center;
      padding: $spacing-sm $spacing-md;
      cursor: pointer;
      transition: all 0.2s;
      position: relative;

      &:hover {
        background: $bg-secondary;
      }

      &.active {
        background: rgba($primary, 0.1);
        color: $primary;
        border-right: 3px solid $primary;
      }

      &.editing {
        background: $bg-secondary;
        padding-right: $spacing-sm;
      }

      .expand-icon,
      .expand-placeholder {
        width: 16px;
        height: 16px;
        margin-right: $spacing-xs;
        font-size: 0.75rem;
        color: $text-tertiary;
      }

      .expand-icon {
        cursor: pointer;

        &:hover {
          color: $text-primary;
        }
      }

      .folder-icon {
        margin-right: $spacing-xs;
        font-size: 1rem;
        color: $primary;
      }

      .folder-name {
        flex: 1;
        font-size: 0.875rem;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .note-count {
        font-size: 0.75rem;
        color: $text-tertiary;
        margin-left: $spacing-xs;
      }

      .folder-actions {
        display: flex;
        gap: 2px;
        opacity: 0;
        transition: opacity 0.2s;

        .el-button {
          padding: 2px;
          font-size: 0.75rem;
        }
      }

      &:hover .folder-actions {
        opacity: 1;
      }

      .el-input {
        flex: 1;

        :deep(.el-input__wrapper) {
          padding: 0 4px;
        }

        :deep(input) {
          height: 24px;
          font-size: 0.875rem;
        }
      }
    }
  }

  .tags-section {
    padding: $spacing-md;
    border-top: 1px solid $border-light;

    .section-title {
      display: flex;
      align-items: center;
      gap: $spacing-xs;
      margin: 0 0 $spacing-sm 0;
      font-size: 0.75rem;
      font-weight: 600;
      color: $text-tertiary;
      text-transform: uppercase;
    }

    .tags-list {
      display: flex;
      flex-wrap: wrap;
      gap: $spacing-xs;

      .tag-item {
        cursor: pointer;
        transition: all 0.2s;

        &:hover {
          transform: scale(1.05);
        }

        &.active {
          box-shadow: 0 0 0 2px $primary;
        }
      }
    }
  }

  .collapse-btn {
    position: absolute;
    right: -12px;
    top: 50%;
    transform: translateY(-50%);
    width: 24px;
    height: 48px;
    background: white;
    border: 1px solid $border-light;
    border-radius: 0 $radius-md $radius-md 0;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    color: $text-tertiary;
    transition: all 0.2s;
    z-index: 10;

    &:hover {
      color: $primary;
      border-color: $primary;
    }
  }
}

// 中间笔记列表
.notes-list-panel {
  width: 320px;
  background: white;
  border-right: 1px solid $border-light;
  display: flex;
  flex-direction: column;
  transition: width 0.3s ease;

  &.expanded {
    flex: 1;
  }

  .list-header {
    padding: $spacing-md;
    border-bottom: 1px solid $border-light;

    .list-title {
      display: flex;
      align-items: baseline;
      justify-content: space-between;
      margin-bottom: $spacing-sm;

      h3 {
        margin: 0;
        font-size: 1.125rem;
        font-weight: 600;
        color: $text-primary;
      }

      .note-total {
        font-size: 0.75rem;
        color: $text-tertiary;
      }
    }

    .list-actions {
      display: flex;
      gap: $spacing-sm;

      .search-input {
        flex: 1;
      }
    }
  }

  .notes-list {
    flex: 1;
    overflow-y: auto;
    padding: $spacing-sm;

    .note-item {
      padding: $spacing-md;
      border-radius: $radius-md;
      cursor: pointer;
      transition: all 0.2s;
      margin-bottom: $spacing-sm;
      border: 1px solid transparent;

      &:hover {
        background: $bg-secondary;
        border-color: $border-light;
      }

      &.active {
        background: rgba($primary, 0.08);
        border-color: $primary;
      }

      .note-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: $spacing-xs;

        .note-title {
          margin: 0;
          font-size: 0.9375rem;
          font-weight: 600;
          color: $text-primary;
          flex: 1;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }

        .note-time {
          font-size: 0.75rem;
          color: $text-tertiary;
          white-space: nowrap;
          margin-left: $spacing-sm;
        }
      }

      .note-excerpt {
        margin: 0 0 $spacing-sm 0;
        font-size: 0.8125rem;
        color: $text-secondary;
        line-height: 1.5;
        overflow: hidden;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
      }

      .note-meta {
        display: flex;
        justify-content: space-between;
        align-items: center;

        .note-tags {
          display: flex;
          gap: 4px;
          flex-wrap: wrap;

          .note-tag {
            font-size: 0.6875rem;
          }
        }

        .note-refs {
          display: flex;
          gap: $spacing-sm;

          .ref-count {
            display: flex;
            align-items: center;
            gap: 2px;
            font-size: 0.75rem;
            color: $text-tertiary;

            .el-icon {
              font-size: 0.875rem;
            }
          }
        }
      }
    }

    .empty-list {
      text-align: center;
      padding: $spacing-2xl 0;
      color: $text-tertiary;

      .empty-icon {
        font-size: 3rem;
        margin-bottom: $spacing-md;
      }

      p {
        margin: 0;

        &.empty-hint {
          font-size: 0.8125rem;
          margin-top: $spacing-xs;
        }
      }
    }
  }
}

// 右侧编辑器
.note-editor-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: white;

  .editor-header {
    display: flex;
    align-items: center;
    padding: $spacing-md;
    border-bottom: 1px solid $border-light;
    gap: $spacing-md;

    .editor-nav {
      .el-button {
        color: $text-secondary;
      }
    }

    .editor-title-area {
      flex: 1;

      .title-input {
        :deep(.el-input__wrapper) {
          box-shadow: none;
          padding: 0;
        }

        :deep(input) {
          font-size: 1.25rem;
          font-weight: 600;
          color: $text-primary;
          padding: 0;

          &::placeholder {
            color: $text-tertiary;
          }
        }
      }
    }

    .editor-actions {
      display: flex;
      gap: $spacing-xs;
    }
  }

  .editor-toolbar {
    display: flex;
    align-items: center;
    padding: $spacing-sm $spacing-md;
    border-bottom: 1px solid $border-light;
    gap: $spacing-xs;
    flex-wrap: wrap;

    .toolbar-group {
      display: flex;
      gap: 2px;
      align-items: center;
    }

    .el-button {
      padding: 4px 8px;
      font-size: 0.875rem;
      min-width: 32px;
      height: 32px;

      &:hover {
        background: $bg-secondary;
      }

      &.is-active {
        background: rgba($primary, 0.1);
        color: $primary;
      }
    }

    .el-dropdown {
      display: flex;
      align-items: center;
    }

    .toolbar-btn-text {
      margin-right: 4px;
    }

    .comment-count {
      margin-left: 4px;
      font-size: 0.75rem;
      background: $primary;
      color: white;
      padding: 0 6px;
      border-radius: 10px;
    }

    .font-color-icon {
      font-size: 0.875rem;
      font-weight: bold;
    }

    .el-divider {
      margin: 0 $spacing-xs;
    }
  }

  // 颜色选择器下拉菜单
  :deep(.color-dropdown-menu) {
    padding: 8px;

    .color-palette {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 6px;

      .color-palette-item {
        width: 24px;
        height: 24px;
        border-radius: 4px;
        cursor: pointer;
        border: 2px solid transparent;
        transition: all 0.2s;

        &:hover {
          border-color: $text-primary;
          transform: scale(1.1);
        }
      }
    }
  }

  .editor-content-wrapper {
    flex: 1;
    display: flex;
    overflow: hidden;

    .editor-content {
      flex: 1;
      overflow-y: auto;
      padding: $spacing-lg;
      background: white;

      .rich-editor {
        min-height: 100%;
        font-size: 1rem;
        line-height: 1.8;
        color: $text-primary;
        outline: none;

        :deep(h1) {
          font-size: 1.75rem;
          font-weight: 600;
          margin: $spacing-lg 0 $spacing-md;
          line-height: 1.3;
        }

        :deep(h2) {
          font-size: 1.375rem;
          font-weight: 600;
          margin: $spacing-lg 0 $spacing-md;
          line-height: 1.4;
        }

        :deep(h3) {
          font-size: 1.125rem;
          font-weight: 600;
          margin: $spacing-md 0 $spacing-sm;
          line-height: 1.5;
        }

        :deep(h4) {
          font-size: 1rem;
          font-weight: 600;
          margin: $spacing-md 0 $spacing-sm;
        }

        :deep(p) {
          margin-bottom: $spacing-md;
          line-height: 1.8;
        }

        :deep(ul), :deep(ol) {
          margin: $spacing-md 0;
          padding-left: $spacing-xl;
        }

        :deep(li) {
          margin-bottom: $spacing-xs;
        }

        :deep(blockquote) {
          border-left: 4px solid $primary;
          padding: $spacing-sm $spacing-md;
          margin: $spacing-md 0;
          background: $bg-secondary;
          color: $text-secondary;
          border-radius: 0 $radius-sm $radius-sm 0;

          p {
            margin: 0;
          }
        }

        :deep(pre) {
          background: #f5f5f5;
          padding: $spacing-md;
          border-radius: $radius-md;
          overflow-x: auto;
          margin: $spacing-md 0;

          code {
            font-family: 'Fira Code', monospace;
            font-size: 0.875rem;
            background: none;
            padding: 0;
          }
        }

        :deep(code) {
          background: $bg-tertiary;
          padding: 2px 6px;
          border-radius: $radius-sm;
          font-family: 'Fira Code', monospace;
          font-size: 0.875rem;
        }

        :deep(table) {
          width: 100%;
          border-collapse: collapse;
          margin: $spacing-md 0;

          th, td {
            border: 1px solid $border-light;
            padding: $spacing-sm;
            text-align: left;
          }

          th {
            background: $bg-secondary;
            font-weight: 600;
          }
        }

        :deep(img) {
          max-width: 100%;
          border-radius: $radius-md;
          margin: $spacing-md 0;
        }

        :deep(a) {
          color: $primary;
          text-decoration: none;

          &:hover {
            text-decoration: underline;
          }
        }

        :deep(.highlight-mark) {
          padding: 2px 0;
          border-radius: 2px;
        }

        :deep(.comment-mark) {
          border-bottom: 2px solid #ffeb3b;
          cursor: pointer;
          transition: background 0.2s;

          &:hover {
            background: rgba(255, 235, 59, 0.3);
          }
        }
      }
    }

    // 评论面板
    .comments-panel {
      border-left: 1px solid $border-light;
      background: $bg-secondary;
      display: flex;
      flex-direction: column;
      position: relative;

      .resize-handle {
        position: absolute;
        left: -3px;
        top: 0;
        bottom: 0;
        width: 6px;
        cursor: col-resize;
        z-index: 10;

        &:hover {
          background: $primary;
          opacity: 0.3;
        }
      }

      .comments-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: $spacing-md;
        border-bottom: 1px solid $border-light;
        background: white;

        h4 {
          margin: 0;
          font-size: 0.9375rem;
          font-weight: 600;
        }
      }

      .comments-list {
        flex: 1;
        overflow-y: auto;
        padding: $spacing-md;

        .comment-card {
          background: white;
          border-radius: $radius-md;
          padding: $spacing-md;
          margin-bottom: $spacing-md;
          border: 1px solid $border-light;
          transition: all 0.2s;

          &.is-active {
            border-color: $primary;
            box-shadow: 0 0 0 2px rgba($primary, 0.1);
          }

          .comment-header {
            display: flex;
            align-items: flex-start;
            gap: $spacing-sm;
            padding: $spacing-sm;
            background: #fffbeb;
            border-radius: $radius-sm;
            margin-bottom: $spacing-sm;
            cursor: pointer;

            .el-icon {
              color: #f59e0b;
              flex-shrink: 0;
            }

            .quoted-text {
              font-size: 0.8125rem;
              color: $text-secondary;
              overflow: hidden;
              display: -webkit-box;
              -webkit-line-clamp: 2;
              -webkit-box-orient: vertical;
            }
          }

          .comment-body {
            .comment-author {
              display: flex;
              align-items: center;
              gap: $spacing-sm;
              margin-bottom: $spacing-sm;

              .author-name {
                font-size: 0.8125rem;
                font-weight: 500;
                color: $text-primary;
              }

              .comment-time {
                font-size: 0.75rem;
                color: $text-tertiary;
              }
            }

            .comment-text {
              font-size: 0.875rem;
              color: $text-primary;
              line-height: 1.6;
              margin-bottom: $spacing-sm;
            }

            .comment-images {
              display: flex;
              flex-wrap: wrap;
              gap: $spacing-sm;
              margin-bottom: $spacing-sm;

              .comment-image {
                width: 80px;
                height: 80px;
                object-fit: cover;
                border-radius: $radius-sm;
                cursor: pointer;
                transition: transform 0.2s;

                &:hover {
                  transform: scale(1.05);
                }
              }
            }
          }

          .comment-actions {
            display: flex;
            gap: $spacing-xs;
            padding-top: $spacing-sm;
            border-top: 1px solid $border-light;

            .el-button {
              font-size: 0.75rem;
            }
          }

          .replies-list {
            margin-top: $spacing-md;
            padding-left: $spacing-lg;
            border-left: 2px solid $border-light;

            .reply-item {
              padding: $spacing-sm 0;
              border-bottom: 1px solid $border-light;

              &:last-child {
                border-bottom: none;
              }

              .reply-author {
                display: flex;
                align-items: center;
                gap: $spacing-xs;
                margin-bottom: $spacing-xs;

                .author-name {
                  font-size: 0.75rem;
                  font-weight: 500;
                }

                .reply-time {
                  font-size: 0.6875rem;
                  color: $text-tertiary;
                }
              }

              .reply-text {
                font-size: 0.8125rem;
                color: $text-secondary;
                line-height: 1.5;
              }

              .reply-images {
                display: flex;
                flex-wrap: wrap;
                gap: $spacing-xs;
                margin-top: $spacing-xs;

                .reply-image {
                  width: 60px;
                  height: 60px;
                  object-fit: cover;
                  border-radius: $radius-sm;
                  cursor: pointer;
                }
              }

              .reply-actions {
                display: flex;
                gap: $spacing-xs;
                margin-top: $spacing-xs;

                .el-button {
                  font-size: 0.6875rem;
                  padding: 2px 6px;
                }
              }
            }
          }
        }

        .empty-comments {
          text-align: center;
          padding: $spacing-xl 0;
          color: $text-tertiary;

          .empty-icon {
            font-size: 2.5rem;
            margin-bottom: $spacing-sm;
          }

          p {
            margin: 0;
            font-size: 0.875rem;

            &.empty-hint {
              font-size: 0.75rem;
              margin-top: $spacing-xs;
            }
          }
        }
      }

      // 评论输入区域
      .comment-input-area {
        padding: $spacing-md;
        background: white;
        border-top: 1px solid $border-light;

        .replying-to,
        .selected-text-hint {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: $spacing-xs $spacing-sm;
          background: $bg-secondary;
          border-radius: $radius-sm;
          margin-bottom: $spacing-sm;
          font-size: 0.8125rem;
          color: $text-secondary;

          .el-button {
            padding: 2px;
            height: auto;
          }
        }

        .comment-images-preview {
          display: flex;
          flex-wrap: wrap;
          gap: $spacing-sm;
          margin-bottom: $spacing-sm;

          .image-preview-item {
            position: relative;
            width: 60px;
            height: 60px;

            img {
              width: 100%;
              height: 100%;
              object-fit: cover;
              border-radius: $radius-sm;
            }

            .remove-image-btn {
              position: absolute;
              top: -4px;
              right: -4px;
              width: 16px;
              height: 16px;
              padding: 0;
              min-height: auto;
              background: $danger;
              color: white;
              border-radius: 50%;

              .el-icon {
                font-size: 0.625rem;
              }
            }
          }
        }

        .el-textarea {
          margin-bottom: $spacing-sm;
        }

        .input-actions {
          display: flex;
          justify-content: space-between;
          align-items: center;

          .input-left {
            display: flex;
            align-items: center;
            gap: $spacing-sm;

            .image-hint {
              font-size: 0.75rem;
              color: $text-tertiary;
            }
          }
        }
      }
    }
  }

  .editor-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: $spacing-sm $spacing-md;
    border-top: 1px solid $border-light;
    font-size: 0.75rem;
    color: $text-tertiary;

    .footer-left,
    .footer-right {
      display: flex;
      align-items: center;
      gap: $spacing-sm;
    }

    .word-count {
      font-weight: 500;
    }

    .save-status {
      color: $success;
    }
  }
}

// 空编辑器状态
.empty-editor {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: $text-tertiary;
  background: white;

  .empty-icon {
    font-size: 4rem;
    margin-bottom: $spacing-md;
  }

  p {
    margin: 0;
  }
}

// 选中文字工具栏
.annotation-toolbar {
  position: fixed;
  z-index: 1000;
  background: white;
  border-radius: $radius-md;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  padding: 8px 12px;

  .toolbar-content {
    display: flex;
    align-items: center;
    gap: 8px;

    .toolbar-item-wrapper {
      position: relative;

      .toolbar-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 2px;
        padding: 6px 8px;
        cursor: pointer;
        border-radius: $radius-sm;
        transition: all 0.2s ease;

        &:hover {
          background: $bg-secondary;
          transform: translateY(-2px);
        }

        &:active {
          transform: translateY(0);
        }

        &.icon-only {
          padding: 8px;
          min-width: 32px;
          min-height: 32px;
          justify-content: center;
        }

        .color-preview {
          width: 18px;
          height: 18px;
          border-radius: 3px;
          transition: transform 0.2s ease;
        }

        .underline-preview {
          width: 18px;
          height: 18px;
          border-bottom: 3px solid;
          transition: transform 0.2s ease;
        }

        .font-color-preview {
          width: 18px;
          height: 18px;
          font-size: 0.875rem;
          font-weight: bold;
          display: flex;
          align-items: center;
          justify-content: center;
          transition: transform 0.2s ease;
        }

        &:hover .color-preview,
        &:hover .underline-preview,
        &:hover .font-color-preview {
          transform: scale(1.1);
        }

        span {
          font-size: 0.6875rem;
          color: $text-secondary;
        }

        .el-icon {
          font-size: 1rem;
          color: $text-primary;
          transition: transform 0.2s ease;
        }

        &:hover .el-icon {
          transform: scale(1.1);
        }
      }

      .color-picker-dropdown {
        position: absolute;
        top: 100%;
        left: 50%;
        transform: translateX(-50%);
        margin-top: 6px;
        background: white;
        border-radius: $radius-sm;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        padding: $spacing-sm;
        display: flex;
        gap: 8px;
        z-index: 1001;

        .color-dot {
          width: 20px;
          height: 20px;
          border-radius: 50%;
          cursor: pointer;
          border: 2px solid transparent;
          transition: all 0.2s ease;

          &:hover {
            border-color: $text-primary;
            transform: scale(1.2);
          }

          &.active {
            border-color: $text-primary;
            transform: scale(1.1);
            box-shadow: 0 0 0 2px white, 0 0 0 4px $primary;
          }
        }
      }
    }

    .toolbar-divider {
      width: 1px;
      height: 24px;
      background: $border-light;
      margin: 0 8px;
    }
  }
}

// 评论对话框
.comment-dialog-content {
  .quoted-text-preview {
    display: flex;
    align-items: flex-start;
    gap: $spacing-sm;
    padding: $spacing-sm;
    background: #fffbeb;
    border-radius: $radius-sm;
    margin-bottom: $spacing-md;

    .el-icon {
      color: #f59e0b;
      flex-shrink: 0;
    }

    span {
      font-size: 0.8125rem;
      color: $text-secondary;
    }
  }

  .image-upload-area {
    margin-top: $spacing-md;

    .upload-dropzone {
      border: 2px dashed $border-light;
      border-radius: $radius-md;
      padding: $spacing-lg;
      text-align: center;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        border-color: $primary;
        background: $bg-secondary;
      }

      .el-icon {
        font-size: 1.5rem;
        color: $text-tertiary;
        margin-bottom: $spacing-xs;
      }

      span {
        font-size: 0.8125rem;
        color: $text-tertiary;
      }
    }

    .uploaded-images {
      display: flex;
      flex-wrap: wrap;
      gap: $spacing-sm;
      margin-top: $spacing-sm;

      .image-preview {
        position: relative;
        width: 80px;
        height: 80px;

        img {
          width: 100%;
          height: 100%;
          object-fit: cover;
          border-radius: $radius-sm;
        }

        .delete-image {
          position: absolute;
          top: -6px;
          right: -6px;
          width: 18px;
          height: 18px;
          background: $danger;
          color: white;
          border-radius: 50%;
          cursor: pointer;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 0.75rem;

          &:hover {
            background: darken($danger, 10%);
          }
        }
      }
    }
  }
}

// 图片查看器
.image-viewer {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  cursor: zoom-out;

  img {
    max-width: 90%;
    max-height: 90%;
    object-fit: contain;
    cursor: default;
  }
}
</style>