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

      <button class="collapse-btn" @click="toggleFolderSidebar">
        <el-icon><Fold v-if="!folderSidebarCollapsed" /><Expand v-else /></el-icon>
      </button>
    </aside>

    <!-- 中间：笔记列表 -->
    <div class="notes-list-panel" :class="{ 'expanded': !selectedNote, 'collapsed': notesListCollapsed }">
      <button class="collapse-list-btn" @click="toggleNotesList" :class="{ 'collapsed': notesListCollapsed }">
        <el-icon><ArrowLeft v-if="!notesListCollapsed" /><ArrowRight v-else /></el-icon>
      </button>
      
      <template v-if="!notesListCollapsed">
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
      </template>
    </div>

    <!-- 右侧：笔记编辑器 -->
    <div class="note-editor-panel" v-if="selectedNote" :class="{ 'is-fullscreen': isFullscreen }">
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
          <el-dropdown trigger="click">
            <el-button text size="small" :class="{ 'is-active': activeFontColor !== '#333' }" @click.stop>
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
                    @click.stop="formatText('foreColor', color)"
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
          <el-button text size="small" @click="showOutlinePanel = !showOutlinePanel" :type="showOutlinePanel ? 'primary' : ''">
            <el-icon><Document /></el-icon>
          </el-button>
          <el-button text size="small" @click="toggleCommentsPanel">
            <el-icon><ChatDotRound /></el-icon>
            <span class="comment-count" v-if="noteComments.length > 0">{{ noteComments.length }}</span>
          </el-button>
          <el-button text size="small" @click="toggleFullscreen" :type="isFullscreen ? 'primary' : ''">
            <el-icon><FullScreen /></el-icon>
          </el-button>
        </div>
      </div>

      <!-- 编辑器内容区 - 飞书风格即时渲染 -->
      <div class="editor-content-wrapper">
        <!-- 左侧目录大纲 -->
        <div class="outline-panel" v-if="showOutlinePanel && outlineItems.length > 0">
          <div class="outline-header">
            <span class="outline-title">目录</span>
            <el-button text size="small" @click="showOutlinePanel = false">
              <el-icon><Close /></el-icon>
            </el-button>
          </div>
          <div class="outline-list">
            <div
              v-for="item in outlineItems"
              :key="item.id"
              class="outline-item"
              :class="{
                'is-active': activeOutlineId === item.id,
                [`level-${item.level}`]: true
              }"
              @click="scrollToHeading(item)"
            >
              {{ item.text }}
            </div>
          </div>
        </div>

        <div class="editor-content" ref="editorContentRef" :class="{ 'with-outline': showOutlinePanel && outlineItems.length > 0 }">
          <!-- 可编辑区域 -->
          <div
            class="rich-editor"
            ref="editorRef"
            contenteditable="true"
            @input="onEditorInput"
            @mouseup="handleTextSelection"
            @mousedown="handleMouseDown"
            @keydown="handleEditorKeydown"
            @keyup="handleEditorKeyup"
            @click="handleEditorClick"
            @scroll="handleEditorScroll"
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
              v-for="comment in sortedComments"
              :key="comment.id"
              class="comment-card"
              :class="{
                'is-active': activeCommentId === comment.id,
                'is-expanded': expandedCommentIds.includes(comment.id)
              }"
              :data-comment-id="comment.id"
            >
              <!-- 评论卡片头部 - 显示引用原文 -->
              <div class="comment-card-header" @click="toggleCommentExpand(comment.id)">
                <div class="selected-text-preview">
                  <span class="quote-icon">"</span>
                  <span class="text-content">{{ comment.selectedText }}</span>
                </div>
                <div class="expand-icon">
                  <el-icon v-if="!expandedCommentIds.includes(comment.id)"><ArrowDown /></el-icon>
                  <el-icon v-else><ArrowUp /></el-icon>
                </div>
              </div>

              <!-- 评论内容区域 -->
              <div v-show="expandedCommentIds.includes(comment.id)" class="comment-card-body">
                <div class="comment-header">
                  <el-avatar :size="28" :src="comment.avatar">
                    {{ comment.author?.charAt(0) || 'U' }}
                  </el-avatar>
                  <div class="user-meta">
                    <span class="user-name">{{ comment.author }}</span>
                    <span class="comment-time">{{ formatRelativeTime(comment.createdAt) }}</span>
                  </div>
                </div>

                <!-- 评论编辑状态 -->
                <div v-if="editingComment?.id === comment.id" class="comment-edit-area">
                  <el-input
                    v-model="editingComment.content"
                    type="textarea"
                    :rows="3"
                    placeholder="编辑评论..."
                  />
                  <div class="edit-actions">
                    <el-button size="small" @click="cancelEditComment">取消</el-button>
                    <el-button type="primary" size="small" @click="saveEditComment">保存</el-button>
                  </div>
                </div>

                <!-- 评论显示状态 -->
                <template v-else>
                  <div class="comment-content markdown-body" v-html="renderMarkdown(comment.content)"></div>

                  <!-- 评论图片 -->
                  <div v-if="comment.images?.length" class="comment-images">
                    <div
                      v-for="(img, imgIndex) in comment.images"
                      :key="imgIndex"
                      class="image-thumbnail"
                      @click="viewImage(img)"
                      @contextmenu.prevent="showImageContextMenu($event, img)"
                    >
                      <img :src="img" alt="评论图片" />
                    </div>
                  </div>
                </template>

                <div v-if="editingComment?.id !== comment.id" class="comment-actions-bar">
                  <el-button text size="small" @click="likeComment(comment)">
                    <el-icon><CircleCheck /></el-icon>
                    <span v-if="comment.likes">{{ comment.likes }}</span>
                  </el-button>
                  <el-button text size="small" @click="replyToComment(comment)">
                    回复
                  </el-button>
                  <el-dropdown trigger="click" @command="handleCommentAction($event, comment)">
                    <el-button text size="small">
                      <el-icon><More /></el-icon>
                    </el-button>
                    <template #dropdown>
                      <el-dropdown-menu>
                        <el-dropdown-item command="edit">编辑</el-dropdown-item>
                        <el-dropdown-item command="delete" divided type="danger">删除</el-dropdown-item>
                      </el-dropdown-menu>
                    </template>
                  </el-dropdown>
                </div>

                <!-- 回复列表 -->
                <div v-if="comment.replies?.length" class="replies-list">
                  <div
                    v-for="reply in comment.replies"
                    :key="reply.id"
                    class="reply-item"
                  >
                    <div class="reply-header">
                      <el-avatar :size="20" :src="reply.avatar">
                        {{ reply.author?.charAt(0) || 'U' }}
                      </el-avatar>
                      <span class="reply-user">{{ reply.author }}</span>
                      <span class="reply-time">{{ formatRelativeTime(reply.createdAt) }}</span>
                      <!-- 回复操作按钮 -->
                      <div class="reply-actions">
                        <el-button text size="small" @click="editReply(comment, reply)">
                          <el-icon><Edit /></el-icon>
                        </el-button>
                        <el-button text size="small" @click="deleteReply(comment, reply)">
                          <el-icon><Delete /></el-icon>
                        </el-button>
                      </div>
                    </div>
                    <!-- 回复编辑模式 -->
                    <div v-if="editingReply?.replyId === reply.id" class="reply-edit-area">
                      <!-- 回复编辑图片预览 -->
                      <div v-if="editingReply.images?.length" class="reply-edit-images">
                        <div
                          v-for="(img, imgIndex) in editingReply.images"
                          :key="imgIndex"
                          class="image-preview-item"
                        >
                          <img :src="img" alt="预览图片" />
                          <el-button
                            class="remove-image-btn"
                            text
                            size="small"
                            @click="removeReplyEditImage(imgIndex)"
                          >
                            <el-icon><Close /></el-icon>
                          </el-button>
                        </div>
                      </div>
                      <el-input
                        v-model="editingReply.content"
                        type="textarea"
                        :rows="2"
                        :placeholder="'编辑回复...（支持拖拽或粘贴图片）'"
                        @drop="handleReplyEditImageDrop"
                        @dragover.prevent
                        @paste="handleReplyEditImagePaste"
                      />
                      <div class="reply-edit-actions">
                        <span class="image-hint">支持拖拽或粘贴图片</span>
                        <div class="action-btns">
                          <el-button size="small" @click="cancelEditReply">取消</el-button>
                          <el-button type="primary" size="small" @click="saveReplyEdit">保存</el-button>
                        </div>
                      </div>
                    </div>
                    <!-- 回复内容 -->
                    <div v-else class="reply-content" v-html="renderMarkdown(reply.content)"></div>
                    <!-- 回复图片 -->
                    <div v-if="reply.images?.length" class="reply-images">
                      <div
                        v-for="(img, imgIndex) in reply.images"
                        :key="imgIndex"
                        class="image-thumbnail"
                        @click="viewImage(img)"
                        @contextmenu.prevent="showImageContextMenu($event, img)"
                      >
                        <img :src="img" alt="回复图片" />
                      </div>
                    </div>
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
          <el-button text size="small" class="toolbar-item icon-only format-btn" @click="addComment">
            <el-icon class="format-icon-svg"><ChatDotRound /></el-icon>
          </el-button>
        </el-tooltip>

        <!-- 加粗 -->
        <el-tooltip content="加粗" placement="top">
          <el-button text size="small" class="toolbar-item icon-only format-btn" :class="{ active: isBold }" @click="formatSelection('bold')">
            <span class="format-icon">B</span>
          </el-button>
        </el-tooltip>

        <!-- 斜体 -->
        <el-tooltip content="斜体" placement="top">
          <el-button text size="small" class="toolbar-item icon-only format-btn" :class="{ active: isItalic }" @click="formatSelection('italic')">
            <span class="format-icon italic">I</span>
          </el-button>
        </el-tooltip>

        <!-- 下划线（无颜色选择） -->
        <el-tooltip content="下划线" placement="top">
          <el-button text size="small" class="toolbar-item icon-only format-btn" :class="{ active: isUnderline }" @click="formatSelection('underline')">
            <span class="format-icon underline">U</span>
          </el-button>
        </el-tooltip>

        <!-- 删除线 -->
        <el-tooltip content="删除线" placement="top">
          <el-button text size="small" class="toolbar-item icon-only format-btn" :class="{ active: isStrikeThrough }" @click="formatSelection('strikeThrough')">
            <span class="format-icon strikethrough">S</span>
          </el-button>
        </el-tooltip>

        <!-- 链接 -->
        <el-tooltip content="链接" placement="top">
          <el-button text size="small" class="toolbar-item icon-only format-btn" @click="addLinkToSelection">
            <el-icon class="format-icon-svg"><Link /></el-icon>
          </el-button>
        </el-tooltip>

        <!-- 翻译 -->
        <el-tooltip content="翻译" placement="top">
          <el-button text size="small" class="toolbar-item icon-only format-btn" @click="translateSelection">
            <span class="format-icon">译</span>
          </el-button>
        </el-tooltip>

        <!-- 复制 -->
        <el-tooltip content="复制" placement="top">
          <el-button text size="small" class="toolbar-item icon-only format-btn" @click="copySelection">
            <el-icon class="format-icon-svg"><DocumentCopy /></el-icon>
          </el-button>
        </el-tooltip>
      </div>
    </div>



    <!-- 翻译弹窗 -->
    <div
      v-if="showTranslationPopup"
      class="translation-popup"
      :style="translationPosition"
    >
      <div class="translation-header">
        <span>翻译</span>
        <el-button text size="small" @click="showTranslationPopup = false">
          <el-icon><Close /></el-icon>
        </el-button>
      </div>
      <div class="translation-content">
        <div class="original-text">{{ selectedText }}</div>
        <div class="translated-text">{{ translatedText }}</div>
      </div>
    </div>

    <!-- 图片查看器 -->
    <div v-if="showImageViewer" class="image-viewer" @click="closeImageViewer">
      <img :src="viewingImage" @click.stop />
    </div>

    <!-- 标签管理对话框 -->
    <el-dialog
      v-model="showTagManager"
      title="管理标签"
      width="500px"
      :close-on-click-modal="false"
      destroy-on-close
    >
      <div class="tag-manager-content">
        <!-- 搜索框 -->
        <div class="tag-search-box">
          <el-input
            v-model="tagSearchQuery"
            placeholder="搜索或创建标签..."
            class="tag-search-input"
            @keyup.enter="createNewTag"
          >
            <template #suffix>
              <el-button
                v-if="tagSearchQuery && !filteredTags.length"
                type="primary"
                link
                @click="createNewTag"
              >
                创建
              </el-button>
            </template>
          </el-input>
        </div>

        <!-- 标签列表 -->
        <div class="tag-list-section">
          <div class="tag-section-title">所有标签（点击多选）</div>
          <div class="tag-select-list">
            <div
              v-for="tag in filteredTags"
              :key="tag.id"
              class="tag-select-item"
              :class="{ 'is-selected': selectedTags.includes(tag.id) }"
              @click="toggleTagSelection(tag.id)"
            >
              <span
                class="tag-color-dot"
                :style="{ backgroundColor: tag.color }"
              ></span>
              <span class="tag-name">{{ tag.name }}</span>
              <span class="tag-count">({{ tag.usageCount }})</span>
              <el-icon v-if="selectedTags.includes(tag.id)" class="tag-check-icon"><Check /></el-icon>
              <el-button
                text
                size="small"
                class="tag-delete-btn"
                @click.stop="deleteTag(tag.id)"
              >
                <el-icon><Delete /></el-icon>
              </el-button>
            </div>
          </div>
          <div v-if="!filteredTags.length && tagSearchQuery" class="tag-empty-tip">
            未找到标签，按回车或点击"创建"按钮创建新标签
          </div>
        </div>

        <!-- 已选标签预览 -->
        <div v-if="selectedTags.length > 0" class="selected-tags-preview">
          <div class="tag-section-title">已选择 {{ selectedTags.length }} 个标签</div>
          <div class="selected-tags-list">
            <el-tag
              v-for="tagId in selectedTags"
              :key="tagId"
              closable
              :color="tags.find(t => t.id === tagId)?.color"
              @close="toggleTagSelection(tagId)"
            >
              {{ tags.find(t => t.id === tagId)?.name }}
            </el-tag>
          </div>
        </div>
      </div>

      <template #footer>
        <div class="tag-manager-footer">
          <el-button @click="closeTagManager">取消</el-button>
          <el-button type="primary" @click="saveTagChanges">保存</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, nextTick, onMounted, onUnmounted, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Folder, FolderOpened, Plus, Edit, Delete, CollectionTag, Search,
  ArrowDown, ArrowRight, Fold, Expand, Document, Notebook, ArrowLeft,
  Share, Download, More, Close, ChatDotRound, ChatLineRound,
  Picture, EditPen, List, Sort,
  Check, Link, Grid, DocumentCopy, View, Hide, RefreshRight, ArrowUp,
  Paperclip, CircleCheck, FullScreen
} from '@element-plus/icons-vue'
import { marked } from 'marked'

