<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark">
    <Navigation />
    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <h1 class="text-2xl font-semibold text-foreground-primary dark:text-foreground-primary-dark">
          Welcome {{ profileStore.profile?.display_name || 'there' }}
        </h1>
        <div class="mt-6 bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow p-6">
          <p class="text-foreground-secondary dark:text-foreground-secondary-dark">
            Assets dashboard content will be implemented here.
          </p>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useProfileStore } from '../stores/profile'
import Navigation from '../components/Navigation.vue'

const { t } = useI18n()
const profileStore = useProfileStore()

onMounted(async () => {
  try {
    await profileStore.fetchProfile()
  } catch (error) {
    console.error('Error fetching profile:', error)
  }
})
</script>