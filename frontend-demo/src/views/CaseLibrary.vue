<template>
  <div class="case-library">
    <!-- 顶部导航栏 -->
    <div class="top-header">
      <div class="header-left">
        <h1 class="page-title">WeLaw案例库</h1>
      </div>
      <div class="header-right">
        <el-button type="text" @click="showGlobalSearch = true">
          <el-icon><Search /></el-icon>
        </el-button>
        <el-button type="primary" @click="showImportDialog = true">
          <el-icon><Upload /></el-icon>
          导入案例
        </el-button>
      </div>
    </div>

    <!-- 文件夹筛选栏 -->
    <div class="folder-filter-bar">
      <div class="folder-tabs">
        <div
          v-for="folder in allFolders"
          :key="folder.id"
          class="folder-tab"
          :class="{ active: selectedFolder === folder.id }"
          @click="selectFolder(folder.id)"
        >
          {{ folder.name }}
        </div>
        <div class="folder-tab new-folder" @click="addNewFolder">
          <el-icon><Plus /></el-icon>
        </div>
      </div>
    </div>

    <!-- 筛选工具栏 -->
    <div class="filter-toolbar">
      <div class="filter-left">
        <el-dropdown @command="handleSortChange">
          <el-button text>
            排序: {{ sortLabel }} <el-icon><ArrowDown /></el-icon>
          </el-button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="recent">最近阅读</el-dropdown-item>
              <el-dropdown-item command="added">最近添加</el-dropdown-item>
              <el-dropdown-item command="date">判决日期</el-dropdown-item>
              <el-dropdown-item command="name">标题字母</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>

        <el-dropdown @command="handleFilterChange">
          <el-button text>
            筛选 <el-icon><ArrowDown /></el-icon>
          </el-button>
          <template #dropdown>
            <el-dropdown-menu class="filter-dropdown-menu">
              <div class="filter-section">
                <div class="filter-title">学习状态</div>
                <el-radio-group v-model="filterStatus" @change="applyFilters">
                  <el-radio-button label="">全部</el-radio-button>
                  <el-radio-button label="待学习">待学习</el-radio-button>
                  <el-radio-button label="学习中">学习中</el-radio-button>
                  <el-radio-button label="已掌握">已掌握</el-radio-button>
                </el-radio-group>
              </div>
              <div class="filter-section">
                <div class="filter-title">阅读时间</div>
                <el-radio-group v-model="filterTime" @change="applyFilters">
                  <el-radio-button label="">全部</el-radio-button>
                  <el-radio-button label="today">今天</el-radio-button>
                  <el-radio-button label="week">本周</el-radio-button>
                  <el-radio-button label="month">本月</el-radio-button>
                </el-radio-group>
              </div>
              <div class="filter-section">
                <div class="filter-title">标注情况</div>
                <el-radio-group v-model="filterAnnotation" @change="applyFilters">
                  <el-radio-button label="">全部</el-radio-button>
                  <el-radio-button label="with">有标注</el-radio-button>
                  <el-radio-button label="without">无标注</el-radio-button>
                </el-radio-group>
              </div>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>

      <div class="filter-right">
        <el-radio-group v-model="viewMode" size="small">
          <el-radio-button label="card">
            <el-icon><Grid /></el-icon>
          </el-radio-button>
          <el-radio-button label="list">
            <el-icon><List /></el-icon>
          </el-radio-button>
        </el-radio-group>
      </div>
    </div>

    <!-- 案例列表 -->
    <div class="cases-container" :class="viewMode">
      <div
        v-for="caseItem in filteredCases"
        :key="caseItem.id"
        class="case-item"
        :class="viewMode"
        @click="openCase(caseItem.id)"
      >
        <!-- 卡片视图 -->
        <template v-if="viewMode === 'card'">
          <div class="case-card">
            <div class="card-header">
              <div class="file-icon">
                <el-icon><Document /></el-icon>
              </div>
              <el-dropdown trigger="click" @command="handleCaseAction($event, caseItem)">
                <el-button type="text" class="more-btn" @click.stop>
                  <el-icon><MoreFilled /></el-icon>
                </el-button>
                <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="edit">
                    <el-icon><EditPen /></el-icon> 编辑
                  </el-dropdown-item>
                  <el-dropdown-item command="share">
                    <el-icon><Share /></el-icon> 分享
                  </el-dropdown-item>
                  <el-dropdown-item command="export">
                    <el-icon><Download /></el-icon> 导出
                  </el-dropdown-item>
                  <el-dropdown-item command="move">
                    <el-icon><FolderOpened /></el-icon> 移动到
                  </el-dropdown-item>
                  <el-dropdown-item command="addToStudySet">
                    <el-icon><Collection /></el-icon> 添加到学习集
                  </el-dropdown-item>
                  <el-dropdown-item command="generateMindMap">
                    <el-icon><Share /></el-icon> 生成思维导图
                  </el-dropdown-item>
                  <el-dropdown-item divided command="delete">
                    <el-icon><Delete /></el-icon> 删除
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
              </el-dropdown>
            </div>

            <div class="card-content">
              <h3 class="case-title">{{ caseItem.title }}</h3>
              <p class="case-citation">{{ caseItem.citation }}</p>
              <p class="case-summary">{{ caseItem.summary }}</p>
            </div>

            <div class="card-meta">
              <div class="meta-tags">
                <el-tag size="small" :type="getCategoryType(caseItem.category)" effect="light">
                  {{ caseItem.category }}
                </el-tag>
                <el-tag size="small" :type="getStatusType(caseItem.status)" effect="light">
                  {{ caseItem.status }}
                </el-tag>
              </div>
              <div class="meta-stats">
                <span v-if="caseItem.annotations > 0" class="stat-item">
                  <el-icon><EditPen /></el-icon>
                  {{ caseItem.annotations }}
                </span>
                <span class="stat-item">
                  <el-icon><Calendar /></el-icon>
                  {{ formatDate(caseItem.date) }}
                </span>
              </div>
            </div>

            <div class="card-tags" v-if="caseItem.tags && caseItem.tags.length">
              <el-tag
                v-for="tag in caseItem.tags.slice(0, 3)"
                :key="tag"
                size="small"
                effect="plain"
                class="keyword-tag"
              >
                {{ tag }}
              </el-tag>
            </div>
          </div>
        </template>

        <!-- 列表视图 -->
        <template v-else>
          <div class="case-list-item">
            <div class="list-icon">
              <el-icon><Document /></el-icon>
            </div>
            <div class="list-content">
              <h3 class="list-title">{{ caseItem.title }}</h3>
              <p class="list-citation">{{ caseItem.citation }}</p>
            </div>
            <div class="list-meta">
              <el-tag size="small" :type="getCategoryType(caseItem.category)" effect="light">
                {{ caseItem.category }}
              </el-tag>
              <el-tag size="small" :type="getStatusType(caseItem.status)" effect="light">
                {{ caseItem.status }}
              </el-tag>
              <span v-if="caseItem.annotations > 0" class="list-stat">
                <el-icon><EditPen /></el-icon> {{ caseItem.annotations }}
              </span>
              <span class="list-date">{{ formatDate(caseItem.date) }}</span>
            </div>
            <el-dropdown trigger="click" @command="handleCaseAction($event, caseItem)">
              <el-button type="text" @click.stop>
                <el-icon><MoreFilled /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="edit">
                    <el-icon><EditPen /></el-icon> 编辑
                  </el-dropdown-item>
                  <el-dropdown-item command="share">
                    <el-icon><Share /></el-icon> 分享
                  </el-dropdown-item>
                  <el-dropdown-item command="export">
                    <el-icon><Download /></el-icon> 导出
                  </el-dropdown-item>
                  <el-dropdown-item command="move">
                    <el-icon><FolderOpened /></el-icon> 移动到
                  </el-dropdown-item>
                  <el-dropdown-item command="addToStudySet">
                    <el-icon><Collection /></el-icon> 添加到学习集
                  </el-dropdown-item>
                  <el-dropdown-item divided command="delete">
                    <el-icon><Delete /></el-icon> 删除
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </template>
      </div>
    </div>

    <!-- 空状态 -->
    <div v-if="filteredCases.length === 0" class="empty-state">
      <el-icon class="empty-icon"><DocumentDelete /></el-icon>
      <h3>没有找到案例</h3>
      <p>尝试调整筛选条件或导入新案例</p>
      <el-button type="primary" @click="showImportDialog = true">
        导入案例
      </el-button>
    </div>

    <!-- 全局搜索对话框 -->
    <el-dialog
      v-model="showGlobalSearch"
      title="搜索"
      width="700px"
      :show-close="false"
      class="global-search-dialog"
    >
      <div class="global-search-content">
        <el-input
          v-model="globalSearchQuery"
          placeholder="搜索案例、笔记、词汇..."
          size="large"
          clearable
          @keyup.enter="performGlobalSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>

        <div class="search-history" v-if="searchHistory.length">
          <div class="history-title">最近搜索</div>
          <div class="history-tags">
            <el-tag
              v-for="item in searchHistory"
              :key="item"
              size="small"
              effect="plain"
              class="history-tag"
              @click="globalSearchQuery = item; performGlobalSearch()"
            >
              {{ item }}
            </el-tag>
          </div>
        </div>

        <div class="search-results" v-if="globalSearchQuery">
          <div class="result-section">
            <div class="result-title">📄 案例 ({{ searchResults.cases.length }})</div>
            <div
              v-for="caseItem in searchResults.cases"
              :key="caseItem.id"
              class="result-item"
              @click="openCase(caseItem.id); showGlobalSearch = false"
            >
              <div class="result-name">{{ caseItem.title }}</div>
              <div class="result-desc">{{ caseItem.summary }}</div>
              <div class="result-meta">
                <el-tag size="small" :type="getCategoryType(caseItem.category)">
                  {{ caseItem.category }}
                </el-tag>
                <el-tag size="small" :type="getStatusType(caseItem.status)">
                  {{ caseItem.status }}
                </el-tag>
                <span>{{ formatDate(caseItem.date) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </el-dialog>

    <!-- 导入对话框 -->
    <el-dialog
      v-model="showImportDialog"
      title="导入案例"
      width="600px"
      destroy-on-close
    >
      <div class="import-dialog">
        <el-tabs v-model="importTab">
          <el-tab-pane label="本地文件" name="file">
            <div class="upload-area">
              <el-upload
                drag
                action="#"
                :auto-upload="false"
                :on-change="handleFileChange"
                accept=".pdf,.txt"
                multiple
              >
                <el-icon class="upload-icon"><Upload /></el-icon>
                <div class="upload-text">
                  <p>拖拽文件到此处，或 <em>点击上传</em></p>
                  <p class="upload-hint">支持 PDF、TXT 格式</p>
                </div>
              </el-upload>
            </div>
          </el-tab-pane>
          <el-tab-pane label="URL导入" name="url">
            <el-input
              v-model="importUrl"
              placeholder="输入案例网页链接..."
              type="textarea"
              :rows="3"
            />
          </el-tab-pane>
          <el-tab-pane label="剪贴板" name="clipboard">
            <div class="clipboard-tab">
              <el-input
                v-model="clipboardText"
                placeholder="粘贴案例文本..."
                type="textarea"
                :rows="8"
              />
              <div class="search-links-section">
                <el-divider>
                  <span class="divider-text">或</span>
                </el-divider>
                <el-button class="search-links-btn" @click="openSearchLinks">
                  <el-icon><Link /></el-icon>
                  去查找
                </el-button>
                <p class="search-links-hint">从权威法律数据库查找案例</p>
              </div>
            </div>
          </el-tab-pane>
        </el-tabs>

        <div class="import-preview" v-if="uploadedFiles.length">
          <h4>已选择文件</h4>
          <div class="file-list">
            <div
              v-for="(file, index) in uploadedFiles"
              :key="index"
              class="file-item"
            >
              <el-icon><Document /></el-icon>
              <span class="file-name">{{ file.name }}</span>
              <span class="file-size">{{ formatFileSize(file.size) }}</span>
              <el-button type="text" @click="removeFile(index)">
                <el-icon><Close /></el-icon>
              </el-button>
            </div>
          </div>
        </div>
      </div>

      <template #footer>
        <el-button @click="showImportDialog = false">取消</el-button>
        <el-button type="primary" @click="importCases" :loading="importing">
          导入
        </el-button>
      </template>
    </el-dialog>

    <!-- 分享对话框 -->
    <el-dialog
      v-model="showShareDialog"
      title="分享案例"
      width="500px"
    >
      <div class="share-dialog-content">
        <el-form label-position="top">
          <el-form-item label="分享链接">
            <el-input v-model="shareLink" readonly>
              <template #append>
                <el-button @click="copyShareLink">复制</el-button>
              </template>
            </el-input>
          </el-form-item>
          <el-form-item label="权限设置">
            <el-radio-group v-model="sharePermission">
              <el-radio label="readonly">仅查看</el-radio>
              <el-radio label="comment">可评论</el-radio>
              <el-radio label="edit">可编辑</el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="有效期">
            <el-radio-group v-model="shareExpiry">
              <el-radio label="forever">永久有效</el-radio>
              <el-radio label="7days">7天</el-radio>
              <el-radio label="30days">30天</el-radio>
            </el-radio-group>
          </el-form-item>
        </el-form>
      </div>
    </el-dialog>

    <!-- 编辑案例对话框 -->
    <el-dialog
      v-model="showEditDialog"
      title="编辑案例"
      width="600px"
    >
      <el-form label-position="top">
        <el-form-item label="案例标题">
          <el-input v-model="editingCase.title" />
        </el-form-item>
        <el-form-item label="引用格式">
          <el-input v-model="editingCase.citation" />
        </el-form-item>
        <el-form-item label="法院">
          <el-input v-model="editingCase.court" />
        </el-form-item>
        <el-form-item label="判决日期">
          <el-date-picker
            v-model="editingCase.date"
            type="date"
            placeholder="选择日期"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="editingCase.category" style="width: 100%">
            <el-option label="宪法" value="宪法" />
            <el-option label="刑法" value="刑法" />
            <el-option label="合同法" value="合同法" />
            <el-option label="侵权法" value="侵权法" />
            <el-option label="证据法" value="证据法" />
          </el-select>
        </el-form-item>
        <el-form-item label="学习状态">
          <el-radio-group v-model="editingCase.status">
            <el-radio-button label="待学习">待学习</el-radio-button>
            <el-radio-button label="学习中">学习中</el-radio-button>
            <el-radio-button label="已掌握">已掌握</el-radio-button>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="摘要">
          <el-input
            v-model="editingCase.summary"
            type="textarea"
            :rows="3"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showEditDialog = false">取消</el-button>
        <el-button type="primary" @click="saveEditCase">保存</el-button>
      </template>
    </el-dialog>

    <!-- 导出对话框 -->
    <el-dialog
      v-model="showExportDialog"
      title="导出案例"
      width="500px"
    >
      <el-form label-position="top">
        <el-form-item label="导出格式">
          <el-radio-group v-model="exportFormat">
            <el-radio-button label="pdf">PDF</el-radio-button>
            <el-radio-button label="word">Word</el-radio-button>
            <el-radio-button label="markdown">Markdown</el-radio-button>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="导出选项">
          <el-checkbox v-model="exportOptions.includeAnnotations">包含标注</el-checkbox>
          <el-checkbox v-model="exportOptions.includeComments">包含评论</el-checkbox>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showExportDialog = false">取消</el-button>
        <el-button type="primary" @click="confirmExport">导出</el-button>
      </template>
    </el-dialog>

    <!-- 移动到文件夹对话框 -->
    <el-dialog
      v-model="showMoveDialog"
      title="移动到文件夹"
      width="400px"
    >
      <div class="folder-list-dialog">
        <div
          v-for="folder in allFolders.filter(f => f.id !== 'all')"
          :key="folder.id"
          class="folder-option"
          :class="{ active: selectedMoveFolder === folder.id }"
          @click="selectedMoveFolder = folder.id"
        >
          <el-icon><Folder /></el-icon>
          <span>{{ folder.name }}</span>
        </div>
      </div>
      <template #footer>
        <el-button @click="showMoveDialog = false">取消</el-button>
        <el-button type="primary" @click="confirmMove">移动</el-button>
      </template>
    </el-dialog>

    <!-- 添加到学习集对话框 -->
    <el-dialog
      v-model="showAddToStudySetDialog"
      title="添加到学习集"
      width="500px"
    >
      <div class="study-set-list">
        <div
          v-for="set in studySets"
          :key="set.id"
          class="study-set-option"
          :class="{ active: selectedStudySets.includes(set.id) }"
          @click="toggleStudySet(set.id)"
        >
          <div class="set-info">
            <el-icon><Collection /></el-icon>
            <div class="set-details">
              <div class="set-name">{{ set.name }}</div>
              <div class="set-count">{{ set.itemCount }} 个条目</div>
            </div>
          </div>
          <el-checkbox :model-value="selectedStudySets.includes(set.id)" />
        </div>
      </div>
      <template #footer>
        <el-button @click="showAddToStudySetDialog = false">取消</el-button>
        <el-button type="primary" @click="confirmAddToStudySet">添加</el-button>
      </template>
    </el-dialog>

    <!-- 查找资源抽屉 -->
    <el-drawer
      v-model="showSearchLinksDrawer"
      title="查找案例资源"
      size="500px"
      :with-header="true"
    >
      <div class="search-links-drawer">
        <!-- 使用建议 -->
        <div class="usage-tips">
          <el-alert
            title="使用建议"
            type="info"
            :closable="false"
          >
            <template #default>
              <p>1. 优先使用免费权威平台查找案例</p>
              <p>2. 如需深度研究，可使用付费数据库</p>
              <p>3. 找到案例后，可复制文本或下载PDF导入</p>
            </template>
          </el-alert>
        </div>

        <!-- 免费权威平台 -->
        <el-collapse v-model="activeCollapse">
          <el-collapse-item title="📚 免费权威平台" name="free">
            <div class="link-list">
              <div
                v-for="link in freeLinks"
                :key="link.id"
                class="link-card"
                @click="openExternalLink(link.url)"
              >
                <div class="link-header">
                  <span class="link-name">{{ link.name }}</span>
                  <el-tag size="small" type="success">免费</el-tag>
                </div>
                <div class="link-url">{{ link.url }}</div>
                <div class="link-desc">{{ link.description }}</div>
              </div>
            </div>
          </el-collapse-item>

          <!-- 付费专业数据库 -->
          <el-collapse-item title="💎 付费专业数据库" name="paid">
            <div class="link-list">
              <div
                v-for="link in paidLinks"
                :key="link.id"
                class="link-card"
                @click="openExternalLink(link.url)"
              >
                <div class="link-header">
                  <span class="link-name">{{ link.name }}</span>
                  <el-tag size="small" type="warning">付费</el-tag>
                </div>
                <div class="link-url">{{ link.url }}</div>
                <div class="link-desc">{{ link.description }}</div>
              </div>
            </div>
          </el-collapse-item>
        </el-collapse>

        <!-- 自定义链接 -->
        <div class="custom-links-section">
          <div class="section-header">
            <h4>我的链接</h4>
            <el-button type="primary" size="small" @click="showAddLinkDialog = true">
              <el-icon><Plus /></el-icon>
              添加
            </el-button>
          </div>
          <div class="link-list">
            <div
              v-for="link in customLinks"
              :key="link.id"
              class="link-card custom"
              @click="openExternalLink(link.url)"
            >
              <div class="link-header">
                <span class="link-name">{{ link.name }}</span>
                <el-button
                  type="text"
                  size="small"
                  @click.stop="deleteCustomLink(link.id)"
                >
                  <el-icon><Delete /></el-icon>
                </el-button>
              </div>
              <div class="link-url">{{ link.url }}</div>
              <div class="link-desc">{{ link.description }}</div>
            </div>
            <div v-if="customLinks.length === 0" class="empty-custom-links">
              暂无自定义链接，点击上方按钮添加
            </div>
          </div>
        </div>
      </div>
    </el-drawer>

    <!-- 添加自定义链接对话框 -->
    <el-dialog
      v-model="showAddLinkDialog"
      title="添加自定义链接"
      width="500px"
    >
      <el-form label-position="top">
        <el-form-item label="网站名称">
          <el-input v-model="newLink.name" placeholder="例如：我的法律博客" />
        </el-form-item>
        <el-form-item label="网址">
          <el-input v-model="newLink.url" placeholder="https://..." />
        </el-form-item>
        <el-form-item label="描述（可选）">
          <el-input
            v-model="newLink.description"
            type="textarea"
            :rows="2"
            placeholder="简单描述这个网站的用途..."
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAddLinkDialog = false">取消</el-button>
        <el-button type="primary" @click="addCustomLink">添加</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useCasesStore } from '@/stores'
import { ElMessage, ElMessageBox } from 'element-plus'

const router = useRouter()
const casesStore = useCasesStore()

// 状态
const viewMode = ref('card')
const selectedFolder = ref('all')
const sortBy = ref('recent')
const sortLabel = ref('最近阅读')
const showGlobalSearch = ref(false)
const showImportDialog = ref(false)
const showShareDialog = ref(false)
const globalSearchQuery = ref('')
const importTab = ref('file')
const importUrl = ref('')
const clipboardText = ref('')
const uploadedFiles = ref([])
const importing = ref(false)
const shareLink = ref('https://enoflaw.com/share/case/123')
const sharePermission = ref('readonly')
const shareExpiry = ref('forever')
const currentShareCase = ref(null)

// 新增对话框状态
const showEditDialog = ref(false)
const showExportDialog = ref(false)
const showMoveDialog = ref(false)
const showAddToStudySetDialog = ref(false)
const editingCase = ref({})
const exportCase = ref(null)
const moveCase = ref(null)
const addToStudySetCase = ref(null)
const exportFormat = ref('pdf')
const exportOptions = ref({
  includeAnnotations: true,
  includeComments: true
})
const selectedStudySets = ref([])
const studySets = ref([
  { id: '1', name: '合同法学习集', itemCount: 12 },
  { id: '2', name: '侵权法专题', itemCount: 8 },
  { id: '3', name: '经典案例收藏', itemCount: 5 }
])

// 查找资源抽屉状态
const showSearchLinksDrawer = ref(false)
const activeCollapse = ref(['free'])
const showAddLinkDialog = ref(false)
const newLink = ref({ name: '', url: '', description: '' })

// 免费权威平台链接
const freeLinks = ref([
  {
    id: '1',
    name: 'BAILII',
    url: 'https://www.bailii.org',
    description: '英国和爱尔兰法律数据库，包含英国最高法院、上诉法院等判决'
  },
  {
    id: '2',
    name: 'CommonLII',
    url: 'https://www.commonlii.org',
    description: '英联邦法律数据库，涵盖多个英联邦国家的法律资源'
  },
  {
    id: '3',
    name: 'AustLII',
    url: 'https://www.austlii.edu.au',
    description: '澳大利亚法律数据库，包含澳大利亚联邦和州法律'
  },
  {
    id: '4',
    name: 'CanLII',
    url: 'https://www.canlii.org',
    description: '加拿大法律数据库，包含加拿大各级法院判决'
  },
  {
    id: '5',
    name: 'CourtListener',
    url: 'https://www.courtlistener.com',
    description: '美国法院案例搜索引擎，包含联邦和州法院判决'
  },
  {
    id: '6',
    name: 'Oyez',
    url: 'https://www.oyez.org',
    description: '美国最高法院案例库，包含庭审录音和判决'
  }
])

// 付费专业数据库链接
const paidLinks = ref([
  {
    id: '1',
    name: 'Westlaw',
    url: 'https://www.westlaw.com',
    description: '全球领先的法律数据库，包含全面的案例、法规和法律评论'
  },
  {
    id: '2',
    name: 'LexisNexis',
    url: 'https://www.lexisnexis.com',
    description: '综合法律研究平台，提供深度法律分析和AI辅助研究'
  },
  {
    id: '3',
    name: 'Bloomberg Law',
    url: 'https://www.bloomberglaw.com',
    description: '商业法律新闻和分析平台，适合商业法律研究'
  },
  {
    id: '4',
    name: 'HeinOnline',
    url: 'https://www.heinonline.org',
    description: '法律期刊和学术资源数据库，适合学术研究'
  }
])

// 自定义链接（从本地存储加载）
const customLinks = ref(JSON.parse(localStorage.getItem('customSearchLinks') || '[]'))

// 筛选状态
const filterStatus = ref('')
const filterTime = ref('')
const filterAnnotation = ref('')

// 搜索历史
const searchHistory = ref(['合同法', '损害赔偿', 'Hadley'])

// 文件夹列表
const allFolders = ref([
  { id: 'all', name: '全部案例' },
  { id: 'constitutional', name: '宪法' },
  { id: 'criminal', name: '刑法' },
  { id: 'contract', name: '合同法' },
  { id: 'tort', name: '侵权法' },
  { id: 'evidence', name: '证据法' }
])

// 搜索结果显示
const searchResults = reactive({
  cases: []
})

// 计算属性：筛选后的案例
const filteredCases = computed(() => {
  let cases = [...casesStore.cases]

  // 文件夹筛选
  if (selectedFolder.value !== 'all') {
    const folderMap = {
      'constitutional': '宪法',
      'criminal': '刑法',
      'contract': '合同法',
      'tort': '侵权法',
      'evidence': '证据法'
    }
    const category = folderMap[selectedFolder.value]
    if (category) {
      cases = cases.filter(c => c.category === category)
    }
  }

  // 学习状态筛选
  if (filterStatus.value) {
    cases = cases.filter(c => c.status === filterStatus.value)
  }

  // 标注情况筛选
  if (filterAnnotation.value === 'with') {
    cases = cases.filter(c => c.annotations > 0)
  } else if (filterAnnotation.value === 'without') {
    cases = cases.filter(c => c.annotations === 0)
  }

  // 排序
  switch (sortBy.value) {
    case 'name':
      cases.sort((a, b) => a.title.localeCompare(b.title))
      break
    case 'date':
      cases.sort((a, b) => new Date(b.date) - new Date(a.date))
      break
    case 'added':
      cases.sort((a, b) => b.id - a.id)
      break
    default:
      cases.sort((a, b) => b.lastRead - a.lastRead)
  }

  return cases
})

// 方法
const selectFolder = (folderId) => {
  selectedFolder.value = folderId
}

const addNewFolder = () => {
  ElMessage.info('新建文件夹功能')
}

const handleSortChange = (command) => {
  sortBy.value = command
  const labels = {
    'recent': '最近阅读',
    'added': '最近添加',
    'date': '判决日期',
    'name': '标题字母'
  }
  sortLabel.value = labels[command]
}

const handleFilterChange = () => {
  // 筛选下拉菜单已打开
}

const applyFilters = () => {
  // 筛选条件已应用
}

const openCase = (caseId) => {
  router.push(`/cases/${caseId}`)
}

const handleCaseAction = (command, caseItem) => {
  switch (command) {
    case 'edit':
      showEditDialog.value = true
      editingCase.value = { ...caseItem }
      break
    case 'share':
      currentShareCase.value = caseItem
      showShareDialog.value = true
      break
    case 'export':
      showExportDialog.value = true
      exportCase.value = caseItem
      break
    case 'move':
      showMoveDialog.value = true
      moveCase.value = caseItem
      break
    case 'addToStudySet':
      showAddToStudySetDialog.value = true
      addToStudySetCase.value = caseItem
      break
    case 'generateMindMap':
      ElMessage.success('正在生成思维导图...')
      setTimeout(() => {
        router.push(`/mindmap?case=${caseItem.id}`)
      }, 1000)
      break
    case 'delete':
      ElMessageBox.confirm(
        `确定要删除案例 "${caseItem.title}" 吗？`,
        '删除案例',
        {
          confirmButtonText: '删除',
          cancelButtonText: '取消',
          type: 'warning'
        }
      ).then(() => {
        ElMessage.success('案例已删除')
      }).catch(() => {})
      break
  }
}

const performGlobalSearch = () => {
  // 模拟搜索结果
  searchResults.cases = casesStore.cases.filter(c => 
    c.title.toLowerCase().includes(globalSearchQuery.value.toLowerCase()) ||
    c.summary.toLowerCase().includes(globalSearchQuery.value.toLowerCase())
  )
}

const handleFileChange = (file) => {
  uploadedFiles.value.push(file.raw)
}

const removeFile = (index) => {
  uploadedFiles.value.splice(index, 1)
}

const importCases = () => {
  importing.value = true
  setTimeout(() => {
    importing.value = false
    showImportDialog.value = false
    uploadedFiles.value = []
    ElMessage.success('案例导入成功')
  }, 1500)
}

const openSearchLinks = () => {
  showImportDialog.value = false
  showSearchLinksDrawer.value = true
}

const copyShareLink = () => {
  navigator.clipboard.writeText(shareLink.value)
  ElMessage.success('链接已复制')
}

const getCategoryType = (category) => {
  const types = {
    '合同法': 'primary',
    '侵权法': 'success',
    '刑法': 'danger',
    '宪法': 'warning',
    '证据法': 'info'
  }
  return types[category] || ''
}

const getStatusType = (status) => {
  const types = {
    '已掌握': 'success',
    '学习中': 'warning',
    '待学习': 'info'
  }
  return types[status] || ''
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

// 新增方法
const saveEditCase = () => {
  const index = casesStore.cases.findIndex(c => c.id === editingCase.value.id)
  if (index !== -1) {
    casesStore.cases[index] = { ...editingCase.value }
    ElMessage.success('案例更新成功')
  }
  showEditDialog.value = false
}

const confirmExport = () => {
  ElMessage.success(`正在导出为 ${exportFormat.value.toUpperCase()} 格式...`)
  showExportDialog.value = false
}

const selectedMoveFolder = ref('')
const confirmMove = () => {
  if (selectedMoveFolder.value) {
    const folderMap = {
      'constitutional': '宪法',
      'criminal': '刑法',
      'contract': '合同法',
      'tort': '侵权法',
      'evidence': '证据法'
    }
    const category = folderMap[selectedMoveFolder.value]
    if (category && moveCase.value) {
      const index = casesStore.cases.findIndex(c => c.id === moveCase.value.id)
      if (index !== -1) {
        casesStore.cases[index].category = category
        ElMessage.success(`已移动到 ${category} 文件夹`)
      }
    }
  }
  showMoveDialog.value = false
  selectedMoveFolder.value = ''
}

const toggleStudySet = (setId) => {
  const index = selectedStudySets.value.indexOf(setId)
  if (index === -1) {
    selectedStudySets.value.push(setId)
  } else {
    selectedStudySets.value.splice(index, 1)
  }
}

const confirmAddToStudySet = () => {
  if (selectedStudySets.value.length > 0) {
    ElMessage.success(`已添加到 ${selectedStudySets.value.length} 个学习集`)
  }
  showAddToStudySetDialog.value = false
  selectedStudySets.value = []
}

// 查找资源抽屉方法
const openExternalLink = (url) => {
  window.open(url, '_blank')
}

const addCustomLink = () => {
  if (!newLink.value.name || !newLink.value.url) {
    ElMessage.warning('请填写网站名称和网址')
    return
  }
  
  const link = {
    id: Date.now().toString(),
    name: newLink.value.name,
    url: newLink.value.url,
    description: newLink.value.description
  }
  
  customLinks.value.push(link)
  localStorage.setItem('customSearchLinks', JSON.stringify(customLinks.value))
  
  ElMessage.success('链接添加成功')
  showAddLinkDialog.value = false
  newLink.value = { name: '', url: '', description: '' }
}

const deleteCustomLink = (linkId) => {
  ElMessageBox.confirm(
    '确定要删除这个链接吗？',
    '删除链接',
    {
      confirmButtonText: '删除',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    const index = customLinks.value.findIndex(l => l.id === linkId)
    if (index !== -1) {
      customLinks.value.splice(index, 1)
      localStorage.setItem('customSearchLinks', JSON.stringify(customLinks.value))
      ElMessage.success('链接已删除')
    }
  }).catch(() => {})
}
</script>

<style lang="scss" scoped>
.case-library {
  max-width: 1200px;
  margin: 0 auto;
  padding: $spacing-lg;
}

// 顶部导航栏
.top-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-lg;
  padding-bottom: $spacing-md;
  border-bottom: 1px solid $border-light;

  .page-title {
    font-size: 1.5rem;
    font-weight: 600;
    color: $text-primary;
    margin: 0;
  }

  .header-right {
    display: flex;
    gap: $spacing-sm;
  }
}

// 文件夹筛选栏
.folder-filter-bar {
  margin-bottom: $spacing-lg;
  padding-bottom: $spacing-md;
  border-bottom: 1px solid $border-light;
  overflow-x: auto;

  .folder-tabs {
    display: flex;
    gap: $spacing-sm;
    flex-wrap: nowrap;
  }

  .folder-tab {
    padding: $spacing-sm $spacing-md;
    border-radius: $radius-md;
    cursor: pointer;
    white-space: nowrap;
    transition: all $transition-fast;
    color: $text-secondary;
    font-size: 0.9375rem;

    &:hover {
      background: $bg-secondary;
      color: $text-primary;
    }

    &.active {
      background: rgba($primary, 0.1);
      color: $primary;
      font-weight: 500;
    }

    &.new-folder {
      display: flex;
      align-items: center;
      gap: $spacing-xs;
      color: $primary;

      &:hover {
        background: rgba($primary, 0.1);
      }
    }
  }
}

// 筛选工具栏
.filter-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-lg;

  .filter-left {
    display: flex;
    gap: $spacing-sm;
  }

  .filter-right {
    display: flex;
    align-items: center;
  }
}

