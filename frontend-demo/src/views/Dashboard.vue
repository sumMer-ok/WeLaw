<template>
  <div class="dashboard">
    <!-- Welcome Section -->
    <div class="welcome-section animate-slide-up">
      <div class="welcome-content">
        <h1 class="welcome-title">
          欢迎回来，{{ mainStore.user.name }}！
        </h1>
        <p class="welcome-subtitle">
          <el-icon class="fire-icon"><Fire /></el-icon>
          今天是您连续学习的第 <strong>{{ mainStore.user.streak }}</strong> 天
        </p>
      </div>
      <div class="welcome-actions">
        <el-button type="primary" size="large" class="action-primary">
          <el-icon><VideoPlay /></el-icon>
          继续学习
        </el-button>
        <el-button size="large" class="action-secondary">
          <el-icon><Plus /></el-icon>
          导入案例
        </el-button>
      </div>
    </div>

    <!-- Stats Grid -->
    <div class="stats-grid">
      <!-- Today's Learning -->
      <div class="stat-card learning-card">
        <div class="card-header">
          <h3 class="card-title">
            <el-icon><Calendar /></el-icon>
            今日学习
          </h3>
          <el-tag type="warning" effect="light">进行中</el-tag>
        </div>
        <div class="learning-stats">
          <div class="stat-item">
            <div class="stat-value">{{ vocabStore.todayStats.new }}/{{ vocabStore.todayStats.targetNew }}</div>
            <div class="stat-label">新词学习</div>
            <el-progress 
              :percentage="(vocabStore.todayStats.new / vocabStore.todayStats.targetNew) * 100" 
              :stroke-width="8"
              :show-text="false"
              color="#8B4513"
            />
          </div>
          <div class="stat-item">
            <div class="stat-value">{{ vocabStore.todayStats.review }}/{{ vocabStore.todayStats.targetReview }}</div>
            <div class="stat-label">复习词汇</div>
            <el-progress 
              :percentage="(vocabStore.todayStats.review / vocabStore.todayStats.targetReview) * 100" 
              :stroke-width="8"
              :show-text="false"
              color="#5A7D5A"
            />
          </div>
        </div>
        <div class="card-footer">
          <el-button type="primary" text>
            继续学习
            <el-icon><ArrowRight /></el-icon>
          </el-button>
        </div>
      </div>

      <!-- Learning Progress -->
      <div class="stat-card progress-card">
        <div class="card-header">
          <h3 class="card-title">
            <el-icon><TrendCharts /></el-icon>
            学习进度
          </h3>
        </div>
        <div class="progress-stats">
          <div class="progress-ring">
            <el-progress 
              type="dashboard" 
              :percentage="mainStore.learningProgress.vocab"
              :stroke-width="10"
              color="#8B4513"
              width="120"
            />
            <div class="progress-label">
              <div class="progress-value">{{ mainStore.user.masteredVocab }}</div>
              <div class="progress-text">已掌握词汇</div>
            </div>
          </div>
          <div class="progress-details">
            <div class="detail-item">
              <span class="detail-label">案例库</span>
              <span class="detail-value">{{ mainStore.user.totalCases }} 个</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">词汇量</span>
              <span class="detail-value">{{ mainStore.user.totalVocab }} 个</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">掌握率</span>
              <span class="detail-value">{{ mainStore.learningProgress.vocab }}%</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Recent Cases -->
      <div class="stat-card cases-card">
        <div class="card-header">
          <h3 class="card-title">
            <el-icon><Document /></el-icon>
            最近案例
          </h3>
          <router-link to="/cases" class="view-all">
            查看全部
            <el-icon><ArrowRight /></el-icon>
          </router-link>
        </div>
        <div class="recent-cases">
          <div 
            v-for="caseItem in recentCases" 
            :key="caseItem.id"
            class="case-item"
            @click="$router.push(`/cases/${caseItem.id}`)"
          >
            <div class="case-icon">
              <el-icon><DocumentChecked v-if="caseItem.status === '已掌握'" /><DocumentCopy v-else /></el-icon>
            </div>
            <div class="case-info">
              <div class="case-title">{{ caseItem.title }}</div>
              <div class="case-meta">
                <el-tag size="small" :type="getStatusType(caseItem.status)">{{ caseItem.status }}</el-tag>
                <span class="case-date">{{ caseItem.date }}</span>
              </div>
            </div>
            <div class="case-annotations" v-if="caseItem.annotations > 0">
              <el-icon><EditPen /></el-icon>
              {{ caseItem.annotations }}
            </div>
          </div>
        </div>
      </div>

      <!-- AI Assistant -->
      <div class="stat-card ai-card">
        <div class="card-header">
          <h3 class="card-title">
            <el-icon><ChatDotRound /></el-icon>
            AI助手
          </h3>
        </div>
        <div class="ai-content">
          <p class="ai-greeting">有什么法律问题？</p>
          <div class="quick-actions">
            <el-button 
              v-for="action in aiStore.quickActions.slice(0, 3)" 
              :key="action.label"
              class="quick-action-btn"
              @click="$router.push('/ai-assistant')"
            >
              <el-icon><component :is="action.icon" /></el-icon>
              {{ action.label }}
            </el-button>
          </div>
        </div>
        <div class="card-footer">
          <el-input 
            placeholder="快速提问..." 
            class="ai-input"
            @focus="$router.push('/ai-assistant')"
          >
            <template #suffix>
              <el-icon><ArrowRight /></el-icon>
            </template>
          </el-input>
        </div>
      </div>
    </div>

    <!-- Recommendations -->
    <div class="recommendations-section">
      <h2 class="section-title">
        <el-icon><StarFilled /></el-icon>
        今日推荐
      </h2>
      <div class="recommendations-grid">
        <div class="recommendation-card">
          <div class="rec-icon vocab">
            <el-icon><Collection /></el-icon>
          </div>
          <div class="rec-content">
            <div class="rec-title">复习词汇: "Jurisdiction"</div>
            <div class="rec-desc">您已经3天没有复习了</div>
          </div>
          <el-button type="primary" text>开始学习</el-button>
        </div>
        <div class="recommendation-card">
          <div class="rec-icon case">
            <el-icon><Document /></el-icon>
          </div>
          <div class="rec-content">
            <div class="rec-title">推荐阅读: "Carlill v. Carbolic Smoke Ball"</div>
            <div class="rec-desc">要约邀请的经典案例</div>
          </div>
          <el-button type="primary" text>查看案例</el-button>
        </div>
        <div class="recommendation-card">
          <div class="rec-icon review">
            <el-icon><Memo /></el-icon>
          </div>
          <div class="rec-content">
            <div class="rec-title">有 12 张闪卡待复习</div>
            <div class="rec-desc">预计用时: 8分钟</div>
          </div>
          <el-button type="primary" text>开始复习</el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useMainStore, useCasesStore, useVocabStore, useAIStore } from '@/stores'

