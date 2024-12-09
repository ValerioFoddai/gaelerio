import { defineStore } from 'pinia'
import { supabase } from '../supabase'

export const useAnalyticsStore = defineStore('analytics', {
  state: () => ({
    loading: false,
    error: null,
    categoryData: [],
    monthlyTotals: [],
    yearlyTotals: []
  }),

  getters: {
    categoryTotals: (state) => {
      const totals = {}
      state.categoryData.forEach(transaction => {
        const categoryName = transaction.category?.name || 'Uncategorized'
        totals[categoryName] = (totals[categoryName] || 0) + Math.abs(transaction.amount)
      })
      return totals
    },

    categoryPercentages: (state) => {
      const totals = state.categoryTotals
      const total = Object.values(totals).reduce((sum, val) => sum + val, 0)
      
      return Object.entries(totals).reduce((acc, [category, amount]) => {
        acc[category] = (amount / total) * 100
        return acc
      }, {})
    },

    monthOverMonthTrend: (state) => {
      return state.monthlyTotals.map((month, index, array) => {
        if (index === 0) return 0
        const previousMonth = array[index - 1].total
        return ((month.total - previousMonth) / previousMonth) * 100
      })
    }
  },

  actions: {
    async fetchAnalyticsData({ startDate, endDate }) {
      try {
        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No authenticated user')

        // Fetch transactions with categories
        const { data: transactions, error } = await supabase
          .from('transactions')
          .select(`
            *,
            category:expense_main_categories(name),
            subcategory:expense_subcategories(name)
          `)
          .eq('user_id', user.id)
          .gte('date', startDate)
          .lte('date', endDate)
          .order('date', { ascending: true })

        if (error) throw error

        this.categoryData = transactions
        this.calculateTotals(transactions)

      } catch (err) {
        console.error('Error fetching analytics data:', err)
        this.error = 'Failed to load analytics data'
      } finally {
        this.loading = false
      }
    },

    calculateTotals(transactions) {
      // Group by month
      const monthlyGroups = {}
      const yearlyGroups = {}

      transactions.forEach(transaction => {
        const date = new Date(transaction.date)
        const monthKey = `${date.getFullYear()}-${date.getMonth() + 1}`
        const yearKey = date.getFullYear().toString()

        monthlyGroups[monthKey] = monthlyGroups[monthKey] || []
        yearlyGroups[yearKey] = yearlyGroups[yearKey] || []

        monthlyGroups[monthKey].push(transaction)
        yearlyGroups[yearKey].push(transaction)
      })

      // Calculate totals
      this.monthlyTotals = Object.entries(monthlyGroups).map(([key, items]) => ({
        period: key,
        total: items.reduce((sum, item) => sum + Math.abs(item.amount), 0)
      }))

      this.yearlyTotals = Object.entries(yearlyGroups).map(([key, items]) => ({
        period: key,
        total: items.reduce((sum, item) => sum + Math.abs(item.amount), 0)
      }))
    }
  }
})