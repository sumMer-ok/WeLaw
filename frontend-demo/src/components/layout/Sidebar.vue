<template>
  <aside class="sidebar" :class="{ 'collapsed': mainStore.sidebarCollapsed }">
    <div class="sidebar-header">
      <div class="logo">
        <el-icon class="logo-icon"><ScaleToOriginal /></el-icon>
        <span class="logo-text" v-show="!mainStore.sidebarCollapsed">WeLaw</span>
      </div>
      <button class="collapse-btn" @click="mainStore.toggleSidebar">
        <el-icon><Fold v-if="!mainStore.sidebarCollapsed" /><Expand v-else /></el-icon>
      </button>
    </div>

    <nav class="sidebar-nav">
      <div class="nav-section">
        <router-link
          v-for="route in mainRoutes"
          :key="route.path"
          :to="route.path"
          class="nav-item"
          :class="{ 'active': $route.path === route.path }"
        >
          <el-icon class="nav-icon">
            <component :is="route.meta.icon" />
          </el-icon>
          <span class="nav-text" v-show="!mainStore.sidebarCollapsed">{{ route.meta.title }}</span>
        </router-link>
      </div>

      <div class="nav-section" v-show="!mainStore.sidebarCollapsed">
        <div class="section-title">我的学习</div>
        <router-link to="/study-sets" class="nav-item" :class="{ 'active': $route.path === '/study-sets' }">
          <el-icon class="nav-icon"><FolderOpened /></el-icon>
          <span class="nav-text">学习集</span>
          <span class="nav-badge">2</span>
        </router-link>
        <router-link to="/flashcards" class="nav-item" :class="{ 'active': $route.path === '/flashcards' }">
          <el-icon class="nav-icon"><Memo /></el-icon>
          <span class="nav-text">闪卡复习</span>
        </router-link>
      </div>

      <div class="nav-section" v-show="!mainStore.sidebarCollapsed">
        <div class="section-title">工具</div>
        <router-link to="/ai-assistant" class="nav-item" :class="{ 'active': $route.path === '/ai-assistant' }">
          <el-icon class="nav-icon"><ChatDotRound /></el-icon>
          <span class="nav-text">AI助手</span>
          <span class="nav-badge new">NEW</span>
        </router-link>
      </div>
    </nav>

    <div class="sidebar-footer" v-show="!mainStore.sidebarCollapsed">
      <div class="user-info">
        <el-avatar :size="32" :icon="UserFilled" class="user-avatar" />
        <div class="user-details">
          <div class="user-name">{{ mainStore.user.name }}</div>
          <div class="user-streak">
            <el-icon><Fire /></el-icon>
            <span>连续学习 {{ mainStore.user.streak }} 天</span>
          </div>
        </div>
      </div>
    </div>
  </aside>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useMainStore } from '@/stores'
import router from '@/router'

const mainStore = useMainStore()
const currentRoute = useRoute()

const mainRoutes = computed(() => {
  const order = ['Dashboard', 'CaseLibrary', 'Vocabulary', 'Notes', 'FileLibrary', 'MindMap']
  return order.map(name => router.getRoutes().find(route => route.name === name)).filter(Boolean)
})
</script>

<style lang="scss" scoped>
.sidebar {
  position: fixed;
  left: 0;
  top: 0;
  bottom: 0;
  width: 260px;
  background: white;
  border-right: 1px solid $border-light;
  display: flex;
  flex-direction: column;
  z-index: $z-sticky;
  transition: width 0.3s ease;

  &.collapsed {
    width: 64px;
  }
}

.sidebar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: $spacing-md $spacing-lg;
  border-bottom: 1px solid $border-light;
  height: 64px;
}

.logo {
  display: flex;
  align-items: center;
  gap: $spacing-sm;

  .logo-icon {
    font-size: 28px;
    color: $primary;
  }

  .logo-text {
    font-family: $font-display;
    font-size: 1.5rem;
    font-weight: 700;
    color: $text-primary;
  }
}

.collapse-btn {
  background: none;
  border: none;
  color: $text-tertiary;
  cursor: pointer;
  padding: $spacing-xs;
  border-radius: $radius-sm;
  transition: all $transition-fast;

  &:hover {
    background: $bg-secondary;
    color: $text-primary;
  }
}

.sidebar-nav {
  flex: 1;
  padding: $spacing-md 0;
  overflow-y: auto;
}

.nav-section {
  margin-bottom: $spacing-lg;
}

.section-title {
  padding: $spacing-sm $spacing-lg;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: $text-tertiary;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: $spacing-sm;
  padding: $spacing-sm $spacing-lg;
  margin: 0 $spacing-sm;
  border-radius: $radius-md;
  color: $text-secondary;
  text-decoration: none;
  transition: all $transition-fast;
  position: relative;

  &:hover {
    background: $bg-secondary;
    color: $text-primary;
  }

  &.active {
    background: rgba($primary, 0.1);
    color: $primary;

    &::before {
      content: '';
      position: absolute;
      left: 0;
      top: 50%;
      transform: translateY(-50%);
      width: 3px;
      height: 20px;
      background: $primary;
      border-radius: 0 2px 2px 0;
    }
  }
}

.nav-icon {
  font-size: 20px;
  flex-shrink: 0;
}

.nav-text {
  font-size: 0.875rem;
  font-weight: 500;
  flex: 1;
}

.nav-badge {
  background: $accent;
  color: white;
  font-size: 0.625rem;
  font-weight: 600;
  padding: 2px 6px;
  border-radius: 10px;

  &.new {
    background: $danger;
  }
}

.sidebar-footer {
  padding: $spacing-md $spacing-lg;
  border-top: 1px solid $border-light;
}

.user-info {
  display: flex;
  align-items: center;
  gap: $spacing-sm;
}

.user-avatar {
  background: $primary;
  color: white;
}

.user-details {
  flex: 1;
  min-width: 0;
}

.user-name {
  font-size: 0.875rem;
  font-weight: 600;
  color: $text-primary;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.user-streak {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.75rem;
  color: $warning;
  margin-top: 2px;

  .el-icon {
    font-size: 14px;
  }
}
</style>
