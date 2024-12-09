<template>
  <TransitionGroup
    tag="div"
    enter-active-class="transition duration-300 ease-out"
    enter-from-class="transform translate-y-2 opacity-0"
    enter-to-class="transform translate-y-0 opacity-100"
    leave-active-class="transition duration-200 ease-in"
    leave-from-class="transform translate-y-0 opacity-100"
    leave-to-class="transform translate-y-2 opacity-0"
    class="fixed bottom-4 right-4 z-50 space-y-2"
  >
    <div
      v-for="toast in toasts"
      :key="toast.id"
      :class="[
        'px-4 py-3 rounded-md shadow-lg max-w-sm flex items-center justify-between gap-4',
        toast.type === 'success' ? 'bg-green-500' : 'bg-red-500'
      ]"
    >
      <span class="text-white">{{ toast.message }}</span>
      <button
        v-if="toast.undoAction"
        @click="handleUndo(toast)"
        class="px-2 py-1 text-sm font-medium text-white hover:bg-white/20 rounded transition-colors duration-200"
      >
        Undo
      </button>
    </div>
  </TransitionGroup>
</template>

<script setup>
import { ref, onUnmounted } from 'vue'
import { TransitionGroup } from 'vue'

const toasts = ref([])
let toastId = 0
const TOAST_DURATION = 5000 // 5 seconds

function addToast(message, type = 'success', undoAction = null) {
  const id = toastId++
  const toast = { id, message, type, undoAction }
  toasts.value.push(toast)
  
  setTimeout(() => {
    removeToast(id)
  }, TOAST_DURATION)
}

function removeToast(id) {
  const index = toasts.value.findIndex(t => t.id === id)
  if (index > -1) {
    toasts.value.splice(index, 1)
  }
}

function handleUndo(toast) {
  if (toast.undoAction && typeof toast.undoAction === 'function') {
    toast.undoAction()
  }
  removeToast(toast.id)
}

defineExpose({ addToast })

onUnmounted(() => {
  toasts.value = []
})
</script>