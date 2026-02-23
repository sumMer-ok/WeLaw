<template>
  <div class="file-library">
    <!-- 顶部导航栏 -->
    <div class="top-header">
      <div class="header-left">
        <h1 class="page-title">文件库</h1>
      </div>
      <div class="header-right">
        <el-input
          v-model="searchKeyword"
          placeholder="搜索文件..."
          size="small"
          clearable
          class="search-input"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <el-dropdown @command="handleUpload">
          <el-button type="primary" size="small">
            <el-icon><Upload /></el-icon>
            上传文件
          </el-button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="case">导入案例</el-dropdown-item>
              <el-dropdown-item command="note">导入笔记</el-dropdown-item>
              <el-dropdown-item command="file">上传其他文件</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>

    <!-- 主内容区 -->
    <div class="main-content">
      <!-- 左侧文件夹树 -->
      <aside class="folder-sidebar">
        <div class="folder-tree">
          <!-- 全部 -->
          <div
            class="folder-item root-folder"
            :class="{ active: activeRootFolder === 'all' }"
            @click="selectRootFolder('all')"
          >
            <el-icon class="folder-icon"><FolderOpened /></el-icon>
            <span class="folder-name">全部</span>
            <span class="file-count">{{ allFilesCount }}</span>
          </div>

          <!-- 案例 -->
          <div class="folder-group">
            <div
              class="folder-item root-folder"
              :class="{ active: activeRootFolder === 'case', expanded: isExpanded('case') }"
              @click="toggleFolder('case')"
            >
              <el-icon class="expand-icon" @click.stop="toggleFolder('case')">
                <ArrowDown v-if="isExpanded('case')" />
                <ArrowRight v-else />
              </el-icon>
              <el-icon class="folder-icon" :class="activeRootFolder === 'case' ? 'FolderOpened' : 'Folder'"><Folder /></el-icon>
              <span class="folder-name">案例</span>
              <span class="file-count">{{ caseFilesCount }}</span>
            </div>
            <!-- 案例子文件夹 -->
            <div v-show="isExpanded('case')" class="sub-folders">
              <div
                v-for="folder in caseFolders"
                :key="folder.id"
                class="folder-item sub-folder"
                :class="{ active: selectedFolderId === folder.id }"
                :style="{ paddingLeft: (folder.level * 16 + 32) + 'px' }"
                @click="selectFolder(folder)"
              >
                <el-icon 
                  v-if="folder.children?.length"
                  class="expand-icon"
                  @click.stop="toggleSubFolder(folder.id)"
                >
                  <ArrowDown v-if="isSubFolderExpanded(folder.id)" />
                  <ArrowRight v-else />
                </el-icon>
                <span v-else class="expand-placeholder"></span>
                <el-icon class="folder-icon">
                  <FolderOpened v-if="selectedFolderId === folder.id || isSubFolderExpanded(folder.id)" />
                  <Folder v-else />
                </el-icon>
                <span class="folder-name">{{ folder.name }}</span>
                <span class="file-count">{{ folder.fileCount || 0 }}</span>
              </div>
            </div>
          </div>

          <!-- 笔记 -->
          <div class="folder-group">
            <div
              class="folder-item root-folder"
              :class="{ active: activeRootFolder === 'note', expanded: isExpanded('note') }"
              @click="toggleFolder('note')"
            >
              <el-icon class="expand-icon" @click.stop="toggleFolder('note')">
                <ArrowDown v-if="isExpanded('note')" />
                <ArrowRight v-else />
              </el-icon>
              <el-icon class="folder-icon"><Notebook /></el-icon>
              <span class="folder-name">笔记</span>
              <span class="file-count">{{ noteFilesCount }}</span>
            </div>
            <!-- 笔记子文件夹 -->
            <div v-show="isExpanded('note')" class="sub-folders">
              <div
                v-for="folder in noteFolders"
                :key="folder.id"
                class="folder-item sub-folder"
                :class="{ active: selectedFolderId === folder.id }"
                :style="{ paddingLeft: (folder.level * 16 + 32) + 'px' }"
                @click="selectFolder(folder)"
              >
                <el-icon 
                  v-if="folder.children?.length"
                  class="expand-icon"
                  @click.stop="toggleSubFolder(folder.id)"
                >
                  <ArrowDown v-if="isSubFolderExpanded(folder.id)" />
                  <ArrowRight v-else />
                </el-icon>
                <span v-else class="expand-placeholder"></span>
                <el-icon class="folder-icon">
                  <FolderOpened v-if="selectedFolderId === folder.id || isSubFolderExpanded(folder.id)" />
                  <Folder v-else />
                </el-icon>
                <span class="folder-name">{{ folder.name }}</span>
                <span class="file-count">{{ folder.fileCount || 0 }}</span>
              </div>
            </div>
          </div>

          <!-- 其他 -->
          <div class="folder-group">
            <div
              class="folder-item root-folder"
              :class="{ active: activeRootFolder === 'other', expanded: isExpanded('other') }"
              @click="toggleFolder('other')"
            >
              <el-icon class="expand-icon" @click.stop="toggleFolder('other')">
                <ArrowDown v-if="isExpanded('other')" />
                <ArrowRight v-else />
              </el-icon>
              <el-icon class="folder-icon"><DocumentCopy /></el-icon>
              <span class="folder-name">其他</span>
              <span class="file-count">{{ otherFilesCount }}</span>
            </div>
            <!-- 其他子文件夹 -->
            <div v-show="isExpanded('other')" class="sub-folders">
              <div
                v-for="folder in otherFolders"
                :key="folder.id"
                class="folder-item sub-folder"
                :class="{ active: selectedFolderId === folder.id }"
                :style="{ paddingLeft: (folder.level * 16 + 32) + 'px' }"
                @click="selectFolder(folder)"
              >
                <el-icon 
                  v-if="folder.children?.length"
                  class="expand-icon"
                  @click.stop="toggleSubFolder(folder.id)"
                >
                  <ArrowDown v-if="isSubFolderExpanded(folder.id)" />
                  <ArrowRight v-else />
                </el-icon>
                <span v-else class="expand-placeholder"></span>
                <el-icon class="folder-icon">
                  <FolderOpened v-if="selectedFolderId === folder.id || isSubFolderExpanded(folder.id)" />
                  <Folder v-else />
                </el-icon>
                <span class="folder-name">{{ folder.name }}</span>
                <span class="file-count">{{ folder.fileCount || 0 }}</span>
              </div>
            </div>
          </div>
        </div>
      </aside>

      <!-- 右侧文件列表 -->
      <div class="file-list-panel">
        <!-- 面包屑导航 -->
        <div class="breadcrumb">
          <span class="breadcrumb-item" @click="selectRootFolder('all')">文件库</span>
          <span v-if="activeRootFolder !== 'all'" class="breadcrumb-separator">/</span>
          <span v-if="activeRootFolder !== 'all'" class="breadcrumb-item active">
            {{ getRootFolderName(activeRootFolder) }}
          </span>
          <span v-if="selectedFolderName" class="breadcrumb-separator">/</span>
          <span v-if="selectedFolderName" class="breadcrumb-item active">{{ selectedFolderName }}</span>
        </div>

        <!-- 视图切换 -->
        <div class="list-header">
          <div class="view-toggle">
            <el-button
              text
              size="small"
              :class="{ 'is-active': viewMode === 'grid' }"
              @click="viewMode = 'grid'"
            >
              <el-icon><Grid /></el-icon>
            </el-button>
            <el-button
              text
              size="small"
              :class="{ 'is-active': viewMode === 'list' }"
              @click="viewMode = 'list'"
            >
              <el-icon><List /></el-icon>
            </el-button>
          </div>
        </div>

        <!-- 文件内容 -->
        <div class="file-content" :class="viewMode">
          <!-- 网格视图 -->
          <template v-if="viewMode === 'grid'">
            <div
              v-for="file in filteredFiles"
              :key="file.id"
              class="file-card"
              @click="openFile(file)"
            >
              <div class="file-icon" :class="file.type">
                <el-icon v-if="file.type === 'case'"><Document /></el-icon>
                <el-icon v-else-if="file.type === 'note'"><Notebook /></el-icon>
                <el-icon v-else><DocumentCopy /></el-icon>
              </div>
              <div class="file-info">
                <h4 class="file-name">{{ file.name }}</h4>
                <p class="file-meta">
                  <span class="file-type">{{ getFileTypeLabel(file.type) }}</span>
                  <span class="file-size">{{ file.size }}</span>
                </p>
                <p class="file-date">{{ formatDate(file.updatedAt) }}</p>
              </div>
              <div class="file-actions" @click.stop>
                <el-dropdown @command="(cmd) => handleFileAction(cmd, file)">
                  <el-button text size="small">
                    <el-icon><More /></el-icon>
                  </el-button>
                  <template #dropdown>
                    <el-dropdown-menu>
                      <el-dropdown-item command="open">打开</el-dropdown-item>
                      <el-dropdown-item command="rename">重命名</el-dropdown-item>
                      <el-dropdown-item command="move">移动到...</el-dropdown-item>
                      <el-dropdown-item command="share">分享</el-dropdown-item>
                      <el-dropdown-item divided command="delete" class="danger">删除</el-dropdown-item>
                    </el-dropdown-menu>
                  </template>
                </el-dropdown>
              </div>
            </div>
          </template>

          <!-- 列表视图 -->
          <template v-else>
            <el-table :data="filteredFiles" style="width: 100%" @row-click="openFile">
              <el-table-column label="文件名" min-width="300">
                <template #default="{ row }">
                  <div class="file-row">
                    <el-icon class="file-row-icon" :class="row.type">
                      <Document v-if="row.type === 'case'" />
                      <Notebook v-else-if="row.type === 'note'" />
                      <DocumentCopy v-else />
                    </el-icon>
                    <span class="file-row-name">{{ row.name }}</span>
                  </div>
                </template>
              </el-table-column>
              <el-table-column label="类型" width="120">
                <template #default="{ row }">
                  <el-tag size="small" :type="getFileTypeTag(row.type)">
                    {{ getFileTypeLabel(row.type) }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column label="大小" width="100" prop="size" />
              <el-table-column label="修改时间" width="180">
                <template #default="{ row }">
                  {{ formatDate(row.updatedAt) }}
                </template>
              </el-table-column>
              <el-table-column label="操作" width="120" fixed="right">
                <template #default="{ row }">
                  <el-dropdown @command="(cmd) => handleFileAction(cmd, row)" @click.stop>
                    <el-button text size="small">
                      <el-icon><More /></el-icon>
                    </el-button>
                    <template #dropdown>
                      <el-dropdown-menu>
                        <el-dropdown-item command="open">打开</el-dropdown-item>
                        <el-dropdown-item command="rename">重命名</el-dropdown-item>
                        <el-dropdown-item command="share">分享</el-dropdown-item>
                        <el-dropdown-item divided command="delete" class="danger">删除</el-dropdown-item>
                      </el-dropdown-menu>
                    </template>
                  </el-dropdown>
                </template>
              </el-table-column>
            </el-table>
          </template>

          <!-- 空状态 -->
          <div v-if="filteredFiles.length === 0" class="empty-state">
            <el-icon class="empty-icon"><FolderOpened /></el-icon>
            <p>暂无文件</p>
            <p class="empty-hint">该文件夹为空</p>
          </div>
        </div>

        <!-- 统计信息 -->
        <div class="file-stats">
          <span>共 {{ filteredFiles.length }} 个文件</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Search, Upload, Grid, List, Document, Notebook,
  DocumentCopy, More, FolderOpened, Folder, ArrowRight, ArrowDown
} from '@element-plus/icons-vue'

