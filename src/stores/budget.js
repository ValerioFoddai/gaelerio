import { defineStore } from 'pinia'
import { supabase } from '../supabase'

export const useBudgetStore = defineStore('budget', {
  state: () => ({
    categories: [],
    budgets: [],
    loading: false,
    error: null
  }),

  actions: {
    async fetchCategories() {
      try {
        this.loading = true
        this.error = null
        const { data: mainCategories, error: mainError } = await supabase
          .from('expense_main_categories')
          .select(`
            id,
            name,
            expense_subcategories (
              id,
              name
            )
          `)
          .order('name')
        
        if (mainError) throw mainError
        this.categories = mainCategories || []
      } catch (err) {
        console.error('Error fetching categories:', err)
        this.error = 'Failed to load categories: ' + (err.message || 'Unknown error')
      } finally {
        this.loading = false
      }
    },

    async fetchBudgets(userId, month) {
      try {
        if (!userId) throw new Error('User ID is required')
        if (!month) throw new Error('Month is required')

        this.loading = true
        this.error = null

        // Validate date format
        const startDate = new Date(month)
        if (isNaN(startDate.getTime())) {
          throw new Error('Invalid date format')
        }

        // Fetch all budgets for the month
        const { data: budgets, error } = await supabase
          .from('budgets')
          .select(`
            id,
            expense_category_id,
            expense_subcategory_id,
            allocated_amount,
            spent_amount,
            month
          `)
          .eq('user_id', userId)
          .eq('month', startDate.toISOString().split('T')[0])
        
        if (error) throw error

        // Create budgets for categories that don't have one yet
        const missingBudgets = []
        
        // Check main categories
        this.categories.forEach(category => {
          const hasMainBudget = budgets.some(b => 
            b.expense_category_id === category.id && 
            !b.expense_subcategory_id
          )
          
          if (!hasMainBudget) {
            missingBudgets.push({
              user_id: userId,
              expense_category_id: category.id,
              month: startDate.toISOString().split('T')[0],
              allocated_amount: 0,
              spent_amount: 0
            })
          }

          // Check subcategories
          category.expense_subcategories?.forEach(sub => {
            const hasSubBudget = budgets.some(b => 
              b.expense_category_id === category.id && 
              b.expense_subcategory_id === sub.id
            )
            
            if (!hasSubBudget) {
              missingBudgets.push({
                user_id: userId,
                expense_category_id: category.id,
                expense_subcategory_id: sub.id,
                month: startDate.toISOString().split('T')[0],
                allocated_amount: 0,
                spent_amount: 0
              })
            }
          })
        })

        // Insert missing budgets if any
        if (missingBudgets.length > 0) {
          const { error: insertError } = await supabase
            .from('budgets')
            .insert(missingBudgets)
          
          if (insertError) throw insertError

          // Fetch all budgets again to get the complete list
          const { data: updatedBudgets, error: refetchError } = await supabase
            .from('budgets')
            .select(`
              id,
              expense_category_id,
              expense_subcategory_id,
              allocated_amount,
              spent_amount,
              month
            `)
            .eq('user_id', userId)
            .eq('month', startDate.toISOString().split('T')[0])
          
          if (refetchError) throw refetchError
          this.budgets = updatedBudgets
        } else {
          this.budgets = budgets
        }
      } catch (err) {
        console.error('Error fetching budgets:', err)
        this.error = 'Failed to load budgets: ' + (err.message || 'Unknown error')
        throw err
      } finally {
        this.loading = false
      }
    },

    async updateBudget({ userId, categoryId, subcategoryId = null, month, amount }) {
      try {
        console.log('Updating budget with:', { userId, categoryId, subcategoryId, month, amount });

        if (!userId) throw new Error('User ID is required')
        if (!categoryId) throw new Error('Category ID is required')
        if (!month) throw new Error('Month is required')
        if (typeof amount !== 'number') throw new Error('Amount must be a number')

        this.loading = true
        this.error = null

        // Validate date format
        const budgetDate = new Date(month)
        if (isNaN(budgetDate.getTime())) {
          throw new Error('Invalid date format')
        }

        // Upsert the budget record
        const { error } = await supabase
          .from('budgets')
          .upsert({
            user_id: userId,
            expense_category_id: categoryId,
            expense_subcategory_id: subcategoryId,
            allocated_amount: amount,
            month: budgetDate.toISOString().split('T')[0]
          }, {
            onConflict: 'user_id,expense_category_id,expense_subcategory_id,month'
          })
        
        if (error) {
          console.error('Error returned by Supabase:', error);
          throw error;
        }
        await this.fetchBudgets(userId, month)
      } catch (err) {
        console.error('Error updating budget:', err)
        this.error = 'Failed to update budget: ' + (err.message || 'Unknown error')
        throw err
      } finally {
        this.loading = false
      }
    }
  }
})
