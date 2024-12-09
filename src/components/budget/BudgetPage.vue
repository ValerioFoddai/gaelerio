<template>
  <div class="budget-page">
    <div v-if="budgetStore.loading" class="text-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
      <p class="mt-4 text-foreground-secondary dark:text-foreground-secondary-dark">
        Loading budget data...
      </p>
    </div>

    <div v-else-if="budgetStore.error" class="text-center py-12 text-red-600">
      {{ budgetStore.error }}
    </div>

    <div v-else>
      <BudgetHeader
        v-model="selectedMonth"
        @change="fetchBudgets"
      />

      <BudgetTable
        :categories="budgetStore.categories"
        :budgets="budgetStore.budgets"
        @update-budget="handleBudgetUpdate"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { useBudgetStore } from '@/stores/budget'
import BudgetHeader from './BudgetHeader.vue'
import BudgetTable from './BudgetTable.vue'

const userStore = useUserStore()
const budgetStore = useBudgetStore()
const selectedMonth = ref(new Date().toISOString().slice(0, 7)) // YYYY-MM format

const fetchBudgets = async () => {
  await budgetStore.fetchBudgets(userStore.user.id, selectedMonth.value)
}

const handleBudgetUpdate = async ({ categoryId, amount }) => {
  try {
    await budgetStore.updateBudget({
      userId: userStore.user.id,
      categoryId,
      month: selectedMonth.value,
      amount
    })
  } catch (error) {
    // Error is already handled in the store
  }
}

onMounted(async () => {
  await userStore.fetchUser()
  await Promise.all([
    budgetStore.fetchCategories(),
    fetchBudgets()
  ])
})
</script>

<style scoped>
.budget-page {
  @apply p-8;
}
</style>