const router = useRouter()

// ============ 状态管理 ============
const searchKeyword = ref('')
const activeRootFolder = ref('all')
const selectedFolderId = ref(null)
const selectedFolderName = ref('')
const viewMode = ref('grid')

// 展开状态
const expandedFolders = ref(new Set())
const expandedSubFolders = ref(new Set())

// ============ 案例库文件夹数据 ============
const caseFolderData = ref([
  { id: 'case-root', name: '案例库', parentId: null, fileCount: 12 },
  { id: 'case-1', name: '合同法', parentId: 'case-root', fileCount: 5 },
  { id: 'case-1-1', name: '合同违约', parentId: 'case-1', fileCount: 2 },
  { id: 'case-1-2', name: '损害赔偿', parentId: 'case-1', fileCount: 3 },
  { id: 'case-2', name: '侵权法', parentId: 'case-root', fileCount: 3 },
  { id: 'case-3', name: '宪法', parentId: 'case-root', fileCount: 2 },
  { id: 'case-4', name: '刑法', parentId: 'case-root', fileCount: 2 }
])

// ============ 笔记库文件夹数据 ============
const noteFolderData = ref([
  { id: 'note-root', name: '笔记库', parentId: null, fileCount: 8 },
  { id: 'note-1', name: '学习笔记', parentId: 'note-root', fileCount: 3 },
  { id: 'note-2', name: '案例笔记', parentId: 'note-root', fileCount: 4 },
  { id: 'note-3', name: '待整理', parentId: 'note-root', fileCount: 1 }
])

