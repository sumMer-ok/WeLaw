<template>
  <div class="mindmap-page">
    <div class="mindmap-header">
      <div class="header-left">
        <el-button text @click="$router.push('/study-sets')">
          <el-icon><ArrowLeft /></el-icon>
          返回学习集
        </el-button>
        <h1>思维导图</h1>
      </div>
      <div class="header-actions">
        <el-button-group>
          <el-button text @click="zoomOut">
            <el-icon><ZoomOut /></el-icon>
          </el-button>
          <el-button text @click="zoomIn">
            <el-icon><ZoomIn /></el-icon>
          </el-button>
          <el-button text @click="resetView">
            <el-icon><FullScreen /></el-icon>
          </el-button>
        </el-button-group>
        <el-button type="primary" @click="exportMap">
          <el-icon><Download /></el-icon>
          导出
        </el-button>
      </div>
    </div>

    <div class="mindmap-container">
      <div class="mindmap-canvas" ref="canvasRef">
        <!-- Root Node -->
        <div class="node root-node" :style="rootNodeStyle">
          <div class="node-content">
            <span class="node-label">合同法</span>
          </div>
        </div>

        <!-- Level 1 Nodes -->
        <div 
          v-for="(node, index) in level1Nodes" 
          :key="node.id"
          class="node level1-node"
          :style="getLevel1Style(index)"
        >
          <div class="node-content">
            <span class="node-label">{{ node.label }}</span>
          </div>
          <svg class="connection-line" :style="getLineStyle(index)">
            <line 
              :x1="rootNodeStyle.left + 60" 
              :y1="rootNodeStyle.top + 25"
              :x2="getLevel1Style(index).left + 60" 
              :y2="getLevel1Style(index).top + 25"
              stroke="#8B4513"
              stroke-width="2"
            />
          </svg>
        </div>

        <!-- Level 2 Nodes -->
        <div 
          v-for="(node, index) in level2Nodes" 
          :key="node.id"
          class="node level2-node"
          :style="getLevel2Style(node.parentIndex, node.childIndex)"
        >
          <div class="node-content">
            <span class="node-label">{{ node.label }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Legend -->
    <div class="mindmap-legend">
      <div class="legend-item">
        <span class="legend-color root"></span>
        <span>根节点</span>
      </div>
      <div class="legend-item">
        <span class="legend-color concept"></span>
        <span>概念</span>
      </div>
      <div class="legend-item">
        <span class="legend-color case"></span>
        <span>案例</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const canvasRef = ref(null)
const zoom = ref(1)

const rootNodeStyle = computed(() => ({
  left: '400px',
  top: '300px'
}))

const level1Nodes = ref([
  { id: '1', label: '对价', type: 'concept' },
  { id: '2', label: '违约', type: 'concept' },
  { id: '3', label: '救济', type: 'concept' }
])

const level2Nodes = ref([
  { id: '1-1', label: 'Currie v. Misa', type: 'case', parentIndex: 0, childIndex: 0 },
  { id: '1-2', label: '充分性', type: 'concept', parentIndex: 0, childIndex: 1 },
  { id: '2-1', label: 'Smith v. Jones', type: 'case', parentIndex: 1, childIndex: 0 },
  { id: '2-2', label: '根本违约', type: 'concept', parentIndex: 1, childIndex: 1 },
  { id: '3-1', label: '损害赔偿', type: 'concept', parentIndex: 2, childIndex: 0 },
  { id: '3-2', label: 'Hadley案', type: 'case', parentIndex: 2, childIndex: 1 }
])

const getLevel1Style = (index) => {
  const angles = [0, 120, 240]
  const radius = 200
  const angle = (angles[index] * Math.PI) / 180
  const left = 400 + radius * Math.cos(angle)
  const top = 300 + radius * Math.sin(angle)
  return { left: `${left}px`, top: `${top}px` }
}

const getLevel2Style = (parentIndex, childIndex) => {
  const parentStyle = getLevel1Style(parentIndex)
  const parentLeft = parseInt(parentStyle.left)
  const parentTop = parseInt(parentStyle.top)
  const offsetX = childIndex === 0 ? -120 : 120
  const offsetY = 80
  return { left: `${parentLeft + offsetX}px`, top: `${parentTop + offsetY}px` }
}

const getLineStyle = (index) => ({
  position: 'absolute',
  left: 0,
  top: 0,
  width: '100%',
  height: '100%',
  pointerEvents: 'none',
  zIndex: -1
})

const zoomIn = () => {
  zoom.value = Math.min(zoom.value + 0.1, 2)
}

const zoomOut = () => {
  zoom.value = Math.max(zoom.value - 0.1, 0.5)
}

const resetView = () => {
  zoom.value = 1
}

const exportMap = () => {
  console.log('Export mind map')
}
</script>

<style lang="scss" scoped>
.mindmap-page {
  height: calc(100vh - 64px);
  display: flex;
  flex-direction: column;
}

.mindmap-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: $spacing-md $spacing-lg;
  background: white;
  border-bottom: 1px solid $border-light;

  .header-left {
    display: flex;
    align-items: center;
    gap: $spacing-lg;

    h1 {
      font-family: $font-display;
      font-size: 1.25rem;
      font-weight: 600;
      margin: 0;
    }
  }

  .header-actions {
    display: flex;
    gap: $spacing-sm;
  }
}

.mindmap-container {
  flex: 1;
  overflow: auto;
  background: $bg-secondary;
  position: relative;
}

.mindmap-canvas {
  width: 1200px;
  height: 800px;
  position: relative;
  margin: $spacing-lg;
  background: white;
  border-radius: $radius-lg;
  box-shadow: $shadow-sm;
}

.node {
  position: absolute;
  transform: translate(-50%, -50%);

  .node-content {
    padding: $spacing-sm $spacing-md;
    background: white;
    border: 2px solid $border-medium;
    border-radius: $radius-lg;
    box-shadow: $shadow-sm;
    cursor: pointer;
    transition: all $transition-fast;

    &:hover {
      box-shadow: $shadow-md;
      border-color: $primary;
    }
  }

  .node-label {
    font-weight: 500;
    color: $text-primary;
  }

  &.root-node {
    .node-content {
      background: $primary;
      border-color: $primary;

      .node-label {
        color: white;
        font-weight: 600;
      }
    }
  }

  &.level1-node {
    .node-content {
      background: rgba($primary, 0.1);
      border-color: $primary;
    }
  }

  &.level2-node {
    .node-content {
      background: white;
      border-color: $border-medium;
    }
  }
}

.connection-line {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.mindmap-legend {
  position: fixed;
  bottom: $spacing-lg;
  left: $spacing-lg;
  background: white;
  padding: $spacing-md;
  border-radius: $radius-md;
  box-shadow: $shadow-md;
  display: flex;
  gap: $spacing-lg;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: $spacing-xs;
  font-size: 0.875rem;
  color: $text-secondary;
}

.legend-color {
  width: 16px;
  height: 16px;
  border-radius: $radius-sm;

  &.root {
    background: $primary;
  }

  &.concept {
    background: rgba($primary, 0.1);
    border: 2px solid $primary;
  }

  &.case {
    background: white;
    border: 2px solid $border-medium;
  }
}
</style>
