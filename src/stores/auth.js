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

        // First, sign up the user with metadata
        const { data: authData, error: authError } = await supabase.auth.signUp({
          email,
          password,
          options: {
            data: {
              first_name: options.first_name || '',
              last_name: options.last_name || ''
            },
            emailRedirectTo: `${window.location.origin}/login`
          }
        })

        if (authError) throw authError

        // Create profile only if user was created successfully
        if (authData?.user?.id) {
          const { error: profileError } = await supabase
            .from('profiles')
            .upsert([
              {
                id: authData.user.id,
                first_name: options.first_name || '',
                last_name: options.last_name || '',
                email: email
              }
            ], {
              onConflict: 'id',
              ignoreDuplicates: false
            })

          if (profileError) {
            console.error('Profile creation error:', profileError)
            // Don't throw here - profile can be created later if needed
          }
        }

        return authData
      } catch (error) {
        console.error('Registration error:', error)
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