<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark flex flex-col justify-center py-12 sm:px-6 lg:px-8">
    <DarkModeToggle />
    
    <div class="sm:mx-auto sm:w-full sm:max-w-md">
      <div class="flex justify-center">
        <img class="h-12 w-auto" src="/vite.svg" alt="Logo" />
      </div>
      
      <h2 class="mt-6 text-center text-3xl font-bold tracking-tight text-foreground-primary dark:text-foreground-primary-dark">
        {{ t('auth.signIn') }}
      </h2>
      <p class="mt-2 text-center text-sm text-foreground-secondary dark:text-foreground-secondary-dark">
        {{ t('auth.noAccount') }}
        <router-link to="/register" class="font-medium text-primary-600 hover:text-primary-500">
          {{ t('auth.register') }}
        </router-link>
      </p>
    </div>

    <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
      <div class="bg-background-secondary dark:bg-background-secondary-dark py-8 px-4 shadow sm:rounded-lg sm:px-10">
        <form class="space-y-6" @submit.prevent="handleLogin">
          <div>
            <label for="email" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
              {{ t('auth.email') }} <span class="text-red-500">*</span>
            </label>
            <div class="mt-1">
              <input
                id="email"
                v-model="email"
                type="email"
                autocomplete="email"
                required
                :class="[
                  'appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm bg-background-default dark:bg-background-default-dark',
                  formErrors.email ? 'border-red-500' : 'border-gray-300'
                ]"
                @blur="validateField('email')"
                @paste="handlePaste($event, 'email')"
              />
              <p v-if="formErrors.email" class="mt-1 text-sm text-red-600">
                {{ formErrors.email }}
              </p>
            </div>
          </div>

          <div>
            <label for="password" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
              {{ t('auth.password') }} <span class="text-red-500">*</span>
            </label>
            <div class="mt-1">
              <input
                id="password"
                v-model="password"
                type="password"
                autocomplete="current-password"
                required
                :class="[
                  'appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm bg-background-default dark:bg-background-default-dark',
                  formErrors.password ? 'border-red-500' : 'border-gray-300'
                ]"
                @blur="validateField('password')"
                @paste="handlePaste($event, 'password')"
              />
              <p v-if="formErrors.password" class="mt-1 text-sm text-red-600">
                {{ formErrors.password }}
              </p>
            </div>
          </div>

          <div class="flex items-center justify-between">
            <div class="text-sm">
              <router-link to="/reset-password" class="font-medium text-primary-600 hover:text-primary-500">
                {{ t('auth.forgotPassword') }}
              </router-link>
            </div>
          </div>

          <div v-if="error" class="text-red-600 text-sm">
            {{ error }}
          </div>

          <div>
            <button
              type="submit"
              :disabled="loading || hasErrors"
              class="btn-primary w-full"
            >
              {{ t('auth.login') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '../../stores/auth'
import DarkModeToggle from '../../components/DarkModeToggle.vue'

const router = useRouter()
const { t } = useI18n()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)
const formErrors = ref({
  email: '',
  password: ''
})

const hasErrors = computed(() => {
  return Object.values(formErrors.value).some(error => error !== '')
})

function validateField(field) {
  formErrors.value[field] = ''
  
  switch (field) {
    case 'email':
      if (!email.value) {
        formErrors.value.email = 'Email is required'
      } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value)) {
        formErrors.value.email = 'Please enter a valid email address'
      }
      break
      
    case 'password':
      if (!password.value) {
        formErrors.value.password = 'Password is required'
      } else if (password.value.length < 6) {
        formErrors.value.password = t('auth.error.passwordLength')
      }
      break
  }
}

function handlePaste(event, field) {
  const text = event.clipboardData.getData('text')
  if (field === 'email') {
    email.value = text
  } else if (field === 'password') {
    password.value = text
  }
  validateField(field)
}

async function handleLogin() {
  try {
    if (!validateForm()) {
      return
    }

    error.value = ''
    loading.value = true

    await authStore.login(email.value, password.value)
    router.push('/assets')
  } catch (err) {
    error.value = t('auth.error.login')
  } finally {
    loading.value = false
  }
}

function validateForm() {
  validateField('email')
  validateField('password')
  
  return !hasErrors.value
}
</script>