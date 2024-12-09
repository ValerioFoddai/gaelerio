<template>
  <nav class="fixed top-0 left-0 right-0 z-50 bg-[#0C0C0D]">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-16">
        <div class="flex items-center">
          <div class="flex-shrink-0">
            <img class="h-8 w-8" src="/vite.svg" alt="Logo" />
          </div>
          <div class="hidden md:block">
            <div class="ml-10 flex items-baseline space-x-4">
              <router-link
                v-for="item in navigation"
                :key="item.name"
                :to="item.path"
                :class="[
                  route.path === item.path
                    ? 'bg-[#1E1E1E] text-white'
                    : 'text-gray-300 hover:bg-[#1E1E1E] hover:text-white',
                  'rounded-md px-3 py-2 text-sm font-medium'
                ]"
              >
                {{ item.name }}
              </router-link>
            </div>
          </div>
        </div>
        
        <div class="flex items-center space-x-4">
          <!-- Dark mode toggle -->
          <button
            @click="themeStore.toggleDarkMode()"
            class="rounded-md p-2 text-gray-300 hover:bg-[#1E1E1E] hover:text-white focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <SunIcon v-if="themeStore.isDark" class="h-5 w-5" aria-hidden="true" />
            <MoonIcon v-else class="h-5 w-5" aria-hidden="true" />
          </button>

          <!-- User menu -->
          <Menu as="div" class="relative">
            <div>
              <MenuButton class="relative flex rounded-full bg-[#1E1E1E] text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 focus:ring-offset-[#0C0C0D]">
                <span class="sr-only">Open user menu</span>
                <div class="h-8 w-8 rounded-full bg-primary-500 flex items-center justify-center text-white">
                  {{ authStore.user?.email?.[0]?.toUpperCase() || '?' }}
                </div>
              </MenuButton>
            </div>
            <transition
              enter-active-class="transition ease-out duration-100"
              enter-from-class="transform opacity-0 scale-95"
              enter-to-class="transform opacity-100 scale-100"
              leave-active-class="transition ease-in duration-75"
              leave-from-class="transform opacity-100 scale-100"
              leave-to-class="transform opacity-0 scale-95"
            >
              <MenuItems class="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-[#0C0C0D] py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
                <!-- Profile Settings -->
                <MenuItem v-slot="{ active }">
                  <router-link
                    to="/profile"
                    :class="[
                      active ? 'bg-[#1E1E1E]' : '',
                      'block px-4 py-2 text-sm text-gray-300 hover:text-white'
                    ]"
                  >
                    Profile Settings
                  </router-link>
                </MenuItem>

                <!-- Language Selection -->
                <div class="px-4 py-2 border-b border-gray-700">
                  <div class="text-sm text-gray-300 mb-2">Language</div>
                  <div class="flex flex-col space-y-2">
                    <button
                      @click="changeLanguage('en')"
                      :class="[
                        'text-sm text-left px-2 py-1 rounded-md',
                        locale === 'en'
                          ? 'bg-[#1E1E1E] text-white'
                          : 'text-gray-300 hover:bg-[#1E1E1E] hover:text-white'
                      ]"
                    >
                      English
                    </button>
                    <button
                      @click="changeLanguage('it')"
                      :class="[
                        'text-sm text-left px-2 py-1 rounded-md',
                        locale === 'it'
                          ? 'bg-[#1E1E1E] text-white'
                          : 'text-gray-300 hover:bg-[#1E1E1E] hover:text-white'
                      ]"
                    >
                      Italiano
                    </button>
                  </div>
                </div>
                
                <!-- Sign Out -->
                <MenuItem v-slot="{ active }">
                  <a
                    href="#"
                    :class="[
                      active ? 'bg-[#1E1E1E]' : '',
                      'block px-4 py-2 text-sm text-gray-300 hover:text-white'
                    ]"
                    @click="handleLogout"
                  >
                    Sign out
                  </a>
                </MenuItem>
              </MenuItems>
            </transition>
          </Menu>
        </div>
      </div>
    </div>
  </nav>

  <!-- Spacer to prevent content from being hidden under fixed nav -->
  <div class="h-16"></div>
</template>

<script setup>
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { Menu, MenuButton, MenuItems, MenuItem } from '@headlessui/vue'
import { SunIcon, MoonIcon } from '@heroicons/vue/24/outline'
import { useAuthStore } from '../stores/auth'
import { useThemeStore } from '../stores/theme'
import { computed } from 'vue'

const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const themeStore = useThemeStore()

const navigation = computed(() => [
  { name: t('nav.assets'), path: '/assets' },
  { name: t('nav.analytics'), path: '/analytics' },
  { name: t('nav.transactions'), path: '/transactions' },
  { name: t('nav.settings'), path: '/settings' }
])

function changeLanguage(lang) {
  locale.value = lang
  localStorage.setItem('language', lang)
}

async function handleLogout() {
  try {
    await authStore.logout()
    router.push('/login')
  } catch (error) {
    console.error('Logout error:', error.message)
  }
}
</script>