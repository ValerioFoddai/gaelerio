import { defineStore } from 'pinia'
import { supabase } from '../supabase'

export const useTagsStore = defineStore('tags', {
  state: () => ({
    categories: [],
    tags: [],
    loading: false,
    error: null
  }),

  getters: {
    getTagsByCategory: (state) => (categoryId) => {
      return state.tags.filter(tag => tag.category_id === categoryId)
    }
  },

  actions: {
    async fetchCategories() {
      try {
        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No authenticated user')

        const { data, error } = await supabase
          .from('tag_categories')
          .select('*')
          .eq('user_id', user.id)
          .order('name')

        if (error) throw error
        this.categories = data || []
      } catch (err) {
        console.error('Error fetching tag categories:', err)
        this.error = 'Failed to load tag categories'
      } finally {
        this.loading = false
      }
    },

    async fetchTags() {
      try {
        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No authenticated user')

        const { data, error } = await supabase
          .from('tags')
          .select(`
            *,
            category:tag_categories(name)
          `)
          .eq('user_id', user.id)
          .order('name')

        if (error) throw error
        this.tags = data || []
      } catch (err) {
        console.error('Error fetching tags:', err)
        this.error = 'Failed to load tags'
      } finally {
        this.loading = false
      }
    },

    async createCategory({ name }) {
      try {
        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No authenticated user')

        const { data, error } = await supabase
          .from('tag_categories')
          .insert([{ 
            name,
            user_id: user.id
          }])
          .select()
          .single()

        if (error) throw error
        await this.fetchCategories()
        return data
      } catch (err) {
        console.error('Error creating tag category:', err)
        this.error = 'Failed to create category'
        throw err
      } finally {
        this.loading = false
      }
    },

    async updateCategory({ id, name }) {
      try {
        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No authenticated user')

        const { data, error } = await supabase
          .from('tag_categories')
          .update({ name })
          .eq('id', id)
          .eq('user_id', user.id)
          .select()
          .single()

        if (error) throw error
        await this.fetchCategories()
        return data
      } catch (err) {
        console.error('Error updating tag category:', err)
        this.error = 'Failed to update category'
        throw err
      } finally {
        this.loading = false
      }
    },

    async deleteCategory(id) {
      try {
        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No authenticated user')

        const { error } = await supabase
          .from('tag_categories')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id)

        if (error) throw error
        await Promise.all([
          this.fetchCategories(),
          this.fetchTags()
        ])
      } catch (err) {
        console.error('Error deleting tag category:', err)
        this.error = 'Failed to delete category'
        throw err
      } finally {
        this.loading = false
      }
    },

    async createTag({ categoryId, name }) {
      try {
        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No authenticated user')

        const { data, error } = await supabase
          .from('tags')
          .insert([{
            category_id: categoryId,
            name,
            user_id: user.id
          }])
          .select()
          .single()

        if (error) throw error
        await this.fetchTags()
        return data
      } catch (err) {
        console.error('Error creating tag:', err)
        this.error = 'Failed to create tag'
        throw err
      } finally {
        this.loading = false
      }
    },

    async updateTag({ id, name }) {
      try {
        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No authenticated user')

        const { data, error } = await supabase
          .from('tags')
          .update({ name })
          .eq('id', id)
          .eq('user_id', user.id)
          .select()
          .single()

        if (error) throw error
        await this.fetchTags()
        return data
      } catch (err) {
        console.error('Error updating tag:', err)
        this.error = 'Failed to update tag'
        throw err
      } finally {
        this.loading = false
      }
    },

    async deleteTag(id) {
      try {
        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No authenticated user')

        const { error } = await supabase
          .from('tags')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id)

        if (error) throw error
        await this.fetchTags()
      } catch (err) {
        console.error('Error deleting tag:', err)
        this.error = 'Failed to delete tag'
        throw err
      } finally {
        this.loading = false
      }
    }
  }
})