// ============ 其他文件夹数据 ============
const otherFolderData = ref([
  { id: 'other-root', name: '其他文件', parentId: null, fileCount: 3 },
  { id: 'other-1', name: '文档', parentId: 'other-root', fileCount: 2 },
  { id: 'other-2', name: '图片', parentId: 'other-root', fileCount: 1 }
])

// ============ 文件数据 ============
const allFiles = ref([
  // 案例文件
  { id: 'file-1', name: 'Hadley v. Baxendale', type: 'case', size: '156 KB', folderId: 'case-1-1', updatedAt: new Date('2026-02-21') },
  { id: 'file-2', name: 'Victoria Laundry v. Newman', type: 'case', size: '203 KB', folderId: 'case-1-1', updatedAt: new Date('2026-02-20') },
  { id: 'file-3', name: 'Donoghue v. Stevenson', type: 'case', size: '189 KB', folderId: 'case-2', updatedAt: new Date('2026-02-19') },
  { id: 'file-4', name: 'Marbury v. Madison', type: 'case', size: '145 KB', folderId: 'case-3', updatedAt: new Date('2026-02-18') },
  // 笔记文件
  { id: 'file-5', name: '合同法基本原则', type: 'note', size: '12 KB', folderId: 'note-1', updatedAt: new Date('2026-02-21') },
  { id: 'file-6', name: '侵权法学习笔记', type: 'note', size: '8 KB', folderId: 'note-2', updatedAt: new Date('2026-02-20') },
  // 其他文件
  { id: 'file-7', name: '法律英语词汇表.pdf', type: 'other', size: '1.2 MB', folderId: 'other-1', updatedAt: new Date('2026-02-15') },
  { id: 'file-8', name: '案例分析模板.docx', type: 'other', size: '45 KB', folderId: 'other-1', updatedAt: new Date('2026-02-12') }
])

