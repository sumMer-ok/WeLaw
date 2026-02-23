<template>
  <div class="vocabulary-page">
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">词汇学习</h1>
        <p class="page-subtitle">管理您的法律英语词汇库</p>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="$router.push('/flashcards')">
          <el-icon><VideoPlay /></el-icon>
          开始学习
        </el-button>
        <el-button>
          <el-icon><Upload /></el-icon>
          导入词汇
        </el-button>
      </div>
    </div>

    <!-- Stats Overview -->
    <div class="stats-overview">
      <div class="stat-card">
        <div class="stat-icon total">
          <el-icon><Collection /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-value">{{ mainStore.user.totalVocab }}</div>
          <div class="stat-label">总词汇量</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon mastered">
          <el-icon><CircleCheck /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-value">{{ mainStore.user.masteredVocab }}</div>
          <div class="stat-label">已掌握</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon learning">
          <el-icon><Reading /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-value">{{ mainStore.user.totalVocab - mainStore.user.masteredVocab }}</div>
          <div class="stat-label">学习中</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon review">
          <el-icon><AlarmClock /></el-icon>
        </div>
        <div class="stat-info">
          <div class="stat-value">{{ totalReview }}</div>
          <div class="stat-label">待复习</div>
        </div>
      </div>
    </div>

    <!-- Decks Grid -->
    <div class="decks-section">
      <h2 class="section-title">我的牌组</h2>
      <div class="decks-grid">
        <div 
          v-for="deck in vocabStore.decks" 
          :key="deck.id"
          class="deck-card"
          @click="openDeck(deck)"
        >
          <div class="deck-header">
            <div class="deck-icon">
              <el-icon><Memo /></el-icon>
            </div>
            <div class="deck-menu" @click.stop>
              <el-dropdown trigger="click">
                <el-button text>
                  <el-icon><MoreFilled /></el-icon>
                </el-button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item>重命名</el-dropdown-item>
                    <el-dropdown-item>导出</el-dropdown-item>
                    <el-dropdown-item divided>删除</el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
          </div>
          <div class="deck-content">
            <h3 class="deck-name">{{ deck.name }}</h3>
            <p class="deck-category">{{ deck.category }}</p>
            <div class="deck-stats">
              <span class="card-count">{{ deck.count }} 张卡片</span>
              <span v-if="deck.review > 0" class="review-count">
                <el-icon><AlarmClock /></el-icon>
                {{ deck.review }} 待复习
              </span>
            </div>
          </div>
          <div class="deck-progress">
            <el-progress 
              :percentage="Math.round((deck.count - deck.review) / deck.count * 100)" 
              :stroke-width="6"
              :show-text="false"
              color="#8B4513"
            />
          </div>
          <div class="deck-actions">
            <el-button type="primary" text @click.stop="startLearning(deck)">
              学习
            </el-button>
            <el-button text @click.stop="browseDeck(deck)">
              浏览
            </el-button>
          </div>
        </div>

        <!-- Add New Deck Card -->
        <div class="deck-card add-new" @click="showCreateDeckDialog = true">
          <div class="add-content">
            <el-icon class="add-icon"><Plus /></el-icon>
            <span>创建新牌组</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Recent Words -->
    <div class="recent-words-section">
      <h2 class="section-title">最近添加</h2>
      <div class="words-table">
        <el-table :data="recentWords" style="width: 100%">
          <el-table-column prop="term" label="单词/术语" width="200">
            <template #default="{ row }">
              <div class="word-cell">
                <span class="word-term">{{ row.term }}</span>
                <span class="word-pronunciation">{{ row.pronunciation }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="meaning" label="释义">
            <template #default="{ row }">
              <div class="meaning-cell">
                <span class="word-meaning">{{ row.meaning }}</span>
                <el-tag v-if="row.field" size="small" effect="plain">{{ row.field }}</el-tag>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="source" label="来源" width="200">
            <template #default="{ row }">
              <span class="source-text">{{ row.source }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="addedAt" label="添加时间" width="120">
            <template #default="{ row }">
              {{ formatDate(row.addedAt) }}
            </template>
          </el-table-column>
          <el-table-column width="100">
            <template #default>
              <el-button type="primary" text>
                <el-icon><ArrowRight /></el-icon>
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </div>

    <!-- Create Deck Dialog -->
    <el-dialog
      v-model="showCreateDeckDialog"
      title="创建新牌组"
      width="500px"
    >
      <el-form :model="newDeckForm" label-width="80px">
        <el-form-item label="名称">
          <el-input v-model="newDeckForm.name" placeholder="输入牌组名称" />
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="newDeckForm.category" placeholder="选择分类">
            <el-option label="合同法" value="合同法" />
            <el-option label="侵权法" value="侵权法" />
            <el-option label="刑法" value="刑法" />
            <el-option label="宪法" value="宪法" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述">
          <el-input 
            v-model="newDeckForm.description" 
            type="textarea" 
            :rows="3"
            placeholder="输入牌组描述（可选）"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDeckDialog = false">取消</el-button>
        <el-button type="primary" @click="createDeck">创建</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useMainStore, useVocabStore } from '@/stores'

const router = useRouter()
const mainStore = useMainStore()
const vocabStore = useVocabStore()

// State
const showCreateDeckDialog = ref(false)
const newDeckForm = ref({
  name: '',
  category: '',
  description: ''
})

// Computed
const totalReview = computed(() => {
  return vocabStore.decks.reduce((sum, deck) => sum + deck.review, 0)
})

const recentWords = ref([
  {
    term: 'precedent',
    pronunciation: '/ˈpresɪdənt/',
    meaning: '先例；判例',
    field: '判例法',
    source: 'Brown v. Board of Education',
    addedAt: new Date(Date.now() - 86400000).toISOString()
  },
  {
    term: 'jurisdiction',
    pronunciation: '/ˌdʒʊərɪsˈdɪkʃn/',
    meaning: '管辖权；司法权',
    field: '程序法',
    source: 'Smith v. Jones',
    addedAt: new Date(Date.now() - 172800000).toISOString()
  },
  {
    term: 'negligence',
    pronunciation: '/ˈneɡlɪdʒəns/',
    meaning: '过失；疏忽',
    field: '侵权法',
    source: 'Donoghue v. Stevenson',
    addedAt: new Date(Date.now() - 259200000).toISOString()
  },
  {
    term: 'consideration',
    pronunciation: '/kənˌsɪdəˈreɪʃn/',
    meaning: '对价；约因',
    field: '合同法',
    source: 'Currie v. Misa',
    addedAt: new Date(Date.now() - 345600000).toISOString()
  }
])

// Methods
const openDeck = (deck) => {
  console.log('Open deck:', deck)
}

const startLearning = (deck) => {
  router.push('/flashcards')
}

const browseDeck = (deck) => {
  console.log('Browse deck:', deck)
}

const createDeck = () => {
  showCreateDeckDialog.value = false
  newDeckForm.value = { name: '', category: '', description: '' }
}

const formatDate = (dateStr) => {
  const date = new Date(dateStr)
  return date.toLocaleDateString('zh-CN', { month: 'short', day: 'numeric' })
}
</script>

<style lang="scss" scoped>
.vocabulary-page {
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
  font-size: 1rem;
}

.header-actions {
  display: flex;
  gap: $spacing-sm;
}

// Stats Overview
.stats-overview {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: $spacing-lg;
  margin-bottom: $spacing-xl;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: $spacing-md;
  background: white;
  padding: $spacing-lg;
  border-radius: $radius-lg;
  border: 1px solid $border-light;
  box-shadow: $shadow-sm;
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: $radius-lg;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;

  &.total {
    background: rgba($primary, 0.1);
    color: $primary;
  }

  &.mastered {
    background: rgba($success, 0.1);
    color: $success;
  }

  &.learning {
    background: rgba($warning, 0.1);
    color: $warning;
  }

  &.review {
    background: rgba($danger, 0.1);
    color: $danger;
  }
}

.stat-info {
  .stat-value {
    font-size: 1.75rem;
    font-weight: 700;
    color: $text-primary;
  }

  .stat-label {
    font-size: 0.875rem;
    color: $text-secondary;
  }
}

// Decks Section
.decks-section {
  margin-bottom: $spacing-xl;
}

.section-title {
  font-family: $font-display;
  font-size: 1.25rem;
  font-weight: 600;
  color: $text-primary;
  margin-bottom: $spacing-lg;
}

.decks-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: $spacing-lg;
}

