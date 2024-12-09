import { defineStore } from 'pinia'
import { supabase } from '../supabase'

export const useAdminStore = defineStore('admin', {
  state: () => ({
    isAdmin: false,
    isSuperAdmin: false,
    loading: false,
    error: null
  }),
  actions: {
    async checkAdminStatus() {
      try {
        this.loading = true
        this.error = null
        
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) {
          this.isAdmin = false
          this.isSuperAdmin = false
          return false
        }

        // Check if user is in admin_users table
        const { data: adminData, error: adminError } = await supabase
          .from('admin_users')
          .select('role')
          .eq('id', user.id)
          .single()

        if (adminError) {
          console.error('Error checking admin status:', adminError)
          this.isAdmin = false
          this.isSuperAdmin = false
          return false
        }

        if (adminData) {
          this.isAdmin = true
          this.isSuperAdmin = adminData.role === 'super_admin'
          return true
        }

        this.isAdmin = false
        this.isSuperAdmin = false
        return false
      } catch (error) {
        console.error('Admin check error:', error)
        this.error = error.message
        return false
      } finally {
        this.loading = false
      }
    },

    async getAllAdmins() {
      try {
        this.loading = true
        this.error = null

        const { data, error } = await supabase
          .from('admin_users')
          .select(`
            id,
            role,
            created_at,
            profiles:profiles(display_name)
          `)
          .order('created_at', { ascending: false })

        if (error) throw error
        return data
      } catch (error) {
        console.error('Error fetching admins:', error)
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async addAdmin(userId, role = 'admin') {
      try {
        this.loading = true
        this.error = null

        const { data, error } = await supabase
          .from('admin_users')
          .insert([
            { id: userId, role }
          ])
          .select()
          .single()

        if (error) throw error
        return data
      } catch (error) {
        console.error('Error adding admin:', error)
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async removeAdmin(userId) {
      try {
        this.loading = true
        this.error = null

        const { error } = await supabase
          .from('admin_users')
          .delete()
          .eq('id', userId)

        if (error) throw error
      } catch (error) {
        console.error('Error removing admin:', error)
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    }
  }
})