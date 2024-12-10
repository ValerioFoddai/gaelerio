<template>
  <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-4 mb-8">
    <div class="bg-white dark:bg-gray-800 p-4 rounded-lg shadow">
      <h3 class="text-sm font-medium text-gray-500 dark:text-gray-400">Total Income</h3>
      <p class="mt-1 text-xl font-semibold text-green-600">+€{{ formatAmount(stats.totalIncome) }}</p>
    </div>
    
    <div class="bg-white dark:bg-gray-800 p-4 rounded-lg shadow">
      <h3 class="text-sm font-medium text-gray-500 dark:text-gray-400">Total Expenses</h3>
      <p class="mt-1 text-xl font-semibold text-red-600">-€{{ formatAmount(stats.totalExpenses) }}</p>
    </div>
    
    <div class="bg-white dark:bg-gray-800 p-4 rounded-lg shadow">
      <h3 class="text-sm font-medium text-gray-500 dark:text-gray-400">Balance</h3>
      <p class="mt-1 text-xl font-semibold" :class="balanceClass">
        €{{ formatAmount(stats.balance) }}
      </p>
    </div>
    
    <div class="bg-white dark:bg-gray-800 p-4 rounded-lg shadow">
      <h3 class="text-sm font-medium text-gray-500 dark:text-gray-400">Transactions</h3>
      <p class="mt-1 text-xl font-semibold text-gray-900 dark:text-white">
        {{ stats.totalTransactions }}
      </p>
    </div>
    
    <div class="bg-white dark:bg-gray-800 p-4 rounded-lg shadow">
      <h3 class="text-sm font-medium text-gray-500 dark:text-gray-400">Highest Transaction</h3>
      <p class="mt-1 text-xl font-semibold text-gray-900 dark:text-white">
        €{{ formatAmount(stats.highestAmount) }}
      </p>
    </div>
    
    <div class="bg-white dark:bg-gray-800 p-4 rounded-lg shadow">
      <h3 class="text-sm font-medium text-gray-500 dark:text-gray-400">Expense Ratio</h3>
      <p class="mt-1 text-xl font-semibold text-gray-900 dark:text-white">
        {{ stats.expenseRatio }}%
      </p>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { formatAmount } from '@/utils/formatters'

const props = defineProps({
  transactions: {
    type: Array,
    required: true
  }
})

const stats = computed(() => {
  const totalIncome = props.transactions
    .filter(t => t.amount > 0)
    .reduce((sum, t) => sum + t.amount, 0)

  const totalExpenses = props.transactions
    .filter(t => t.amount < 0)
    .reduce((sum, t) => sum + Math.abs(t.amount), 0)

  const balance = totalIncome - totalExpenses
  const highestAmount = Math.max(...props.transactions.map(t => Math.abs(t.amount)), 0)
  const expenseRatio = totalIncome ? Math.round((totalExpenses / totalIncome) * 100) : 0

  return {
    totalIncome,
    totalExpenses,
    balance,
    totalTransactions: props.transactions.length,
    highestAmount,
    expenseRatio
  }
})

const balanceClass = computed(() => ({
  'text-green-600': stats.value.balance > 0,
  'text-red-600': stats.value.balance < 0,
  'text-gray-900 dark:text-white': stats.value.balance === 0
}))
</script>