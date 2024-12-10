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
        <TransactionForm
          :saving="saving"
          :error="error"
          @submit="handleSubmit"
        />
      </div>
    </main>

    <!-- Toast -->
    <Toast ref="toast" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { ChevronRightIcon } from '@heroicons/vue/24/outline'
import Navigation from '../../components/Navigation.vue'
import TransactionForm from '../../components/transactions/TransactionForm.vue'
import Toast from '../../components/common/Toast.vue'
import { useTransactionsStore } from '../../stores/transactions'
import { useExpenseCategoriesStore } from '../../stores/expenseCategories'

const router = useRouter()
const { t } = useI18n()
const transactionsStore = useTransactionsStore()
const categoriesStore = useExpenseCategoriesStore()

const saving = ref(false)
const error = ref('')
const toast = ref(null)

async function handleSubmit(formData) {
  try {
    saving.value = true
    error.value = ''

    await transactionsStore.createTransaction({
      date: formData.date,
      description: formData.description,
      amount: formData.amount,
      categoryId: formData.categoryId,
      subcategoryId: formData.subcategoryId
    })

    toast.value.addToast('Transaction created successfully', 'success')
    router.push('/transactions')
  } catch (err) {
    console.error('Error creating transaction:', err)
    error.value = t('transactions.new.error')
  } finally {
    saving.value = false
  }
}

onMounted(async () => {
  await categoriesStore.fetchCategories()
})
</script>