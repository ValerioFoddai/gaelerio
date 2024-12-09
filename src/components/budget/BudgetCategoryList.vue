<template>
  <div class="divide-y divide-gray-200 dark:divide-gray-700">
    <template v-for="category in categories" :key="category.id">
      <BudgetCategoryRow
        :category="category"
        :budget="getBudgetForCategory(category.id)"
        @update-budget="amount => $emit('update-budget', { categoryId: category.id, amount })"
      />
      
      <BudgetSubcategoryRow
        v-for="subcategory in category.subCategories"
        :key="subcategory.id"
        :subcategory="subcategory"
        :budget="getBudgetForCategory(subcategory.id)"
        @update-budget="amount => $emit('update-budget', { categoryId: subcategory.id, amount })"
      />
    </template>
  </div>
</template>

<script setup>
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

defineEmits(['update-budget'])

const getBudgetForCategory = (categoryId) => {
  return props.budgets.find(b => b.category_id === categoryId)
}
</script>