// ============ 计算属性 ============

// 构建案例文件夹树
const caseFolders = computed(() => {
  return buildFolderTree(caseFolderData.value, 'case-root')
})

// 构建笔记文件夹树
const noteFolders = computed(() => {
  return buildFolderTree(noteFolderData.value, 'note-root')
})

// 构建其他文件夹树
const otherFolders = computed(() => {
  return buildFolderTree(otherFolderData.value, 'other-root')
})

// 统计数量
const allFilesCount = computed(() => allFiles.value.length)
const caseFilesCount = computed(() => allFiles.value.filter(f => f.type === 'case').length)
const noteFilesCount = computed(() => allFiles.value.filter(f => f.type === 'note').length)
const otherFilesCount = computed(() => allFiles.value.filter(f => f.type === 'other').length)

// 过滤后的文件列表
const filteredFiles = computed(() => {
  let result = allFiles.value

  // 根据选中的文件夹筛选
  if (activeRootFolder.value === 'all') {
    // 显示所有文件
  } else if (selectedFolderId.value) {
    // 显示选中文件夹及其子文件夹的文件
    const folderIds = getAllSubFolderIds(selectedFolderId.value)
    result = result.filter(f => folderIds.includes(f.folderId))
  } else {
    // 显示该类型所有文件
    result = result.filter(f => f.type === activeRootFolder.value)
  }

  // 搜索过滤
  if (searchKeyword.value) {
    const keyword = searchKeyword.value.toLowerCase()
    result = result.filter(f => f.name.toLowerCase().includes(keyword))
  }

  return result.sort((a, b) => b.updatedAt - a.updatedAt)
})

// ============ 方法 ============

// 构建文件夹树
function buildFolderTree(folders, rootId, level = 0) {
  return folders
    .filter(f => f.parentId === rootId)
    .map(f => ({
      ...f,
      level,
      children: buildFolderTree(folders, f.id, level + 1)
    }))
}

// 获取所有子文件夹ID
function getAllSubFolderIds(folderId) {
  const ids = [folderId]
  const allFolders = [...caseFolderData.value, ...noteFolderData.value, ...otherFolderData.value]
  const children = allFolders.filter(f => f.parentId === folderId)
  children.forEach(child => {
    ids.push(...getAllSubFolderIds(child.id))
  })
  return ids
}

