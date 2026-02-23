<template>
  <div class="app-container">
    <Sidebar />
    <div class="main-content" :class="{ 'expanded': mainStore.sidebarCollapsed }">
      <TopBar />
      <main class="page-content">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </main>
    </div>
  </div>
</template>

<script setup>
import { useMainStore } from '@/stores'
import Sidebar from '@/components/layout/Sidebar.vue'
import TopBar from '@/components/layout/TopBar.vue'

const mainStore = useMainStore()
</script>

<style lang="scss" scoped>
.app-container {
  display: flex;
  min-height: 100vh;
  background: $bg-primary;
}

.main-content {
  flex: 1;
  margin-left: 260px;
  transition: margin-left 0.3s ease;
  display: flex;
  flex-direction: column;

  &.expanded {
    margin-left: 64px;
  }
}

.page-content {
  flex: 1;
  padding: $spacing-lg;
  overflow-y: auto;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
