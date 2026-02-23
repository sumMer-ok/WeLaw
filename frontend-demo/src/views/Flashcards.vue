<template>
  <div class="flashcards-page">
    <!-- Study Header -->
    <div class="study-header">
      <div class="header-left">
        <el-button text @click="$router.push('/vocabulary')">
          <el-icon><ArrowLeft /></el-icon>
          返回词汇库
        </el-button>
        <div class="study-info">
          <h1>闪卡学习</h1>
          <p>合同法词汇 · 第 {{ currentIndex + 1 }} / {{ totalCards }} 张</p>
        </div>
      </div>
      <div class="study-progress">
        <el-progress 
          :percentage="studyProgress" 
          :stroke-width="8"
          color="#8B4513"
          class="progress-bar"
        />
        <span class="progress-text">{{ studyProgress }}%</span>
      </div>
    </div>

    <!-- Flashcard Container -->
    <div class="flashcard-container">
      <div 
        class="flashcard"
        :class="{ 'flipped': isFlipped, 'animate-in': animateIn }"
        @click="flipCard"
      >
        <!-- Front -->
        <div class="card-face card-front">
          <div class="card-content">
            <div class="card-header">
              <el-tag size="small" effect="plain">{{ currentCard.tags[0] }}</el-tag>
              <el-button text @click.stop="speakWord">
                <el-icon><Microphone /></el-icon>
              </el-button>
            </div>
            <div class="word-section">
              <h2 class="word-term">{{ currentCard.term }}</h2>
              <p class="word-pronunciation">{{ currentCard.pronunciation }}</p>
            </div>
            <div class="card-hint">
              <el-icon><InfoFilled /></el-icon>
              <span>点击卡片查看释义</span>
            </div>
          </div>
        </div>

        <!-- Back -->
        <div class="card-face card-back">
          <div class="card-content">
            <div class="meaning-section">
              <h3 class="meaning-title">中文释义</h3>
              <p class="meaning-text">{{ currentCard.meaning }}</p>
            </div>
            <div class="definition-section">
              <h3 class="definition-title">英文定义</h3>
              <p class="definition-text">{{ currentCard.definition }}</p>
            </div>
            <div class="example-section">
              <h3 class="example-title">例句</h3>
              <p class="example-text">"{{ currentCard.example }}"</p>
              <p class="example-source">— {{ currentCard.source }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Navigation Arrows -->
      <button class="nav-arrow prev" @click="prevCard" :disabled="currentIndex === 0">
        <el-icon><ArrowLeft /></el-icon>
      </button>
      <button class="nav-arrow next" @click="nextCard" :disabled="currentIndex === totalCards - 1">
        <el-icon><ArrowRight /></el-icon>
      </button>
    </div>

    <!-- Rating Buttons (shown after flip) -->
    <div v-if="isFlipped" class="rating-section animate-slide-up">
      <p class="rating-label">您掌握了这个词吗？</p>
      <div class="rating-buttons">
        <el-button class="rating-btn again" @click="rateCard('again')">
          <span class="btn-label">再次</span>
          <span class="btn-interval">&lt; 1m</span>
        </el-button>
        <el-button class="rating-btn hard" @click="rateCard('hard')">
          <span class="btn-label">困难</span>
          <span class="btn-interval">2d</span>
        </el-button>
        <el-button class="rating-btn good" @click="rateCard('good')">
          <span class="btn-label">良好</span>
          <span class="btn-interval">4d</span>
        </el-button>
        <el-button class="rating-btn easy" @click="rateCard('easy')">
          <span class="btn-label">简单</span>
          <span class="btn-interval">7d</span>
        </el-button>
      </div>
    </div>

    <!-- Flip Hint (shown before flip) -->
    <div v-else class="flip-hint">
      <el-icon><Pointer /></el-icon>
      <span>点击卡片翻转</span>
    </div>

    <!-- Keyboard Shortcuts -->
    <div class="shortcuts-hint">
      <span class="shortcut"><kbd>Space</kbd> 翻转</span>
      <span class="shortcut"><kbd>1-4</kbd> 评分</span>
      <span class="shortcut"><kbd>← →</kbd> 切换</span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useVocabStore } from '@/stores'

const vocabStore = useVocabStore()

// State
const currentIndex = ref(0)
const isFlipped = ref(false)
const animateIn = ref(true)
const totalCards = ref(20)