const mainStore = useMainStore()
const casesStore = useCasesStore()
const vocabStore = useVocabStore()
const aiStore = useAIStore()

const recentCases = computed(() => casesStore.cases.slice(0, 3))

const getStatusType = (status) => {
  const types = {
    '已掌握': 'success',
    '学习中': 'warning',
    '待审': 'info'
  }
  return types[status] || 'info'
}
</script>

<style lang="scss" scoped>
.dashboard {
  max-width: 1400px;
  margin: 0 auto;
}

// Welcome Section
.welcome-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: linear-gradient(135deg, $primary 0%, $primary-dark 100%);
  color: white;
  padding: $spacing-xl;
  border-radius: $radius-xl;
  margin-bottom: $spacing-xl;
  box-shadow: $shadow-lg;
}

.welcome-title {
  font-family: $font-display;
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: $spacing-sm;
  color: white;
}

.welcome-subtitle {
  display: flex;
  align-items: center;
  gap: $spacing-xs;
  font-size: 1rem;
  opacity: 0.9;

  .fire-icon {
    color: #FFD700;
    font-size: 20px;
  }

  strong {
    color: #FFD700;
    font-weight: 700;
  }
}

.welcome-actions {
  display: flex;
  gap: $spacing-md;

  .action-primary {
    background: white;
    color: $primary;
    border: none;
    font-weight: 600;

    &:hover {
      background: rgba(white, 0.9);
    }
  }

  .action-secondary {
    background: rgba(white, 0.2);
    color: white;
    border: 1px solid rgba(white, 0.3);

    &:hover {
      background: rgba(white, 0.3);
    }
  }
}

// Stats Grid
.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: $spacing-lg;
  margin-bottom: $spacing-xl;
}

