<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark">
    <Navigation />
    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <!-- Header with Add Transaction button and Date Filter -->
        <div class="flex justify-between items-center mb-6">
          <div class="flex items-center space-x-4">
            <h1 class="text-2xl font-semibold text-foreground-primary dark:text-foreground-primary-dark">
              {{ t('transactions.title') }}
            </h1>
            <!-- Date Filter -->
            <div class="flex items-center space-x-2">
              <input
                type="date"
                v-model="dateRange.start"
                class="px-3 py-2 bg-background-default dark:bg-background-default-dark border border-gray-300 dark:border-gray-700 rounded-md shadow-sm text-foreground-primary dark:text-foreground-primary-dark"
              />
              <span class="text-foreground-secondary dark:text-foreground-secondary-dark">to</span>
              <input
                type="date"
                v-model="dateRange.end"
                class="px-3 py-2 bg-background-default dark:bg-background-default-dark border border-gray-300 dark:border-gray-700 rounded-md shadow-sm text-foreground-primary dark:text-foreground-primary-dark"
              />
              <button
                @click="applyDateFilter"
                class="btn-primary"
              >
                Apply
              </button>
            </div>
          </div>
          <router-link
            to="/transactions/new"
            class="btn-primary"
          >
            <PlusIcon class="h-5 w-5 mr-2" />
            {{ t('transactions.new.title') }}
          </router-link>
        </div>

        <!-- Transactions Table -->
        <div class="bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow overflow-hidden">
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
              <thead class="bg-gray-50 dark:bg-gray-800">
                <tr>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-foreground-secondary dark:text-foreground-secondary-dark uppercase tracking-wider">
                    {{ t('transactions.date') }}
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-foreground-secondary dark:text-foreground-secondary-dark uppercase tracking-wider">
                    {{ t('transactions.category') }}
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-foreground-secondary dark:text-foreground-secondary-dark uppercase tracking-wider">
                    {{ t('transactions.amount') }}
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-foreground-secondary dark:text-foreground-secondary-dark uppercase tracking-wider">
                    {{ t('transactions.description') }}
                  </th>
                  <th scope="col" class="relative px-6 py-3">
                    <span class="sr-only">Actions</span>
                  </th>
                </tr>
              </thead>
              <tbody class="bg-background-default dark:bg-background-default-dark divide-y divide-gray-200 dark:divide-gray-700">
                <tr v-if="transactionsStore.loading" class="animate-pulse">
                  <td colspan="5" class="px-6 py-4">
                    <div class="h-4 bg-gray-200 dark:bg-gray-700 rounded w-3/4"></div>
                  </td>
                </tr>
                <tr v-else-if="transactionsStore.error" class="text-red-600">
                  <td colspan="5" class="px-6 py-4">
                    {{ transactionsStore.error }}
                  </td>
                </tr>
                <tr v-else-if="!transactionsStore.transactions.length" class="text-foreground-secondary dark:text-foreground-secondary-dark">
                  <td colspan="5" class="px-6 py-4 text-center">
                    No transactions found
                  </td>
                </tr>
                <tr
                  v-for="transaction in transactionsStore.transactions"
                  :key="transaction.id"
                  class="hover:bg-gray-50 dark:hover:bg-gray-800"
                >
                  <!-- Date -->
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-foreground-primary dark:text-foreground-primary-dark">
                    {{ formatDate(transaction.date) }}
                  </td>

                  <!-- Category -->
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-foreground-primary dark:text-foreground-primary-dark">
                    {{ transaction.category?.name }}
                    <span v-if="transaction.subcategory?.name" class="text-foreground-secondary dark:text-foreground-secondary-dark">
                      / {{ transaction.subcategory.name }}
                    </span>
                  </td>

                  <!-- Amount -->
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <span :class="transaction.amount > 0 ? 'text-green-600' : 'text-red-600'">
                      {{ transaction.amount > 0 ? '+' : '' }}€{{ transaction.amount.toFixed(2) }}
                    </span>
                  </td>

                  <!-- Description -->
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-foreground-primary dark:text-foreground-primary-dark">
                    {{ transaction.description }}
                  </td>

                  <!-- Actions -->
                  <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <div class="flex items-center justify-end space-x-2">
                      <button
                        @click="handleEdit(transaction)"
                        class="p-1 text-gray-400 hover:text-gray-500"
                      >
                        <PencilIcon class="h-5 w-5" />
                      </button>
                      <button
                        @click="handleDelete(transaction)"
                        class="p-1 text-gray-400 hover:text-gray-500"
                      >
                        <TrashIcon class="h-5 w-5" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>

    <!-- Delete Confirmation Modal -->
    <Modal v-if="showDeleteModal" @close="closeDeleteModal">
      <div class="p-6">
        <div class="text-center">
          <ExclamationTriangleIcon class="mx-auto h-12 w-12 text-red-500" />
          <h3 class="mt-4 text-lg font-medium text-foreground-primary dark:text-foreground-primary-dark">
            {{ t('transactions.delete.title') }}
          </h3>
          <p class="mt-2 text-sm text-foreground-secondary dark:text-foreground-secondary-dark">
            {{ t('transactions.delete.message') }}
          </p>
        </div>
        <div class="mt-6 flex justify-end space-x-3">
          <button
            type="button"
            class="px-4 py-2 text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md"
            @click="closeDeleteModal"
          >
            {{ t('common.cancel') }}
          </button>
          <button
            type="button"
            class="px-4 py-2 text-sm font-medium text-white bg-red-600 hover:bg-red-700 rounded-md"
            @click="handleDeleteConfirm"
          >
            {{ t('common.delete') }}
          </button>
        </div>
      </div>
    </Modal>

    <!-- Toast -->
    <Toast ref="toast" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { 
  PlusIcon,
  PencilIcon,
  TrashIcon,
  ExclamationTriangleIcon
} from '@heroicons/vue/24/outline'
import Navigation from '../components/Navigation.vue'
import Modal from '../components/common/Modal.vue'
import Toast from '../components/common/Toast.vue'
import { useTransactionsStore } from '../stores/transactions'
import { useExpenseCategoriesStore } from '../stores/expenseCategories'

