<template>
  <Modal @close="$emit('close')">
    <div class="p-6">
      <div class="text-center">
        <ExclamationTriangleIcon class="mx-auto h-12 w-12 text-red-500" />
        <h3 class="mt-4 text-lg font-medium text-foreground-primary dark:text-foreground-primary-dark">
          Delete {{ itemType }}
        </h3>
        <p class="mt-2 text-sm text-foreground-secondary dark:text-foreground-secondary-dark">
          Are you sure you want to delete this {{ itemType.toLowerCase() }}? This action cannot be undone.
        </p>
      </div>
      <div class="mt-6 flex justify-end space-x-3">
        <button
          type="button"
          class="px-4 py-2 text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md"
          @click="$emit('close')"
        >
          Cancel
        </button>
        <button
          type="button"
          class="px-4 py-2 text-sm font-medium text-white bg-red-600 hover:bg-red-700 rounded-md"
          @click="$emit('confirm')"
        >
          Delete
        </button>
      </div>
    </div>
  </Modal>
</template>

<script setup>
import { ExclamationTriangleIcon } from '@heroicons/vue/24/outline'
import Modal from './Modal.vue'

defineProps({
  itemType: {
    type: String,
    required: true
  }
})

defineEmits(['close', 'confirm'])
</script>