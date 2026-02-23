<template>
  <div class="case-reader">
    <!-- 顶部导航栏 -->
    <div class="reader-header">
      <div class="header-left">
        <el-button text @click="$router.push('/cases')">
          <el-icon><ArrowLeft /></el-icon>
          <span class="back-text">返回案例库</span>
        </el-button>
      </div>
      <div class="header-center">
        <h1 class="case-title">{{ currentCase?.title }}</h1>
        <p class="case-citation">{{ currentCase?.citation }}</p>
      </div>
      <div class="header-actions">
        <el-tooltip content="编辑正文" placement="bottom">
          <el-button text @click="toggleEditMode" :type="isEditing ? 'primary' : ''">
            <el-icon><Edit /></el-icon>
          </el-button>
        </el-tooltip>
        <el-tooltip content="分享" placement="bottom">
          <el-button text @click="showShareDialog = true">
            <el-icon><Share /></el-icon>
          </el-button>
        </el-tooltip>
        <el-tooltip content="AI分析" placement="bottom">
          <el-button text @click="showAIAnalysis = true">
            <el-icon><MagicStick /></el-icon>
          </el-button>
        </el-tooltip>
        <el-tooltip content="评论" placement="bottom">
          <el-button text @click="toggleComments">
            <el-icon><ChatDotRound /></el-icon>
            <span class="comment-badge" v-if="comments.length > 0">{{ comments.length }}</span>
          </el-button>
        </el-tooltip>
        <el-tooltip content="关联笔记" placement="bottom">
          <el-button text @click="showRelatedNotes">
            <el-icon><Notebook /></el-icon>
          </el-button>
        </el-tooltip>
        <el-tooltip content="案例对比" placement="bottom">
          <el-button text @click="showCaseComparison">
            <el-icon><ScaleToOriginal /></el-icon>
          </el-button>
        </el-tooltip>
        <el-tooltip content="设置" placement="bottom">
          <el-button text @click="showSettings = true">
            <el-icon><Setting /></el-icon>
          </el-button>
        </el-tooltip>
      </div>
    </div>

    <!-- 案例元信息 -->
    <div class="case-metadata-bar">
      <el-tag size="small" type="primary">{{ currentCase?.court }}</el-tag>
      <el-tag size="small" type="info">{{ currentCase?.date }}</el-tag>
      <el-tag size="small" :type="getCategoryType(currentCase?.category)">{{ currentCase?.category }}</el-tag>
    </div>

    <!-- 阅读器主体 -->
    <div class="reader-container">
      <!-- 左侧目录 -->
      <div class="toc-sidebar" :class="{ collapsed: tocCollapsed }">
        <div class="toc-header">
          <span v-if="!tocCollapsed">目录</span>
          <el-button text @click="tocCollapsed = !tocCollapsed">
            <el-icon><ArrowLeft v-if="!tocCollapsed" /><ArrowRight v-else /></el-icon>
          </el-button>
        </div>
        <div v-if="!tocCollapsed" class="toc-content">
          <div v-if="tocItems.length === 0" class="empty-toc">
            暂无目录，请在正文中选择文本添加
          </div>
          <div
            v-for="(item, index) in tocItems"
            :key="item.id"
            class="toc-item-wrapper"
          >
            <div
              v-if="editingTocIndex !== index"
              class="toc-item"
              :class="{ active: currentSection === item.id }"
              :style="{ paddingLeft: (item.level * 12) + 'px' }"
              @click="scrollToParagraph(item.paragraphIndex)"
            >
              <span class="toc-text">{{ item.title }}</span>
              <div class="toc-actions">
                <el-icon @click.stop="startEditToc(index)" title="重命名"><Edit /></el-icon>
                <el-icon @click.stop="updateTocLevel(index, -1)" title="升级"><ArrowLeft /></el-icon>
                <el-icon @click.stop="updateTocLevel(index, 1)" title="降级"><ArrowRight /></el-icon>
                <el-icon @click.stop="removeTocItem(index)" title="删除"><Close /></el-icon>
              </div>
            </div>
            <!-- 重命名输入框 -->
            <div
              v-else
              class="toc-item toc-editing"
              :style="{ paddingLeft: (item.level * 12) + 'px' }"
            >
              <el-input
                v-model="editingTocTitle"
                size="small"
                @keyup.enter="saveTocEdit"
                @keyup.esc="cancelTocEdit"
                @blur="saveTocEdit"
                ref="tocEditInput"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- 中间正文 -->
      <div class="content-area" :class="{ 'with-comments': showCommentsPanel }">
        <div class="document-content" ref="documentRef">
          <div class="case-text" :style="{ fontSize: fontSize + 'px' }">
            <!-- 编辑模式 - 使用 editableParagraphs -->
            <template v-if="isEditing">
              <div
                v-for="(paragraph, index) in editableParagraphs"
                :key="'edit-' + index"
                class="paragraph"
                :data-paragraph-index="index"
              >
                <div class="paragraph-editor">
                  <div class="editor-row">
                    <span class="paragraph-number-edit">{{ index + 1 }}</span>
                    <el-input
                      v-model="editableParagraphs[index]"
                      type="textarea"
                      :rows="1"
                      autosize
                      @keydown.enter.prevent="handleParagraphEnter(index, $event)"
                      @keydown.delete="handleParagraphDelete(index, $event)"
                      :ref="(el) => setParagraphInputRef(el, index)"
                    />
                    <el-button
                      text
                      size="small"
                      class="delete-paragraph-btn"
                      @click="removeParagraph(index)"
                      title="删除段落"
                    >
                      <el-icon><Delete /></el-icon>
                    </el-button>
                  </div>
                </div>
              </div>
            </template>
            <!-- 阅读模式 - 使用 displayParagraphs -->
            <template v-else>
              <div
                v-for="(paragraph, index) in displayParagraphs"
                :key="'read-' + index"
                class="paragraph"
                :data-paragraph-index="index"
              >
                <span v-if="showParagraphNumbers" class="paragraph-number">{{ index + 1 }}</span>
                <span
                  class="paragraph-text"
                  @mouseup="handleTextSelection"
                  @mousedown="handleMouseDown"
                  v-html="renderParagraphWithAnnotations(paragraph, index)"
                ></span>
              </div>
            </template>
          </div>
        </div>
      </div>

      <!-- 右侧评论面板 -->
      <div
        v-if="showCommentsPanel"
        class="comments-sidebar"
        :style="{ width: commentsPanelWidth + 'px' }"
      >
        <div class="sidebar-header">
          <h3>评论 ({{ comments.length }})</h3>
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
                <el-avatar :size="28" :src="comment.userAvatar">
                  {{ comment.userName?.charAt(0) || 'U' }}
                </el-avatar>
                <div class="user-meta">
                  <span class="user-name">{{ comment.userName }}</span>
                  <span class="comment-time">{{ formatRelativeTime(comment.createdAt) }}</span>
                </div>
              </div>

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

              <div class="comment-actions-bar">
                <el-button text size="small" @click="likeComment(comment)">
                  <el-icon><CircleCheck /></el-icon>
                  <span v-if="comment.likes">{{ comment.likes }}</span>
                </el-button>
                <el-button text size="small" @click="replyToComment(comment)">
                  回复
                </el-button>
                <el-dropdown trigger="click" @command="handleCommentAction($event, comment)">
                  <el-button text size="small">
                    <el-icon><MoreFilled /></el-icon>
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
                    <el-avatar :size="20" :src="reply.userAvatar">
                      {{ reply.userName?.charAt(0) || 'U' }}
                    </el-avatar>
                    <span class="reply-user">{{ reply.userName }}</span>
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
          <div v-if="comments.length === 0" class="empty-comments">
            <el-icon class="empty-icon"><ChatDotRound /></el-icon>
            <p>暂无评论</p>
            <p class="empty-hint">选中文本后点击"评论"按钮添加</p>
          </div>
        </div>

        <!-- 添加评论输入框 -->
        <div
          class="comment-input-area"
          @drop="handleImageDrop"
          @dragover.prevent
          @paste="handleImagePaste"
        >
          <div v-if="replyingTo" class="replying-to">
            <span>回复 {{ replyingTo.userName }}</span>
            <el-button text size="small" @click="cancelReply">
              <el-icon><Close /></el-icon>
            </el-button>
          </div>
          <div v-if="selectedTextForComment" class="selected-text-hint">
            <span>引用: "{{ selectedTextForComment.substring(0, 50) }}{{ selectedTextForComment.length > 50 ? '...' : '' }}"</span>
            <el-button text size="small" @click="clearSelectedText">
              <el-icon><Close /></el-icon>
            </el-button>
          </div>
          <!-- 图片预览区域 -->
          <div v-if="commentImages.length" class="comment-images-preview">
            <div
              v-for="(img, index) in commentImages"
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
            :placeholder="replyingTo ? '回复评论...（支持拖拽或粘贴图片）' : '添加评论...（支持Markdown格式、拖拽或粘贴图片）'"
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

    <!-- 标注工具栏（选中文本后显示）- 飞书风格 -->
    <div
      v-if="showAnnotationToolbar"
      class="annotation-toolbar"
      :style="toolbarPosition"
    >
      <div class="toolbar-content">
        <!-- 高亮按钮 + 颜色选择 -->
        <div class="toolbar-item-wrapper" @mouseenter="showHighlightColors = true" @mouseleave="showHighlightColors = false">
          <div class="toolbar-item" @click="addHighlight(activeHighlightColor)">
            <div class="color-preview" :style="{ background: activeHighlightColor }"></div>
            <span>高亮</span>
          </div>
          <!-- 高亮颜色选择面板 -->
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

        <!-- 下划线按钮 + 颜色选择 -->
        <div class="toolbar-item-wrapper" @mouseenter="showUnderlineColors = true" @mouseleave="showUnderlineColors = false">
          <div class="toolbar-item" @click="addUnderline(activeUnderlineColor)">
            <div class="underline-preview" :style="{ borderBottomColor: activeUnderlineColor }"></div>
            <span>下划线</span>
          </div>
          <!-- 下划线颜色选择面板 -->
          <div v-show="showUnderlineColors" class="color-picker-dropdown">
            <div
              v-for="color in underlineColors"
              :key="color"
              class="color-dot"
              :class="{ active: activeUnderlineColor === color }"
              :style="{ background: color }"
              @click.stop="addUnderline(color)"
            ></div>
          </div>
        </div>

        <div class="toolbar-divider"></div>

        <!-- 评论 -->
        <el-tooltip content="评论" placement="top">
          <div class="toolbar-item" @click="addComment">
            <el-icon><ChatDotRound /></el-icon>
            <span>评论</span>
          </div>
        </el-tooltip>
        <!-- 笔记 -->
        <el-tooltip content="添加到笔记" placement="top">
          <div class="toolbar-item" @click="addToNote">
            <el-icon><Notebook /></el-icon>
            <span>笔记</span>
          </div>
        </el-tooltip>
        <!-- 翻译 -->
        <el-tooltip content="翻译" placement="top">
          <div class="toolbar-item" @click="translateText">
            <el-icon><Compass /></el-icon>
            <span>翻译</span>
          </div>
        </el-tooltip>
        <!-- 牌组 -->
        <el-tooltip content="添加到牌组" placement="top">
          <div class="toolbar-item" @click="addToDeck">
            <el-icon><Collection /></el-icon>
            <span>牌组</span>
          </div>
        </el-tooltip>
        <!-- 目录 -->
        <el-tooltip content="添加到目录" placement="top">
          <div class="toolbar-item" @click="addToDirectory">
            <el-icon><List /></el-icon>
            <span>目录</span>
          </div>
        </el-tooltip>
      </div>
    </div>

    <!-- 标注删除弹窗（点击已有标注时显示） -->
    <div
      v-if="showAnnotationPopup"
      class="annotation-popup"
      :style="annotationPopupPosition"
    >
      <el-button size="small" type="danger" text @click="deleteAnnotation(activeAnnotationId)">
        <el-icon><Delete /></el-icon>
        删除
      </el-button>
    </div>

    <!-- 翻译悬浮框 -->
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

    <!-- 设置对话框 -->
    <el-dialog v-model="showSettings" title="阅读设置" width="400px">
      <el-form label-position="left" label-width="120px">
        <el-form-item label="字体大小">
          <el-slider v-model="fontSize" :min="14" :max="24" :step="1" show-stops />
        </el-form-item>
        <el-form-item label="显示段落编号">
          <el-switch v-model="showParagraphNumbers" />
        </el-form-item>
        <el-form-item label="夜间模式">
          <el-switch v-model="darkMode" @change="toggleDarkMode" />
        </el-form-item>
        <el-form-item label="评论面板宽度">
          <el-slider v-model="commentsPanelWidth" :min="300" :max="500" :step="10" />
        </el-form-item>
      </el-form>
    </el-dialog>

    <!-- AI分析对话框 -->
    <el-dialog v-model="showAIAnalysis" title="AI智能分析" width="600px">
      <div class="ai-analysis-content">
        <el-skeleton :rows="5" animated v-if="aiLoading" />
        <div v-else>
          <h4>📋 争议点</h4>
          <ul>
            <li>合同违约责任的认定</li>
            <li>损害赔偿范围的确定</li>
          </ul>
          <h4>⚖️ 法律规则</h4>
          <p>Hadley v. Baxendale规则：损害赔偿应限于违约时可合理预见的损失</p>
        </div>
      </div>
    </el-dialog>

    <!-- 分享对话框 -->
    <el-dialog v-model="showShareDialog" title="分享案例" width="500px">
      <el-form label-position="top">
        <el-form-item label="分享链接">
          <el-input v-model="shareLink" readonly>
            <template #append>
              <el-button @click="copyShareLink">复制</el-button>
            </template>
          </el-input>
        </el-form-item>
        <el-form-item label="权限">
          <el-radio-group v-model="sharePermission">
            <el-radio label="readonly">仅查看</el-radio>
            <el-radio label="comment">可评论</el-radio>
            <el-radio label="edit">可编辑</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, onUnmounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useCasesStore } from '@/stores'
