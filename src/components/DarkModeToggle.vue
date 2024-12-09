<template>
  <button
    @click="themeStore.toggleDarkMode()"
    class="absolute top-4 right-4 p-2 rounded-md text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200 focus:outline-none focus:ring-2 focus:ring-primary-500"
    aria-label="Toggle dark mode"
  >
    <SunIcon v-if="themeStore.isDark" class="h-5 w-5" aria-hidden="true" />
    <MoonIcon v-else class="h-5 w-5" aria-hidden="true" />
  </button>
</template>

<script setup>
import { SunIcon, MoonIcon } from '@heroicons/vue/24/outline'
import { useThemeStore } from '../stores/theme'

const themeStore = useThemeStore()
</script>