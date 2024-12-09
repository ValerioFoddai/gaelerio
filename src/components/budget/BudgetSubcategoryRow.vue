<template>
  <div class="grid grid-cols-5 px-4 py-3 bg-gray-50 dark:bg-gray-800 pl-8">
    <div class="text-sm text-foreground-secondary dark:text-foreground-secondary-dark">
      {{ subcategory.name }}
    </div>
    <div class="text-right">
      <input
        type="number"
        v-model="budgetAmount"
        @change="updateBudget"
        class="w-24 px-2 py-1 bg-background-default dark:bg-background-default-dark border border-gray-300 dark:border-gray-700 rounded text-right text-sm"
      />
    </div>
    <div class="text-right text-sm">
      {{ formatAmount(subcategory.spent) }}
    </div>
    <div class="text-right text-sm" :class="availableClass">
      {{ formatAmount(subcategory.available) }}
    </div>
    <div class="text-right text-sm">
      {{ formatAmount(subcategory.previousBalance) }}
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { formatAmount } from '@/utils/formatters'

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

const availableClass = computed(() => {
  const available = props.subcategory.available || 0
  return {
    'text-green-600': available > 0,
    'text-red-600': available < 0
  }
})

const updateBudget = () => {
  emit('update-budget', parseFloat(budgetAmount.value) || 0)
}
</script>