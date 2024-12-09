<template>
  <div class="grid grid-cols-5 px-4 py-3 hover:bg-gray-50 dark:hover:bg-gray-800">
    <div class="font-medium text-foreground-primary dark:text-foreground-primary-dark">
      {{ category.name }}
    </div>
    <div class="text-right">
      <input
        type="number"
        v-model="budgetAmount"
        @change="updateBudget"
        class="w-24 px-2 py-1 bg-background-default dark:bg-background-default-dark border border-gray-300 dark:border-gray-700 rounded text-right"
      />
    </div>
    <div class="text-right">
      {{ formatAmount(category.spent) }}
    </div>
    <div class="text-right" :class="availableClass">
      {{ formatAmount(category.available) }}
    </div>
    <div class="text-right">
      {{ formatAmount(category.previousBalance) }}
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { formatAmount } from '@/utils/formatters'

const props = defineProps({
  category: {
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

const availableClass = computed(() => {
  const available = props.category.available || 0
  return {
    'text-green-600': available > 0,
    'text-red-600': available < 0
  }
})

const updateBudget = () => {
  emit('update-budget', parseFloat(budgetAmount.value) || 0)
}
</script>