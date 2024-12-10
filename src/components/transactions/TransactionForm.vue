<template>
  <form @submit.prevent="handleSubmit" class="space-y-6">
    <!-- Date -->
    <div>
      <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-1">
        {{ t('transactions.date') }} <span class="text-red-500">*</span>
      </label>
      <input
        type="datetime-local"
        v-model="formData.date"
        class="w-full px-3 py-2 bg-background-default dark:bg-background-default-dark border border-gray-300 dark:border-gray-700 rounded-md shadow-sm text-foreground-primary dark:text-foreground-primary-dark"
        required
      />
    </div>

    <!-- Description -->
    <div>
      <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-1">
        {{ t('transactions.description') }} <span class="text-red-500">*</span>
      </label>
      <input
        type="text"
        v-model="formData.description"
        class="w-full px-3 py-2 bg-background-default dark:bg-background-default-dark border border-gray-300 dark:border-gray-700 rounded-md shadow-sm text-foreground-primary dark:text-foreground-primary-dark"
        required
      />
    </div>

    <!-- Amount -->
    <div>
      <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-1">
        {{ t('transactions.amount') }} <span class="text-red-500">*</span>
      </label>
      <div class="relative">
        <span class="absolute inset-y-0 left-0 pl-3 flex items-center text-foreground-secondary dark:text-foreground-secondary-dark">
          €
        </span>
        <input
          type="number"
          v-model="formData.amount"
          step="0.01"
          class="w-full pl-8 pr-3 py-2 bg-background-default dark:bg-background-default-dark border border-gray-300 dark:border-gray-700 rounded-md shadow-sm text-foreground-primary dark:text-foreground-primary-dark"
          required
        />
      </div>
    </div>

    <!-- Category -->
    <div>
      <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-1">
        {{ t('transactions.category') }} <span class="text-red-500">*</span>
      </label>
      <select
        v-model="formData.categoryId"
        class="w-full px-3 py-2 bg-background-default dark:bg-background-default-dark border border-gray-300 dark:border-gray-700 rounded-md shadow-sm text-foreground-primary dark:text-foreground-primary-dark"
        required
      >
        <option value="">{{ t('transactions.selectCategory') }}</option>
        <option
          v-for="category in categoriesStore.mainCategories"
          :key="category.id"
          :value="category.id"
        >
          {{ category.name }}
        </option>
      </select>
    </div>

    <!-- Subcategory -->
    <div v-if="formData.categoryId && subcategories.length > 0">
      <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-1">
        {{ t('transactions.subcategory') }}
      </label>
      <select
        v-model="formData.subcategoryId"
        class="w-full px-3 py-2 bg-background-default dark:bg-background-default-dark border border-gray-300 dark:border-gray-700 rounded-md shadow-sm text-foreground-primary dark:text-foreground-primary-dark"
      >
        <option value="">{{ t('transactions.selectSubcategory') }}</option>
        <option
          v-for="subcategory in subcategories"
          :key="subcategory.id"
          :value="subcategory.id"
        >
          {{ subcategory.name }}
        </option>
      </select>
    </div>

    <!-- Error message -->
    <div v-if="error" class="text-red-600 text-sm">
      {{ error }}
    </div>

    <!-- Form actions -->
    <div class="flex justify-end space-x-3 pt-6">
      <router-link
        to="/transactions"
        class="px-4 py-2 text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md"
      >
        {{ t('common.cancel') }}
      </router-link>
      <button
        type="submit"
        :disabled="!isFormValid || saving"
        class="btn-primary"
      >
        {{ saving ? t('common.saving') : t('common.create') }}
      </button>
    </div>
  </form>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useExpenseCategoriesStore } from '../../stores/expenseCategories'

const props = defineProps({
  saving: Boolean,
  error: String
})

const emit = defineEmits(['submit'])
const { t } = useI18n()
const categoriesStore = useExpenseCategoriesStore()

const formData = ref({
  date: new Date().toISOString().slice(0, 16),
  description: '',
  amount: '',
  categoryId: '',
  subcategoryId: ''
})

const subcategories = computed(() => {
  if (!formData.value.categoryId) return []
  return categoriesStore.getSubcategoriesByMainId(formData.value.categoryId)
})

const isFormValid = computed(() => {
  return (
    formData.value.date &&
    formData.value.description &&
    formData.value.amount > 0 &&
    formData.value.categoryId
  )
})

function handleSubmit() {
  if (!isFormValid.value) return
  emit('submit', {
    date: new Date(formData.value.date).toISOString(),
    description: formData.value.description,
    amount: parseFloat(formData.value.amount),
    categoryId: formData.value.categoryId,
    subcategoryId: formData.value.subcategoryId || null
  })
}
</script>