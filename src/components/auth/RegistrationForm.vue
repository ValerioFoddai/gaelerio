<template>
  <form @submit.prevent="handleSubmit" class="space-y-6">
    <!-- Error Alert -->
    <div v-if="error" class="p-4 bg-red-50 border border-red-400 rounded-md">
      <p class="text-sm text-red-700">{{ error }}</p>
    </div>

    <!-- First Name -->
    <div>
      <label for="firstName" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
        First Name <span class="text-red-500">*</span>
      </label>
      <div class="mt-1">
        <input
          id="firstName"
          v-model="form.firstName"
          type="text"
          required
          :class="[
            'appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm',
            'bg-background-default dark:bg-background-default-dark',
            'text-foreground-primary dark:text-foreground-primary-dark',
            'border-gray-300 dark:border-gray-700',
            formErrors.firstName ? 'border-red-500' : ''
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
          v-model="form.lastName"
          type="text"
          :class="[
            'appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm',
            'bg-background-default dark:bg-background-default-dark',
            'text-foreground-primary dark:text-foreground-primary-dark',
            'border-gray-300 dark:border-gray-700'
          ]"
        />
      </div>
    </div>

    <!-- Email -->
    <div>
      <label for="email" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
        Email <span class="text-red-500">*</span>
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
        Password <span class="text-red-500">*</span>
      </label>
      <div class="mt-1">
        <input
          id="password"
          v-model="form.password"
          type="password"
          autocomplete="new-password"
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

    <!-- Confirm Password -->
    <div>
      <label for="confirmPassword" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
        Confirm Password <span class="text-red-500">*</span>
      </label>
      <div class="mt-1">
        <input
          id="confirmPassword"
          v-model="form.confirmPassword"
          type="password"
          autocomplete="new-password"
          required
          :class="[
            'appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm',
            'bg-background-default dark:bg-background-default-dark',
            'text-foreground-primary dark:text-foreground-primary-dark',
            'border-gray-300 dark:border-gray-700',
            formErrors.confirmPassword ? 'border-red-500' : ''
          ]"
          @blur="validateField('confirmPassword')"
        />
        <p v-if="formErrors.confirmPassword" class="mt-1 text-sm text-red-600">
          {{ formErrors.confirmPassword }}
        </p>
      </div>
    </div>

    <!-- Submit Button -->
    <div>
      <button
        type="submit"
        :disabled="loading || !isFormValid"
        class="w-full btn-primary"
      >
        {{ loading ? t('common.saving') : t('auth.register') }}
      </button>
    </div>
  </form>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { validateRegistrationData } from '@/utils/validation';

const props = defineProps({
  loading: Boolean,
  error: String
});

const emit = defineEmits(['submit']);
const { t } = useI18n();

const form = ref({
  firstName: '',
  lastName: '',
  email: '',
  password: '',
  confirmPassword: ''
});

const formErrors = ref({
  firstName: '',
  email: '',
  password: '',
  confirmPassword: ''
});

const isFormValid = computed(() => {
  return (
    !formErrors.value.firstName &&
    !formErrors.value.email &&
    !formErrors.value.password &&
    !formErrors.value.confirmPassword &&
    form.value.firstName &&
    form.value.email &&
    form.value.password &&
    form.value.confirmPassword &&
    form.value.password === form.value.confirmPassword
  );
});

function validateField(field: string) {
  const { errors } = validateRegistrationData({
    first_name: form.value.firstName,
    last_name: form.value.lastName,
    email: form.value.email,
    password: form.value.password,
    confirmPassword: form.value.confirmPassword
  });

  formErrors.value[field] = errors[field] || '';
}

function validateForm() {
  const { isValid, errors } = validateRegistrationData({
    first_name: form.value.firstName,
    last_name: form.value.lastName,
    email: form.value.email,
    password: form.value.password,
    confirmPassword: form.value.confirmPassword
  });

  Object.keys(formErrors.value).forEach(key => {
    formErrors.value[key] = errors[key] || '';
  });

  return isValid;
}

function handleSubmit() {
  if (!validateForm()) return;
  
  emit('submit', {
    first_name: form.value.firstName.trim(),
    last_name: form.value.lastName.trim(),
    email: form.value.email.trim(),
    password: form.value.password
  });
}
</script>