import { ElMessage, ElMessageBox } from 'element-plus'
import { marked } from 'marked'

const route = useRoute()
const router = useRouter()
const casesStore = useCasesStore()

// ==================== 颜色配置 ====================
const highlightColors = ['#FCD34D', '#93C5FD', '#86EFAC', '#F9A8D4', '#C4B5FD']
const underlineColors = ['#EF4444', '#3B82F6', '#22C55E', '#8B5CF6', '#F97316']
const activeHighlightColor = ref('#FCD34D')
const activeUnderlineColor = ref('#EF4444')
const showHighlightColors = ref(false)
const showUnderlineColors = ref(false)

// ==================== 基础状态 ====================
const currentCase = ref(null)
const showCommentsPanel = ref(true)
const showAnnotationToolbar = ref(false)
const showSettings = ref(false)
const showAIAnalysis = ref(false)
const showShareDialog = ref(false)
const showTranslationPopup = ref(false)
const aiLoading = ref(false)
const tocCollapsed = ref(false)
const currentSection = ref('')
const activeCommentId = ref(null)
const expandedCommentIds = ref([])

// 编辑模式
const isEditing = ref(false)
const editableParagraphs = ref([])

// 目录
const tocItems = ref([])
const editingTocIndex = ref(-1)
const editingTocTitle = ref('')
const tocEditInput = ref(null)

