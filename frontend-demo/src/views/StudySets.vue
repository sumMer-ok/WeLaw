<template>
  <div class="study-sets-page">
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">学习集</h1>
        <p class="page-subtitle">组织您的学习资料</p>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="showCreateDialog = true">
          <el-icon><Plus /></el-icon>
          创建学习集
        </el-button>
      </div>
    </div>

    <div class="study-sets-grid">
      <div 
        v-for="set in studySetsStore.studySets" 
        :key="set.id"
        class="study-set-card"
      >
        <div class="set-header">
          <div class="set-icon">
            <el-icon><FolderOpened /></el-icon>
          </div>
          <div class="set-menu" @click.stop>
            <el-dropdown trigger="click">
              <el-button text>
                <el-icon><MoreFilled /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item>重命名</el-dropdown-item>
                  <el-dropdown-item @click="$router.push('/mindmap/' + set.id)">思维导图</el-dropdown-item>
                  <el-dropdown-item divided>删除</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </div>
        <div class="set-content">
          <h3 class="set-name">{{ set.name }}</h3>
          <p class="set-description">{{ set.description }}</p>
          <div class="set-meta">
            <span class="item-count">{{ set.itemCount }} 个项目</span>
            <span class="created-date">创建于 {{ formatDate(set.createdAt) }}</span>
          </div>
        </div>
        <div class="set-items-preview">
          <div 
            v-for="(item, index) in set.items.slice(0, 3)" 
            :key="index"
            class="preview-item"
          >
            <el-icon v-if="item.type === 'case'"><Document /></el-icon>
            <el-icon v-else-if="item.type === 'note'"><Memo /></el-icon>
            <el-icon v-else-if="item.type === 'vocab'"><Collection /></el-icon>
            <el-icon v-else><Share /></el-icon>
            <span class="item-title">{{ item.title }}</span>
          </div>
          <div v-if="set.items.length > 3" class="more-items">
            +{{ set.items.length - 3 }} 更多
          </div>
        </div>
        <div class="set-actions">
          <el-button type="primary" text @click="openStudySet(set)">
            打开
          </el-button>
          <el-button text @click="$router.push('/mindmap/' + set.id)">
            思维导图
          </el-button>
        </div>
      </div>

      <!-- Add New Card -->
      <div class="study-set-card add-new" @click="showCreateDialog = true">
        <div class="add-content">
          <el-icon class="add-icon"><Plus /></el-icon>
          <span>创建新学习集</span>
        </div>
      </div>
    </div>

    <!-- Create Dialog -->
    <el-dialog v-model="showCreateDialog" title="创建学习集" width="500px">
      <el-form :model="newSetForm" label-width="80px">
        <el-form-item label="名称">
          <el-input v-model="newSetForm.name" placeholder="输入学习集名称" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="newSetForm.description" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="createStudySet">创建</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useStudySetsStore } from '@/stores'

const router = useRouter()
const studySetsStore = useStudySetsStore()

const showCreateDialog = ref(false)
const newSetForm = ref({ name: '', description: '' })

const openStudySet = (set) => {
  console.log('Open study set:', set)
}

const createStudySet = () => {
  showCreateDialog.value = false
  newSetForm.value = { name: '', description: '' }
}

const formatDate = (dateStr) => {
  return new Date(dateStr).toLocaleDateString('zh-CN')
}
</script>

<style lang="scss" scoped>
.study-sets-page {
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: $spacing-xl;
}

.page-title {
  font-family: $font-display;
  font-size: 2rem;
  font-weight: 700;
  color: $text-primary;
  margin-bottom: $spacing-xs;
}

.page-subtitle {
  color: $text-secondary;
}

.study-sets-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: $spacing-lg;
}

.study-set-card {
  background: white;
  border-radius: $radius-lg;
  border: 1px solid $border-light;
  padding: $spacing-lg;
  transition: all $transition-normal;

  &:hover {
    box-shadow: $shadow-lg;
    transform: translateY(-2px);
  }

  &.add-new {
    display: flex;
    align-items: center;
    justify-content: center;
    border-style: dashed;
    background: $bg-secondary;
    cursor: pointer;

    &:hover {
      border-color: $primary;
    }

    .add-content {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: $spacing-sm;
      color: $text-tertiary;

      .add-icon {
        font-size: 32px;
      }
    }
  }
}

.set-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: $spacing-md;
}

.set-icon {
  width: 48px;
  height: 48px;
  border-radius: $radius-md;
  background: rgba($primary, 0.1);
  color: $primary;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.set-content {
  margin-bottom: $spacing-md;
}

.set-name {
  font-family: $font-display;
  font-size: 1.125rem;
  font-weight: 600;
  color: $text-primary;
  margin-bottom: 4px;
}

.set-description {
  font-size: 0.875rem;
  color: $text-secondary;
  margin-bottom: $spacing-sm;
}

.set-meta {
  display: flex;
  gap: $spacing-md;
  font-size: 0.75rem;
  color: $text-tertiary;
}

.set-items-preview {
  background: $bg-secondary;
  border-radius: $radius-md;
  padding: $spacing-md;
  margin-bottom: $spacing-md;
}

.preview-item {
  display: flex;
  align-items: center;
  gap: $spacing-sm;
  font-size: 0.875rem;
  color: $text-secondary;
  margin-bottom: $spacing-xs;

  &:last-child {
    margin-bottom: 0;
  }

  .el-icon {
    color: $primary;
  }

  .item-title {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
}

.more-items {
  font-size: 0.75rem;
  color: $text-tertiary;
  text-align: center;
  margin-top: $spacing-xs;
}

.set-actions {
  display: flex;
  gap: $spacing-sm;
}
</style>
