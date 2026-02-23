<template>
  <div class="ai-assistant-page">
    <div class="chat-container">
      <!-- Chat Header -->
      <div class="chat-header">
        <div class="header-info">
          <div class="ai-avatar">
            <el-icon><MagicStick /></el-icon>
          </div>
          <div class="header-text">
            <h1>Henry</h1>
            <p>基于您的案例库提供智能回答</p>
          </div>
        </div>
        <div class="header-actions">
          <el-button text @click="clearChat">
            <el-icon><Delete /></el-icon>
            清空对话
          </el-button>
          <el-button text>
            <el-icon><Setting /></el-icon>
            设置
          </el-button>
        </div>
      </div>

      <!-- Chat Messages -->
      <div class="chat-messages" ref="messagesRef">
        <div 
          v-for="(message, index) in aiStore.messages" 
          :key="index"
          class="message"
          :class="message.role"
        >
          <div class="message-avatar">
            <el-icon v-if="message.role === 'assistant'"><MagicStick /></el-icon>
            <el-icon v-else><UserFilled /></el-icon>
          </div>
          <div class="message-content">
            <div class="message-text" v-html="formatMessage(message.content)"></div>
            <div class="message-time">{{ formatTime(message.timestamp) }}</div>
          </div>
        </div>

        <!-- Loading Indicator -->
        <div v-if="aiStore.isLoading" class="message assistant loading">
          <div class="message-avatar">
            <el-icon><MagicStick /></el-icon>
          </div>
          <div class="message-content">
            <div class="typing-indicator">
              <span></span>
              <span></span>
              <span></span>
            </div>
          </div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="quick-actions">
        <el-button
          v-for="action in aiStore.quickActions"
          :key="action.label"
          size="small"
          class="quick-action-btn"
          @click="sendQuickAction(action.label)"
        >
          <el-icon><component :is="action.icon" /></el-icon>
          {{ action.label }}
        </el-button>
      </div>

      <!-- Chat Input -->
      <div class="chat-input-area">
        <div class="input-wrapper">
          <el-input
            v-model="inputMessage"
            type="textarea"
            :rows="2"
            placeholder="输入您的问题..."
            resize="none"
            @keydown.enter.prevent="sendMessage"
          />
          <div class="input-actions">
            <el-button text>
              <el-icon><Paperclip /></el-icon>
            </el-button>
            <el-button
              type="primary"
              :disabled="!inputMessage.trim() || aiStore.isLoading"
              @click="sendMessage"
            >
              <el-icon><Promotion /></el-icon>
              发送
            </el-button>
          </div>
        </div>
        <p class="input-hint">AI 回答仅供参考，请以权威法律资料为准</p>
      </div>
    </div>

    <!-- Sidebar -->
    <div class="chat-sidebar">
      <div class="sidebar-section">
        <h3>对话历史</h3>
        <div class="history-list">
          <div class="history-item active">
            <el-icon><ChatDotRound /></el-icon>
            <span>当前对话</span>
          </div>
          <div class="history-item">
            <el-icon><ChatDotRound /></el-icon>
            <span>合同法问题</span>
          </div>
          <div class="history-item">
            <el-icon><ChatDotRound /></el-icon>
            <span>侵权法分析</span>
          </div>
        </div>
      </div>

      <div class="sidebar-section">
        <h3>相关案例</h3>
        <div class="related-cases">
          <div class="related-case">
            <span class="case-name">Smith v. Jones</span>
            <el-tag size="small">合同法</el-tag>
          </div>
          <div class="related-case">
            <span class="case-name">Hadley v. Baxendale</span>
            <el-tag size="small">损害赔偿</el-tag>
          </div>
          <div class="related-case">
            <span class="case-name">Donoghue v. Stevenson</span>
            <el-tag size="small">侵权法</el-tag>
          </div>
        </div>
      </div>

      <div class="sidebar-section">
        <h3>常用词汇</h3>
        <div class="related-vocab">
          <el-tag 
            v-for="word in relatedWords" 
            :key="word"
            class="vocab-tag"
            effect="plain"
          >
            {{ word }}
          </el-tag>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick, watch } from 'vue'
import { useAIStore } from '@/stores'

const aiStore = useAIStore()

const messagesRef = ref(null)
const inputMessage = ref('')

const relatedWords = ['precedent', 'jurisdiction', 'negligence', 'consideration', 'breach']

const formatMessage = (content) => {
  // Simple markdown-like formatting
  return content
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\n/g, '<br>')
}

const formatTime = (timestamp) => {
  return new Date(timestamp).toLocaleTimeString('zh-CN', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

const sendMessage = async () => {
  const message = inputMessage.value.trim()
  if (!message || aiStore.isLoading) return

  inputMessage.value = ''
  await aiStore.sendMessage(message)

  // Scroll to bottom
  nextTick(() => {
    if (messagesRef.value) {
      messagesRef.value.scrollTop = messagesRef.value.scrollHeight
    }
  })
}

// 监听消息变化，自动滚动到底部
watch(() => aiStore.messages.length, () => {
  nextTick(() => {
    if (messagesRef.value) {
      messagesRef.value.scrollTop = messagesRef.value.scrollHeight
    }
  })
})

const sendQuickAction = (action) => {
  inputMessage.value = action
  sendMessage()
}

const clearChat = () => {
  aiStore.clearMessages()
}
</script>

<style lang="scss" scoped>
.ai-assistant-page {
  display: flex;
  height: calc(100vh - 140px);
  gap: $spacing-lg;
}

.chat-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: white;
  border-radius: $radius-lg;
  border: 1px solid $border-light;
  overflow: hidden;
}

// Chat Header
.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: $spacing-lg;
  border-bottom: 1px solid $border-light;
}