// 设置
const fontSize = ref(16)
const showParagraphNumbers = ref(true)
const darkMode = ref(false)
const commentsPanelWidth = ref(380)

// ==================== 标注数据（独立于评论） ====================
const annotations = ref([
  {
    id: 'anno-1',
    paragraphIndex: 3,
    startOffset: 0,
    endOffset: 45,
    type: 'highlight',
    color: '#FCD34D',
    text: 'The plaintiff entered into a contract with'
  },
  {
    id: 'anno-2',
    paragraphIndex: 6,
    startOffset: 10,
    endOffset: 55,
    type: 'underline',
    color: '#EF4444',
    text: 'breached the contract by failing to deliver'
  }
])

// ==================== 评论数据（独立于标注） ====================
const comments = ref([
  {
    id: 'comment-1',
    paragraphIndex: 6,
    startOffset: 10,
    endOffset: 80,
    selectedText: 'The defendant breached the contract by failing to deliver the goods on time',
    content: '这是本案的关键违约事实，需要重点关注',
    userName: '法律学习者',
    userAvatar: '',
    createdAt: new Date(Date.now() - 5 * 60 * 1000),
    likes: 3,
    replies: [
      {
        id: 'reply-1',
        userName: '当前用户',
        userAvatar: '',
        content: '同意，这是核心争议点',
        createdAt: new Date(Date.now() - 60 * 60 * 1000)
      }
    ]
  },
  {
    id: 'comment-2',
    paragraphIndex: 8,
    startOffset: 5,
    endOffset: 30,
    selectedText: 'Hadley v. Baxendale rule',
    content: '这是损害赔偿的经典规则，需要重点掌握',
    userName: '案例分析师',
    userAvatar: '',
    createdAt: new Date(Date.now() - 24 * 60 * 60 * 1000),
    likes: 5,
    replies: []
  }
])

const newCommentContent = ref('')
const replyingTo = ref(null)
const editingCommentId = ref(null)
const selectedTextForComment = ref('')
const editingReply = ref(null)
const commentImages = ref([])
const replyImages = ref([])

// ==================== 选区状态 ====================
const selectedText = ref('')
const selectedRange = ref(null)
const selectedParagraphIndex = ref(-1)
const toolbarPosition = ref({ top: '0px', left: '0px' })
const translationPosition = ref({ top: '0px', left: '0px' })
const translatedText = ref('')

// ==================== 标注删除弹窗 ====================
const showAnnotationPopup = ref(false)
const activeAnnotationId = ref(null)
const annotationPopupPosition = ref({ top: '0px', left: '0px' })

// 分享
const shareLink = ref('https://enoflaw.com/share/case/123')
const sharePermission = ref('readonly')

// ==================== 计算属性 ====================
const displayParagraphs = computed(() => {
  if (!currentCase.value?.content) return []
  const paras = currentCase.value.content.split('\n').filter(p => p.trim())
  // 移除正文中的段落编号 (如 "1. ", "(1) ", "1 ")
  return paras.map(p => p.replace(/^\s*\(?\d+[\.\)]?\s*/, ''))
})

const sortedComments = computed(() => {
  return [...comments.value].sort((a, b) => a.paragraphIndex - b.paragraphIndex)
})

// ==================== 生命周期 ====================
onMounted(() => {
  const caseId = route.params.id
  currentCase.value = casesStore.getCaseById(caseId)
  if (!currentCase.value) {
    ElMessage.error('案例不存在')
    router.push('/cases')
    return
  }

  // 初始化可编辑段落
  editableParagraphs.value = displayParagraphs.value.map(p => p)

  expandedCommentIds.value = comments.value.map(c => c.id)
  document.addEventListener('mousedown', handleDocumentClick)
})

onUnmounted(() => {
  document.removeEventListener('mousedown', handleDocumentClick)
  delete window.handleAnnotationClick
  delete window.handleCommentMarkerClick
})

// ==================== 编辑模式 ====================
const toggleEditMode = () => {
  isEditing.value = !isEditing.value
  if (isEditing.value) {
    // 进入编辑模式，同步当前显示内容到编辑器
    editableParagraphs.value = displayParagraphs.value.map(p => p)
    showAnnotationToolbar.value = false
    showAnnotationPopup.value = false
  } else {
    // 退出编辑模式，保存更改
    // 这里简单地将段落合并回 content
    // 注意：这可能会破坏基于偏移量的标注，实际项目中需要更复杂的处理
    const newContent = editableParagraphs.value.join('\n')
    currentCase.value.content = newContent
    ElMessage.success('已保存更改')
  }
}

const handleParagraphChange = (index, val) => {
  editableParagraphs.value[index] = val
}

// 段落输入框引用
const paragraphInputRefs = ref([])
const setParagraphInputRef = (el, index) => {
  if (el) {
    paragraphInputRefs.value[index] = el
  }
}

// 处理回车键 - 在光标位置拆分段落或创建新段落
const handleParagraphEnter = (index, event) => {
  const currentText = editableParagraphs.value[index]
  const input = paragraphInputRefs.value[index]

  if (!input) return

  const textarea = input.$el.querySelector('textarea')
  if (!textarea) return

  const cursorPosition = textarea.selectionStart
  const textBeforeCursor = currentText.substring(0, cursorPosition)
  const textAfterCursor = currentText.substring(cursorPosition)

  // 更新当前段落为光标前的内容
  editableParagraphs.value[index] = textBeforeCursor

  // 在当前段落后插入新段落，内容为光标后的内容
  editableParagraphs.value.splice(index + 1, 0, textAfterCursor)

  // 聚焦到新段落
  nextTick(() => {
    const newInput = paragraphInputRefs.value[index + 1]
    if (newInput) {
      newInput.focus()
      // 将光标移到新段落开头
      const newTextarea = newInput.$el.querySelector('textarea')
      if (newTextarea) {
        newTextarea.setSelectionRange(0, 0)
      }
    }
  })
}

// 处理删除键 - 如果段落为空且不是第一段，则删除并合并到上一段
const handleParagraphDelete = (index, event) => {
  const currentText = editableParagraphs.value[index]
  // 只有当段落为空且不是第一段时才删除
  if (currentText === '' && index > 0) {
    event.preventDefault()
    // 删除当前段落
    editableParagraphs.value.splice(index, 1)
    // 聚焦到上一段末尾
    nextTick(() => {
      const prevInput = paragraphInputRefs.value[index - 1]
      if (prevInput) {
        prevInput.focus()
        const textarea = prevInput.$el.querySelector('textarea')
        if (textarea) {
          const len = textarea.value.length
          textarea.setSelectionRange(len, len)
        }
      }
    })
  }
}

