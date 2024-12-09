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
        this.error = null
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
        this.error = 'Failed to load categories: ' + (err.message || 'Unknown error')
      } finally {
        this.loading = false
      }
    },

    async fetchBudgets(userId, month) {
      try {
        if (!userId) throw new Error('User ID is required')
        if (!month) throw new Error('Month is required')

        this.loading = true
        this.error = null

        // Validate date format
        const startDate = new Date(month)
        if (isNaN(startDate.getTime())) {
          throw new Error('Invalid date format')
        }

        const { data: budgets, error } = await supabase
          .from('budgets')
          .select(`
            id,
            expense_category_id,
            expense_subcategory_id,
            allocated_amount,
            month
          `)
          .eq('user_id', userId)
          .eq('month', startDate.toISOString().split('T')[0])
        
        if (error) throw error

        this.budgets = budgets || []
      } catch (err) {
        console.error('Error fetching budgets:', err)
        this.error = 'Failed to load budgets: ' + (err.message || 'Unknown error')
        throw err
      } finally {
        this.loading = false
      }
    },

    async updateBudget({ userId, categoryId, month, amount }) {
      try {
        if (!userId) throw new Error('User ID is required')
        if (!categoryId) throw new Error('Category ID is required')
        if (!month) throw new Error('Month is required')
        if (typeof amount !== 'number') throw new Error('Amount must be a number')

        this.loading = true
        this.error = null

        // Validate date format
        const budgetDate = new Date(month)
        if (isNaN(budgetDate.getTime())) {
          throw new Error('Invalid date format')
        }

        // Upsert the budget record
        const { error } = await supabase
          .from('budgets')
          .upsert({
            user_id: userId,
            expense_category_id: categoryId,
            allocated_amount: amount,
            month: budgetDate.toISOString().split('T')[0]
          }, {
            onConflict: 'user_id,expense_category_id,expense_subcategory_id,month'
          })
        
        if (error) throw error
        await this.fetchBudgets(userId, month)
      } catch (err) {
        console.error('Error updating budget:', err)
        this.error = 'Failed to update budget: ' + (err.message || 'Unknown error')
        throw err
      } finally {
        this.loading = false
      }
    }
  }
})