// 切换顶级文件夹展开
function toggleFolder(type) {
  if (expandedFolders.value.has(type)) {
    expandedFolders.value.delete(type)
  } else {
    expandedFolders.value.add(type)
  }
  // 同时选中该类型
  selectRootFolder(type)
}

// 检查文件夹是否展开
function isExpanded(type) {
  return expandedFolders.value.has(type)
}

// 切换子文件夹展开
function toggleSubFolder(folderId) {
  if (expandedSubFolders.value.has(folderId)) {
    expandedSubFolders.value.delete(folderId)
  } else {
    expandedSubFolders.value.add(folderId)
  }
}

// 检查子文件夹是否展开
function isSubFolderExpanded(folderId) {
  return expandedSubFolders.value.has(folderId)
}

// 选择顶级文件夹
function selectRootFolder(type) {
  activeRootFolder.value = type
  selectedFolderId.value = null
  selectedFolderName.value = ''
}

// 选择子文件夹
function selectFolder(folder) {
  selectedFolderId.value = folder.id
  selectedFolderName.value = folder.name
}

// 获取根文件夹名称
function getRootFolderName(type) {
  const names = { all: '全部', case: '案例', note: '笔记', other: '其他' }
  return names[type] || type
}

// 获取文件类型标签
function getFileTypeLabel(type) {
  const labels = { case: '案例', note: '笔记', other: '其他' }
  return labels[type] || '其他'
}

// 获取文件类型标签样式
function getFileTypeTag(type) {
  const tags = { case: 'success', note: 'primary', other: 'info' }
  return tags[type] || 'info'
}

// 格式化日期
function formatDate(date) {
  if (!date) return ''
  return new Date(date).toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

// 打开文件
function openFile(file) {
  if (file.type === 'case') {
    router.push(`/cases/${file.id}`)
  } else if (file.type === 'note') {
    router.push('/notes')
  } else {
    ElMessage.info(`打开文件: ${file.name}`)
  }
}

// 处理上传
function handleUpload(command) {
  const messages = {
    case: '请选择要导入的案例文件',
    note: '请选择要导入的笔记文件',
    file: '请选择要上传的文件'
  }
  ElMessage.info(messages[command])
}

// 处理文件操作
async function handleFileAction(command, file) {
  switch (command) {
    case 'open':
      openFile(file)
      break
    case 'rename':
      const { value } = await ElMessageBox.prompt('请输入新文件名', '重命名', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        inputValue: file.name
      })
      if (value) {
        file.name = value
        file.updatedAt = new Date()
        ElMessage.success('重命名成功')
      }
      break
    case 'share':
      ElMessage.success(`已生成分享链接: ${file.name}`)
      break
    case 'delete':
      await ElMessageBox.confirm(`确定要删除 "${file.name}" 吗？`, '确认删除', {
        confirmButtonText: '删除',
        cancelButtonText: '取消',
        type: 'warning'
      })
      const index = allFiles.value.findIndex(f => f.id === file.id)
      if (index > -1) {
        allFiles.value.splice(index, 1)
        ElMessage.success('删除成功')
      }
      break
  }
}
</script>

<style lang="scss" scoped>
.file-library {
  padding: $spacing-lg;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.top-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-lg;

  .page-title {
    margin: 0;
    font-size: 1.5rem;
    font-weight: 600;
    color: $text-primary;
  }

  .header-right {
    display: flex;
    gap: $spacing-sm;

    .search-input {
      width: 240px;
    }
  }
}

.main-content {
  display: flex;
  flex: 1;
  overflow: hidden;
  gap: $spacing-lg;
}

