```vue
<template>
  <div class="flex flex-col sm:flex-row justify-between items-center gap-4 mb-8">
    <div class="flex items-center gap-4">
      <div class="flex items-center gap-2">
        <input
          type="date"
          v-model="dateRange.start"
          class="px-3 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-md shadow-sm"
        />
        <span class="text-gray-500">to</span>
        <input
          type="date"
          v-model="dateRange.end"
          class="px-3 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-md shadow-sm"
        />
      </div>
      <button
        @click="applyFilter"
        class="btn-primary"
      >
        Apply Filter
      </button>
    </div>
    
    <router-link
      to="/transactions/new"
      class="btn-primary"
    >
      <PlusIcon class="h-5 w-5 mr-2" />
      Add Transaction
    </router-link>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { PlusIcon } from '@heroicons/vue/24/outline'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue', 'filter'])

const dateRange = ref({
  start: props.modelValue.start,
  end: props.modelValue.end
})

watch(() => props.modelValue, (newValue) => {
  dateRange.value = { ...newValue }
}, { deep: true })

function applyFilter() {
  emit('update:modelValue', { ...dateRange.value })
  emit('filter')
}
</script>
```