```typescript
<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useAuthStore } from '@/stores/auth';
import DarkModeToggle from '@/components/DarkModeToggle.vue';
import LoginForm from '@/components/auth/LoginForm.vue';
import { formatAuthError } from '@/lib/supabase/auth';

const router = useRouter();
const route = useRoute();
const { t } = useI18n();
const authStore = useAuthStore();

const loading = ref(false);
const error = ref('');

async function handleLogin(formData: { email: string; password: string }) {
  try {
    loading.value = true;
    error.value = '';

    await authStore.login(formData.email, formData.password);
    
    // Handle redirect after successful login
    const redirect = route.query.redirect as string;
    router.push(redirect || '/dashboard');
  } catch (err: any) {
    console.error('Login error:', err);
    error.value = formatAuthError(err) || t('auth.error.login');
  } finally {
    loading.value = false;
  }
}

// Check for redirect param on mount
onMounted(() => {
  if (route.query.redirect) {
    error.value = t('auth.error.sessionExpired');
  }
});
</script>

<!-- Rest of the template remains unchanged -->
```