.deck-card {
  background: white;
  border-radius: $radius-lg;
  border: 1px solid $border-light;
  padding: $spacing-lg;
  cursor: pointer;
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

    &:hover {
      border-color: $primary;
      background: rgba($primary, 0.05);
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

.deck-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: $spacing-md;
}

.deck-icon {
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

.deck-content {
  margin-bottom: $spacing-md;
}

.deck-name {
  font-family: $font-display;
  font-size: 1.125rem;
  font-weight: 600;
  color: $text-primary;
  margin-bottom: 4px;
}

.deck-category {
  font-size: 0.875rem;
  color: $text-tertiary;
  margin-bottom: $spacing-sm;
}

.deck-stats {
  display: flex;
  gap: $spacing-md;
  font-size: 0.875rem;

  .card-count {
    color: $text-secondary;
  }

  .review-count {
    display: flex;
    align-items: center;
    gap: 4px;
    color: $danger;

    .el-icon {
      font-size: 14px;
    }
  }
}

.deck-progress {
  margin-bottom: $spacing-md;
}

.deck-actions {
  display: flex;
  gap: $spacing-sm;
}

// Recent Words Section
.recent-words-section {
  background: white;
  border-radius: $radius-lg;
  border: 1px solid $border-light;
  padding: $spacing-lg;
}

.words-table {
  :deep(.el-table) {
    .el-table__header {
      th {
        background: $bg-secondary;
        font-weight: 600;
      }
    }
  }
}

.word-cell {
  display: flex;
  flex-direction: column;

  .word-term {
    font-weight: 600;
    color: $text-primary;
  }

  .word-pronunciation {
    font-size: 0.75rem;
    color: $text-tertiary;
  }
}

.meaning-cell {
  display: flex;
  align-items: center;
  gap: $spacing-sm;

  .word-meaning {
    color: $text-primary;
  }
}

.source-text {
  font-size: 0.875rem;
  color: $text-secondary;
}

// Responsive
@media (max-width: 1024px) {
  .stats-overview {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .stats-overview {
    grid-template-columns: 1fr;
  }

  .decks-grid {
    grid-template-columns: 1fr;
  }
}
</style>
