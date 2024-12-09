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
        const { data, error } = await supabase
          .from('expense_categories')
          .select('*')
          .order('name')
        
        if (error) throw error
        this.categories = data
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
        const { data, error } = await supabase
          .from('budgets')
          .select(`
            *,
            expense_categories (*)
          `)
          .eq('user_id', userId)
          .eq('month', month)
        
        if (error) throw error
        this.budgets = data
      } catch (err) {
        console.error('Error fetching budgets:', err)
        this.error = 'Failed to load budgets'
      } finally {
        this.loading = false
      }
    },

    async updateBudget({ userId, categoryId, month, amount }) {
      try {
        this.loading = true
        const { error } = await supabase
          .from('budgets')
          .upsert({
            user_id: userId,
            category_id: categoryId,
            month: month,
            allocated_amount: amount,
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