// 筛选下拉菜单样式
.filter-dropdown-menu {
  padding: $spacing-md;
  min-width: 280px;

  .filter-section {
    margin-bottom: $spacing-md;

    &:last-child {
      margin-bottom: 0;
    }
  }

  .filter-title {
    font-size: 0.875rem;
    font-weight: 500;
    color: $text-secondary;
    margin-bottom: $spacing-sm;
  }

  .el-radio-group {
    display: flex;
    flex-wrap: wrap;
    gap: $spacing-xs;
  }
}

// 案例容器
.cases-container {
  &.card {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: $spacing-lg;
  }

  &.list {
    display: flex;
    flex-direction: column;
    gap: $spacing-md;
  }
}

// 卡片视图
.case-item.card {
  cursor: pointer;

  .case-card {
    background: white;
    border-radius: $radius-lg;
    border: 1px solid $border-light;
    padding: $spacing-lg;
    transition: all $transition-fast;
    height: 100%;
    display: flex;
    flex-direction: column;

    &:hover {
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      transform: translateY(-2px);
    }
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: $spacing-md;

    .file-icon {
      width: 40px;
      height: 40px;
      border-radius: $radius-md;
      background: rgba($primary, 0.1);
      display: flex;
      align-items: center;
      justify-content: center;
      color: $primary;
      font-size: 20px;
    }

    .more-btn {
      opacity: 0;
      transition: opacity $transition-fast;
    }
  }

  &:hover .more-btn {
    opacity: 1;
  }

  .card-content {
    flex: 1;
    margin-bottom: $spacing-md;

    .case-title {
      font-size: 1.125rem;
      font-weight: 600;
      color: $text-primary;
      margin: 0 0 $spacing-xs 0;
      line-height: 1.4;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    .case-citation {
      font-size: 0.875rem;
      color: $text-secondary;
      font-style: italic;
      margin: 0 0 $spacing-xs 0;
    }

    .case-summary {
      font-size: 0.875rem;
      color: $text-secondary;
      margin: 0;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }
  }

  .card-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: $spacing-sm;

    .meta-tags {
      display: flex;
      gap: $spacing-xs;
    }

    .meta-stats {
      display: flex;
      gap: $spacing-md;
      color: $text-tertiary;
      font-size: 0.875rem;

      .stat-item {
        display: flex;
        align-items: center;
        gap: $spacing-xs;

        .el-icon {
          font-size: 14px;
        }
      }
    }
  }

  .card-tags {
    display: flex;
    flex-wrap: wrap;
    gap: $spacing-xs;

    .keyword-tag {
      background: $bg-secondary;
      border: none;
    }
  }
}

