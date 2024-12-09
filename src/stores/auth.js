import { defineStore } from 'pinia'
import { supabase } from '../supabase'
import { ref } from 'vue'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    loading: false,
    error: null
  }),
  actions: {
    async login(email, password) {
      try {
        this.loading = true
        this.error = null
        const { data, error } = await supabase.auth.signInWithPassword({
          email,
          password
        })
        if (error) throw error
        this.user = data.user
        return data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async register(email, password, options = {}) {
      try {
        this.loading = true
        this.error = null
        
        const metadata = {
          first_name: options.data?.first_name || '',
          last_name: options.data?.last_name || '',
          phone: options.data?.phone || '',
          newsletter: options.data?.newsletter || false
        }
        
        const { data, error } = await supabase.auth.signUp({
          email,
          password,
          options: {
            ...options,
            data: metadata,
            emailRedirectTo: `${window.location.origin}/login`
          }
        })

        if (error) throw error
        return data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async logout() {
      try {
        this.loading = true
        this.error = null
        const { error } = await supabase.auth.signOut()
        if (error) throw error
        this.user = null
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async resetPassword(email) {
      try {
        this.loading = true
        this.error = null
        const { error } = await supabase.auth.resetPasswordForEmail(email, {
          redirectTo: `${window.location.origin}/update-password`
        })
        if (error) throw error
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async updatePassword(password) {
      try {
        this.loading = true
        this.error = null
        const { error } = await supabase.auth.updateUser({
          password
        })
        if (error) throw error
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async signInWithGoogle() {
      try {
        this.loading = true
        this.error = null
        const { data, error } = await supabase.auth.signInWithOAuth({
          provider: 'google',
          options: {
            redirectTo: `${window.location.origin}/assets`
          }
        })
        if (error) throw error
        return data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async signInWithGithub() {
      try {
        this.loading = true
        this.error = null
        const { data, error } = await supabase.auth.signInWithOAuth({
          provider: 'github',
          options: {
            redirectTo: `${window.location.origin}/assets`
          }
        })
        if (error) throw error
        return data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    }
  }
})