// Mock cards data
const cards = ref([
  {
    term: 'precedent',
    pronunciation: '/ˈpresɪdənt/',
    meaning: '先例；判例',
    definition: 'An earlier event or action that is regarded as an example or guide to be considered in subsequent similar circumstances.',
    example: 'This case could serve as a precedent for future employment disputes.',
    source: 'Brown v. Board of Education (1954)',
    tags: ['判例法', '基础术语']
  },
  {
    term: 'jurisdiction',
    pronunciation: '/ˌdʒʊərɪsˈdɪkʃn/',
    meaning: '管辖权；司法权',
    definition: 'The official power to make legal decisions and judgments.',
    example: 'The court has jurisdiction over all criminal matters in this district.',
    source: 'Smith v. Jones (2024)',
    tags: ['程序法', '基础术语']
  },
  {
    term: 'negligence',
    pronunciation: '/ˈneɡlɪdʒəns/',
    meaning: '过失；疏忽',
    definition: 'Failure to take proper care in doing something, resulting in damage or injury to another.',
    example: 'The defendant was found liable for negligence in maintaining the premises.',
    source: 'Donoghue v. Stevenson (1932)',
    tags: ['侵权法', '核心概念']
  }
])

// Computed
const currentCard = computed(() => cards.value[currentIndex.value] || cards.value[0])
const studyProgress = computed(() => Math.round((currentIndex.value / totalCards.value) * 100))

// Methods
const flipCard = () => {
  isFlipped.value = !isFlipped.value
}

const nextCard = () => {
  if (currentIndex.value < totalCards.value - 1) {
    animateIn.value = false
    setTimeout(() => {
      currentIndex.value++
      isFlipped.value = false
      animateIn.value = true
    }, 150)
  }
}

const prevCard = () => {
  if (currentIndex.value > 0) {
    animateIn.value = false
    setTimeout(() => {
      currentIndex.value--
      isFlipped.value = false
      animateIn.value = true
    }, 150)
  }
}

const rateCard = (rating) => {
  console.log('Rated card:', rating)
  nextCard()
}

const speakWord = () => {
  // Text to speech
  const utterance = new SpeechSynthesisUtterance(currentCard.value.term)
  utterance.lang = 'en-US'
  speechSynthesis.speak(utterance)
}

// Keyboard shortcuts
const handleKeydown = (e) => {
  if (e.code === 'Space') {
    e.preventDefault()
    flipCard()
  } else if (e.key === 'ArrowRight') {
    nextCard()
  } else if (e.key === 'ArrowLeft') {
    prevCard()
  } else if (isFlipped.value && ['1', '2', '3', '4'].includes(e.key)) {
    const ratings = ['again', 'hard', 'good', 'easy']
    rateCard(ratings[parseInt(e.key) - 1])
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown)
})
</script>

<style lang="scss" scoped>
.flashcards-page {
  max-width: 900px;
  margin: 0 auto;
  height: calc(100vh - 140px);
  display: flex;
  flex-direction: column;
}

// Study Header
.study-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-xl;
  padding-bottom: $spacing-lg;
  border-bottom: 1px solid $border-light;
}

.header-left {
  display: flex;
  align-items: center;
  gap: $spacing-lg;
}

.study-info {
  h1 {
    font-family: $font-display;
    font-size: 1.5rem;
    font-weight: 600;
    color: $text-primary;
    margin: 0 0 4px 0;
  }

  p {
    color: $text-secondary;
    margin: 0;
  }
}

.study-progress {
  display: flex;
  align-items: center;
  gap: $spacing-md;

  .progress-bar {
    width: 200px;
  }

  .progress-text {
    font-weight: 600;
    color: $text-primary;
    min-width: 40px;
  }
}

// Flashcard Container
.flashcard-container {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  perspective: 1000px;
}

.flashcard {
  width: 600px;
  height: 400px;
  position: relative;
  transform-style: preserve-3d;
  transition: transform 0.6s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;

  &.flipped {
    transform: rotateY(180deg);
  }

  &.animate-in {
    animation: cardIn 0.3s ease-out;
  }
}

