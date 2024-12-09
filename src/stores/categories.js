import { defineStore } from 'pinia'
import { supabase } from '../supabase'

export const useCategoriesStore = defineStore('categories', {
  state: () => ({
    categories: [],
    loading: false,
    error: null
  }),

  getters: {
    rootCategories: (state) => {
      return state.categories.filter(cat => !cat.parent_id)
    },

    getSubcategories: (state) => (parentId) => {
      return state.categories.filter(cat => cat.parent_id === parentId)
    },

    getCategoryPath: (state) => (categoryId) => {
      const path = []
      let currentCategory = state.categories.find(c => c.id === categoryId)
      
      while (currentCategory) {
        path.unshift(currentCategory)
        currentCategory = state.categories.find(c => c.id === currentCategory.parent_id)
      }
      
      return path
    }
  },

  actions: {
    async fetchCategories() {
      try {
        this.loading = true
        this.error = null

        const { data, error } = await supabase
          .from('transaction_categories')
          .select('*')
          .or(`is_system.eq.true,user_id.eq.${supabase.auth.user()?.id}`)
          .order('name')

        if (error) throw error

        this.categories = data || []
      } catch (error) {
        console.error('Error fetching categories:', error)
        this.error = error.message
      } finally {
        this.loading = false
      }
    },

    async createCategory({ name, description, parentId }) {
      try {
        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No user found')

        const { data, error } = await supabase
          .from('transaction_categories')
          .insert([{
            user_id: user.id,
            name,
            description,
            parent_id: parentId
          }])
          .select()
          .single()

        if (error) throw error

        await this.fetchCategories()
        return data
      } catch (error) {
        console.error('Error creating category:', error)
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async updateCategory(id, { name, description, isActive }) {
      try {
        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No user found')

        const { data, error } = await supabase
          .from('transaction_categories')
          .update({
            name,
            description,
            is_active: isActive
          })
          .eq('id', id)
          .eq('user_id', user.id)
          .select()
          .single()

        if (error) throw error

        await this.fetchCategories()
        return data
      } catch (error) {
        console.error('Error updating category:', error)
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async deleteCategory(id) {
      try {
        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No user found')

        const { error } = await supabase
          .from('transaction_categories')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id)

        if (error) throw error

        await this.fetchCategories()
      } catch (error) {
        console.error('Error deleting category:', error)
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    }
  }
})