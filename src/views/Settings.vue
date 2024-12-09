<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark">
    <Navigation />
    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <h1 class="text-2xl font-semibold text-foreground-primary dark:text-foreground-primary-dark mb-6">
          {{ t('settings.title') }}
        </h1>

        <!-- Tabs -->
        <div class="border-b border-gray-200 dark:border-gray-700">
          <nav class="-mb-px flex space-x-8" aria-label="Tabs">
            <button
              v-for="tab in tabs"
              :key="tab.id"
              @click="currentTab = tab.id"
              :class="[
                currentTab === tab.id
                  ? 'border-primary-500 text-primary-600'
                  : 'border-transparent text-foreground-secondary dark:text-foreground-secondary-dark hover:text-foreground-primary dark:hover:text-foreground-primary-dark hover:border-gray-300',
                'whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm'
              ]"
            >
              {{ tab.name }}
            </button>
          </nav>
        </div>

        <!-- Tab Content -->
        <div class="mt-6">
          <!-- General Settings -->
          <div v-if="currentTab === 'general'" class="space-y-6">
            <div class="bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow p-6">
              <h2 class="text-lg font-medium text-foreground-primary dark:text-foreground-primary-dark mb-4">
                {{ t('settings.general') }}
              </h2>
            </div>
          </div>

          <!-- Expense Categories -->
          <div v-if="currentTab === 'categories'">
            <ExpenseCategories />
          </div>

          <!-- Tags -->
          <div v-if="currentTab === 'tags'">
            <Tags />
          </div>

          <!-- Notifications -->
          <div v-if="currentTab === 'notifications'" class="space-y-6">
            <div class="bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow p-6">
              <h2 class="text-lg font-medium text-foreground-primary dark:text-foreground-primary-dark mb-4">
                {{ t('settings.notifications') }}
              </h2>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useI18n } from 'vue-i18n'
import Navigation from '../components/Navigation.vue'
import ExpenseCategories from './settings/ExpenseCategories.vue'
import Tags from './settings/Tags.vue'

const { t } = useI18n()

const tabs = computed(() => [
  { id: 'general', name: t('settings.general') },
  { id: 'categories', name: t('settings.categories.title') },
  { id: 'tags', name: t('settings.tags.title') },
  { id: 'notifications', name: t('settings.notifications') }
])

const currentTab = ref('general')
</script>