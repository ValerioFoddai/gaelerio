<template>
  <div class="bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow">
    <div class="grid grid-cols-5 px-4 py-3 bg-gray-50 dark:bg-gray-800 rounded-t-lg">
      <div class="text-sm font-medium text-foreground-secondary dark:text-foreground-secondary-dark">Category</div>
      <div class="text-sm font-medium text-foreground-secondary dark:text-foreground-secondary-dark text-right">Budget</div>
      <div class="text-sm font-medium text-foreground-secondary dark:text-foreground-secondary-dark text-right">Spent</div>
      <div class="text-sm font-medium text-foreground-secondary dark:text-foreground-secondary-dark text-right">Available</div>
      <div class="text-sm font-medium text-foreground-secondary dark:text-foreground-secondary-dark text-right">Previous Balance</div>
    </div>

    <BudgetCategoryList 
      :categories="categories"
      :budgets="budgets"
      @update-budget="$emit('update-budget', $event)"
    />
  </div>
</template>

<script setup>
import BudgetCategoryList from './BudgetCategoryList.vue'

defineProps({
  categories: {
    type: Array,
    required: true
  },
  budgets: {
    type: Array,
    required: true
  }
})

defineEmits(['update-budget'])
</script>