// 删除段落
const removeParagraph = (index) => {
  if (editableParagraphs.value.length <= 1) {
    ElMessage.warning('至少需要保留一个段落')
    return
  }
  editableParagraphs.value.splice(index, 1)
  ElMessage.success('已删除段落')
}

// ==================== 目录管理 ====================
const addToDirectory = () => {
  if (!selectedText.value) return
  
  const title = selectedText.value.length > 20 
    ? selectedText.value.substring(0, 20) + '...' 
    : selectedText.value

  tocItems.value.push({
    id: 'toc-' + Date.now(),
    title: title,
    level: 1,
    paragraphIndex: selectedParagraphIndex.value
  })
  
  ElMessage.success('已添加到目录')
  showAnnotationToolbar.value = false
  window.getSelection().removeAllRanges()
}

const updateTocLevel = (index, change) => {
  const item = tocItems.value[index]
  const newLevel = item.level + change
  if (newLevel >= 1 && newLevel <= 3) {
    item.level = newLevel
  }
}

const removeTocItem = (index) => {
  tocItems.value.splice(index, 1)
}

// 开始编辑目录项
const startEditToc = (index) => {
  editingTocIndex.value = index
  editingTocTitle.value = tocItems.value[index].title
  nextTick(() => {
    tocEditInput.value?.focus()
  })
}

// 保存目录编辑
const saveTocEdit = () => {
  if (editingTocIndex.value >= 0 && editingTocTitle.value.trim()) {
    tocItems.value[editingTocIndex.value].title = editingTocTitle.value.trim()
  }
  editingTocIndex.value = -1
  editingTocTitle.value = ''
}

// 取消目录编辑
const cancelTocEdit = () => {
  editingTocIndex.value = -1
  editingTocTitle.value = ''
}

const scrollToParagraph = (index) => {
  const el = document.querySelector(`[data-paragraph-index="${index}"]`)
  if (el) {
    el.scrollIntoView({ behavior: 'smooth', block: 'center' })
    // 高亮一下目标段落
    el.style.backgroundColor = 'rgba(252, 211, 77, 0.2)'
    setTimeout(() => {
      el.style.backgroundColor = ''
    }, 1500)
  }
}

// ==================== 文档点击处理 ====================
const handleDocumentClick = (e) => {
  const toolbar = document.querySelector('.annotation-toolbar')
  const popup = document.querySelector('.annotation-popup')

  // 关闭标注删除弹窗
  if (popup && !popup.contains(e.target) && !e.target.closest('[data-annotation-id]')) {
    showAnnotationPopup.value = false
  }

  // 关闭工具栏
  if (toolbar && !toolbar.contains(e.target)) {
    setTimeout(() => {
      if (!showAnnotationToolbar.value) return
      const selection = window.getSelection()
      if (selection.toString().trim() === '') {
        showAnnotationToolbar.value = false
      }
    }, 200)
  }
}

// ==================== 文本选择 ====================
const handleMouseDown = () => {
  showAnnotationToolbar.value = false
  showAnnotationPopup.value = false
}

const handleTextSelection = () => {
  if (isEditing.value) return // 编辑模式下禁用标注

  const selection = window.getSelection()
  const text = selection.toString().trim()

  if (text && text.length > 0) {
    selectedText.value = text
    selectedRange.value = selection.getRangeAt(0)

    const node = selection.anchorNode
    const paragraphEl = node?.parentElement?.closest('.paragraph')
    if (paragraphEl) {
      selectedParagraphIndex.value = parseInt(paragraphEl.dataset.paragraphIndex)
    }

    const range = selection.getRangeAt(0)
    const rect = range.getBoundingClientRect()
    toolbarPosition.value = {
      top: rect.top - 60 + 'px',
      left: Math.max(10, rect.left + rect.width / 2 - 200) + 'px' // 调整位置以适应更多按钮
    }

    showAnnotationToolbar.value = true
  } else {
    showAnnotationToolbar.value = false
  }
}

// ==================== 扫描线渲染算法 ====================
const renderParagraphWithAnnotations = (text, paragraphIndex) => {
  // 收集该段落所有标注
  const paraAnnotations = annotations.value.filter(a => a.paragraphIndex === paragraphIndex)
  const paraComments = comments.value.filter(c => c.paragraphIndex === paragraphIndex)

  if (paraAnnotations.length === 0 && paraComments.length === 0) {
    return escapeHtml(text)
  }

  // 构建事件点（扫描线）
  const events = []

  paraAnnotations.forEach(a => {
    const start = Math.max(0, Math.min(a.startOffset, text.length))
    const end = Math.max(0, Math.min(a.endOffset, text.length))
    if (start < end) {
      events.push({ pos: start, type: 'start', annotation: a, kind: a.type })
      events.push({ pos: end, type: 'end', annotation: a, kind: a.type })
    }
  })

  paraComments.forEach(c => {
    const start = Math.max(0, Math.min(c.startOffset, text.length))
    const end = Math.max(0, Math.min(c.endOffset, text.length))
    if (start < end) {
      events.push({ pos: start, type: 'start', annotation: c, kind: 'comment' })
      events.push({ pos: end, type: 'end', annotation: c, kind: 'comment' })
    }
  })

  // 按位置排序，start 在 end 前
  events.sort((a, b) => a.pos - b.pos || (a.type === 'start' ? -1 : 1))

  // 收集所有断点
  const breakpoints = [...new Set(events.map(e => e.pos))].sort((a, b) => a - b)

  if (breakpoints.length === 0) return escapeHtml(text)

  // 构建结果
  let result = ''
  let lastPos = 0

  // 当前活跃的标注集合
  const activeHighlights = new Set()
  const activeUnderlines = new Set()
  const activeComments = new Set()

  let eventIdx = 0

  // 添加所有断点，包括0和text.length
  const allPoints = [0, ...breakpoints, text.length]
  const uniquePoints = [...new Set(allPoints)].sort((a, b) => a - b)

  for (let i = 0; i < uniquePoints.length - 1; i++) {
    const segStart = uniquePoints[i]
    const segEnd = uniquePoints[i + 1]

    // 处理该位置的事件
    while (eventIdx < events.length && events[eventIdx].pos <= segStart) {
      const evt = events[eventIdx]
      const set = evt.kind === 'highlight' ? activeHighlights
        : evt.kind === 'underline' ? activeUnderlines
        : activeComments
      if (evt.type === 'start') {
        set.add(evt.annotation)
      } else {
        set.delete(evt.annotation)
      }
      eventIdx++
    }

    const segText = escapeHtml(text.substring(segStart, segEnd))

    if (activeHighlights.size === 0 && activeUnderlines.size === 0 && activeComments.size === 0) {
      result += segText
    } else {
      // 构建样式
      const styles = []
      const classes = []
      const dataAttrs = []

      // 高亮：取最后添加的颜色
      if (activeHighlights.size > 0) {
        const hl = [...activeHighlights].pop()
        styles.push(`background-color: ${hl.color}`)
        classes.push('ann-highlight')
        dataAttrs.push(`data-annotation-id="${hl.id}"`)
      }

      // 下划线：取最后添加的颜色
      if (activeUnderlines.size > 0) {
        const ul = [...activeUnderlines].pop()
        styles.push(`border-bottom: 2px solid ${ul.color}`)
        classes.push('ann-underline')
        if (activeHighlights.size === 0) {
          dataAttrs.push(`data-annotation-id="${ul.id}"`)
        }
      }

      // 评论标记：浅黄色虚线下划线
      if (activeComments.size > 0) {
        const cm = [...activeComments].pop()
        if (activeUnderlines.size === 0) {
          styles.push('border-bottom: 2px dashed #F59E0B')
        }
        classes.push('ann-comment')
        dataAttrs.push(`data-comment-id="${cm.id}"`)
      }

      const clickHandler = activeComments.size > 0
        ? `onclick="window.handleCommentMarkerClick('${[...activeComments].pop().id}', event)"`
        : activeHighlights.size > 0 || activeUnderlines.size > 0
          ? `onclick="window.handleAnnotationClick('${dataAttrs[0]?.match(/"([^"]+)"/)?.[1]}', event)"`
          : ''

      result += `<span class="${classes.join(' ')}" style="${styles.join('; ')}" ${dataAttrs.join(' ')} ${clickHandler}>${segText}</span>`
    }
  }

  return result
}

