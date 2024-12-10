import { defineStore } from 'pinia';
import { supabase } from '../supabase';
import type { User } from '@supabase/supabase-js';
import { 
  signUpUser, 
  signInUser, 
  resetPassword, 
  updatePassword, 
  signOut,
  type SignUpData 
} from '../lib/supabase/auth';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as User | null,
    loading: false,
    error: null as string | null
  }),

  actions: {
    async register(data: SignUpData) {
      try {
        this.loading = true;
        this.error = null;
        const { user, error } = await signUpUser(data);
        
        if (error) throw error;
        return user;
      } catch (error: any) {
        this.error = error.message;
        throw error;
      } finally {
        this.loading = false;
      }
    },

    async login(email: string, password: string) {
      try {
        this.loading = true;
        this.error = null;
        const { user, error } = await signInUser(email, password);
        
        if (error) throw error;
        this.user = user;
        return user;
      } catch (error: any) {
        this.error = error.message;
        throw error;
      } finally {
        this.loading = false;
      }
    },

    async resetPassword(email: string) {
      try {
        this.loading = true;
        this.error = null;
        const { error } = await resetPassword(email);
        
        if (error) throw error;
      } catch (error: any) {
        this.error = error.message;
        throw error;
      } finally {
        this.loading = false;
      }
    },

    async updatePassword(password: string) {
      try {
        this.loading = true;
        this.error = null;
        const { error } = await updatePassword(password);
        
        if (error) throw error;
      } catch (error: any) {
        this.error = error.message;
        throw error;
      } finally {
        this.loading = false;
      }
    },

    async logout() {
      try {
        this.loading = true;
        this.error = null;
        const { error } = await signOut();
        
        if (error) throw error;
        this.user = null;
      } catch (error: any) {
        this.error = error.message;
        throw error;
      } finally {
        this.loading = false;
      }
    },

    async checkSession() {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        this.user = session?.user ?? null;
        return session?.user ?? null;
      } catch (error: any) {
        console.error('Session check error:', error);
        this.error = error.message;
        return null;
      }
    }
  }
});