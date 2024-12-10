import { defineStore } from 'pinia'
import { supabase } from '../supabase'
import { validateRegistration, formatAuthError } from '../utils/auth'
import { handleRegistrationError, prepareRegistrationData } from '../utils/registration'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    loading: false,
    error: null
  }),

  actions: {
    async register(email, password, options = {}) {
      try {
        this.loading = true
        this.error = null

        // Validate registration data
        const { isValid, errors } = validateRegistration({ email, password, ...options })
        if (!isValid) {
          throw new Error(Object.values(errors)[0])
        }

        // Prepare registration data
        const registrationData = prepareRegistrationData({
          email,
          password,
          first_name: options.first_name,
          last_name: options.last_name
        })

        // Sign up the user
        const { data, error } = await supabase.auth.signUp(registrationData)
        if (error) throw error

        // Check if email confirmation is required
        if (data?.user?.identities?.length === 0) {
          return { emailConfirmationRequired: true }
        }

        return data
      } catch (error) {
        this.error = handleRegistrationError(error)
        throw error
      } finally {
        this.loading = false
      }
    },

    // ... rest of the auth store methods remain unchanged ...
  }
})