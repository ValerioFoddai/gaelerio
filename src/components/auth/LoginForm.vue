```vue
<template>
  <form @submit.prevent="handleSubmit" class="space-y-6">
    <!-- Error Alert -->
    <div v-if="error" class="p-4 bg-red-50 border border-red-400 rounded-md">
      <p class="text-sm text-red-700">{{ error }}</p>
    </div>

    <!-- Email -->
    <div>
      <label for="email" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
        {{ t('auth.email') }} <span class="text-red-500">*</span>
      </label>
      <div class="mt-1">
        <input
          id="email"
          v-model="form.email"
          type="email"
          autocomplete="email"
          required
          :class="[
            'appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm',
            'bg-background-default dark:bg-background-default-dark',
            'text-foreground-primary dark:text-foreground-primary-dark',
            'border-gray-300 dark:border-gray-700',
            formErrors.email ? 'border-red-500' : ''
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
      <div class="mt-1">
        <input
          id="password"
          v-model="form.password"
          type="password"
          autocomplete="current-password"
          required
          :class="[
            'appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm',
            'bg-background-default dark:bg-background-default-dark',
            'text-foreground-primary dark:text-foreground-primary-dark',
            'border-gray-300 dark:border-gray-700',
            formErrors.password ? 'border-red-500' : ''
          ]"
          @blur="validateField('password')"
        />
        <p v-if="formErrors.password" class="mt-1 text-sm text-red-600">
          {{ formErrors.password }}
        </p>
      </div>
    </div>

    <!-- Forgot Password Link -->
    <div class="flex items-center justify-end">
      <router-link 
        to="/reset-password"
        class="text-sm font-medium text-primary-600 hover:text-primary-500"
      >
        {{ t('auth.forgotPassword') }}
      </router-link>
    </div>

    <!-- Submit Button -->
    <div>
      <button
        type="submit"
        :disabled="loading || !isFormValid"
        class="w-full btn-primary"
      >
        {{ loading ? t('common.loading') : t('auth.login') }}
      </button>
    </div>
  </form>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { validateLoginData } from '@/utils/validation';

const props = defineProps({
  loading: Boolean,
  error: String
});

const emit = defineEmits(['submit']);
const { t } = useI18n();

const form = ref({
  email: '',
  password: ''
});

const formErrors = ref({
  email: '',
  password: ''
});

const isFormValid = computed(() => {
  return (
    !formErrors.value.email &&
    !formErrors.value.password &&
    form.value.email &&
    form.value.password
  );
});

function validateField(field: string) {
  const { errors } = validateLoginData({
    email: form.value.email,
    password: form.value.password
  });

  formErrors.value[field] = errors[field] || '';
}

function validateForm() {
  const { isValid, errors } = validateLoginData({
    email: form.value.email,
    password: form.value.password
  });

  Object.keys(formErrors.value).forEach(key => {
    formErrors.value[key] = errors[key] || '';
  });

  return isValid;
}

function handleSubmit() {
  if (!validateForm()) return;
  
  emit('submit', {
    email: form.value.email.trim(),
    password: form.value.password
  });
}
</script>
```