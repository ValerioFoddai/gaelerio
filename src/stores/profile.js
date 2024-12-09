import { defineStore } from 'pinia'
import { supabase } from '../supabase'

export const useProfileStore = defineStore('profile', {
  state: () => ({
    profile: null,
    loading: false,
    error: null
  }),
  actions: {
    async fetchProfile() {
      try {
        this.loading = true
        this.error = null
        
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No user found')

        const { data, error } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .single()

        if (error) throw error
        
        this.profile = data
        return data
      } catch (error) {
        console.error('Error fetching profile:', error)
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async updateProfile(updates) {
      try {
        this.loading = true
        this.error = null
        
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No user found')

        const { data, error } = await supabase
          .from('profiles')
          .update({
            display_name: updates.displayName
          })
          .eq('id', user.id)
          .select()
          .single()

        if (error) {
          console.error('Error updating profile:', error)
          throw error
        }
        
        this.profile = data
        return data
      } catch (error) {
        console.error('Profile update error:', error)
        this.error = error.message || 'Failed to update profile'
        throw error
      } finally {
        this.loading = false
      }
    }
  }
})