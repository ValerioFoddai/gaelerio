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
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useAuthStore } from '@/stores/auth';
import DarkModeToggle from '@/components/DarkModeToggle.vue';
import RegistrationForm from '@/components/auth/RegistrationForm.vue';
import type { SignUpData } from '@/lib/supabase/auth';

const router = useRouter();
const { t } = useI18n();
const authStore = useAuthStore();

const loading = ref(false);
const error = ref('');

async function handleRegister(formData: SignUpData) {
  try {
    loading.value = true;
    error.value = '';

    await authStore.register(formData);
    router.push('/login');
  } catch (err: any) {
    console.error('Registration error:', err);
    error.value = err.message || t('auth.error.register');
  } finally {
    loading.value = false;
  }
}
</script>