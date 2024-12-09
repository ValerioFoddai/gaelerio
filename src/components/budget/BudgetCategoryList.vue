<template>
  <div class="divide-y divide-gray-200 dark:divide-gray-700">
    <template v-for="category in categories" :key="category.id">
      <!-- Main category row -->
      <BudgetCategoryRow
        :category="category"
        :budget="getBudgetForCategory(category.id)"
        @update-budget="amount => handleBudgetUpdate(category.id, null, amount)"
      />
      
      <!-- Subcategory rows -->
      <BudgetSubcategoryRow
        v-for="subcategory in category.expense_subcategories"
        :key="subcategory.id"
        :subcategory="subcategory"
        :budget="getBudgetForSubcategory(category.id, subcategory.id)"
        @update-budget="amount => handleBudgetUpdate(category.id, subcategory.id, amount)"
      />
    </template>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import BudgetCategoryRow from './BudgetCategoryRow.vue'
import BudgetSubcategoryRow from './BudgetSubcategoryRow.vue'

const props = defineProps({
  categories: {
    type: Array,
    required: true
  },
  budgets: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update-budget'])

const getBudgetForCategory = (categoryId) => {
  return props.budgets.find(b => 
    b.expense_category_id === categoryId && 
    !b.expense_subcategory_id
  )
}

const getBudgetForSubcategory = (categoryId, subcategoryId) => {
  return props.budgets.find(b => 
    b.expense_category_id === categoryId && 
    b.expense_subcategory_id === subcategoryId
  )
}

const handleBudgetUpdate = (categoryId, subcategoryId, amount) => {
  emit('update-budget', { 
    categoryId, 
    subcategoryId,
    amount 
  })
}
</script>