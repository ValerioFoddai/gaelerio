```vue
<template>
  <div class="space-y-6">
    <!-- Loading State -->
    <div v-if="categoriesStore.loading" class="text-center py-4">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
    </div>

    <!-- Error State -->
    <div v-else-if="categoriesStore.error" class="text-red-600 text-center py-4">
      {{ categoriesStore.error }}
    </div>

    <!-- Categories List -->
    <CategoryList v-else />
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useExpenseCategoriesStore } from '../../stores/expenseCategories'
import CategoryList from '../../components/categories/CategoryList.vue'

const categoriesStore = useExpenseCategoriesStore()

onMounted(async () => {
  await categoriesStore.fetchCategories()
})
</script>
```