// 列表视图
.case-item.list {
  cursor: pointer;

  .case-list-item {
    display: flex;
    align-items: center;
    gap: $spacing-md;
    padding: $spacing-md $spacing-lg;
    background: white;
    border-radius: $radius-md;
    border: 1px solid $border-light;
    transition: all $transition-fast;

    &:hover {
      background: $bg-secondary;
    }

    .list-icon {
      width: 36px;
      height: 36px;
      border-radius: $radius-sm;
      background: rgba($primary, 0.1);
      display: flex;
      align-items: center;
      justify-content: center;
      color: $primary;
      font-size: 18px;
      flex-shrink: 0;
    }

    .list-content {
      flex: 1;
      min-width: 0;

      .list-title {
        font-size: 1rem;
        font-weight: 500;
        color: $text-primary;
        margin: 0 0 $spacing-xs 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .list-citation {
        font-size: 0.875rem;
        color: $text-secondary;
        font-style: italic;
        margin: 0;
      }
    }

    .list-meta {
      display: flex;
      align-items: center;
      gap: $spacing-sm;
      flex-shrink: 0;

      .list-stat {
        display: flex;
        align-items: center;
        gap: $spacing-xs;
        color: $text-tertiary;
        font-size: 0.875rem;
      }

      .list-date {
        color: $text-tertiary;
        font-size: 0.875rem;
      }
    }
  }
}

// 空状态
.empty-state {
  text-align: center;
  padding: $spacing-2xl;
  color: $text-secondary;

  .empty-icon {
    font-size: 64px;
    color: $border-light;
    margin-bottom: $spacing-lg;
  }

  h3 {
    font-size: 1.25rem;
    color: $text-primary;
    margin-bottom: $spacing-sm;
  }

  p {
    margin-bottom: $spacing-lg;
  }
}

// 全局搜索对话框
.global-search-dialog {
  :deep(.el-dialog__body) {
    padding-top: $spacing-sm;
  }

  .global-search-content {
    .search-history {
      margin-top: $spacing-lg;

      .history-title {
        font-size: 0.875rem;
        color: $text-secondary;
        margin-bottom: $spacing-sm;
      }

      .history-tags {
        display: flex;
        flex-wrap: wrap;
        gap: $spacing-xs;

        .history-tag {
          cursor: pointer;

          &:hover {
            background: rgba($primary, 0.1);
            color: $primary;
          }
        }
      }
    }

    .search-results {
      margin-top: $spacing-lg;

      .result-section {
        margin-bottom: $spacing-lg;

        .result-title {
          font-size: 0.875rem;
          font-weight: 500;
          color: $text-secondary;
          margin-bottom: $spacing-sm;
        }

        .result-item {
          padding: $spacing-md;
          border-radius: $radius-md;
          cursor: pointer;
          transition: background $transition-fast;

          &:hover {
            background: $bg-secondary;
          }

          .result-name {
            font-weight: 500;
            color: $text-primary;
            margin-bottom: $spacing-xs;
          }

          .result-desc {
            font-size: 0.875rem;
            color: $text-secondary;
            margin-bottom: $spacing-xs;
          }

          .result-meta {
            display: flex;
            gap: $spacing-sm;
            align-items: center;
            font-size: 0.875rem;
            color: $text-tertiary;
          }
        }
      }
    }
  }
}

// 导入对话框
.import-dialog {
  .upload-area {
    :deep(.el-upload) {
      width: 100%;
    }

    :deep(.el-upload-dragger) {
      width: 100%;
      padding: $spacing-xl;
    }

    .upload-icon {
      font-size: 48px;
      color: $text-tertiary;
      margin-bottom: $spacing-md;
    }

    .upload-text {
      color: $text-secondary;

      em {
        color: $primary;
        font-style: normal;
      }

      .upload-hint {
        font-size: 0.875rem;
        color: $text-tertiary;
        margin-top: $spacing-xs;
      }
    }
  }

  .clipboard-tab {
    .search-links-section {
      margin-top: $spacing-lg;
      text-align: center;

      .divider-text {
        color: $text-tertiary;
      }

      .search-links-btn {
        margin-top: $spacing-md;
      }

      .search-links-hint {
        font-size: 0.875rem;
        color: $text-tertiary;
        margin-top: $spacing-sm;
      }
    }
  }

  .import-preview {
    margin-top: $spacing-lg;
    padding-top: $spacing-lg;
    border-top: 1px solid $border-light;

    h4 {
      margin-bottom: $spacing-md;
      font-size: 1rem;
    }

    .file-list {
      .file-item {
        display: flex;
        align-items: center;
        gap: $spacing-sm;
        padding: $spacing-sm;
        background: $bg-secondary;
        border-radius: $radius-sm;
        margin-bottom: $spacing-xs;

        .file-name {
          flex: 1;
        }

        .file-size {
          color: $text-tertiary;
          font-size: 0.875rem;
        }
      }
    }
  }
}

// 分享对话框
.share-dialog-content {
  padding: $spacing-md 0;
}

// 文件夹列表对话框
.folder-list-dialog {
  .folder-option {
    display: flex;
    align-items: center;
    gap: $spacing-md;
    padding: $spacing-md;
    border-radius: $radius-md;
    cursor: pointer;
    transition: all $transition-fast;
    margin-bottom: $spacing-xs;

    &:hover {
      background: $bg-secondary;
    }

    &.active {
      background: rgba($primary, 0.1);
      color: $primary;
    }

    .el-icon {
      font-size: 20px;
      color: $primary;
    }
  }
}

// 学习集列表
.study-set-list {
  .study-set-option {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: $spacing-md;
    border-radius: $radius-md;
    cursor: pointer;
    transition: all $transition-fast;
    margin-bottom: $spacing-xs;
    border: 1px solid transparent;

    &:hover {
      background: $bg-secondary;
    }

    &.active {
      background: rgba($primary, 0.05);
      border-color: $primary;
    }

    .set-info {
      display: flex;
      align-items: center;
      gap: $spacing-md;

      .el-icon {
        font-size: 24px;
        color: $primary;
      }

      .set-details {
        .set-name {
          font-weight: 500;
          color: $text-primary;
        }

        .set-count {
          font-size: 0.875rem;
          color: $text-secondary;
        }
      }
    }
  }
}

// 查找资源抽屉
.search-links-drawer {
  .usage-tips {
    margin-bottom: $spacing-lg;

    p {
      margin: $spacing-xs 0;
      font-size: 0.875rem;
    }
  }

  .link-list {
    display: flex;
    flex-direction: column;
    gap: $spacing-md;
  }

  .link-card {
    padding: $spacing-md;
    border: 1px solid $border-light;
    border-radius: $radius-md;
    cursor: pointer;
    transition: all $transition-fast;

    &:hover {
      border-color: $primary;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }

    &.custom {
      background: rgba($primary, 0.02);
    }

    .link-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: $spacing-xs;

      .link-name {
        font-weight: 500;
        color: $text-primary;
        font-size: 1rem;
      }
    }

    .link-url {
      font-size: 0.875rem;
      color: $primary;
      margin-bottom: $spacing-xs;
      word-break: break-all;
    }

    .link-desc {
      font-size: 0.875rem;
      color: $text-secondary;
      line-height: 1.5;
    }
  }

  .custom-links-section {
    margin-top: $spacing-xl;
    padding-top: $spacing-lg;
    border-top: 1px solid $border-light;

    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: $spacing-md;

      h4 {
        margin: 0;
        font-size: 1rem;
        color: $text-primary;
      }
    }

    .empty-custom-links {
      text-align: center;
      padding: $spacing-xl;
      color: $text-secondary;
      font-size: 0.875rem;
    }
  }
}
</style>
