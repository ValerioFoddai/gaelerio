<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark">
    <Navigation />
    
    <main class="max-w-3xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
      <!-- Breadcrumb -->
      <nav class="flex mb-8" aria-label="Breadcrumb">
        <ol class="flex items-center space-x-2">
          <li>
            <router-link 
              to="/transactions" 
              class="text-foreground-secondary dark:text-foreground-secondary-dark hover:text-foreground-primary dark:hover:text-foreground-primary-dark"
            >
              {{ t('nav.transactions') }}
            </router-link>
          </li>
          <li>
            <ChevronRightIcon class="h-5 w-5 text-gray-400" aria-hidden="true" />
          </li>
          <li>
            <span class="text-foreground-primary dark:text-foreground-primary-dark">
              {{ t('transactions.new.title') }}
            </span>
          </li>
        </ol>
      </nav>

      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-2xl font-semibold text-foreground-primary dark:text-foreground-primary-dark">
          {{ t('transactions.new.title') }}
        </h1>
        <p class="mt-2 text-sm text-foreground-secondary dark:text-foreground-secondary-dark">
          {{ t('transactions.new.description') }}
        </p>
      </div>

      <!-- Form -->
      <div class="bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow p-6">
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
      </div>
    </main>

    <!-- Toast -->
    <Toast ref="toast" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { ChevronRightIcon } from '@heroicons/vue/24/outline'
import Navigation from '../../components/Navigation.vue'
import Toast from '../../components/common/Toast.vue'
import { useTransactionsStore } from '../../stores/transactions'
import { useExpenseCategoriesStore } from '../../stores/expenseCategories'

const router = useRouter()
const { t } = useI18n()
const transactionsStore = useTransactionsStore()
const categoriesStore = useExpenseCategoriesStore()

const formData = ref({
  date: new Date().toISOString().slice(0, 16),
  description: '',
  amount: '',
  categoryId: '',
  subcategoryId: ''
})

const error = ref('')
const saving = ref(false)
const toast = ref(null)

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

async function handleSubmit() {
  if (!isFormValid.value) return
  
  try {
    saving.value = true
    error.value = ''

    await transactionsStore.createTransaction({
      categoryId: formData.value.categoryId,
      subcategoryId: formData.value.subcategoryId || null,
      amount: parseFloat(formData.value.amount),
      description: formData.value.description,
      date: new Date(formData.value.date).toISOString()
    })

    toast.value.addToast('Transaction created successfully', 'success')
    router.push('/transactions')
  } catch (err) {
    error.value = t('transactions.new.error')
    console.error('Error creating transaction:', err)
  } finally {
    saving.value = false
  }
}

onMounted(async () => {
  await categoriesStore.fetchCategories()
})
</script>
```