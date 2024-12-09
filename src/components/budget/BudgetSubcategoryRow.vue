<template>
  <div class="grid grid-cols-5 px-4 py-3 bg-gray-50 dark:bg-gray-800 pl-8">
    <div class="text-sm text-foreground-secondary dark:text-foreground-secondary-dark">
      {{ subcategory.name }}
    </div>
    <div class="text-right">
      <input
        type="number"
        v-model="budgetAmount"
        @input="handleInput"
        @blur="handleBlur"
        class="w-24 px-2 py-1 bg-background-default dark:bg-background-default-dark border border-gray-300 dark:border-gray-700 rounded text-right text-sm"
      />
    </div>
    <div class="text-right text-sm">
      {{ formatAmount(spentAmount) }}
    </div>
    <div class="text-right text-sm" :class="availableClass">
      {{ formatAmount(availableAmount) }}
    </div>
    <div class="text-right text-sm">
      {{ formatAmount(0) }} <!-- Previous balance to be implemented -->
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { formatAmount } from '@/utils/formatters'
import { debounce } from '@/utils/debounce'

const props = defineProps({
  subcategory: {
    type: Object,
    required: true
  },
  budget: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['update-budget'])

const budgetAmount = ref(props.budget?.allocated_amount || 0)
const spentAmount = computed(() => props.budget?.spent_amount || 0)
const availableAmount = computed(() => budgetAmount.value - spentAmount.value)

const availableClass = computed(() => {
  return {
    'text-green-600': availableAmount.value > 0,
    'text-red-600': availableAmount.value < 0
  }
})

// Debounced save function
const debouncedSave = debounce((value) => {
  emit('update-budget', parseFloat(value) || 0)
}, 500)

const handleInput = (event) => {
  const value = event.target.value
  debouncedSave(value)
}

const handleBlur = () => {
  emit('update-budget', parseFloat(budgetAmount.value) || 0)
}
</script>