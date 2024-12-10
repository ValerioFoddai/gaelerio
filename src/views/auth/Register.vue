<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark flex flex-col justify-center py-12 sm:px-6 lg:px-8">
    <DarkModeToggle />

    <div class="sm:mx-auto sm:w-full sm:max-w-md">
      <div class="flex justify-center">
        <img class="h-12 w-auto" src="/vite.svg" alt="Logo" />
      </div>
      
      <h2 class="mt-6 text-center text-3xl font-bold tracking-tight text-foreground-primary dark:text-foreground-primary-dark">
        {{ t('auth.signUp') }}
      </h2>
      <p class="mt-2 text-center text-sm text-foreground-secondary dark:text-foreground-secondary-dark">
        {{ t('auth.hasAccount') }}
        <router-link to="/login" class="font-medium text-primary-600 hover:text-primary-500">
          {{ t('auth.login') }}
        </router-link>
      </p>
    </div>

    <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
      <div class="bg-background-secondary dark:bg-background-secondary-dark py-8 px-4 shadow sm:rounded-lg sm:px-10">
        <RegistrationForm
          :loading="loading"
          :error="error"
          @submit="handleRegister"
        />

        <!-- Social Media Sign-up -->
        <div class="mt-6">
          <div class="relative">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-gray-300"></div>
            </div>
            <div class="relative flex justify-center text-sm">
              <span class="px-2 bg-background-secondary dark:bg-background-secondary-dark text-foreground-secondary dark:text-foreground-secondary-dark">
                Or continue with
              </span>
            </div>
          </div>

          <div class="mt-6 grid grid-cols-2 gap-3">
            <button
              type="button"
              class="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm bg-background-default dark:bg-background-default-dark text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark hover:bg-gray-50"
              @click="signInWithGoogle"
            >
              <img class="h-5 w-5" src="/google.svg" alt="Google" />
              <span class="ml-2">Google</span>
            </button>

            <button
              type="button"
              class="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm bg-background-default dark:bg-background-default-dark text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark hover:bg-gray-50"
              @click="signInWithGithub"
            >
              <img class="h-5 w-5" src="/github.svg" alt="GitHub" />
              <span class="ml-2">GitHub</span>
            </button>
          </div>
        </div>
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
import RegistrationForm from '../../components/auth/RegistrationForm.vue'

const router = useRouter()
const { t } = useI18n()
const authStore = useAuthStore()

const loading = ref(false)
const error = ref('')

async function handleRegister(formData) {
  try {
    loading.value = true
    error.value = ''

    await authStore.register(formData.email, formData.password, {
      first_name: formData.firstName,
      last_name: formData.lastName
    })

    router.push('/login')
  } catch (err) {
    console.error('Registration error:', err)
    error.value = err.message || t('auth.error.register')
  } finally {
    loading.value = false
  }
}

async function signInWithGoogle() {
  try {
    await authStore.signInWithGoogle()
    router.push('/assets')
  } catch (err) {
    error.value = 'Failed to sign in with Google'
  }
}

async function signInWithGithub() {
  try {
    await authStore.signInWithGithub()
    router.push('/assets')
  } catch (err) {
    error.value = 'Failed to sign in with GitHub'
  }
}
</script>