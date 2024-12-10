<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full relative">
      <!-- Close Button -->
      <button
        @click="router.push('/transactions')"
        class="absolute -top-12 right-0 flex items-center text-foreground-secondary dark:text-foreground-secondary-dark hover:text-foreground-primary dark:hover:text-foreground-primary-dark"
      >
        <XMarkIcon class="h-5 w-5 mr-1" />
        Close
      </button>

      <!-- Form Header -->
      <div class="mb-8">
        <h1 class="text-2xl font-semibold text-foreground-primary dark:text-foreground-primary-dark mb-2 text-center">
          {{ t('transactions.add.title') }}
        </h1>
        <p class="text-foreground-secondary dark:text-foreground-secondary-dark text-center">
          {{ t('transactions.add.instructions') }}
        </p>
      </div>

      <!-- Form Content -->
      <form @submit.prevent="submitForm" class="space-y-6 bg-background-secondary dark:bg-background-secondary-dark rounded-lg p-6">
        <!-- Category -->
        <div>
          <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-2">
            {{ t('transactions.category') }} <span class="text-red-500">*</span>
          </label>
          <select
            v-model="formData.category_id"
            class="w-full rounded-md border border-gray-300 bg-background-default dark:bg-background-default-dark text-foreground-primary dark:text-foreground-primary-dark px-3 py-2"
            required
          >
            <option value="">Select category</option>
            <option v-for="category in categoriesStore.mainCategories" :key="category.id" :value="category.id">
              {{ category.name }}
            </option>
          </select>
        </div>

        <!-- Subcategory -->
        <div v-if="formData.category_id">
          <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-2">
            Subcategory
          </label>
          <select
            v-model="formData.subcategory_id"
            class="w-full rounded-md border border-gray-300 bg-background-default dark:bg-background-default-dark text-foreground-primary dark:text-foreground-primary-dark px-3 py-2"
          >
            <option value="">Select subcategory</option>
            <option 
              v-for="subcategory in categoriesStore.getSubcategoriesByMainId(formData.category_id)" 
              :key="subcategory.id" 
              :value="subcategory.id"
            >
              {{ subcategory.name }}
            </option>
          </select>
        </div>

        <!-- Date -->
        <div>
          <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-2">
            {{ t('transactions.date') }} <span class="text-red-500">*</span>
          </label>
          <input
            type="datetime-local"
            v-model="formData.date"
            class="w-full rounded-md border border-gray-300 bg-background-default dark:bg-background-default-dark text-foreground-primary dark:text-foreground-primary-dark px-3 py-2"
            required
          />
        </div>

        <!-- Amount -->
        <div>
          <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-2">
            {{ t('transactions.amount') }} <span class="text-red-500">*</span>
          </label>
          <input
            type="number"
            v-model="formData.amount"
            step="0.01"
            class="w-full rounded-md border border-gray-300 bg-background-default dark:bg-background-default-dark text-foreground-primary dark:text-foreground-primary-dark px-3 py-2"
            required
          />
        </div>

        <!-- Description -->
        <div>
          <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-2">
            {{ t('transactions.description') }} <span class="text-red-500">*</span>
          </label>
          <input
            type="text"
            v-model="formData.description"
            class="w-full rounded-md border border-gray-300 bg-background-default dark:bg-background-default-dark text-foreground-primary dark:text-foreground-primary-dark px-3 py-2"
            required
          />
        </div>

        <!-- Error message -->
        <div v-if="error" class="mt-4 text-red-600 text-sm">
          {{ error }}
        </div>

        <!-- Submit button -->
        <div>
          <button
            type="submit"
            class="w-full btn-primary"
            :disabled="loading || !isFormValid"
          >
            {{ t('transactions.add.submit') }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { XMarkIcon } from '@heroicons/vue/24/outline'
import { useTransactionsStore } from '../stores/transactions'
import { useExpenseCategoriesStore } from '../stores/expenseCategories'

const router = useRouter()
const { t } = useI18n()
const transactionsStore = useTransactionsStore()
const categoriesStore = useExpenseCategoriesStore()

const loading = ref(false)
const error = ref('')

const formData = ref({
  category_id: '',
  subcategory_id: '',
  date: new Date().toISOString().slice(0, 16),
  amount: '',
  description: ''
})

const isFormValid = computed(() => {
  return (
    formData.value.category_id &&
    formData.value.date &&
    formData.value.amount &&
    formData.value.description
  )
})

async function submitForm() {
  try {
    loading.value = true
    error.value = ''

    await transactionsStore.createTransaction({
      categoryId: formData.value.category_id,
      subcategoryId: formData.value.subcategory_id || null,
      amount: parseFloat(formData.value.amount),
      description: formData.value.description,
      date: new Date(formData.value.date).toISOString()
    })

    router.push('/transactions')
  } catch (err) {
    error.value = t('transactions.add.error')
    console.error('Error creating transaction:', err)
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  await categoriesStore.fetchCategories()
})
</script>
