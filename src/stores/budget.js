import { defineStore } from 'pinia'
import { supabase } from '../supabase'

export const useBudgetStore = defineStore('budget', {
  state: () => ({
    categories: [],
    budgets: [],
    loading: false,
    error: null
  }),

  actions: {
    async fetchCategories() {
      try {
        this.loading = true
        const { data: mainCategories, error: mainError } = await supabase
          .from('expense_main_categories')
          .select(`
            id,
            name,
            expense_subcategories (
              id,
              name
            )
          `)
          .order('name')
        
        if (mainError) throw mainError
        this.categories = mainCategories || []
      } catch (err) {
        console.error('Error fetching categories:', err)
        this.error = 'Failed to load categories'
      } finally {
        this.loading = false
      }
    },

    async fetchBudgets(userId, month) {
      try {
        this.loading = true
        const { data: transactions, error } = await supabase
          .from('transactions')
          .select(`
            id,
            amount,
            date,
            expense_category_id,
            expense_subcategory_id
          `)
          .eq('user_id', userId)
          .gte('date', `${month}-01`)
          .lt('date', this.getNextMonth(month))
        
        if (error) throw error

        // Calculate budgets from transactions
        this.budgets = this.calculateBudgets(transactions)
      } catch (err) {
        console.error('Error fetching budgets:', err)
        this.error = 'Failed to load budgets'
      } finally {
        this.loading = false
      }
    },

    getNextMonth(month) {
      const [year, monthNum] = month.split('-')
      const nextMonth = new Date(year, parseInt(monthNum), 1)
      return nextMonth.toISOString().slice(0, 7)
    },

    calculateBudgets(transactions) {
      const budgets = {}
      
      transactions.forEach(transaction => {
        const categoryId = transaction.expense_category_id
        if (!budgets[categoryId]) {
          budgets[categoryId] = {
            category_id: categoryId,
            total_amount: 0,
            transaction_count: 0
          }
        }
        
        budgets[categoryId].total_amount += transaction.amount
        budgets[categoryId].transaction_count++
      })

      return Object.values(budgets)
    },

    async updateBudget({ userId, categoryId, month, amount }) {
      try {
        this.loading = true
        const { error } = await supabase
          .from('transactions')
          .insert({
            user_id: userId,
            expense_category_id: categoryId,
            amount: amount,
            date: new Date().toISOString(),
            description: 'Budget allocation'
          })
        
        if (error) throw error
        await this.fetchBudgets(userId, month)
      } catch (err) {
        console.error('Error updating budget:', err)
        this.error = 'Failed to update budget'
        throw err
      } finally {
        this.loading = false
      }
    }
  }
})