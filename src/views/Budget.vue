<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark">
    <Navigation />
    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <BudgetPage />
      </div>
    </main>
  </div>
</template>

<script setup>
import Navigation from '../components/Navigation.vue'
import BudgetPage from '../components/budget/BudgetPage.vue'
</script>