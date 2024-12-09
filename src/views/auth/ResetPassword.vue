<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark flex flex-col justify-center py-12 sm:px-6 lg:px-8">
    <DarkModeToggle />

    <div class="sm:mx-auto sm:w-full sm:max-w-md">
      <h2 class="mt-6 text-center text-3xl font-bold tracking-tight text-foreground-primary dark:text-foreground-primary-dark">
        {{ t('auth.resetPassword') }}
      </h2>
    </div>

    <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
      <div class="bg-background-secondary dark:bg-background-secondary-dark py-8 px-4 shadow sm:rounded-lg sm:px-10">
        <form class="space-y-6" @submit.prevent="handleReset">
          <div>
            <label for="email" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
              {{ t('auth.email') }}
            </label>
            <div class="mt-1">
              <input
                id="email"
                v-model="email"
                type="email"
                autocomplete="email"
                required
                class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm bg-background-default dark:bg-background-default-dark"
              />
            </div>
          </div>

          <div v-if="error" class="text-red-600 text-sm">
            {{ error }}
          </div>

          <div v-if="success" class="text-green-600 text-sm">
            {{ success }}
          </div>

          <div>
            <button
              type="submit"
              :disabled="loading"
              class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50"
            >
              {{ t('auth.resetLink') }}
            </button>
          </div>

          <div class="text-center">
            <router-link to="/login" class="font-medium text-primary-600 hover:text-primary-500">
              {{ t('auth.login') }}
            </router-link>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '../../stores/auth'
import DarkModeToggle from '../../components/DarkModeToggle.vue'

const { t } = useI18n()
const authStore = useAuthStore()

const email = ref('')
const error = ref('')
const success = ref('')
const loading = ref(false)

async function handleReset() {
  try {
    error.value = ''
    success.value = ''
    loading.value = true

    await authStore.resetPassword(email.value)
    success.value = t('auth.success.reset')
  } catch (err) {
    error.value = t('auth.error.reset')
  } finally {
    loading.value = false
  }
}
</script>