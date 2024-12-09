import { defineStore } from 'pinia'
import { supabase } from '../supabase'

export const useTransactionsStore = defineStore('transactions', {
  state: () => ({
    transactions: [],
    loading: false,
    error: null
  }),

  actions: {
    async fetchTransactions(startDate = null, endDate = null) {
      try {
        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No authenticated user')

        let query = supabase
          .from('transactions')
          .select(`
            *,
            expense_main_categories!inner(name),
            expense_subcategories(name)
          `)
          .eq('user_id', user.id)

        if (startDate) {
          query = query.gte('date', startDate)
        }
        if (endDate) {
          const endDateTime = new Date(endDate)
          endDateTime.setHours(23, 59, 59, 999)
          query = query.lte('date', endDateTime.toISOString())
        }

        query = query.order('date', { ascending: false })

        const { data, error } = await query
        if (error) throw error

        this.transactions = data || []
      } catch (err) {
        console.error('Error fetching transactions:', err)
        this.error = 'Failed to load transactions'
        throw err
      } finally {
        this.loading = false
      }
    },

    async createTransaction({ categoryId, subcategoryId, amount, description, date }) {
      try {
        console.log('Creating transaction with:', { categoryId, subcategoryId, amount, description, date });

        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No authenticated user')

        const { data: transaction, error } = await supabase
          .from('transactions')
          .insert([{
            user_id: user.id,
            expense_category_id: categoryId,
            expense_subcategory_id: subcategoryId,
            amount,
            description,
            date
          }])
          .select()

        if (error) {
          console.error('Error returned by Supabase:', error);
          throw error;
        }

        await this.fetchTransactions()
        return transaction
      } catch (err) {
        console.error('Error creating transaction:', err)
        this.error = 'Failed to create transaction: ' + (err.message || 'Unknown error')
        throw err
      } finally {
        this.loading = false
      }
    },

    async updateTransaction(id, { categoryId, subcategoryId, amount, description, date }) {
      try {
        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No authenticated user')

        const { data: transaction, error } = await supabase
          .from('transactions')
          .update({
            expense_category_id: categoryId,
            expense_subcategory_id: subcategoryId,
            amount,
            description,
            date
          })
          .eq('id', id)
          .eq('user_id', user.id)
          .select()
          .single()

        if (error) throw error

        await this.fetchTransactions()
        return transaction
      } catch (err) {
        console.error('Error updating transaction:', err)
        this.error = 'Failed to update transaction'
        throw err
      } finally {
        this.loading = false
      }
    },

    async deleteTransaction(id) {
      try {
        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No authenticated user')

        const { error } = await supabase
          .from('transactions')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id)

        if (error) throw error

        await this.fetchTransactions()
      } catch (err) {
        console.error('Error deleting transaction:', err)
        this.error = 'Failed to delete transaction'
        throw err
      } finally {
        this.loading = false
      }
    }
  }
})
