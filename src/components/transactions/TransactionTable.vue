<template>
  <div class="bg-white dark:bg-gray-800 shadow rounded-lg overflow-hidden">
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
        <thead class="bg-gray-50 dark:bg-gray-900">
          <tr>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              Date
            </th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              Description
            </th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              Amount
            </th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              Category
            </th>
            <th scope="col" class="relative px-6 py-3">
              <span class="sr-only">Actions</span>
            </th>
          </tr>
        </thead>
        <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
          <tr v-for="transaction in transactions" :key="transaction.id">
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
              {{ formatDate(transaction.date) }}
            </td>
            <td class="px-6 py-4 text-sm text-gray-900 dark:text-white">
              {{ transaction.description }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm" :class="amountClass(transaction.amount)">
              {{ transaction.amount > 0 ? '+' : '-' }}€{{ formatAmount(transaction.amount) }}
            </td>
            <td class="px-6 py-4 text-sm text-gray-900 dark:text-white">
              {{ transaction.expense_main_categories?.name }}
              <span v-if="transaction.expense_subcategories" class="text-gray-500">
                / {{ transaction.expense_subcategories.name }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <button
                @click="$emit('edit', transaction)"
                class="text-primary-600 hover:text-primary-900 mr-4"
              >
                Edit
              </button>
              <button
                @click="$emit('delete', transaction)"
                class="text-red-600 hover:text-red-900"
              >
                Delete
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { formatDate, formatAmount } from '@/utils/formatters'

defineProps({
  transactions: {
    type: Array,
    required: true
  }
})

defineEmits(['edit', 'delete'])

function amountClass(amount) {
  return {
    'text-green-600': amount > 0,
    'text-red-600': amount < 0
  }
}
</script>