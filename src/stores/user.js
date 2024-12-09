import { defineStore } from 'pinia'
import { supabase } from '../supabase'

export const useUserStore = defineStore('user', {
  state: () => ({
    user: null,
    loading: false,
    error: null
  }),

  actions: {
    async fetchUser() {
      try {
        this.loading = true
        this.error = null
        
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No authenticated user')

        this.user = user
        return user
      } catch (error) {
        console.error('Error fetching user:', error)
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    }
  }
})