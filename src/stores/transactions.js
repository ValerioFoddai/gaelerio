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
            category:expense_main_categories(name),
            subcategory:expense_subcategories(name)
          `)
          .eq('user_id', user.id)

        // Add date filters if provided
        if (startDate) {
          query = query.gte('date', startDate)
        }
        if (endDate) {
          // Set end date to end of day (23:59:59.999)
          const endDateTime = new Date(endDate)
          endDateTime.setHours(23, 59, 59, 999)
          query = query.lte('date', endDateTime.toISOString())
        }

        // Order by date descending
        query = query.order('date', { ascending: false })

        const { data, error } = await query

        if (error) throw error
        this.transactions = data || []
      } catch (err) {
        console.error('Error fetching transactions:', err)
        this.error = 'Failed to load transactions'
      } finally {
        this.loading = false
      }
    },

    async createTransaction({ categoryId, subcategoryId, amount, description, date }) {
      try {
        this.loading = true
        this.error = null

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('No authenticated user')

        const { data: transaction, error: transactionError } = await supabase
          .from('transactions')
          .insert([{
            user_id: user.id,
            expense_category_id: categoryId,
            expense_subcategory_id: subcategoryId,
            amount: amount,
            description: description,
            date: date
          }])
          .select()
          .single()

        if (transactionError) throw transactionError

        await this.fetchTransactions()
        return transaction
      } catch (err) {
        console.error('Error creating transaction:', err)
        this.error = 'Failed to create transaction'
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

        const { data: transaction, error: transactionError } = await supabase
          .from('transactions')
          .update({
            expense_category_id: categoryId,
            expense_subcategory_id: subcategoryId,
            amount: amount,
            description: description,
            date: date
          })
          .eq('id', id)
          .eq('user_id', user.id)
          .select()
          .single()

        if (transactionError) throw transactionError

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

        const { data: transaction, error: fetchError } = await supabase
          .from('transactions')
          .select('*')
          .eq('id', id)
          .single()

        if (fetchError) throw fetchError

        const { error: deleteError } = await supabase
          .from('transactions')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id)

        if (deleteError) throw deleteError

        await this.fetchTransactions()
        return transaction
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