const escapeHtml = (text) => {
  const div = document.createElement('div')
  div.textContent = text
  return div.innerHTML
}

// ==================== 全局点击处理 ====================
window.handleAnnotationClick = (annotationId, event) => {
  event.stopPropagation()
  if (!annotationId) return

  activeAnnotationId.value = annotationId
  const rect = event.target.getBoundingClientRect()
  annotationPopupPosition.value = {
    top: rect.top - 40 + 'px',
    left: rect.left + rect.width / 2 - 30 + 'px'
  }
  showAnnotationPopup.value = true
  // 确保不打开评论面板
  // showCommentsPanel.value = false // 用户可能希望保持评论面板状态，只是不弹出
}

window.handleCommentMarkerClick = (commentId, event) => {
  event.stopPropagation()
  activeCommentId.value = commentId
  showCommentsPanel.value = true

  if (!expandedCommentIds.value.includes(commentId)) {
    expandedCommentIds.value.push(commentId)
  }

  nextTick(() => {
    const commentEl = document.querySelector(`[data-comment-id="${commentId}"]`)
    if (commentEl) {
      commentEl.scrollIntoView({ behavior: 'smooth', block: 'center' })
    }
  })
}

// ==================== 偏移量计算 ====================
const getTextOffset = (container, node, offset) => {
  let textOffset = 0
  const walker = document.createTreeWalker(container, NodeFilter.SHOW_TEXT)
  let currentNode
  while (currentNode = walker.nextNode()) {
    if (currentNode === node) {
      return textOffset + offset
    }
    textOffset += currentNode.textContent.length
  }
  return textOffset
}

// ==================== 添加高亮 ====================
const addHighlight = (color) => {
  if (!selectedRange.value) return

  activeHighlightColor.value = color
  const paragraphIndex = selectedParagraphIndex.value
  const paragraphEl = document.querySelector(`[data-paragraph-index="${paragraphIndex}"] .paragraph-text`)

  if (paragraphEl) {
    const range = selectedRange.value
    const startOffset = getTextOffset(paragraphEl, range.startContainer, range.startOffset)
    const endOffset = getTextOffset(paragraphEl, range.endContainer, range.endOffset)

    annotations.value.push({
      id: 'anno-' + Date.now(),
      paragraphIndex,
      startOffset,
      endOffset,
      type: 'highlight',
      color,
      text: selectedText.value
    })

    ElMessage.success('已添加高亮')
  }

  showAnnotationToolbar.value = false
  showHighlightColors.value = false
  window.getSelection().removeAllRanges()
}

// ==================== 添加下划线 ====================
const addUnderline = (color) => {
  if (!selectedRange.value) return

  activeUnderlineColor.value = color
  const paragraphIndex = selectedParagraphIndex.value
  const paragraphEl = document.querySelector(`[data-paragraph-index="${paragraphIndex}"] .paragraph-text`)

  if (paragraphEl) {
    const range = selectedRange.value
    const startOffset = getTextOffset(paragraphEl, range.startContainer, range.startOffset)
    const endOffset = getTextOffset(paragraphEl, range.endContainer, range.endOffset)

    annotations.value.push({
      id: 'anno-' + Date.now(),
      paragraphIndex,
      startOffset,
      endOffset,
      type: 'underline',
      color,
      text: selectedText.value
    })

    ElMessage.success('已添加下划线')
  }

  showAnnotationToolbar.value = false
  showUnderlineColors.value = false
  window.getSelection().removeAllRanges()
}

// ==================== 删除标注 ====================
const deleteAnnotation = (annotationId) => {
  const index = annotations.value.findIndex(a => a.id === annotationId)
  if (index > -1) {
    annotations.value.splice(index, 1)
    ElMessage.success('标注已删除')
  }
  showAnnotationPopup.value = false
  activeAnnotationId.value = null
}

// ==================== 添加评论 ====================
const addComment = () => {
  showAnnotationToolbar.value = false
  showCommentsPanel.value = true
  selectedTextForComment.value = selectedText.value

  const paragraphIndex = selectedParagraphIndex.value
  const paragraphEl = document.querySelector(`[data-paragraph-index="${paragraphIndex}"] .paragraph-text`)

  if (paragraphEl && selectedRange.value) {
    const range = selectedRange.value
    const startOffset = getTextOffset(paragraphEl, range.startContainer, range.startOffset)
    const endOffset = getTextOffset(paragraphEl, range.endContainer, range.endOffset)

    const newCommentId = 'comment-' + Date.now()
    const newComment = {
      id: newCommentId,
      paragraphIndex,
      startOffset,
      endOffset,
      selectedText: selectedText.value,
      content: '',
      userName: '当前用户',
      userAvatar: '',
      createdAt: new Date(),
      likes: 0,
      replies: []
    }

    comments.value.push(newComment)
    activeCommentId.value = newCommentId
    expandedCommentIds.value.push(newCommentId)

    nextTick(() => {
      const commentEl = document.querySelector(`[data-comment-id="${newCommentId}"]`)
      if (commentEl) {
        commentEl.scrollIntoView({ behavior: 'smooth', block: 'center' })
      }
    })
  }

  window.getSelection().removeAllRanges()
}

// ==================== 评论操作 ====================
const toggleComments = () => {
  showCommentsPanel.value = !showCommentsPanel.value
}

const toggleCommentExpand = (commentId) => {
  const index = expandedCommentIds.value.indexOf(commentId)
  if (index > -1) {
    expandedCommentIds.value.splice(index, 1)
  } else {
    expandedCommentIds.value.push(commentId)
  }
  activeCommentId.value = commentId

  // 自动定位到左侧正文对应段落
  const comment = comments.value.find(c => c.id === commentId)
  if (comment && comment.paragraphIndex !== undefined) {
    scrollToParagraph(comment.paragraphIndex)
  }
}

const clearSelectedText = () => {
  selectedTextForComment.value = ''
}