.stat-card {
  background: white;
  border-radius: $radius-lg;
  border: 1px solid $border-light;
  padding: $spacing-lg;
  box-shadow: $shadow-sm;
  transition: box-shadow $transition-normal;

  &:hover {
    box-shadow: $shadow-md;
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-md;
}

.card-title {
  display: flex;
  align-items: center;
  gap: $spacing-sm;
  font-family: $font-display;
  font-size: 1.125rem;
  font-weight: 600;
  color: $text-primary;
  margin: 0;

  .el-icon {
    color: $primary;
  }
}

.view-all {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.875rem;
  color: $primary;
  text-decoration: none;

  &:hover {
    text-decoration: underline;
  }
}

.card-footer {
  margin-top: $spacing-md;
  padding-top: $spacing-md;
  border-top: 1px solid $border-light;
}

// Learning Card
.learning-stats {
  display: flex;
  flex-direction: column;
  gap: $spacing-md;
}

.stat-item {
  .stat-value {
    font-size: 1.5rem;
    font-weight: 700;
    color: $text-primary;
    margin-bottom: 4px;
  }

  .stat-label {
    font-size: 0.875rem;
    color: $text-secondary;
    margin-bottom: $spacing-sm;
  }
}

// Progress Card
.progress-stats {
  display: flex;
  align-items: center;
  gap: $spacing-xl;
}

.progress-ring {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;

  .progress-label {
    position: absolute;
    text-align: center;

    .progress-value {
      font-size: 1.75rem;
      font-weight: 700;
      color: $text-primary;
    }

    .progress-text {
      font-size: 0.75rem;
      color: $text-secondary;
    }
  }
}

.progress-details {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: $spacing-sm;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: $spacing-sm 0;
  border-bottom: 1px solid $border-light;

  &:last-child {
    border-bottom: none;
  }

  .detail-label {
    font-size: 0.875rem;
    color: $text-secondary;
  }

  .detail-value {
    font-size: 0.875rem;
    font-weight: 600;
    color: $text-primary;
  }
}

// Cases Card
.recent-cases {
  display: flex;
  flex-direction: column;
  gap: $spacing-sm;
}

.case-item {
  display: flex;
  align-items: center;
  gap: $spacing-sm;
  padding: $spacing-sm;
  border-radius: $radius-md;
  cursor: pointer;
  transition: background $transition-fast;

  &:hover {
    background: $bg-secondary;
  }
}

.case-icon {
  width: 40px;
  height: 40px;
  border-radius: $radius-md;
  background: $bg-secondary;
  display: flex;
  align-items: center;
  justify-content: center;
  color: $primary;
  flex-shrink: 0;
}

.case-info {
  flex: 1;
  min-width: 0;
}

.case-title {
  font-weight: 500;
  color: $text-primary;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  margin-bottom: 4px;
}

.case-meta {
  display: flex;
  align-items: center;
  gap: $spacing-sm;

  .case-date {
    font-size: 0.75rem;
    color: $text-tertiary;
  }
}

.case-annotations {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.75rem;
  color: $text-tertiary;
  padding: 2px 8px;
  background: $bg-secondary;
  border-radius: $radius-sm;
}

// AI Card
.ai-content {
  margin-bottom: $spacing-md;
}

.ai-greeting {
  font-size: 1rem;
  color: $text-secondary;
  margin-bottom: $spacing-md;
}

.quick-actions {
  display: flex;
  flex-wrap: wrap;
  gap: $spacing-sm;
}

.quick-action-btn {
  background: $bg-secondary;
  border: 1px solid $border-light;
  color: $text-secondary;
  font-size: 0.75rem;

  &:hover {
    background: $bg-tertiary;
    color: $text-primary;
  }

  .el-icon {
    margin-right: 4px;
  }
}

.ai-input {
  :deep(.el-input__wrapper) {
    background: $bg-secondary;
    box-shadow: none;
    border: 1px solid $border-light;

    &:hover, &:focus {
      border-color: $primary;
    }
  }
}

// Recommendations Section
.recommendations-section {
  margin-top: $spacing-xl;
}

.section-title {
  display: flex;
  align-items: center;
  gap: $spacing-sm;
  font-family: $font-display;
  font-size: 1.25rem;
  font-weight: 600;
  color: $text-primary;
  margin-bottom: $spacing-lg;

  .el-icon {
    color: $warning;
  }
}

.recommendations-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: $spacing-lg;
}

.recommendation-card {
  display: flex;
  align-items: center;
  gap: $spacing-md;
  background: white;
  padding: $spacing-lg;
  border-radius: $radius-lg;
  border: 1px solid $border-light;
  box-shadow: $shadow-sm;
  transition: all $transition-normal;

  &:hover {
    box-shadow: $shadow-md;
    transform: translateY(-2px);
  }
}

.rec-icon {
  width: 48px;
  height: 48px;
  border-radius: $radius-lg;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  flex-shrink: 0;

  &.vocab {
    background: rgba($primary, 0.1);
    color: $primary;
  }

  &.case {
    background: rgba($info, 0.1);
    color: $info;
  }

  &.review {
    background: rgba($success, 0.1);
    color: $success;
  }
}

.rec-content {
  flex: 1;
  min-width: 0;
}

.rec-title {
  font-weight: 600;
  color: $text-primary;
  margin-bottom: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.rec-desc {
  font-size: 0.875rem;
  color: $text-secondary;
}

// Responsive
@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }

  .recommendations-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .welcome-section {
    flex-direction: column;
    text-align: center;
    gap: $spacing-lg;
  }

  .progress-stats {
    flex-direction: column;
    text-align: center;
  }
}
</style>
