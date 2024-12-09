<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark">
    <Navigation />
    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <h1 class="text-2xl font-semibold text-foreground-primary dark:text-foreground-primary-dark">
          {{ t('nav.movements') }}
        </h1>
        <div class="mt-6 bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow p-6">
          <p class="text-foreground-secondary dark:text-foreground-secondary-dark">
            Movements dashboard content will be implemented here.
          </p>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { useI18n } from 'vue-i18n'
import Navigation from '../components/Navigation.vue'

const { t } = useI18n()
</script>