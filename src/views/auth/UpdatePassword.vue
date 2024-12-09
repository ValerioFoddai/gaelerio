<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark flex flex-col justify-center py-12 sm:px-6 lg:px-8">
    <DarkModeToggle />

    <div class="sm:mx-auto sm:w-full sm:max-w-md">
      <h2 class="mt-6 text-center text-3xl font-bold tracking-tight text-foreground-primary dark:text-foreground-primary-dark">
        {{ t('auth.updatePassword') }}
      </h2>
    </div>

    <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
      <div class="bg-background-secondary dark:bg-background-secondary-dark py-8 px-4 shadow sm:rounded-lg sm:px-10">
        <form class="space-y-6" @submit.prevent="handleUpdate">
          <div>
            <label for="password" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
              {{ t('auth.password') }}
            </label>
            <div class="mt-1">
              <input
                id="password"
                v-model="password"
                type="password"
                autocomplete="new-password"
                required
                class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm bg-background-default dark:bg-background-default-dark"
              />
            </div>
            <p class="mt-2 text-sm text-foreground-tertiary dark:text-foreground-tertiary-dark">
              {{ t('auth.passwordRequirement') }}
            </p>
          </div>

          <div>
            <label for="confirmPassword" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
              {{ t('auth.confirmPassword') }}
            </label>
            <div class="mt-1">
              <input
                id="confirmPassword"
                v-model="confirmPassword"
                type="password"
                autocomplete="new-password"
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
              {{ t('auth.update') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '../../stores/auth'
import DarkModeToggle from '../../components/DarkModeToggle.vue'

const router = useRouter()
const { t } = useI18n()
const authStore = useAuthStore()

const password = ref('')
const confirmPassword = ref('')
const error = ref('')
const success = ref('')
const loading = ref(false)

async function handleUpdate() {
  try {
    error.value = ''
    success.value = ''
    loading.value = true

    // Validate password length
    if (password.value.length < 6) {
      error.value = t('auth.error.passwordLength')
      return
    }

    // Validate password match
    if (password.value !== confirmPassword.value) {
      error.value = t('auth.error.passwordMatch')
      return
    }

    await authStore.updatePassword(password.value)
    success.value = t('auth.success.update')
    setTimeout(() => {
      router.push('/login')
    }, 2000)
  } catch (err) {
    error.value = t('auth.error.update')
  } finally {
    loading.value = false
  }
}
</script>