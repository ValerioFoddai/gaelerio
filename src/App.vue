<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark">
    <router-view v-slot="{ Component }">
      <component :is="Component" />
    </router-view>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { onMounted } from 'vue'
import { supabase } from './supabase'
import { useAuthStore } from './stores/auth'
import { useThemeStore } from './stores/theme'

const router = useRouter()
const authStore = useAuthStore()
const themeStore = useThemeStore()

onMounted(async () => {
  // Initialize theme
  themeStore.initTheme()

  try {
    const { data: { session } } = await supabase.auth.getSession()
    if (session) {
      authStore.user = session.user
      router.push('/assets')
    } else {
      router.push('/login')
    }

    supabase.auth.onAuthStateChange(async (event, session) => {
      authStore.user = session?.user || null
      if (!session) {
        router.push('/login')
      }
    })
  } catch (error) {
    console.error('Authentication error:', error)
    router.push('/login')
  }
})
</script>