const submitComment = () => {
  if (!newCommentContent.value.trim() && commentImages.value.length === 0) return

  if (replyingTo.value) {
    const parentComment = comments.value.find(c => c.id === replyingTo.value.id)
    if (parentComment) {
      if (!parentComment.replies) parentComment.replies = []
      parentComment.replies.push({
        id: 'reply-' + Date.now(),
        userName: '当前用户',
        userAvatar: '',
        content: newCommentContent.value,
        images: [...commentImages.value],
        createdAt: new Date()
      })
    }
    replyingTo.value = null
  } else if (editingCommentId.value) {
    const comment = comments.value.find(c => c.id === editingCommentId.value)
    if (comment) {
      comment.content = newCommentContent.value
      if (commentImages.value.length > 0) {
        comment.images = [...commentImages.value]
      }
    }
    editingCommentId.value = null
  } else {
    // 填充待填写的评论
    const pendingComment = comments.value.find(c => c.id === activeCommentId.value && !c.content)
    if (pendingComment) {
      pendingComment.content = newCommentContent.value
      if (commentImages.value.length > 0) {
        pendingComment.images = [...commentImages.value]
      }
    }
  }

  newCommentContent.value = ''
  selectedTextForComment.value = ''
  commentImages.value = []
}

const replyToComment = (comment) => {
  replyingTo.value = comment
  editingCommentId.value = null
}

const cancelReply = () => {
  replyingTo.value = null
}

const likeComment = (comment) => {
  comment.likes = (comment.likes || 0) + 1
}

const handleCommentAction = (command, comment) => {
  switch (command) {
    case 'edit':
      editingCommentId.value = comment.id
      newCommentContent.value = comment.content
      replyingTo.value = null
      break
    case 'delete':
      ElMessageBox.confirm('确定要删除这条评论吗？', '删除评论', {
        confirmButtonText: '删除',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        const index = comments.value.findIndex(c => c.id === comment.id)
        if (index > -1) {
          comments.value.splice(index, 1)
          ElMessage.success('评论已删除')
        }
      }).catch(() => {})
      break
  }
}

// 编辑回复
const editReply = (comment, reply) => {
  editingReply.value = {
    commentId: comment.id,
    replyId: reply.id,
    content: reply.content,
    images: reply.images ? [...reply.images] : []
  }
}

