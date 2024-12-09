<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark">
    <Navigation />
    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <div class="max-w-3xl mx-auto">
          <h1 class="text-2xl font-semibold text-foreground-primary dark:text-foreground-primary-dark mb-6">
            {{ t('profile.title') }}
          </h1>

          <div class="bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow p-6">
            <form @submit.prevent="updateProfile" class="space-y-6">
              <!-- Display Name -->
              <div>
                <label for="displayName" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
                  {{ t('profile.displayName') }} <span class="text-red-500">*</span>
                </label>
                <div class="mt-1">
                  <input
                    id="displayName"
                    v-model="displayName"
                    type="text"
                    required
                    :class="[
                      'appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm bg-background-default dark:bg-background-default-dark',
                      formErrors.displayName ? 'border-red-500' : 'border-gray-300'
                    ]"
                    @blur="validateField('displayName')"
                  />
                  <p v-if="formErrors.displayName" class="mt-1 text-sm text-red-600">
                    {{ formErrors.displayName }}
                  </p>
                </div>
              </div>

              <!-- Email -->
              <div>
                <label for="email" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
                  {{ t('auth.email') }}
                </label>
                <div class="mt-1">
                  <input
                    id="email"
                    v-model="email"
                    type="email"
                    disabled
                    class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 bg-gray-100 dark:bg-gray-700 text-gray-500 dark:text-gray-400 cursor-not-allowed sm:text-sm"
                  />
                  <p class="mt-1 text-sm text-foreground-tertiary dark:text-foreground-tertiary-dark">
                    {{ t('profile.emailNotEditable') }}
                  </p>
                </div>
              </div>

              <!-- Error/Success Messages -->
              <div v-if="error" class="text-red-600 text-sm">
                {{ error }}
              </div>
              <div v-if="success" class="text-green-600 text-sm">
                {{ success }}
              </div>

              <!-- Submit Button -->
              <div>
                <button
                  type="submit"
                  :disabled="loading || hasErrors"
                  class="btn-primary w-full"
                >
                  {{ t('profile.update') }}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '../stores/auth'
import { useProfileStore } from '../stores/profile'
import Navigation from '../components/Navigation.vue'

const { t } = useI18n()
const authStore = useAuthStore()
const profileStore = useProfileStore()

const displayName = ref('')
const email = ref('')
const error = ref('')
const success = ref('')
const loading = ref(false)
const formErrors = ref({
  displayName: ''
})

const hasErrors = computed(() => {
  return Object.values(formErrors.value).some(error => error !== '')
})

onMounted(async () => {
  try {
    loading.value = true
    const profile = await profileStore.fetchProfile()
    if (profile) {
      displayName.value = profile.display_name || ''
      email.value = authStore.user?.email || ''
    }
  } catch (err) {
    console.error('Error loading profile:', err)
    error.value = t('profile.error.fetch')
  } finally {
    loading.value = false
  }
})

function validateField(field) {
  formErrors.value[field] = ''
  
  if (field === 'displayName' && !displayName.value.trim()) {
    formErrors.value.displayName = t('profile.error.displayNameRequired')
  }
}

function validateForm() {
  validateField('displayName')
  return !hasErrors.value
}

async function updateProfile() {
  try {
    if (!validateForm()) return

    error.value = ''
    success.value = ''
    loading.value = true

    await profileStore.updateProfile({
      displayName: displayName.value.trim()
    })

    success.value = t('profile.success.update')
  } catch (err) {
    console.error('Error updating profile:', err)
    error.value = t('profile.error.update')
  } finally {
    loading.value = false
  }
}
</script>