// ============ 状态管理 ============
const folderSidebarCollapsed = ref(false)
const notesListCollapsed = ref(false)
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
const expandedCommentIds = ref([])
const editingCommentId = ref(null)

// 目录大纲
const outlineItems = ref([])
const showOutlinePanel = ref(true)
const activeOutlineId = ref(null)
const outlineUpdateTimer = ref(null) // 目录更新定时器

// 全屏编辑
const isFullscreen = ref(false)

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

// 翻译弹窗
const showTranslationPopup = ref(false)
const translationPosition = ref({ top: '0px', left: '0px' })
const translatedText = ref('')

// 评论输入
const newCommentContent = ref('')
const newCommentImages = ref([])

// 编辑状态
const editingComment = ref(null)
const editingReply = ref(null)

// 图片查看器
const showImageViewer = ref(false)
const viewingImage = ref('')

// 格式状态
const isBold = ref(false)
const isItalic = ref(false)
const isUnderline = ref(false)
const isStrikeThrough = ref(false)

// 标签管理对话框
const showTagManager = ref(false)
const tagSearchQuery = ref('')
const selectedTags = ref([])
const tagManagerActiveTab = ref('current') // 'current' 或 'all'

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

// 排序后的评论列表 - 按照在文档中出现的顺序排列
const sortedComments = computed(() => {
  // 获取编辑器中所有评论标记的顺序
  const editorMarks = editorRef.value?.querySelectorAll('.comment-mark') || []
  const markOrder = Array.from(editorMarks).map(mark => mark.dataset.commentId)

  return [...noteComments.value].sort((a, b) => {
    const indexA = markOrder.indexOf(a.id)
    const indexB = markOrder.indexOf(b.id)

    // 如果都在文档中有标记，按照文档中的顺序
    if (indexA !== -1 && indexB !== -1) {
      return indexA - indexB
    }
    // 如果只有一个在文档中，文档中的排在前面
    if (indexA !== -1) return -1
    if (indexB !== -1) return 1
    // 都不在文档中，按创建时间倒序
    return new Date(b.createdAt) - new Date(a.createdAt)
  })
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

function toggleNotesList() {
  // 如果笔记列表当前是展开的，则收缩它
  if (!notesListCollapsed.value) {
    notesListCollapsed.value = true
  } else {
    // 如果笔记列表当前是收缩的，先检查笔记库栏是否收缩
    // 如果笔记库栏也是收缩的，必须先打开笔记库栏
    if (folderSidebarCollapsed.value) {
      folderSidebarCollapsed.value = false
      // 延迟展开笔记列表，确保笔记库栏先展开
      setTimeout(() => {
        notesListCollapsed.value = false
      }, 100)
    } else {
      notesListCollapsed.value = false
    }
  }
}

function toggleFolderSidebar() {
  // 如果笔记库栏当前是展开的，则收缩它
  if (!folderSidebarCollapsed.value) {
    folderSidebarCollapsed.value = true
  } else {
    folderSidebarCollapsed.value = false
  }
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

function formatText(command, value = null) {
  document.execCommand(command, false, value)
  onEditorInput()
  updateFormatStates()
}

function formatSelection(command) {
  // 保存当前选区
  const selection = window.getSelection()
  if (selection.rangeCount === 0) return
  
  const range = selection.getRangeAt(0)
  
  // 先恢复选区（防止选区丢失）
  selection.removeAllRanges()
  selection.addRange(range)
  
  // 应用格式
  document.execCommand(command, false, null)
  onEditorInput()
  
  // 更新格式状态
  updateFormatStates()
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

function insertCheckbox() {
  const html = '<div style="display:flex;align-items:center;gap:8px;margin:8px 0;"><input type="checkbox" style="width:16px;height:16px;cursor:pointer;"><span>待办事项</span></div><p><br></p>'
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

  // 回车键在标题后创建新段落
  if (e.key === 'Enter') {
    handleEnterKey(e)
  }
}

// 处理按键抬起 - 用于即时渲染
function handleEditorKeyup(e) {
  // 空格键触发即时渲染
  if (e.key === ' ') {
    handleMarkdownShortcut(e)
  }
}

// 处理 Markdown 快捷语法
function handleMarkdownShortcut(e) {
  const selection = window.getSelection()
  if (!selection.rangeCount) return

  const range = selection.getRangeAt(0)
  const currentNode = range.startContainer

  // 获取当前行
  let lineElement = currentNode.nodeType === Node.TEXT_NODE
    ? currentNode.parentElement
    : currentNode

  // 找到块级元素
  while (lineElement && !['P', 'DIV', 'H1', 'H2', 'H3', 'H4', 'H5', 'H6', 'LI'].includes(lineElement.tagName)) {
    lineElement = lineElement.parentElement
  }

  if (!lineElement) return

  const lineText = lineElement.textContent || ''

  // 检查是否是 Markdown 语法（在行首）
  // 注意：这里检查原始文本，因为空格已经输入了
  const h1Match = lineText.match(/^(#{1})\s(.+)$/)
  const h2Match = lineText.match(/^(#{2})\s(.+)$/)
  const h3Match = lineText.match(/^(#{3})\s(.+)$/)
  const h4Match = lineText.match(/^(#{4})\s(.+)$/)
  const h5Match = lineText.match(/^(#{5})\s(.+)$/)
  const h6Match = lineText.match(/^(#{6})\s(.+)$/)
  const ulMatch = lineText.match(/^(-|\*)\s(.+)$/)
  const olMatch = lineText.match(/^(\d+)\.\s(.+)$/)
  const quoteMatch = lineText.match(/^(>)\s(.+)$/)

  let matched = false
  let matchResult = null
  let tagName = ''

  if (h6Match) {
    matched = true
    matchResult = h6Match
    tagName = 'h6'
  } else if (h5Match) {
    matched = true
    matchResult = h5Match
    tagName = 'h5'
  } else if (h4Match) {
    matched = true
    matchResult = h4Match
    tagName = 'h4'
  } else if (h3Match) {
    matched = true
    matchResult = h3Match
    tagName = 'h3'
  } else if (h2Match) {
    matched = true
    matchResult = h2Match
    tagName = 'h2'
  } else if (h1Match) {
    matched = true
    matchResult = h1Match
    tagName = 'h1'
  } else if (ulMatch) {
    matched = true
    matchResult = ulMatch
  } else if (olMatch) {
    matched = true
    matchResult = olMatch
  } else if (quoteMatch) {
    matched = true
    matchResult = quoteMatch
  }

  if (matched) {
    e.preventDefault()
    e.stopPropagation()

    if (tagName) {
      convertToHeading(lineElement, tagName, matchResult[2])
    } else if (ulMatch) {
      convertToList(lineElement, 'ul', matchResult[2])
    } else if (olMatch) {
      convertToList(lineElement, 'ol', matchResult[2], parseInt(matchResult[1]))
    } else if (quoteMatch) {
      convertToQuote(lineElement, matchResult[2])
    }
  }
}

// 转换为标题
function convertToHeading(element, tagName, text) {
  const newElement = document.createElement(tagName)
  newElement.textContent = text
  newElement.style.margin = '16px 0 12px 0'
  newElement.style.fontWeight = '600'
  newElement.style.lineHeight = '1.4'
  // 关键：设置 contenteditable 使标题可编辑
  newElement.contentEditable = 'true'

  // 设置字号
  const fontSizes = {
    'h1': '1.75rem',
    'h2': '1.5rem',
    'h3': '1.25rem',
    'h4': '1.125rem',
    'h5': '1rem',
    'h6': '0.875rem'
  }
  newElement.style.fontSize = fontSizes[tagName]

  element.parentNode.replaceChild(newElement, element)

  // 将光标移动到新元素末尾
  const range = document.createRange()
  range.selectNodeContents(newElement)
  range.collapse(false)
  const selection = window.getSelection()
  selection.removeAllRanges()
  selection.addRange(range)

  onEditorInput()
  updateOutline()
}

// 转换为列表
function convertToList(element, listType, text, startNum = null) {
  const list = document.createElement(listType)
  if (startNum && listType === 'ol') {
    list.start = startNum
  }
  list.style.margin = '8px 0'
  list.style.paddingLeft = '24px'
  // 关键：设置 contenteditable 使列表可编辑
  list.contentEditable = 'true'

  const li = document.createElement('li')
  li.textContent = text
  li.style.marginBottom = '4px'
  list.appendChild(li)

  element.parentNode.replaceChild(list, element)

  // 将光标移动到列表项末尾
  const range = document.createRange()
  range.selectNodeContents(li)
  range.collapse(false)
  const selection = window.getSelection()
  selection.removeAllRanges()
  selection.addRange(range)

  onEditorInput()
}

// 转换为引用
function convertToQuote(element, text) {
  const blockquote = document.createElement('blockquote')
  blockquote.textContent = text
  blockquote.style.borderLeft = '3px solid #409EFF'
  blockquote.style.paddingLeft = '12px'
  blockquote.style.margin = '8px 0'
  blockquote.style.color = '#606266'
  // 关键：设置 contenteditable 使引用可编辑
  blockquote.contentEditable = 'true'

  element.parentNode.replaceChild(blockquote, element)

  // 将光标移动到引用末尾
  const range = document.createRange()
  range.selectNodeContents(blockquote)
  range.collapse(false)
  const selection = window.getSelection()
  selection.removeAllRanges()
  selection.addRange(range)

  onEditorInput()
}

// 处理回车键
function handleEnterKey(e) {
  const selection = window.getSelection()
  if (!selection.rangeCount) return

  const range = selection.getRangeAt(0)
  const currentNode = range.startContainer
  let element = currentNode.nodeType === Node.TEXT_NODE
    ? currentNode.parentElement
    : currentNode

  // 如果在标题内按回车，创建新段落
  if (['H1', 'H2', 'H3', 'H4', 'H5', 'H6'].includes(element.tagName)) {
    e.preventDefault()
    const p = document.createElement('p')
    p.innerHTML = '<br>'
    element.parentNode.insertBefore(p, element.nextSibling)

    // 将光标移动到新段落
    const newRange = document.createRange()
    newRange.setStart(p, 0)
    newRange.collapse(true)
    selection.removeAllRanges()
    selection.addRange(newRange)

    onEditorInput()
  }
}

// 更新目录大纲
function updateOutline() {
  if (!editorRef.value) return

  const headings = editorRef.value.querySelectorAll('h1, h2, h3, h4, h5, h6')
  const newOutlineItems = Array.from(headings).map((heading, index) => {
    // 复用已有ID或创建新ID
    let id = heading.id
    if (!id || !id.startsWith('heading-')) {
      id = `heading-${index}`
      heading.id = id
    }

    return {
      id,
      level: parseInt(heading.tagName.charAt(1)),
      text: heading.textContent || '',
      element: heading
    }
  })

  // 只有目录发生变化时才更新
  const hasChanged = JSON.stringify(outlineItems.value.map(i => ({ text: i.text, level: i.level }))) !==
                     JSON.stringify(newOutlineItems.map(i => ({ text: i.text, level: i.level })))

  if (hasChanged) {
    outlineItems.value = newOutlineItems
  }
}

// 启动目录定时更新
function startOutlineTimer() {
  if (outlineUpdateTimer.value) return
  outlineUpdateTimer.value = setInterval(() => {
    updateOutline()
  }, 3000) // 每3秒更新一次
}

// 停止目录定时更新
function stopOutlineTimer() {
  if (outlineUpdateTimer.value) {
    clearInterval(outlineUpdateTimer.value)
    outlineUpdateTimer.value = null
  }
}

// 滚动到指定标题
function scrollToHeading(item) {
  activeOutlineId.value = item.id
  item.element.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

// 切换全屏模式（编辑区域全屏）
function toggleFullscreen() {
  isFullscreen.value = !isFullscreen.value
}

// 监听编辑器滚动，更新当前激活的标题
function handleEditorScroll() {
  if (!editorRef.value || outlineItems.value.length === 0) return

  const scrollTop = editorRef.value.scrollTop
  const editorRect = editorRef.value.getBoundingClientRect()

  for (let i = outlineItems.value.length - 1; i >= 0; i--) {
    const item = outlineItems.value[i]
    const rect = item.element.getBoundingClientRect()
    const relativeTop = rect.top - editorRect.top

    if (relativeTop <= 100) {
      activeOutlineId.value = item.id
      break
    }
  }
}

// ============ 选中文字工具栏 ============
function handleMouseDown() {
  showAnnotationToolbar.value = false
}

function handleEditorClick(e) {
  // 检查是否点击了评论标记
  const commentMark = e.target.closest('.comment-mark')
  if (commentMark) {
    const commentId = commentMark.dataset.commentId
    if (commentId) {
      scrollToHighlight(commentId)
    }
  }
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
    // 计算弹窗位置
    const selection = window.getSelection()
    if (selection.rangeCount > 0) {
      const rect = selection.getRangeAt(0).getBoundingClientRect()
      translationPosition.value = { top: rect.bottom + 10 + 'px', left: rect.left + 'px' }
    }
    // 模拟翻译结果
    translatedText.value = `[译文] ${selectedText.value}`
    showTranslationPopup.value = true
  }
  showAnnotationToolbar.value = false
}

function copySelection() {
  if (selectedText.value) {
    navigator.clipboard.writeText(selectedText.value).then(() => {
      ElMessage.success('已复制到剪贴板')
    }).catch(() => {
      ElMessage.error('复制失败')
    })
  }
  showAnnotationToolbar.value = false
}

// ============ 评论功能 ============
function toggleCommentsPanel() {
  showCommentsPanel.value = !showCommentsPanel.value
}

function toggleCommentExpand(commentId) {
  const index = expandedCommentIds.value.indexOf(commentId)
  if (index > -1) {
    expandedCommentIds.value.splice(index, 1)
  } else {
    expandedCommentIds.value.push(commentId)
  }
  activeCommentId.value = commentId

  // 自动定位到左侧正文对应位置
  const comment = noteComments.value.find(c => c.id === commentId)
  if (comment) {
    scrollToHighlight(commentId)
  }
}

function likeComment(comment) {
  comment.likes = (comment.likes || 0) + 1
}

function handleCommentAction(command, comment) {
  switch (command) {
    case 'edit':
      editingCommentId.value = comment.id
      editingComment.value = { ...comment }
      replyingTo.value = null
      break
    case 'delete':
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
      break
  }
}

// 编辑回复（新方式）
function editReply(comment, reply) {
  editingReply.value = {
    commentId: comment.id,
    replyId: reply.id,
    content: reply.content,
    images: reply.images ? [...reply.images] : []
  }
}

// 保存回复编辑
function saveReplyEdit() {
  if (!editingReply.value) return
  const comment = noteComments.value.find(c => c.id === editingReply.value.commentId)
  if (comment && comment.replies) {
    const reply = comment.replies.find(r => r.id === editingReply.value.replyId)
    if (reply) {
      reply.content = editingReply.value.content
      reply.images = editingReply.value.images?.length ? [...editingReply.value.images] : undefined
      ElMessage.success('回复已更新')
    }
  }
  editingReply.value = null
}

// 处理回复编辑时的图片拖拽
function handleReplyEditImageDrop(e) {
  e.preventDefault()
  const files = e.dataTransfer.files
  for (let i = 0; i < files.length; i++) {
    if (files[i].type.indexOf('image') !== -1) {
      const reader = new FileReader()
      reader.onload = (event) => {
        if (!editingReply.value.images) {
          editingReply.value.images = []
        }
        editingReply.value.images.push(event.target.result)
      }
      reader.readAsDataURL(files[i])
    }
  }
}

// 处理回复编辑时的图片粘贴
function handleReplyEditImagePaste(e) {
  const items = e.clipboardData.items
  for (let i = 0; i < items.length; i++) {
    if (items[i].type.indexOf('image') !== -1) {
      const file = items[i].getAsFile()
      const reader = new FileReader()
      reader.onload = (event) => {
        if (!editingReply.value.images) {
          editingReply.value.images = []
        }
        editingReply.value.images.push(event.target.result)
      }
      reader.readAsDataURL(file)
    }
  }
}

// 移除回复编辑中的图片
function removeReplyEditImage(index) {
  if (editingReply.value && editingReply.value.images) {
    editingReply.value.images.splice(index, 1)
  }
}

const renderMarkdown = (content) => {
  if (!content) return ''
  try {
    return marked.parse(content, { breaks: true, gfm: true })
  } catch (e) {
    console.error('Markdown渲染错误:', e)
    return content
  }
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

function startEditComment(comment) {
  editingComment.value = { ...comment }
}

function cancelEditComment() {
  editingComment.value = null
}

function saveEditComment() {
  if (!editingComment.value.content.trim()) {
    ElMessage.warning('评论内容不能为空')
    return
  }
  
  const comment = noteComments.value.find(c => c.id === editingComment.value.id)
  if (comment) {
    comment.content = editingComment.value.content
    comment.updatedAt = new Date()
    
    // 同步更新 allComments
    const allComment = allComments.value.find(c => c.id === editingComment.value.id)
    if (allComment) {
      allComment.content = editingComment.value.content
      allComment.updatedAt = new Date()
    }
    
    ElMessage.success('评论已更新')
  }
  editingComment.value = null
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

// ============ 回复编辑功能 ============
function startEditReply(comment, reply) {
  editingReply.value = { ...reply, parentCommentId: comment.id }
}

function cancelEditReply() {
  editingReply.value = null
}

function saveEditReply() {
  if (!editingReply.value.content.trim()) {
    ElMessage.warning('回复内容不能为空')
    return
  }
  
  const comment = noteComments.value.find(c => c.id === editingReply.value.parentCommentId)
  if (comment && comment.replies) {
    const reply = comment.replies.find(r => r.id === editingReply.value.id)
    if (reply) {
      reply.content = editingReply.value.content
      reply.updatedAt = new Date()
      ElMessage.success('回复已更新')
    }
  }
  editingReply.value = null
}

function deleteReply(comment, reply) {
  ElMessageBox.confirm('确定要删除这条回复吗？', '删除回复', {
    confirmButtonText: '删除',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    if (comment.replies) {
      const index = comment.replies.findIndex(r => r.id === reply.id)
      if (index > -1) {
        comment.replies.splice(index, 1)
        ElMessage.success('回复已删除')
      }
    }
  }).catch(() => {})
}

function scrollToHighlight(commentId) {
  activeCommentId.value = commentId

  // 打开评论面板
  showCommentsPanel.value = true

  // 展开对应评论
  if (!expandedCommentIds.value.includes(commentId)) {
    expandedCommentIds.value.push(commentId)
  }

  // 滚动到评论位置
  nextTick(() => {
    const commentEl = document.querySelector(`[data-comment-id="${commentId}"]`)
    if (commentEl) {
      commentEl.scrollIntoView({ behavior: 'smooth', block: 'center' })
    }
  })

  // 高亮原文标记
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
  // 创建全屏图片查看器
  const viewer = document.createElement('div')
  viewer.style.cssText = `
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.9);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
    cursor: zoom-out;
  `
  const image = document.createElement('img')
  image.src = img
  image.style.cssText = `
    max-width: 90%;
    max-height: 90%;
    object-fit: contain;
  `
  viewer.appendChild(image)
  viewer.onclick = () => document.body.removeChild(viewer)
  document.body.appendChild(viewer)
}

function closeImageViewer() {
  showImageViewer.value = false
}

// 显示图片右键菜单
function showImageContextMenu(e, imgSrc) {
  // 创建右键菜单
  const menu = document.createElement('div')
  menu.style.cssText = `
    position: fixed;
    top: ${e.clientY}px;
    left: ${e.clientX}px;
    background: white;
    border: 1px solid #ddd;
    border-radius: 4px;
    padding: 4px 0;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    z-index: 9999;
  `
  menu.innerHTML = `
    <div style="padding: 8px 16px; cursor: pointer; hover: background: #f5f5f5;" onmouseover="this.style.background='#f5f5f5'" onmouseout="this.style.background='white'">
      复制图片
    </div>
    <div style="padding: 8px 16px; cursor: pointer;" onmouseover="this.style.background='#f5f5f5'" onmouseout="this.style.background='white'">
      在新窗口打开
    </div>
  `

  // 复制图片功能
  menu.children[0].onclick = () => {
    copyImageToClipboard(imgSrc)
    document.body.removeChild(menu)
  }

  // 新窗口打开
  menu.children[1].onclick = () => {
    window.open(imgSrc, '_blank')
    document.body.removeChild(menu)
  }

  document.body.appendChild(menu)

  // 点击其他地方关闭菜单
  const closeMenu = (event) => {
    if (!menu.contains(event.target)) {
      if (menu.parentNode) {
        document.body.removeChild(menu)
      }
      document.removeEventListener('click', closeMenu)
    }
  }
  setTimeout(() => {
    document.addEventListener('click', closeMenu)
  }, 0)
}

// 复制图片到剪贴板
async function copyImageToClipboard(imgSrc) {
  try {
    const response = await fetch(imgSrc)
    const blob = await response.blob()
    await navigator.clipboard.write([
      new ClipboardItem({ [blob.type]: blob })
    ])
    ElMessage.success('图片已复制到剪贴板')
  } catch (err) {
    // 降级方案：使用 canvas
    const img = new Image()
    img.crossOrigin = 'anonymous'
    img.onload = () => {
      const canvas = document.createElement('canvas')
      canvas.width = img.width
      canvas.height = img.height
      const ctx = canvas.getContext('2d')
      ctx.drawImage(img, 0, 0)
      canvas.toBlob(async (blob) => {
        try {
          await navigator.clipboard.write([
            new ClipboardItem({ 'image/png': blob })
          ])
          ElMessage.success('图片已复制到剪贴板')
        } catch (e) {
          ElMessage.error('复制失败，请手动保存图片')
        }
      })
    }
    img.src = imgSrc
  }
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

// ============ 标签管理 ============
// 打开标签管理对话框
function openTagManager() {
  showTagManager.value = true
  tagSearchQuery.value = ''
  selectedTags.value = []
  // 初始化已选中的标签为当前笔记的标签
  if (selectedNote.value?.tags) {
    selectedTags.value = [...selectedNote.value.tags]
  }
}

// 关闭标签管理对话框
function closeTagManager() {
  showTagManager.value = false
  tagSearchQuery.value = ''
  selectedTags.value = []
}

// 保存标签更改
function saveTagChanges() {
  if (selectedNote.value) {
    selectedNote.value.tags = [...selectedTags.value]
    ElMessage.success('标签已更新')
  }
  closeTagManager()
}

// 切换标签选中状态（多选）
function toggleTagSelection(tagId) {
  const index = selectedTags.value.indexOf(tagId)
  if (index > -1) {
    selectedTags.value.splice(index, 1)
  } else {
    selectedTags.value.push(tagId)
  }
}

// 过滤后的标签列表
const filteredTags = computed(() => {
  if (!tagSearchQuery.value) return tags.value
  const query = tagSearchQuery.value.toLowerCase()
  return tags.value.filter(tag =>
    tag.name.toLowerCase().includes(query)
  )
})

// 当前笔记已添加的标签
const currentNoteTags = computed(() => {
  if (!selectedNote.value?.tags) return []
  return tags.value.filter(tag => selectedNote.value.tags.includes(tag.id))
})

// 创建新标签
function createNewTag() {
  const name = tagSearchQuery.value.trim()
  if (!name) {
    ElMessage.warning('请输入标签名称')
    return
  }
  // 检查是否已存在
  const exists = tags.value.find(t => t.name === name)
  if (exists) {
    ElMessage.warning('标签已存在')
    return
  }
  // 创建新标签
  const colors = ['#409EFF', '#67C23A', '#E6A23C', '#F56C6C', '#909399', '#8B5CF6', '#EC4899']
  const newTag = {
    id: Date.now().toString(),
    name,
    color: colors[Math.floor(Math.random() * colors.length)],
    usageCount: 0
  }
  tags.value.push(newTag)
  // 自动选中新标签
  selectedTags.value.push(newTag.id)
  tagSearchQuery.value = ''
  ElMessage.success('标签创建成功')
}

// 删除标签
function deleteTag(tagId) {
  ElMessageBox.confirm('确定要删除这个标签吗？', '删除标签', {
    confirmButtonText: '删除',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    // 从所有笔记中移除该标签
    notes.value.forEach(note => {
      if (note.tags?.includes(tagId)) {
        note.tags = note.tags.filter(id => id !== tagId)
      }
    })
    // 从标签列表中移除
    const index = tags.value.findIndex(t => t.id === tagId)
    if (index > -1) {
      tags.value.splice(index, 1)
    }
    // 从选中列表中移除
    const selectedIndex = selectedTags.value.indexOf(tagId)
    if (selectedIndex > -1) {
      selectedTags.value.splice(selectedIndex, 1)
    }
    ElMessage.success('标签已删除')
  }).catch(() => {})
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
      openTagManager()
      break
    case 'history':
      ElMessage.info('历史版本功能开发中')
      break
  }
}

onMounted(() => {
  // 启动目录定时更新
  startOutlineTimer()
})

onUnmounted(() => {
  // 停止目录定时更新
  stopOutlineTimer()
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
        color: #000000 !important;

        :deep(.el-tag__content) {
          color: #000000 !important;
        }

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
  position: relative;

  &.expanded {
    flex: 1;
  }

  &.collapsed {
    width: 32px;
    min-width: 32px;
    background: #fafafa;
  }

  .collapse-list-btn {
    position: absolute;
    right: -12px;
    top: 50%;
    transform: translateY(-50%);
    width: 24px;
    height: 48px;
    background: white;
    border: 1px solid $border-light;
    border-radius: 0 4px 4px 0;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    z-index: 10;
    box-shadow: 2px 0 4px rgba(0, 0, 0, 0.05);
    transition: all 0.2s ease;

    &:hover {
      background: $primary;
      color: white;
      border-color: $primary;
    }

    &.collapsed {
      right: -24px;
      border-radius: 0 4px 4px 0;
    }

    .el-icon {
      font-size: 0.75rem;
    }
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
            color: #000000 !important;

            :deep(.el-tag__content) {
              color: #000000 !important;
            }
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

  // 全屏模式样式
  &.is-fullscreen {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    z-index: 9999;
    width: 100vw;
    height: 100vh;

    .editor-content-wrapper {
      height: calc(100vh - 120px); // 减去header和toolbar的高度
    }
  }

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
    padding: 8px 16px;
    border-bottom: 1px solid $border-light;
    gap: 4px;
    flex-wrap: wrap;
    background: #fafafa;

    .toolbar-group {
      display: flex;
      gap: 2px;
      align-items: center;
      padding: 0 4px;

      &:not(:last-child) {
        border-right: 1px solid $border-light;
        padding-right: 8px;
        margin-right: 4px;
      }
    }

    .el-button {
      padding: 6px;
      font-size: 0.875rem;
      min-width: 32px;
      height: 32px;
      border-radius: 4px;
      transition: all 0.2s ease;

      &:hover {
        background: #e8e8e8;
      }

      &.is-active {
        background: rgba($primary, 0.1);
        color: $primary;
      }

      .el-icon {
        font-size: 1rem;
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

    // 目录大纲面板
    .outline-panel {
      width: 220px;
      min-width: 220px;
      background: white;
      border-right: 1px solid $border-light;
      display: flex;
      flex-direction: column;

      .outline-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: $spacing-md $spacing-lg;
        border-bottom: 1px solid $border-light;

        .outline-title {
          font-size: 0.875rem;
          font-weight: 600;
          color: $text-primary;
        }
      }

      .outline-list {
        flex: 1;
        overflow-y: auto;
        padding: $spacing-sm 0;

        .outline-item {
          padding: $spacing-xs $spacing-lg;
          font-size: 0.8125rem;
          color: $text-secondary;
          cursor: pointer;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          transition: all 0.2s;
          border-left: 2px solid transparent;

          &:hover {
            background: $bg-secondary;
            color: $text-primary;
          }

          &.is-active {
            background: rgba($primary, 0.08);
            color: $primary;
            border-left-color: $primary;
          }

          // 不同层级缩进
          &.level-1 { padding-left: $spacing-lg; }
          &.level-2 { padding-left: $spacing-lg + 12px; }
          &.level-3 { padding-left: $spacing-lg + 24px; }
          &.level-4 { padding-left: $spacing-lg + 36px; }
          &.level-5 { padding-left: $spacing-lg + 48px; }
          &.level-6 { padding-left: $spacing-lg + 60px; }
        }
      }
    }

    .editor-content {
      flex: 1;
      overflow-y: auto;
      padding: $spacing-lg;
      background: white;

      &.with-outline {
        border-left: 1px solid $border-light;
      }

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
      background: #ffffff;
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
        background: #ffffff;

        .comment-card {
          background: #ffffff;
          border-radius: $radius-md;
          margin-bottom: $spacing-md;
          border: 1px solid $border-light;
          transition: all 0.2s;
          overflow: hidden;

          &.is-active {
            border-color: $primary;
            box-shadow: 0 0 0 2px rgba($primary, 0.1);
          }

          .comment-card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: $spacing-sm $spacing-md;
            background: #fffbeb;
            cursor: pointer;
            transition: background 0.2s;

            &:hover {
              background: #fef3c7;
            }

            .selected-text-preview {
              display: flex;
              align-items: flex-start;
              gap: $spacing-xs;
              flex: 1;
              min-width: 0;

              .quote-icon {
                font-size: 1.25rem;
                color: #f59e0b;
                line-height: 1;
              }

              .text-content {
                font-size: 0.8125rem;
                color: $text-secondary;
                overflow: hidden;
                display: -webkit-box;
                -webkit-line-clamp: 2;
                -webkit-box-orient: vertical;
                line-height: 1.5;
              }
            }

            .expand-icon {
              margin-left: $spacing-sm;
              color: $text-tertiary;
              flex-shrink: 0;
            }
          }

          .comment-card-body {
            padding: $spacing-md;

            .comment-header {
              display: flex;
              align-items: center;
              gap: $spacing-sm;
              margin-bottom: $spacing-sm;

              .user-meta {
                display: flex;
                flex-direction: column;
                gap: 2px;

                .user-name {
                  font-size: 0.875rem;
                  font-weight: 500;
                  color: $text-primary;
                }

                .comment-time {
                  font-size: 0.75rem;
                  color: $text-tertiary;
                }
              }
            }

            .comment-content {
              font-size: 0.875rem;
              color: $text-primary;
              line-height: 1.6;
              margin-bottom: $spacing-sm;

              :deep(p) {
                margin: 0 0 $spacing-sm 0;

                &:last-child {
                  margin-bottom: 0;
                }
              }

              :deep(h1), :deep(h2), :deep(h3), :deep(h4), :deep(h5), :deep(h6) {
                font-weight: 600;
                margin: $spacing-md 0 $spacing-sm 0;
                line-height: 1.4;
              }

              :deep(h1) { font-size: 1.25rem; }
              :deep(h2) { font-size: 1.125rem; }
              :deep(h3) { font-size: 1rem; }
              :deep(h4), :deep(h5), :deep(h6) { font-size: 0.9375rem; }

              :deep(ul), :deep(ol) {
                margin: $spacing-sm 0;
                padding-left: $spacing-lg;
              }

              :deep(li) {
                margin-bottom: $spacing-xs;
              }

              :deep(strong) {
                font-weight: 600;
              }

              :deep(em) {
                font-style: italic;
              }

              :deep(blockquote) {
                border-left: 3px solid $primary;
                padding-left: $spacing-md;
                margin: $spacing-sm 0;
                color: $text-secondary;
              }

              :deep(code) {
                background: $bg-tertiary;
                padding: 2px 6px;
                border-radius: $radius-sm;
                font-family: 'Fira Code', monospace;
                font-size: 0.8125rem;
              }

              :deep(pre) {
                background: #f5f5f5;
                padding: $spacing-md;
                border-radius: $radius-md;
                overflow-x: auto;
                margin: $spacing-sm 0;

                code {
                  background: none;
                  padding: 0;
                }
              }

              :deep(a) {
                color: $primary;
                text-decoration: none;

                &:hover {
                  text-decoration: underline;
                }
              }

              :deep(hr) {
                border: none;
                border-top: 1px solid $border-light;
                margin: $spacing-md 0;
              }
            }

            .comment-images {
              display: flex;
              flex-wrap: wrap;
              gap: $spacing-sm;
              margin-bottom: $spacing-sm;

              .image-thumbnail {
                width: 80px;
                height: 80px;
                border-radius: $radius-sm;
                overflow: hidden;
                cursor: pointer;
                transition: transform 0.2s;

                &:hover {
                  transform: scale(1.05);
                }

                img {
                  width: 100%;
                  height: 100%;
                  object-fit: cover;
                }
              }
            }

            // 评论编辑区域
            .comment-edit-area {
              margin-bottom: $spacing-sm;

              .el-textarea {
                margin-bottom: $spacing-sm;
              }

              .edit-actions {
                display: flex;
                justify-content: flex-end;
                gap: $spacing-sm;
              }
            }

            .comment-actions-bar {
              display: flex;
              gap: $spacing-xs;
              padding-top: $spacing-sm;
              border-top: 1px solid $border-light;

              .el-button {
                font-size: 0.8125rem;
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

                .reply-header {
                  display: flex;
                  align-items: center;
                  gap: $spacing-xs;
                  margin-bottom: $spacing-xs;

                  .reply-user {
                    font-size: 0.8125rem;
                    font-weight: 500;
                  }

                  .reply-time {
                    font-size: 0.6875rem;
                    color: $text-tertiary;
                  }

                  .reply-actions {
                    margin-left: auto;
                    display: flex;
                    gap: 2px;

                    .el-button {
                      padding: 2px;
                      font-size: 0.75rem;
                    }
                  }
                }

                .reply-content {
                  font-size: 0.8125rem;
                  color: $text-secondary;
                  line-height: 1.5;

                  :deep(p) {
                    margin: 0 0 $spacing-xs 0;

                    &:last-child {
                      margin-bottom: 0;
                    }
                  }

                  :deep(h1), :deep(h2), :deep(h3), :deep(h4), :deep(h5), :deep(h6) {
                    font-weight: 600;
                    margin: $spacing-sm 0 $spacing-xs 0;
                    line-height: 1.4;
                  }

                  :deep(h1) { font-size: 1rem; }
                  :deep(h2) { font-size: 0.9375rem; }
                  :deep(h3), :deep(h4), :deep(h5), :deep(h6) { font-size: 0.875rem; }

                  :deep(ul), :deep(ol) {
                    margin: $spacing-xs 0;
                    padding-left: $spacing-md;
                  }

                  :deep(li) {
                    margin-bottom: 2px;
                  }

                  :deep(strong) {
                    font-weight: 600;
                  }

                  :deep(em) {
                    font-style: italic;
                  }

                  :deep(code) {
                    background: $bg-tertiary;
                    padding: 1px 4px;
                    border-radius: $radius-sm;
                    font-family: 'Fira Code', monospace;
                    font-size: 0.75rem;
                  }

                  :deep(pre) {
                    background: #f5f5f5;
                    padding: $spacing-sm;
                    border-radius: $radius-sm;
                    overflow-x: auto;
                    margin: $spacing-xs 0;

                    code {
                      background: none;
                      padding: 0;
                    }
                  }

                  :deep(a) {
                    color: $primary;
                    text-decoration: none;

                    &:hover {
                      text-decoration: underline;
                    }
                  }
                }

                .reply-images {
                  display: flex;
                  flex-wrap: wrap;
                  gap: $spacing-xs;
                  margin-top: $spacing-xs;

                  .image-thumbnail {
                    width: 60px;
                    height: 60px;
                    border-radius: $radius-sm;
                    overflow: hidden;
                    cursor: pointer;

                    img {
                      width: 100%;
                      height: 100%;
                      object-fit: cover;
                    }
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

                // 回复编辑区域
                .reply-edit-area {
                  margin: $spacing-sm 0;

                  .reply-edit-images {
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

                  .reply-edit-actions {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;

                    .image-hint {
                      font-size: 0.75rem;
                      color: $text-tertiary;
                    }

                    .action-btns {
                      display: flex;
                      gap: $spacing-sm;
                    }
                  }
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
  padding: 6px 10px;

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
        padding: 6px;
        cursor: pointer;
        border-radius: 4px;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);

        &:hover {
          background: #f0f0f0;
          transform: scale(1.05);
        }

        &:active {
          transform: scale(0.95);
        }

        &.icon-only {
          padding: 6px;
          min-width: 28px;
          min-height: 28px;
          justify-content: center;
        }

        // 格式按钮统一样式
        &.format-btn {
          display: flex;
          align-items: center;
          justify-content: center;
          width: 28px;
          height: 28px;
          padding: 0 !important;
          margin: 0 4px;
          border: none !important;
          
          &.active {
            background: rgba($primary, 0.1);
            color: $primary;
          }
          
          &:hover {
            background: #f0f0f0 !important;
            transform: scale(1.05) !important;
          }
          
          &:active {
            transform: scale(0.95) !important;
          }
          
          &:hover.active {
            background: rgba($primary, 0.2);
          }
        }

        // 覆盖el-button默认样式
        .el-button.text {
          padding: 0;
          border: none;
        }

        .format-icon {
          font-size: 0.875rem;
          font-weight: 600;
          color: $text-primary;
          line-height: 1;
          
          &.italic {
            font-style: italic;
          }
          
          &.underline {
            text-decoration: underline;
          }
          
          &.strikethrough {
            text-decoration: line-through;
          }
        }

        .format-icon-svg {
          font-size: 1rem;
          color: $text-primary;
          transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
          
          svg {
            transition: transform 0.2s cubic-bezier(0.4, 0, 0.2, 1);
          }
        }

        &:hover .format-icon-svg {
          transform: scale(1.1);
          
          svg {
            transform: scale(1.1);
          }
        }

        .color-preview {
          width: 16px;
          height: 16px;
          border-radius: 3px;
          transition: transform 0.2s ease;
        }

        .font-color-preview {
          width: 16px;
          height: 16px;
          font-size: 0.875rem;
          font-weight: bold;
          display: flex;
          align-items: center;
          justify-content: center;
          transition: transform 0.2s ease;
        }

        &:hover .color-preview,
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
      height: 20px;
      background: $border-light;
      margin: 0 5px;
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

// 翻译弹窗
.translation-popup {
  position: fixed;
  z-index: 1001;
  background: white;
  border-radius: $radius-lg;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  width: 320px;
  max-width: 90vw;

  .translation-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: $spacing-sm $spacing-md;
    border-bottom: 1px solid $border-light;
    font-weight: 500;
  }

  .translation-content {
    padding: $spacing-md;

    .original-text {
      font-size: 0.875rem;
      color: $text-secondary;
      margin-bottom: $spacing-sm;
      padding-bottom: $spacing-sm;
      border-bottom: 1px solid $border-light;
    }

    .translated-text {
      font-size: 0.9375rem;
      color: $text-primary;
      line-height: 1.6;
    }
  }
}

// 标签管理对话框样式
.tag-manager-content {
  .tag-search-box {
    margin-bottom: $spacing-lg;

    .tag-search-input {
      :deep(.el-input__wrapper) {
        background: $bg-secondary;
      }

      :deep(.el-input__inner) {
        color: #000000 !important; // 搜索框文字颜色设为黑色

        &::placeholder {
          color: $text-tertiary;
        }
      }
    }
  }

  .tag-list-section {
    margin-bottom: $spacing-lg;

    .tag-section-title {
      font-size: 0.75rem;
      color: $text-tertiary;
      margin-bottom: $spacing-sm;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }

    .tag-select-list {
      max-height: 250px;
      overflow-y: auto;

      .tag-select-item {
        display: flex;
        align-items: center;
        padding: $spacing-sm $spacing-md;
        border-radius: $radius-md;
        cursor: pointer;
        transition: all 0.2s;
        margin-bottom: $spacing-xs;

        &:hover {
          background: $bg-secondary;
        }

        &.is-selected {
          background: rgba($primary, 0.1);
          border: 1px solid rgba($primary, 0.3);
        }

        .tag-color-dot {
          width: 10px;
          height: 10px;
          border-radius: 50%;
          margin-right: $spacing-sm;
          flex-shrink: 0;
        }

        .tag-name {
          flex: 1;
          font-size: 0.875rem;
          color: #000000 !important; // 标签名称文字颜色设为黑色
        }

        .tag-count {
          font-size: 0.75rem;
          color: $text-tertiary;
          margin-right: $spacing-sm;
        }

        .tag-check-icon {
          color: $primary;
          margin-right: $spacing-sm;
        }

        .tag-delete-btn {
          opacity: 0;
          transition: opacity 0.2s;
          color: $text-tertiary;

          &:hover {
            color: $danger;
          }
        }

        &:hover .tag-delete-btn {
          opacity: 1;
        }
      }
    }

    .tag-empty-tip {
      text-align: center;
      padding: $spacing-lg;
      color: $text-tertiary;
      font-size: 0.8125rem;
    }
  }

  .selected-tags-preview {
    padding-top: $spacing-md;
    border-top: 1px solid $border-light;

    .tag-section-title {
      font-size: 0.75rem;
      color: $text-tertiary;
      margin-bottom: $spacing-sm;
    }

    .selected-tags-list {
      display: flex;
      flex-wrap: wrap;
      gap: $spacing-xs;

      .el-tag {
        color: white;
        border: none;

        .el-tag__close {
          color: rgba(255, 255, 255, 0.8);

          &:hover {
            color: white;
            background: rgba(255, 255, 255, 0.2);
          }
        }
      }
    }
  }
}

.tag-manager-footer {
  display: flex;
  justify-content: flex-end;
  gap: $spacing-sm;
}
</style>