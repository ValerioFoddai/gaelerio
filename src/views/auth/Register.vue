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
        <form class="space-y-6" @submit.prevent="handleRegister">
          <!-- First Name -->
          <div>
            <label for="firstName" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
              First Name <span class="text-red-500">*</span>
            </label>
            <div class="mt-1">
              <input
                id="firstName"
                v-model="firstName"
                type="text"
                required
                :class="[
                  'appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm bg-background-default dark:bg-background-default-dark',
                  formErrors.firstName ? 'border-red-500' : 'border-gray-300'
                ]"
                @blur="validateField('firstName')"
              />
              <p v-if="formErrors.firstName" class="mt-1 text-sm text-red-600">
                {{ formErrors.firstName }}
              </p>
            </div>
          </div>

          <!-- Last Name -->
          <div>
            <label for="lastName" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
              Last Name
            </label>
            <div class="mt-1">
              <input
                id="lastName"
                v-model="lastName"
                type="text"
                :class="[
                  'appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm bg-background-default dark:bg-background-default-dark',
                  formErrors.lastName ? 'border-red-500' : 'border-gray-300'
                ]"
              />
            </div>
          </div>

          <!-- Email -->
          <div>
            <label for="email" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
              {{ t('auth.email') }} <span class="text-red-500">*</span>
            </label>
            <div class="mt-1">
              <input
                id="email"
                v-model="email"
                type="email"
                required
                autocomplete="email"
                :class="[
                  'appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm bg-background-default dark:bg-background-default-dark',
                  formErrors.email ? 'border-red-500' : 'border-gray-300'
                ]"
                @blur="validateField('email')"
              />
              <p v-if="formErrors.email" class="mt-1 text-sm text-red-600">
                {{ formErrors.email }}
              </p>
            </div>
          </div>

          <!-- Password -->
          <div>
            <label for="password" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
              {{ t('auth.password') }} <span class="text-red-500">*</span>
            </label>
            <div class="mt-1 relative">
              <input
                id="password"
                v-model="password"
                :type="showPassword ? 'text' : 'password'"
                required
                autocomplete="new-password"
                :class="[
                  'appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm bg-background-default dark:bg-background-default-dark pr-10',
                  formErrors.password ? 'border-red-500' : 'border-gray-300'
                ]"
                @blur="validateField('password')"
              />
              <button
                type="button"
                class="absolute inset-y-0 right-0 pr-3 flex items-center"
                @click="showPassword = !showPassword"
              >
                <EyeIcon v-if="showPassword" class="h-5 w-5 text-gray-400" />
                <EyeSlashIcon v-else class="h-5 w-5 text-gray-400" />
              </button>
              <p v-if="formErrors.password" class="mt-1 text-sm text-red-600">
                {{ formErrors.password }}
              </p>
            </div>
          </div>

          <!-- Confirm Password -->
          <div>
            <label for="confirmPassword" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
              {{ t('auth.confirmPassword') }} <span class="text-red-500">*</span>
            </label>
            <div class="mt-1 relative">
              <input
                id="confirmPassword"
                v-model="confirmPassword"
                :type="showConfirmPassword ? 'text' : 'password'"
                required
                autocomplete="new-password"
                :class="[
                  'appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm bg-background-default dark:bg-background-default-dark pr-10',
                  formErrors.confirmPassword ? 'border-red-500' : 'border-gray-300'
                ]"
                @blur="validateField('confirmPassword')"
              />
              <button
                type="button"
                class="absolute inset-y-0 right-0 pr-3 flex items-center"
                @click="showConfirmPassword = !showConfirmPassword"
              >
                <EyeIcon v-if="showConfirmPassword" class="h-5 w-5 text-gray-400" />
                <EyeSlashIcon v-else class="h-5 w-5 text-gray-400" />
              </button>
              <p v-if="formErrors.confirmPassword" class="mt-1 text-sm text-red-600">
                {{ formErrors.confirmPassword }}
              </p>
            </div>
          </div>

          <!-- Error Messages -->
          <div v-if="error" class="text-red-600 text-sm">
            {{ error }}
          </div>

          <div>
            <button
              type="submit"
              :disabled="loading || hasErrors"
              class="btn-primary w-full"
            >
              {{ t('auth.register') }}
            </button>
          </div>
        </form>

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
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { EyeIcon, EyeSlashIcon } from '@heroicons/vue/24/outline'
import { useAuthStore } from '../../stores/auth'
import DarkModeToggle from '../../components/DarkModeToggle.vue'

const router = useRouter()
const { t } = useI18n()
const authStore = useAuthStore()

// Form fields
const firstName = ref('')
const lastName = ref('')
const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const showPassword = ref(false)
const showConfirmPassword = ref(false)

// Form state
const error = ref('')
const loading = ref(false)
const formErrors = ref({
  firstName: '',
  email: '',
  password: '',
  confirmPassword: ''
})

// Computed properties
const hasErrors = computed(() => {
  return Object.values(formErrors.value).some(error => error !== '')
})

// Methods
function validateField(field) {
  formErrors.value[field] = ''
  
  switch (field) {
    case 'firstName':
      if (!firstName.value.trim()) {
        formErrors.value.firstName = 'First name is required'
      }
      break
      
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

    case 'confirmPassword':
      if (!confirmPassword.value) {
        formErrors.value.confirmPassword = 'Confirm password is required'
      } else if (confirmPassword.value !== password.value) {
        formErrors.value.confirmPassword = t('auth.error.passwordMatch')
      }
      break
  }
}

function validateForm() {
  validateField('firstName')
  validateField('email')
  validateField('password')
  validateField('confirmPassword')
  
  return !hasErrors.value
}

async function handleRegister() {
  try {
    if (!validateForm()) return

    // Additional validation for password match
    if (password.value !== confirmPassword.value) {
      formErrors.value.confirmPassword = t('auth.error.passwordMatch')
      return
    }

    error.value = ''
    loading.value = true

    await authStore.register(email.value, password.value, {
      data: {
        first_name: firstName.value.trim(),
        last_name: lastName.value.trim()
      }
    })

    router.push('/login')
  } catch (err) {
    error.value = err.message
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