const router = useRouter()
const { t } = useI18n()
const transactionsStore = useTransactionsStore()
const categoriesStore = useExpenseCategoriesStore()

// Initialize date range to current month
const dateRange = ref({
  start: new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0],
  end: new Date().toISOString().split('T')[0]
})

const showDeleteModal = ref(false)
const deletingTransaction = ref(null)
const toast = ref(null)

function formatDate(dateString) {
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('default', {
    year: 'numeric',
    month: 'short',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date)
}

function handleEdit(transaction) {
  router.push(`/transactions/${transaction.id}/edit`)
}

function handleDelete(transaction) {
  deletingTransaction.value = transaction
  showDeleteModal.value = true
}

function closeDeleteModal() {
  showDeleteModal.value = false
  deletingTransaction.value = null
}

async function handleDeleteConfirm() {
  try {
    const deletedTransaction = { ...deletingTransaction.value }
    await transactionsStore.deleteTransaction(deletingTransaction.value.id)
    
    toast.value.addToast(
      'Transaction deleted',
      'error',
      async () => {
        try {
          await transactionsStore.createTransaction({
            categoryId: deletedTransaction.expense_category_id,
            subcategoryId: deletedTransaction.expense_subcategory_id,
            amount: deletedTransaction.amount,
            description: deletedTransaction.description,
            date: deletedTransaction.date
          })
          toast.value.addToast('Transaction restored', 'success')
        } catch (err) {
          toast.value.addToast('Failed to restore transaction', 'error')
        }
      }
    )
  } catch (err) {
    toast.value.addToast('Failed to delete transaction', 'error')
  } finally {
    closeDeleteModal()
  }
}

async function applyDateFilter() {
  await transactionsStore.fetchTransactions(dateRange.value.start, dateRange.value.end)
}

onMounted(async () => {
  await Promise.all([
    transactionsStore.fetchTransactions(dateRange.value.start, dateRange.value.end),
    categoriesStore.fetchCategories()
  ])
})
</script>