<template>
  <header class="top-bar">
    <div class="search-box">
      <el-icon class="search-icon"><Search /></el-icon>
      <input 
        type="text" 
        placeholder="搜索案例、笔记、词汇... (Ctrl+K)" 
        class="search-input"
      />
      <span class="search-shortcut">⌘K</span>
    </div>

    <div class="top-bar-actions">
      <el-tooltip content="通知" placement="bottom">
        <button class="action-btn">
          <el-icon><Bell /></el-icon>
          <span class="notification-dot"></span>
        </button>
      </el-tooltip>

      <el-tooltip content="设置" placement="bottom">
        <button class="action-btn">
          <el-icon><Setting /></el-icon>
        </button>
      </el-tooltip>

      <el-dropdown trigger="click">
        <button class="action-btn user-btn">
          <el-avatar :size="32" :icon="UserFilled" />
        </button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item>个人资料</el-dropdown-item>
            <el-dropdown-item>学习统计</el-dropdown-item>
            <el-dropdown-item divided>退出登录</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </header>
</template>

<script setup>
// Top bar component with search and user actions
</script>

<style lang="scss" scoped>
.top-bar {
  height: 64px;
  background: white;
  border-bottom: 1px solid $border-light;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 $spacing-lg;
  position: sticky;
  top: 0;
  z-index: $z-sticky;
}

.search-box {
  position: relative;
  width: 400px;
  max-width: 100%;

  .search-icon {
    position: absolute;
    left: $spacing-md;
    top: 50%;
    transform: translateY(-50%);
    color: $text-tertiary;
    font-size: 18px;
  }

  .search-input {
    width: 100%;
    height: 40px;
    padding: 0 $spacing-xl 0 44px;
    border: 1px solid $border-light;
    border-radius: $radius-lg;
    background: $bg-secondary;
    font-size: 0.875rem;
    color: $text-primary;
    transition: all $transition-fast;

    &::placeholder {
      color: $text-tertiary;
    }

    &:focus {
      outline: none;
      border-color: $primary;
      background: white;
    }
  }

  .search-shortcut {
    position: absolute;
    right: $spacing-md;
    top: 50%;
    transform: translateY(-50%);
    font-size: 0.75rem;
    color: $text-tertiary;
    background: white;
    padding: 2px 6px;
    border-radius: $radius-sm;
    border: 1px solid $border-light;
  }
}

.top-bar-actions {
  display: flex;
  align-items: center;
  gap: $spacing-sm;
}

.action-btn {
  position: relative;
  width: 40px;
  height: 40px;
  border: none;
  background: transparent;
  border-radius: $radius-md;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: $text-secondary;
  transition: all $transition-fast;

  &:hover {
    background: $bg-secondary;
    color: $text-primary;
  }

  .el-icon {
    font-size: 20px;
  }

  &.user-btn {
    padding: 0;
    overflow: hidden;
  }
}

.notification-dot {
  position: absolute;
  top: 8px;
  right: 8px;
  width: 8px;
  height: 8px;
  background: $danger;
  border-radius: 50%;
  border: 2px solid white;
}
</style>
