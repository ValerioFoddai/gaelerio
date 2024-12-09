<template>
  <div>
    <!-- Modal Backdrop -->
    <div class="fixed inset-0 bg-black bg-opacity-50 transition-opacity z-40"></div>

    <!-- Modal Content -->
    <div class="fixed inset-0 z-50 overflow-y-auto">
      <div class="flex min-h-full items-center justify-center p-4">
        <div 
          class="bg-background-default dark:bg-background-default-dark w-full max-w-md rounded-lg shadow-xl"
          @click.stop
        >
          <slot></slot>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted } from 'vue'

const emit = defineEmits(['close'])

// Handle escape key
function handleEscape(e) {
  if (e.key === 'Escape') {
    emit('close')
  }
}

onMounted(() => {
  document.addEventListener('keydown', handleEscape)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleEscape)
})
</script>