// 左侧文件夹侧边栏
.folder-sidebar {
  width: 260px;
  background: white;
  border-radius: $radius-md;
  border: 1px solid $border-light;
  overflow-y: auto;
  flex-shrink: 0;

  .folder-tree {
    padding: $spacing-sm 0;
  }

  .folder-group {
    border-bottom: 1px solid $border-light;

    &:last-child {
      border-bottom: none;
    }
  }

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

      .folder-icon {
        color: $primary;
      }
    }

    &.expanded {
      .expand-icon {
        color: $primary;
      }
    }

    &.root-folder {
      font-weight: 500;
    }

    &.sub-folder {
      font-size: 0.9375rem;
    }

    .expand-icon,
    .expand-placeholder {
      width: 16px;
      height: 16px;
      margin-right: $spacing-xs;
      font-size: 0.75rem;
      color: $text-tertiary;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .expand-icon {
      cursor: pointer;
      border-radius: $radius-sm;
      transition: all 0.2s;

      &:hover {
        background: rgba($text-primary, 0.1);
        color: $text-primary;
      }
    }

    .folder-icon {
      margin-right: $spacing-xs;
      font-size: 1.125rem;
      color: $text-secondary;
      transition: color 0.2s;
    }

    .folder-name {
      flex: 1;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .file-count {
      font-size: 0.75rem;
      color: $text-tertiary;
      margin-left: $spacing-xs;
      background: $bg-secondary;
      padding: 2px 6px;
      border-radius: 10px;
      min-width: 20px;
      text-align: center;
    }
  }

  .sub-folders {
    animation: slideDown 0.2s ease;
  }
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

// 右侧文件列表
.file-list-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;

  .breadcrumb {
    display: flex;
    align-items: center;
    gap: $spacing-xs;
    margin-bottom: $spacing-md;
    font-size: 0.875rem;

    .breadcrumb-item {
      color: $text-secondary;
      cursor: pointer;
      transition: color 0.2s;

      &:hover {
        color: $primary;
      }

      &.active {
        color: $text-primary;
        font-weight: 500;
        cursor: default;
      }
    }

    .breadcrumb-separator {
      color: $text-tertiary;
    }
  }

  .list-header {
    display: flex;
    justify-content: flex-end;
    margin-bottom: $spacing-md;

    .view-toggle {
      display: flex;
      gap: 4px;

      .el-button {
        padding: 6px 10px;

        &.is-active {
          background: rgba($primary, 0.1);
          color: $primary;
        }
      }
    }
  }

  .file-content {
    flex: 1;
    overflow-y: auto;

    &.grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: $spacing-md;
      align-content: flex-start;
    }

    &.list {
      .el-table {
        background: transparent;

        :deep(.el-table__row) {
          cursor: pointer;

          &:hover {
            background: $bg-secondary;
          }
        }
      }
    }
  }
}

.file-card {
  background: white;
  border-radius: $radius-md;
  padding: $spacing-md;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid $border-light;
  position: relative;

  &:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    transform: translateY(-2px);

    .file-actions {
      opacity: 1;
    }
  }

  .file-icon {
    width: 56px;
    height: 56px;
    border-radius: $radius-md;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: $spacing-sm;

    &.case {
      background: rgba($success, 0.1);
      color: $success;
    }

    &.note {
      background: rgba($primary, 0.1);
      color: $primary;
    }

    &.other {
      background: rgba($info, 0.1);
      color: $info;
    }

    .el-icon {
      font-size: 1.75rem;
    }
  }

  .file-info {
    width: 100%;

    .file-name {
      margin: 0 0 $spacing-xs;
      font-size: 0.875rem;
      font-weight: 500;
      color: $text-primary;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .file-meta {
      margin: 0 0 $spacing-xs;
      font-size: 0.75rem;
      color: $text-secondary;
      display: flex;
      justify-content: center;
      gap: $spacing-sm;
    }

    .file-date {
      margin: 0;
      font-size: 0.75rem;
      color: $text-tertiary;
    }
  }

  .file-actions {
    position: absolute;
    top: $spacing-sm;
    right: $spacing-sm;
    opacity: 0;
    transition: opacity 0.2s;
  }
}

.file-row {
  display: flex;
  align-items: center;
  gap: $spacing-sm;

  .file-row-icon {
    font-size: 1.25rem;

    &.case {
      color: $success;
    }

    &.note {
      color: $primary;
    }

    &.other {
      color: $info;
    }
  }

  .file-row-name {
    color: $text-primary;
  }
}

.empty-state {
  grid-column: 1 / -1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: $spacing-2xl;
  color: $text-tertiary;

  .empty-icon {
    font-size: 4rem;
    margin-bottom: $spacing-md;
  }

  p {
    margin: 0;

    &.empty-hint {
      font-size: 0.875rem;
      margin-top: $spacing-xs;
    }
  }
}

.file-stats {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: $spacing-sm;
  padding: $spacing-md;
  margin-top: $spacing-md;
  background: white;
  border-radius: $radius-md;
  border: 1px solid $border-light;
  font-size: 0.875rem;
  color: $text-secondary;
}
</style>
