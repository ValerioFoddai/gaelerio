```vue
<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark">
    <Navigation />
    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <h1 class="text-2xl font-semibold text-foreground-primary dark:text-foreground-primary-dark mb-6">
          {{ t('transactions.title') }}
        </h1>

        <TransactionStats :transactions="transactions" />
        
        <TransactionFilters
          v-model="dateRange"
          @filter="fetchTransactions"
        />
        
        <TransactionTable
          :transactions="transactions"
          @edit="handleEdit"
          @delete="handleDelete"
        />
      </div>
    </main>

    <EditTransactionModal
      v-if="editingTransaction"
      :transaction="editingTransaction"
      @close="editingTransaction = null"
      @success="handleEditSuccess"
    />

    <DeleteConfirmation
      v-if="showDeleteConfirmation"
      item-type="Transaction"
      @close="showDeleteConfirmation = false"
      @confirm="confirmDelete"
    />

    <Toast ref="toast" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import Navigation from '../components/Navigation.vue'
import TransactionStats from '../components/transactions/TransactionStats.vue'
import TransactionFilters from '../components/transactions/TransactionFilters.vue'
import TransactionTable from '../components/transactions/TransactionTable.vue'
import EditTransactionModal from '../components/transactions/EditTransactionModal.vue'
import DeleteConfirmation from '../components/common/DeleteConfirmation.vue'
import Toast from '../components/common/Toast.vue'
import { useTransactionsStore } from '../stores/transactions'

const { t } = useI18n()
const transactionsStore = useTransactionsStore()

const transactions = ref([])
const dateRange = ref({
  start: new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0],
  end: new Date().toISOString().split('T')[0]
})

const editingTransaction = ref(null)
const showDeleteConfirmation = ref(false)
const deletingTransaction = ref(null)
const toast = ref(null)

async function fetchTransactions() {
  try {
    await transactionsStore.fetchTransactions(dateRange.value.start, dateRange.value.end)
    transactions.value = transactionsStore.transactions
  } catch (err) {
    console.error('Error fetching transactions:', err)
    toast.value.addToast('Failed to load transactions', 'error')
  }
}

function handleEdit(transaction) {
  editingTransaction.value = transaction
}

function handleEditSuccess() {
  editingTransaction.value = null
  toast.value.addToast('Transaction updated successfully', 'success')
  fetchTransactions()
}

function handleDelete(transaction) {
  deletingTransaction.value = transaction
  showDeleteConfirmation.value = true
}

async function confirmDelete() {
  try {
    await transactionsStore.deleteTransaction(deletingTransaction.value.id)
    toast.value.addToast('Transaction deleted successfully', 'success')
    showDeleteConfirmation.value = false
    deletingTransaction.value = null
    fetchTransactions()
  } catch (err) {
    console.error('Error deleting transaction:', err)
    toast.value.addToast('Failed to delete transaction', 'error')
  }
}

onMounted(() => {
  fetchTransactions()
})
</script>
```