// 保存回复编辑
const saveReplyEdit = () => {
  if (!editingReply.value) return
  const comment = comments.value.find(c => c.id === editingReply.value.commentId)
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
const handleReplyEditImageDrop = (e) => {
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
const handleReplyEditImagePaste = (e) => {
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
const removeReplyEditImage = (index) => {
  if (editingReply.value && editingReply.value.images) {
    editingReply.value.images.splice(index, 1)
  }
}

// 取消回复编辑
const cancelEditReply = () => {
  editingReply.value = null
}

// 删除回复
const deleteReply = (comment, reply) => {
  ElMessageBox.confirm('确定要删除这条回复吗？', '删除回复', {
    confirmButtonText: '删除',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    const replyIndex = comment.replies.findIndex(r => r.id === reply.id)
    if (replyIndex > -1) {
      comment.replies.splice(replyIndex, 1)
      ElMessage.success('回复已删除')
    }
  }).catch(() => {})
}

const handleCommentKeydown = (e) => {
  if (e.key === 'Enter' && e.metaKey) {
    submitComment()
  }
}

// ==================== 图片处理功能 ====================
// 处理拖拽图片
const handleImageDrop = (e) => {
  e.preventDefault()
  const files = e.dataTransfer.files
  handleImageFiles(files)
}

// 处理粘贴图片
const handleImagePaste = (e) => {
  const items = e.clipboardData.items
  for (let i = 0; i < items.length; i++) {
    if (items[i].type.indexOf('image') !== -1) {
      const file = items[i].getAsFile()
      handleImageFile(file)
    }
  }
}

// 处理多个图片文件
const handleImageFiles = (files) => {
  for (let i = 0; i < files.length; i++) {
    if (files[i].type.indexOf('image') !== -1) {
      handleImageFile(files[i])
    }
  }
}

// 处理单个图片文件
const handleImageFile = (file) => {
  const reader = new FileReader()
  reader.onload = (e) => {
    commentImages.value.push(e.target.result)
  }
  reader.readAsDataURL(file)
}

// 移除评论图片
const removeCommentImage = (index) => {
  commentImages.value.splice(index, 1)
}

// 查看图片全图
const viewImage = (imgSrc) => {
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
  const img = document.createElement('img')
  img.src = imgSrc
  img.style.cssText = `
    max-width: 90%;
    max-height: 90%;
    object-fit: contain;
  `
  viewer.appendChild(img)
  viewer.onclick = () => document.body.removeChild(viewer)
  document.body.appendChild(viewer)
}

// 显示图片右键菜单
const showImageContextMenu = (e, imgSrc) => {
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
const copyImageToClipboard = async (imgSrc) => {
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

// ==================== 其他功能 ====================
const toggleDarkMode = () => {
  document.body.classList.toggle('dark-mode', darkMode.value)
}

const startResize = (e) => {
  const startX = e.clientX
  const startWidth = commentsPanelWidth.value
  const doResize = (e) => {
    const newWidth = startWidth - (e.clientX - startX)
    if (newWidth >= 300 && newWidth <= 500) {
      commentsPanelWidth.value = newWidth
    }
  }
  const stopResize = () => {
    document.removeEventListener('mousemove', doResize)
    document.removeEventListener('mouseup', stopResize)
  }
  document.addEventListener('mousemove', doResize)
  document.addEventListener('mouseup', stopResize)
}

const renderMarkdown = (content) => {
  if (!content) return ''
  return marked.parse(content, { breaks: true, gfm: true })
}

const formatRelativeTime = (date) => {
  const now = new Date()
  const diff = now - new Date(date)
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)
  if (minutes < 1) return '刚刚'
  if (minutes < 60) return `${minutes}分钟前`
  if (hours < 24) return `${hours}小时前`
  if (days < 30) return `${days}天前`
  return new Date(date).toLocaleDateString('zh-CN')
}

const getCategoryType = (category) => {
  const types = { '合同法': 'primary', '侵权法': 'success', '刑法': 'danger', '宪法': 'warning', '证据法': 'info' }
  return types[category] || ''
}

const copyShareLink = () => {
  navigator.clipboard.writeText(shareLink.value)
  ElMessage.success('链接已复制')
}

const showRelatedNotes = () => { ElMessage.info('关联笔记功能') }
const showCaseComparison = () => { ElMessage.info('案例对比功能') }

const addToNote = () => {
  ElMessage.success('已添加到笔记')
  showAnnotationToolbar.value = false
  window.getSelection().removeAllRanges()
}

const translateText = () => {
  const range = selectedRange.value
  if (range) {
    const rect = range.getBoundingClientRect()
    translationPosition.value = { top: rect.bottom + 10 + 'px', left: rect.left + 'px' }
  }
  translatedText.value = `[译文] ${selectedText.value}`
  showTranslationPopup.value = true
  showAnnotationToolbar.value = false
}

const addToDeck = () => {
  ElMessage.success('已添加到牌组')
  showAnnotationToolbar.value = false
  window.getSelection().removeAllRanges()
}

const attachFile = () => { ElMessage.info('附件功能') }

</script>

<style lang="scss" scoped>
.case-reader {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: #faf8f5;
}

// 顶部导航栏
.reader-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: $spacing-md $spacing-lg;
  background: white;
  border-bottom: 1px solid $border-light;
  height: 60px;

  .header-left {
    display: flex;
    align-items: center;
    gap: $spacing-lg;

    .back-text {
      margin-left: $spacing-xs;
    }
  }

  .header-center {
    text-align: center;
    flex: 1;

    .case-title {
      font-size: 1.25rem;
      font-weight: 600;
      margin: 0;
      color: $text-primary;
    }

    .case-citation {
      font-size: 0.875rem;
      color: $text-secondary;
      font-style: italic;
      margin: $spacing-xs 0 0 0;
    }
  }

  .header-actions {
    display: flex;
    align-items: center;
    gap: $spacing-xs;

    .comment-badge {
      margin-left: $spacing-xs;
      background: $primary;
      color: white;
      border-radius: 10px;
      padding: 2px 6px;
      font-size: 0.75rem;
    }
  }
}

// 案例元信息
.case-metadata-bar {
  display: flex;
  justify-content: center;
  gap: $spacing-sm;
  padding: $spacing-sm;
  background: white;
  border-bottom: 1px solid $border-light;
}

// 阅读器主体
.reader-container {
  flex: 1;
  display: flex;
  overflow: hidden;
}

// 左侧目录
.toc-sidebar {
  width: 240px;
  background: white;
  border-right: 1px solid $border-light;
  display: flex;
  flex-direction: column;
  transition: width $transition-fast;

  &.collapsed {
    width: 40px;
  }

  .toc-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: $spacing-md;
    border-bottom: 1px solid $border-light;
    font-weight: 500;
  }

  .toc-content {
    flex: 1;
    overflow-y: auto;
    padding: $spacing-sm;

    .empty-toc {
      padding: $spacing-lg;
      text-align: center;
      color: $text-tertiary;
      font-size: 0.875rem;
    }

    .toc-item-wrapper {
      margin-bottom: 2px;
    }

    .toc-item {
      padding: $spacing-sm $spacing-md;
      cursor: pointer;
      border-radius: $radius-md;
      transition: all $transition-fast;
      font-size: 0.875rem;
      display: flex;
      justify-content: space-between;
      align-items: center;

      &:hover {
        background: $bg-secondary;
        
        .toc-actions {
          opacity: 1;
        }
      }

      &.active {
        background: rgba($primary, 0.1);
        color: $primary;
      }

      .toc-text {
        flex: 1;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .toc-actions {
        display: flex;
        gap: 4px;
        opacity: 0;
        transition: opacity 0.2s;

        .el-icon {
          padding: 2px;
          border-radius: 4px;
          cursor: pointer;
          &:hover {
            background: rgba(0,0,0,0.1);
          }
        }
      }

      &.toc-editing {
        padding: 4px 8px;
        background: #e6f7ff;
        border: 1px solid #1890ff;
        border-radius: 4px;

        .el-input {
          width: 100%;
        }
      }
    }
  }
}

// 中间正文
.content-area {
  flex: 1;
  overflow-y: auto;
  padding: $spacing-xl;

  &.with-comments {
    padding-right: 0;
  }
}

.document-content {
  max-width: 800px;
  margin: 0 auto;
  background: white;
  padding: $spacing-2xl;
  border-radius: $radius-lg;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.case-text {
  line-height: 1.8;
  color: $text-primary;

  .paragraph {
    position: relative;
    margin-bottom: $spacing-md;
    display: flex;
    gap: $spacing-md;

    .paragraph-number {
      color: $text-tertiary;
      font-size: 0.875rem;
      min-width: 30px;
      text-align: right;
      user-select: none;
      padding-top: 2px;
    }

    .paragraph-editor {
      flex: 1;

      .editor-row {
        display: flex;
        align-items: flex-start;
        gap: 8px;

        .paragraph-number-edit {
          min-width: 24px;
          text-align: right;
          color: #999;
          font-size: 12px;
          line-height: 32px;
          user-select: none;
        }

        .el-textarea {
          flex: 1;
        }

        .delete-paragraph-btn {
          opacity: 0;
          transition: opacity 0.2s;
          padding: 4px;
          margin-top: 4px;

          &:hover {
            color: #f56c6c;
          }
        }

        &:hover .delete-paragraph-btn {
          opacity: 1;
        }
      }
    }

    .paragraph-text {
      flex: 1;
      cursor: text;

      :deep(.ann-highlight) {
        cursor: pointer;
        border-radius: 2px;
        transition: filter 0.2s;
        padding: 1px 0;

        &:hover {
          filter: brightness(0.92);
        }
      }

      :deep(.ann-underline) {
        cursor: pointer;
        transition: background 0.2s;
        padding-bottom: 1px;

        &:hover {
          background: rgba(0, 0, 0, 0.04);
        }
      }

      :deep(.ann-comment) {
        cursor: pointer;
        transition: background 0.2s;

        &:hover {
          background: rgba(245, 158, 11, 0.12);
        }
      }
    }
  }
}

// 右侧评论面板
.comments-sidebar {
  background: white;
  border-left: 1px solid $border-light;
  display: flex;
  flex-direction: column;
  position: relative;

  .sidebar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: $spacing-md $spacing-lg;
    border-bottom: 1px solid $border-light;

    h3 {
      margin: 0;
      font-size: 1rem;
    }
  }

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

  .comments-list {
    flex: 1;
    overflow-y: auto;
    padding: $spacing-md;
  }

  .empty-comments {
    text-align: center;
    padding: $spacing-2xl $spacing-lg;
    color: $text-tertiary;

    .empty-icon {
      font-size: 48px;
      margin-bottom: $spacing-md;
      color: $border-light;
    }

    p {
      margin: $spacing-xs 0;
    }

    .empty-hint {
      font-size: 0.8125rem;
    }
  }

  // 飞书风格评论卡片
  .comment-card {
    margin-bottom: $spacing-md;
    border: 1px solid $border-light;
    border-radius: $radius-lg;
    overflow: hidden;
    transition: all $transition-fast;
    background: white;

    &:hover {
      border-color: $border-medium;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    }

    &.is-active {
      border-color: $primary;
      box-shadow: 0 0 0 2px rgba($primary, 0.1);
    }

    .comment-card-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: $spacing-md;
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
        overflow: hidden;

        .quote-icon {
          color: #f59e0b;
          font-size: 1.25rem;
          line-height: 1;
        }

        .text-content {
          font-size: 0.875rem;
          color: $text-primary;
          line-height: 1.5;
          display: -webkit-box;
          -webkit-line-clamp: 2;
          -webkit-box-orient: vertical;
          overflow: hidden;
        }
      }

      .expand-icon {
        color: $text-secondary;
        margin-left: $spacing-sm;
      }
    }

    .comment-card-body {
      padding: $spacing-md;
      border-top: 1px solid $border-light;
    }

    .comment-header {
      display: flex;
      align-items: center;
      gap: $spacing-sm;
      margin-bottom: $spacing-sm;

      .user-meta {
        display: flex;
        flex-direction: column;

        .user-name {
          font-weight: 500;
          font-size: 0.875rem;
        }

        .comment-time {
          font-size: 0.75rem;
          color: $text-secondary;
        }
      }
    }

    .comment-content {
      font-size: 0.9375rem;
      line-height: 1.6;
      margin-bottom: $spacing-sm;
    }

    .comment-images,
    .reply-images {
      display: flex;
      flex-wrap: wrap;
      gap: $spacing-xs;
      margin-bottom: $spacing-sm;

      .image-thumbnail {
        width: 80px;
        height: 80px;
        border-radius: $radius-sm;
        overflow: hidden;
        cursor: pointer;
        border: 1px solid $border-light;

        img {
          width: 100%;
          height: 100%;
          object-fit: cover;
          transition: transform 0.2s;
        }

        &:hover img {
          transform: scale(1.05);
        }
      }
    }

    .comment-actions-bar {
      display: flex;
      align-items: center;
      gap: $spacing-xs;
      margin-bottom: $spacing-sm;
    }

    .replies-list {
      margin-top: $spacing-md;
      padding-top: $spacing-md;
      border-top: 1px solid $border-light;

      .reply-item {
        margin-bottom: $spacing-sm;

        &:last-child {
          margin-bottom: 0;
        }

        .reply-header {
          display: flex;
          align-items: center;
          gap: $spacing-xs;
          margin-bottom: $spacing-xs;

          .reply-user {
            font-weight: 500;
            font-size: 0.875rem;
          }

          .reply-time {
            font-size: 0.75rem;
            color: $text-secondary;
          }

          .reply-actions {
            margin-left: auto;
            opacity: 0;
            transition: opacity 0.2s;

            .el-button {
              padding: 2px 4px;
            }
          }

          &:hover .reply-actions {
            opacity: 1;
          }
        }

        .reply-edit-area {
          padding-left: 28px;
          margin-bottom: $spacing-sm;

          .reply-edit-images {
            display: flex;
            flex-wrap: wrap;
            gap: $spacing-xs;
            margin-bottom: $spacing-xs;

            .image-preview-item {
              position: relative;
              width: 60px;
              height: 60px;
              border-radius: $radius-sm;
              overflow: hidden;
              border: 1px solid $border-light;

              img {
                width: 100%;
                height: 100%;
                object-fit: cover;
              }

              .remove-image-btn {
                position: absolute;
                top: 2px;
                right: 2px;
                padding: 2px;
                background: rgba(0, 0, 0, 0.5);
                color: white;
                border-radius: 50%;
                opacity: 0;
                transition: opacity 0.2s;

                &:hover {
                  background: rgba(0, 0, 0, 0.7);
                }
              }

              &:hover .remove-image-btn {
                opacity: 1;
              }
            }
          }

          .reply-edit-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: $spacing-xs;
            margin-top: $spacing-xs;

            .image-hint {
              font-size: 0.75rem;
              color: $text-tertiary;
            }

            .action-btns {
              display: flex;
              gap: $spacing-xs;
            }
          }
        }

        .reply-content {
          font-size: 0.875rem;
          color: $text-secondary;
          padding-left: 28px;
        }

        .reply-images {
          padding-left: 28px;
        }
      }
    }
  }

  .comment-input-area {
    padding: $spacing-md;
    border-top: 1px solid $border-light;
    background: #fafafa;

    .replying-to,
    .selected-text-hint {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 0.875rem;
      color: $text-secondary;
      margin-bottom: $spacing-sm;
      padding: $spacing-xs $spacing-sm;
      background: white;
      border-radius: $radius-sm;
      border: 1px solid $border-light;

      span {
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
    }

    .comment-images-preview {
      display: flex;
      flex-wrap: wrap;
      gap: $spacing-xs;
      margin-bottom: $spacing-sm;

      .image-preview-item {
        position: relative;
        width: 60px;
        height: 60px;
        border-radius: $radius-sm;
        overflow: hidden;
        border: 1px solid $border-light;

        img {
          width: 100%;
          height: 100%;
          object-fit: cover;
        }

        .remove-image-btn {
          position: absolute;
          top: 2px;
          right: 2px;
          padding: 2px;
          background: rgba(0, 0, 0, 0.5);
          color: white;
          border-radius: 50%;
          opacity: 0;
          transition: opacity 0.2s;

          &:hover {
            background: rgba(0, 0, 0, 0.7);
          }
        }

        &:hover .remove-image-btn {
          opacity: 1;
        }
      }
    }

    .input-actions {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: $spacing-sm;

      .input-left {
        display: flex;
        align-items: center;
        gap: $spacing-xs;

        .image-hint {
          font-size: 0.75rem;
          color: $text-tertiary;
        }
      }
    }
  }
}

// ==================== 飞书风格标注工具栏 ====================
.annotation-toolbar {
  position: fixed;
  z-index: 1000;
  background: white;
  border-radius: $radius-lg;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  padding: $spacing-xs;

  .toolbar-content {
    display: flex;
    align-items: center;
    gap: 2px;
  }

  .toolbar-item-wrapper {
    position: relative;
  }

  .toolbar-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
    padding: $spacing-sm $spacing-md;
    cursor: pointer;
    border-radius: $radius-md;
    transition: all 0.2s;
    min-width: 48px;

    &:hover {
      background: $bg-secondary;
    }

    .el-icon {
      font-size: 1.25rem;
      color: $text-primary;
    }

    span {
      font-size: 0.75rem;
      color: $text-secondary;
    }

    .color-preview {
      width: 20px;
      height: 20px;
      border-radius: 4px;
    }

    .underline-preview {
      width: 20px;
      height: 20px;
      border-bottom: 3px solid;
    }
  }

  .toolbar-divider {
    width: 1px;
    height: 32px;
    background: $border-light;
    margin: 0 $spacing-xs;
  }

  // 颜色选择下拉面板
  .color-picker-dropdown {
    position: absolute;
    top: 100%;
    left: 50%;
    transform: translateX(-50%);
    margin-top: 4px;
    background: white;
    border-radius: $radius-md;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
    padding: $spacing-sm;
    display: flex;
    gap: $spacing-xs;
    z-index: 1002;

    .color-dot {
      width: 24px;
      height: 24px;
      border-radius: 50%;
      cursor: pointer;
      transition: all 0.15s;
      border: 2px solid transparent;

      &:hover {
        transform: scale(1.2);
      }

      &.active {
        border-color: $text-primary;
        box-shadow: 0 0 0 2px white, 0 0 0 4px $text-primary;
      }
    }
  }
}

