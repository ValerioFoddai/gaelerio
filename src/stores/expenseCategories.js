import { defineStore } from 'pinia'
import { supabase } from '../supabase'

export const useExpenseCategoriesStore = defineStore('expenseCategories', {
  state: () => ({
    mainCategories: [],
    subCategories: [],
    loading: false,
    error: null
  }),

  getters: {
    getSubcategoriesByMainId: (state) => (mainId) => {
      return state.subCategories.filter(sub => sub.main_category_id === mainId)
    },

    getSubcategoryById: (state) => (id) => {
      return state.subCategories.find(sub => sub.id === id)
    }
  },

  actions: {
    async fetchCategories() {
      try {
        this.loading = true
        this.error = null

        const [mainResult, subResult] = await Promise.all([
          supabase
            .from('expense_main_categories')
            .select('*')
            .order('name'),
          supabase
            .from('expense_subcategories')
            .select('*')
            .order('name')
        ])

        if (mainResult.error) throw mainResult.error
        if (subResult.error) throw subResult.error

        this.mainCategories = mainResult.data || []
        this.subCategories = subResult.data || []
      } catch (err) {
        console.error('Error fetching categories:', err)
        this.error = 'Failed to load categories'
      } finally {
        this.loading = false
      }
    }
  }
})