.header-info {
  display: flex;
  align-items: center;
  gap: $spacing-md;
}

.ai-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: linear-gradient(135deg, $primary 0%, $primary-dark 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.header-text {
  h1 {
    font-family: $font-display;
    font-size: 1.25rem;
    font-weight: 600;
    margin: 0 0 4px 0;
  }

  p {
    color: $text-secondary;
    margin: 0;
    font-size: 0.875rem;
  }
}

.header-actions {
  display: flex;
  gap: $spacing-sm;
}

// Chat Messages
.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: $spacing-lg;
  display: flex;
  flex-direction: column;
  gap: $spacing-lg;
}

.message {
  display: flex;
  gap: $spacing-md;
  max-width: 80%;

  &.user {
    align-self: flex-end;
    flex-direction: row-reverse;

    .message-avatar {
      background: $bg-tertiary;
      color: $text-secondary;
    }

    .message-content {
      background: $primary;
      color: white;

      .message-time {
        color: rgba(white, 0.7);
      }
    }
  }

  &.assistant {
    align-self: flex-start;

    .message-avatar {
      background: rgba($primary, 0.1);
      color: $primary;
    }

    .message-content {
      background: $bg-secondary;
    }
  }

  &.loading {
    .message-content {
      padding: $spacing-md $spacing-lg;
    }
  }
}

.message-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.message-content {
  padding: $spacing-md;
  border-radius: $radius-lg;
  max-width: 100%;
}

.message-text {
  line-height: 1.6;

  :deep(strong) {
    font-weight: 600;
  }
}

.message-time {
  font-size: 0.75rem;
  margin-top: $spacing-xs;
  opacity: 0.7;
}

// Typing Indicator
.typing-indicator {
  display: flex;
  gap: 4px;

  span {
    width: 8px;
    height: 8px;
    background: $text-tertiary;
    border-radius: 50%;
    animation: typing 1.4s infinite;

    &:nth-child(2) {
      animation-delay: 0.2s;
    }

    &:nth-child(3) {
      animation-delay: 0.4s;
    }
  }
}

@keyframes typing {
  0%, 60%, 100% {
    transform: translateY(0);
  }
  30% {
    transform: translateY(-10px);
  }
}

// Quick Actions
.quick-actions {
  display: flex;
  gap: $spacing-sm;
  padding: 0 $spacing-lg $spacing-md;
  flex-wrap: wrap;
}

.quick-action-btn {
  background: $bg-secondary;
  border-color: $border-light;

  &:hover {
    background: $bg-tertiary;
    border-color: $primary;
    color: $primary;
  }
}

// Chat Input
.chat-input-area {
  padding: $spacing-lg;
  border-top: 1px solid $border-light;
}

.input-wrapper {
  display: flex;
  gap: $spacing-sm;
  align-items: flex-end;

  .el-textarea {
    flex: 1;

    :deep(.el-textarea__inner) {
      background: $bg-secondary;
      border-color: $border-light;
      resize: none;

      &:focus {
        border-color: $primary;
      }
    }
  }
}

.input-actions {
  display: flex;
  gap: $spacing-xs;
}

.input-hint {
  font-size: 0.75rem;
  color: $text-tertiary;
  margin: $spacing-sm 0 0 0;
  text-align: center;
}

// Sidebar
.chat-sidebar {
  width: 280px;
  display: flex;
  flex-direction: column;
  gap: $spacing-lg;
}

.sidebar-section {
  background: white;
  border-radius: $radius-lg;
  border: 1px solid $border-light;
  padding: $spacing-lg;

  h3 {
    font-family: $font-display;
    font-size: 1rem;
    font-weight: 600;
    margin: 0 0 $spacing-md 0;
    color: $text-primary;
  }
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: $spacing-xs;
}

.history-item {
  display: flex;
  align-items: center;
  gap: $spacing-sm;
  padding: $spacing-sm;
  border-radius: $radius-md;
  cursor: pointer;
  color: $text-secondary;
  font-size: 0.875rem;

  &:hover, &.active {
    background: $bg-secondary;
    color: $primary;
  }

  .el-icon {
    font-size: 16px;
  }
}

.related-cases {
  display: flex;
  flex-direction: column;
  gap: $spacing-sm;
}

.related-case {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: $spacing-sm;
  background: $bg-secondary;
  border-radius: $radius-md;

  .case-name {
    font-size: 0.875rem;
    color: $text-primary;
  }
}

.related-vocab {
  display: flex;
  flex-wrap: wrap;
  gap: $spacing-xs;
}

.vocab-tag {
  cursor: pointer;

  &:hover {
    color: $primary;
    border-color: $primary;
  }
}

// Responsive
@media (max-width: 1024px) {
  .chat-sidebar {
    display: none;
  }
}
</style>