// ==================== 标注删除弹窗 ====================
.annotation-popup {
  position: fixed;
  z-index: 1001;
  background: white;
  border-radius: $radius-md;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.15);
  padding: 2px;
}

// ==================== 翻译悬浮框 ====================
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

// Markdown 样式
.markdown-body {
  :deep(h1), :deep(h2), :deep(h3), :deep(h4), :deep(h5), :deep(h6) {
    margin: $spacing-md 0 $spacing-sm;
  }

  :deep(p) {
    margin: $spacing-sm 0;
  }

  :deep(ul), :deep(ol) {
    margin: $spacing-sm 0;
    padding-left: $spacing-lg;
  }

  :deep(code) {
    background: $bg-secondary;
    padding: 2px 4px;
    border-radius: $radius-sm;
    font-family: monospace;
  }

  :deep(blockquote) {
    margin: $spacing-sm 0;
    padding-left: $spacing-md;
    border-left: 3px solid $primary;
    color: $text-secondary;
  }
}

// AI分析内容
.ai-analysis-content {
  h4 {
    margin: $spacing-lg 0 $spacing-md;
    color: $text-primary;
  }

  ul {
    padding-left: $spacing-lg;
    margin-bottom: $spacing-md;
  }

  p {
    line-height: 1.6;
    color: $text-secondary;
  }
}
</style>