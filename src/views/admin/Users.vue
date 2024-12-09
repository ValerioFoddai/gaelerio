<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark">
    <AdminNavigation />
    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <h1 class="text-2xl font-semibold text-foreground-primary dark:text-foreground-primary-dark mb-6">
          User Management
        </h1>

        <div class="bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow">
          <!-- User List -->
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
              <thead class="bg-gray-50 dark:bg-gray-800">
                <tr>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-foreground-secondary dark:text-foreground-secondary-dark uppercase tracking-wider">
                    Name
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-foreground-secondary dark:text-foreground-secondary-dark uppercase tracking-wider">
                    Email
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-foreground-secondary dark:text-foreground-secondary-dark uppercase tracking-wider">
                    Role
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-foreground-secondary dark:text-foreground-secondary-dark uppercase tracking-wider">
                    Status
                  </th>
                  <th scope="col" class="relative px-6 py-3">
                    <span class="sr-only">Actions</span>
                  </th>
                </tr>
              </thead>
              <tbody class="bg-background-default dark:bg-background-default-dark divide-y divide-gray-200 dark:divide-gray-700">
                <tr v-for="user in users" :key="user.id">
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-foreground-primary dark:text-foreground-primary-dark">
                    {{ user.display_name }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-foreground-primary dark:text-foreground-primary-dark">
                    {{ user.email }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-foreground-primary dark:text-foreground-primary-dark">
                    {{ user.role }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full"
                          :class="user.active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'">
                      {{ user.active ? 'Active' : 'Inactive' }}
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <button
                      @click="editUser(user)"
                      class="text-primary-600 hover:text-primary-900 dark:hover:text-primary-400 mr-4"
                    >
                      Edit
                    </button>
                    <button
                      v-if="adminStore.isSuperAdmin"
                      @click="deleteUser(user)"
                      class="text-red-600 hover:text-red-900"
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import AdminNavigation from '../../components/AdminNavigation.vue'
import { useAdminStore } from '../../stores/admin'

const adminStore = useAdminStore()
const users = ref([])

onMounted(async () => {
  // Verify admin status
  await adminStore.checkAdminStatus()
  
  // Fetch users (to be implemented)
  // users.value = await fetchUsers()
})

function editUser(user) {
  // Implement edit user functionality
  console.log('Edit user:', user)
}

function deleteUser(user) {
  // Implement delete user functionality
  console.log('Delete user:', user)
}
</script>