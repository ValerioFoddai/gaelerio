<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark">
    <AdminNavigation />
    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <h1 class="text-2xl font-semibold text-foreground-primary dark:text-foreground-primary-dark mb-6">
          Admin Dashboard
        </h1>

        <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          <!-- Stats Cards -->
          <div class="bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow p-6">
            <h3 class="text-lg font-medium text-foreground-primary dark:text-foreground-primary-dark">
              Total Users
            </h3>
            <p class="mt-2 text-3xl font-semibold text-foreground-primary dark:text-foreground-primary-dark">
              {{ stats.totalUsers }}
            </p>
          </div>

          <div class="bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow p-6">
            <h3 class="text-lg font-medium text-foreground-primary dark:text-foreground-primary-dark">
              Active Users
            </h3>
            <p class="mt-2 text-3xl font-semibold text-foreground-primary dark:text-foreground-primary-dark">
              {{ stats.activeUsers }}
            </p>
          </div>

          <div class="bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow p-6">
            <h3 class="text-lg font-medium text-foreground-primary dark:text-foreground-primary-dark">
              New Users (Today)
            </h3>
            <p class="mt-2 text-3xl font-semibold text-foreground-primary dark:text-foreground-primary-dark">
              {{ stats.newUsers }}
            </p>
          </div>
        </div>

        <!-- Recent Activity -->
        <div class="mt-8">
          <h2 class="text-xl font-semibold text-foreground-primary dark:text-foreground-primary-dark mb-4">
            Recent Activity
          </h2>
          <div class="bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow">
            <!-- Activity list will be implemented here -->
            <p class="p-6 text-foreground-secondary dark:text-foreground-secondary-dark">
              Recent activity will be displayed here.
            </p>
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

const stats = ref({
  totalUsers: 0,
  activeUsers: 0,
  newUsers: 0
})

onMounted(async () => {
  // Verify admin status
  await adminStore.checkAdminStatus()
  
  // Fetch dashboard stats (to be implemented)
  // stats.value = await fetchDashboardStats()
})
</script>