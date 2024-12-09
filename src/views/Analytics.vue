<template>
  <div class="min-h-screen bg-background-default dark:bg-background-default-dark">
    <Navigation />
    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <!-- Header -->
        <h1 class="text-2xl font-semibold text-foreground-primary dark:text-foreground-primary-dark mb-6">
          Analytics Dashboard
        </h1>

        <!-- Date Range Filter -->
        <div class="mb-6 bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow p-4">
          <div class="flex items-center space-x-4">
            <div>
              <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-1">
                Start Date
              </label>
              <input
                type="date"
                v-model="dateRange.start"
                class="px-3 py-2 bg-background-default dark:bg-background-default-dark border border-gray-300 dark:border-gray-700 rounded-md shadow-sm text-foreground-primary dark:text-foreground-primary-dark"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-1">
                End Date
              </label>
              <input
                type="date"
                v-model="dateRange.end"
                class="px-3 py-2 bg-background-default dark:bg-background-default-dark border border-gray-300 dark:border-gray-700 rounded-md shadow-sm text-foreground-primary dark:text-foreground-primary-dark"
              />
            </div>
            <button
              @click="fetchData"
              class="mt-6 btn-primary"
              :disabled="analyticsStore.loading"
            >
              Apply Filter
            </button>
          </div>
        </div>

        <!-- Loading State -->
        <div v-if="analyticsStore.loading" class="text-center py-12">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          <p class="mt-4 text-foreground-secondary dark:text-foreground-secondary-dark">
            Loading analytics data...
          </p>
        </div>

        <!-- Error State -->
        <div v-else-if="analyticsStore.error" class="text-center py-12 text-red-600">
          {{ analyticsStore.error }}
        </div>

        <!-- Analytics Content -->
        <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Category Distribution -->
          <div class="bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow p-6">
            <h2 class="text-lg font-medium text-foreground-primary dark:text-foreground-primary-dark mb-4">
              Category Distribution
            </h2>
            <div class="relative" style="height: 300px;">
              <Pie
                v-if="chartData.labels.length > 0"
                :data="chartData"
                :options="chartOptions"
              />
            </div>
          </div>

          <!-- Monthly Trend -->
          <div class="bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow p-6">
            <h2 class="text-lg font-medium text-foreground-primary dark:text-foreground-primary-dark mb-4">
              Monthly Trend
            </h2>
            <div class="relative" style="height: 300px;">
              <Line
                v-if="lineChartData.labels.length > 0"
                :data="lineChartData"
                :options="lineChartOptions"
              />
            </div>
          </div>

          <!-- Category Details -->
          <div class="md:col-span-2 bg-background-secondary dark:bg-background-secondary-dark rounded-lg shadow p-6">
            <h2 class="text-lg font-medium text-foreground-primary dark:text-foreground-primary-dark mb-4">
              Category Details
            </h2>
            <div class="space-y-4">
              <div v-for="(amount, category) in analyticsStore.categoryTotals" :key="category">
                <div class="flex justify-between text-sm mb-1">
                  <span class="text-foreground-primary dark:text-foreground-primary-dark">
                    {{ category }}
                  </span>
                  <span class="text-foreground-secondary dark:text-foreground-secondary-dark">
                    €{{ amount.toFixed(2) }}
                  </span>
                </div>
                <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
                  <div
                    class="bg-primary-600 h-2 rounded-full"
                    :style="{ width: `${(amount / totalAmount) * 100}%` }"
                  ></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Pie, Line } from 'vue-chartjs'
import { Chart as ChartJS, ArcElement, Tooltip, Legend, CategoryScale, LinearScale, PointElement, LineElement } from 'chart.js'
import Navigation from '../components/Navigation.vue'
import { useAnalyticsStore } from '../stores/analytics'

// Register Chart.js components
ChartJS.register(ArcElement, Tooltip, Legend, CategoryScale, LinearScale, PointElement, LineElement)

const analyticsStore = useAnalyticsStore()

const dateRange = ref({
  start: new Date(new Date().getFullYear(), new Date().getMonth() - 1, 1).toISOString().split('T')[0],
  end: new Date().toISOString().split('T')[0]
})

// Chart data
const chartData = computed(() => ({
  labels: Object.keys(analyticsStore.categoryTotals),
  datasets: [{
    data: Object.values(analyticsStore.categoryTotals),
    backgroundColor: [
      '#FF6384',
      '#36A2EB',
      '#FFCE56',
      '#4BC0C0',
      '#9966FF',
      '#FF9F40',
      '#FF6384',
      '#36A2EB',
      '#FFCE56'
    ]
  }]
}))

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false
}

// Line chart data
const lineChartData = computed(() => ({
  labels: analyticsStore.monthlyTotals.map(item => {
    const [year, month] = item.period.split('-')
    return new Date(year, month - 1).toLocaleDateString('default', { month: 'short', year: 'numeric' })
  }),
  datasets: [{
    label: 'Monthly Spending',
    data: analyticsStore.monthlyTotals.map(item => item.total),
    borderColor: '#36A2EB',
    tension: 0.1
  }]
}))

const lineChartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  scales: {
    y: {
      beginAtZero: true
    }
  }
}

const totalAmount = computed(() => {
  return Object.values(analyticsStore.categoryTotals).reduce((sum, val) => sum + val, 0)
})

async function fetchData() {
  await analyticsStore.fetchAnalyticsData({
    startDate: dateRange.value.start,
    endDate: dateRange.value.end
  })
}

onMounted(() => {
  fetchData()
})
</script>