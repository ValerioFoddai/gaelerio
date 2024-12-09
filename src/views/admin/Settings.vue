<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark">
    <AdminNavigation />
    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <h1 class="text-2xl font-semibold text-foreground-primary dark:text-foreground-primary-dark mb-6">
          Admin Settings
        </h1>

        <div class="space-y-6">
          <!-- Admin Management -->
          <div class="bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow p-6">
            <h2 class="text-lg font-medium text-foreground-primary dark:text-foreground-primary-dark mb-4">
              Admin Management
            </h2>
            
            <!-- Add Admin Form -->
            <form @submit.prevent="addNewAdmin" class="space-y-4 mb-6">
              <div>
                <label for="adminEmail" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
                  User Email
                </label>
                <div class="mt-1">
                  <input
                    id="adminEmail"
                    v-model="newAdminEmail"
                    type="email"
                    required
                    class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm bg-background-default dark:bg-background-default-dark"
                  />
                </div>
              </div>

              <div>
                <label for="adminRole" class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
                  Role
                </label>
                <select
                  id="adminRole"
                  v-model="newAdminRole"
                  class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm rounded-md bg-background-default dark:bg-background-default-dark"
                >
                  <option value="admin">Admin</option>
                  <option value="super_admin">Super Admin</option>
                </select>
              </div>

              <div>
                <button
                  type="submit"
                  :disabled="loading"
                  class="btn-primary"
                >
                  Add Admin
                </button>
              </div>
            </form>

            <!-- Admin List -->
            <div class="mt-6">
              <h3 class="text-md font-medium text-foreground-primary dark:text-foreground-primary-dark mb-4">
                Current Admins
              </h3>
              <ul class="divide-y divide-gray-200 dark:divide-gray-700">
                <li v-for="admin in admins" :key="admin.id" class="py-4 flex justify-between items-center">
                  <div>
                    <p class="text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
                      {{ admin.profiles?.display_name }}
                    </p>
                    <p class="text-sm text-foreground-secondary dark:text-foreground-secondary-dark">
                      Role: {{ admin.role }}
                    </p>
                  </div>
                  <button
                    v-if="admin.id !== currentUserId"
                    @click="removeAdmin(admin)"
                    class="text-sm text-red-600 hover:text-red-900"
                  >
                    Remove
                  </button>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../../stores/auth'
import { useAdminStore } from '../../stores/admin'
import AdminNavigation from '../../components/AdminNavigation.vue'

const authStore = useAuthStore()
const adminStore = useAdminStore()

const admins = ref([])
const newAdminEmail = ref('')
const newAdminRole = ref('admin')
const loading = ref(false)
const currentUserId = ref('')

onMounted(async () => {
  // Verify super admin status
  await adminStore.checkAdminStatus()
  if (!adminStore.isSuperAdmin) {
    return
  }

  // Set current user ID
  const { data: { user } } = await supabase.auth.getUser()
  currentUserId.value = user?.id

  // Load current admins
  try {
    admins.value = await adminStore.getAllAdmins()
  } catch (error) {
    console.error('Error loading admins:', error)
  }
})

async function addNewAdmin() {
  try {
    loading.value = true
    // Implementation for adding new admin
    // This will need to be completed based on your requirements
  } catch (error) {
    console.error('Error adding admin:', error)
  } finally {
    loading.value = false
  }
}

async function removeAdmin(admin) {
  try {
    loading.value = true
    await adminStore.removeAdmin(admin.id)
    admins.value = admins.value.filter(a => a.id !== admin.id)
  } catch (error) {
    console.error('Error removing admin:', error)
  } finally {
    loading.value = false
  }
}
</script>