@keyframes cardIn {
  from {
    opacity: 0;
    transform: translateX(30px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.card-face {
  position: absolute;
  width: 100%;
  height: 100%;
  backface-visibility: hidden;
  background: white;
  border-radius: $radius-xl;
  border: 1px solid $border-light;
  box-shadow: $shadow-lg;
  padding: $spacing-xl;
}

.card-front {
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.card-back {
  transform: rotateY(180deg);
  overflow-y: auto;
}

.card-content {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-lg;
}

.word-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
}

.word-term {
  font-family: $font-display;
  font-size: 3rem;
  font-weight: 700;
  color: $text-primary;
  margin: 0 0 $spacing-md 0;
}

.word-pronunciation {
  font-size: 1.25rem;
  color: $text-tertiary;
  font-style: italic;
  margin: 0;
}

.card-hint {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: $spacing-xs;
  color: $text-tertiary;
  font-size: 0.875rem;
  padding-top: $spacing-lg;
  border-top: 1px solid $border-light;
}

// Card Back Content
.meaning-section,
.definition-section,
.example-section {
  margin-bottom: $spacing-lg;

  &:last-child {
    margin-bottom: 0;
  }
}

.meaning-title,
.definition-title,
.example-title {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: $text-tertiary;
  margin-bottom: $spacing-sm;
}

.meaning-text {
  font-size: 1.5rem;
  font-weight: 600;
  color: $primary;
  margin: 0;
}

.definition-text {
  font-size: 1rem;
  line-height: 1.6;
  color: $text-primary;
  margin: 0;
}

.example-text {
  font-family: $font-display;
  font-size: 1rem;
  font-style: italic;
  color: $text-secondary;
  line-height: 1.6;
  margin: 0 0 $spacing-xs 0;
}

.example-source {
  font-size: 0.875rem;
  color: $text-tertiary;
  margin: 0;
}

// Navigation Arrows
.nav-arrow {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 48px;
  height: 48px;
  border-radius: 50%;
  border: none;
  background: white;
  box-shadow: $shadow-md;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: $text-secondary;
  transition: all $transition-fast;

  &:hover:not(:disabled) {
    background: $primary;
    color: white;
  }

  &:disabled {
    opacity: 0.3;
    cursor: not-allowed;
  }

  &.prev {
    left: -80px;
  }

  &.next {
    right: -80px;
  }

  .el-icon {
    font-size: 20px;
  }
}

// Rating Section
.rating-section {
  margin-top: $spacing-xl;
  text-align: center;
}

.rating-label {
  color: $text-secondary;
  margin-bottom: $spacing-md;
}

.rating-buttons {
  display: flex;
  justify-content: center;
  gap: $spacing-md;
}

.rating-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: $spacing-md $spacing-lg;
  min-width: 100px;
  border-radius: $radius-lg;
  border: 2px solid transparent;
  transition: all $transition-fast;

  .btn-label {
    font-size: 1rem;
    font-weight: 600;
    margin-bottom: 4px;
  }

  .btn-interval {
    font-size: 0.75rem;
    opacity: 0.8;
  }

  &.again {
    background: rgba($danger, 0.1);
    color: $danger;
    border-color: $danger;

    &:hover {
      background: $danger;
      color: white;
    }
  }

  &.hard {
    background: rgba($warning, 0.1);
    color: $warning;
    border-color: $warning;

    &:hover {
      background: $warning;
      color: white;
    }
  }

  &.good {
    background: rgba($primary, 0.1);
    color: $primary;
    border-color: $primary;

    &:hover {
      background: $primary;
      color: white;
    }
  }

  &.easy {
    background: rgba($success, 0.1);
    color: $success;
    border-color: $success;

    &:hover {
      background: $success;
      color: white;
    }
  }
}

// Flip Hint
.flip-hint {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: $spacing-sm;
  margin-top: $spacing-xl;
  color: $text-tertiary;

  .el-icon {
    font-size: 18px;
  }
}

// Shortcuts Hint
.shortcuts-hint {
  display: flex;
  justify-content: center;
  gap: $spacing-lg;
  margin-top: $spacing-xl;
  padding-top: $spacing-lg;
  border-top: 1px solid $border-light;

  .shortcut {
    display: flex;
    align-items: center;
    gap: $spacing-xs;
    font-size: 0.875rem;
    color: $text-tertiary;

    kbd {
      background: $bg-secondary;
      border: 1px solid $border-medium;
      border-radius: $radius-sm;
      padding: 2px 8px;
      font-family: monospace;
      font-size: 0.75rem;
    }
  }
}

// Responsive
@media (max-width: 768px) {
  .flashcard {
    width: 100%;
    height: 350px;
  }

  .nav-arrow {
    display: none;
  }

  .word-term {
    font-size: 2rem;
  }

  .rating-buttons {
    flex-wrap: wrap;
  }

  .rating-btn {
    min-width: 80px;
    padding: $spacing-sm $spacing-md;
  }
}
</style>
