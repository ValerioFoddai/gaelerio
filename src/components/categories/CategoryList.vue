```vue
<template>
  <div class="space-y-1">
    <!-- Categories List -->
    <div v-for="category in categoriesStore.mainCategories" :key="category.id">
      <!-- Category Header -->
      <div
        class="w-full px-4 py-3 flex items-center justify-between bg-white dark:bg-[#1E1E1E] hover:bg-gray-50 dark:hover:bg-[#2E2E2E] transition-colors duration-200 cursor-pointer rounded-lg shadow-sm"
        @click="toggleCategory(category.id)"
      >
        <div class="flex items-center space-x-3">
          <component
            :is="getCategoryIcon(category.name)"
            class="h-5 w-5 text-gray-500 dark:text-gray-400"
            aria-hidden="true"
          />
          <h3 class="text-sm font-medium text-gray-900 dark:text-white">
            {{ category.name }}
          </h3>
        </div>
        <ChevronDownIcon
          class="h-4 w-4 text-gray-500 dark:text-gray-400 transition-transform duration-200"
          :class="{ 'transform rotate-180': expandedCategories.includes(category.id) }"
        />
      </div>

      <!-- Subcategories List -->
      <div
        v-show="expandedCategories.includes(category.id)"
        class="mt-1 ml-4 space-y-1"
      >
        <div
          v-for="subcategory in getSubcategoriesByMainId(category.id)"
          :key="subcategory.id"
          class="pl-8 pr-4 py-2 bg-white dark:bg-[#1E1E1E] hover:bg-gray-50 dark:hover:bg-[#2E2E2E] transition-colors duration-150 cursor-pointer rounded-md"
        >
          <span class="text-sm text-gray-700 dark:text-gray-300">{{ subcategory.name }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { 
  ChevronDownIcon,
  BanknotesIcon,
  TruckIcon,
  DocumentTextIcon,
  UserGroupIcon,
  AcademicCapIcon,
  CurrencyDollarIcon,
  ShoppingBagIcon,
  HeartIcon,
  HomeIcon,
  ArrowsRightLeftIcon,
  GlobeAltIcon,
  BuildingOfficeIcon
} from '@heroicons/vue/24/outline'
import { useExpenseCategoriesStore } from '../../stores/expenseCategories'

const categoriesStore = useExpenseCategoriesStore()
const expandedCategories = ref([])

const categoryIcons = {
  'Income': BanknotesIcon,
  'Auto & Transport': TruckIcon,
  'Bills': DocumentTextIcon,
  'Children': UserGroupIcon,
  'Education': AcademicCapIcon,
  'Financial': CurrencyDollarIcon,
  'Food': ShoppingBagIcon,
  'Health & Wellness': HeartIcon,
  'House': HomeIcon,
  'Shopping': ShoppingBagIcon,
  'Transfer': ArrowsRightLeftIcon,
  'Travel & Lifestyle': GlobeAltIcon
}

function getCategoryIcon(categoryName) {
  return categoryIcons[categoryName] || BuildingOfficeIcon
}

function toggleCategory(categoryId) {
  const index = expandedCategories.value.indexOf(categoryId)
  if (index === -1) {
    expandedCategories.value.push(categoryId)
  } else {
    expandedCategories.value.splice(index, 1)
  }
}

function getSubcategoriesByMainId(mainId) {
  return categoriesStore.getSubcategoriesByMainId(mainId)
}
</script>
```