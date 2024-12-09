<template>
  <Modal @close="$emit('close')">
    <div class="p-6">
      <h2 class="text-lg font-semibold text-foreground-primary dark:text-foreground-primary-dark mb-4">
        Edit Transaction
      </h2>

      <form @submit.prevent="handleSubmit" class="space-y-4">
        <!-- Category -->
        <div>
          <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-1">
            {{ t('transactions.category') }}
          </label>
          <select
            v-model="form.category_id"
            class="w-full px-3 py-2 bg-background-secondary dark:bg-[#1E1E1E] border border-gray-300 dark:border-gray-700 rounded-md shadow-sm text-foreground-primary dark:text-foreground-primary-dark"
            required
          >
            <option v-for="category in categoriesStore.mainCategories" :key="category.id" :value="category.id">
              {{ category.name }}
            </option>
          </select>
        </div>

        <!-- Subcategory -->
        <div v-if="form.category_id">
          <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-1">
            Subcategory
          </label>
          <select
            v-model="form.subcategory_id"
            class="w-full px-3 py-2 bg-background-secondary dark:bg-[#1E1E1E] border border-gray-300 dark:border-gray-700 rounded-md shadow-sm text-foreground-primary dark:text-foreground-primary-dark"
          >
            <option value="">Select subcategory</option>
            <option 
              v-for="subcategory in categoriesStore.getSubcategoriesByMainId(form.category_id)" 
              :key="subcategory.id" 
              :value="subcategory.id"
            >
              {{ subcategory.name }}
            </option>
          </select>
        </div>

        <!-- Date -->
        <div>
          <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-1">
            {{ t('transactions.date') }}
          </label>
          <input
            type="datetime-local"
            v-model="form.date"
            class="w-full px-3 py-2 bg-background-secondary dark:bg-[#1E1E1E] border border-gray-300 dark:border-gray-700 rounded-md shadow-sm text-foreground-primary dark:text-foreground-primary-dark"
            required
          />
        </div>

        <!-- Amount -->
        <div>
          <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-1">
            {{ t('transactions.amount') }}
          </label>
          <input
            type="number"
            v-model="form.amount"
            step="0.01"
            class="w-full px-3 py-2 bg-background-secondary dark:bg-[#1E1E1E] border border-gray-300 dark:border-gray-700 rounded-md shadow-sm text-foreground-primary dark:text-foreground-primary-dark"
            required
          />
        </div>

        <!-- Description -->
        <div>
          <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-1">
            {{ t('transactions.description') }}
          </label>
          <input
            type="text"
            v-model="form.description"
            class="w-full px-3 py-2 bg-background-secondary dark:bg-[#1E1E1E] border border-gray-300 dark:border-gray-700 rounded-md shadow-sm text-foreground-primary dark:text-foreground-primary-dark"
            required
          />
        </div>

        <!-- Tags -->
        <div>
          <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-1">
            Tags
          </label>
          <TagSelect v-model="form.tags" />
          <p class="mt-1 text-sm text-foreground-tertiary dark:text-foreground-tertiary-dark">
            Select from existing tags. New tags can be created in Settings.
          </p>
        </div>

        <div class="flex justify-end space-x-3 pt-4">
          <button
            type="button"
            class="px-4 py-2 text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md"
            @click="$emit('close')"
          >
            Cancel
          </button>
          <button
            type="submit"
            :disabled="!isFormValid || saving"
            class="btn-primary"
          >
            {{ saving ? 'Saving...' : 'Save Changes' }}
          </button>
        </div>
      </form>
    </div>
  </Modal>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useI18n } from 'vue-i18n'
import Modal from '../common/Modal.vue'
import TagSelect from '../tags/TagSelect.vue'
import { useTransactionsStore } from '../../stores/transactions'
import { useExpenseCategoriesStore } from '../../stores/expenseCategories'

const props = defineProps({
  transaction: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close', 'success'])
const { t } = useI18n()
const transactionsStore = useTransactionsStore()
const categoriesStore = useExpenseCategoriesStore()

const form = ref({
  category_id: props.transaction.category_id,
  subcategory_id: props.transaction.subcategory_id || '',
  date: new Date(props.transaction.date).toISOString().slice(0, 16),
  amount: Math.abs(props.transaction.amount),
  description: props.transaction.description,
  tags: props.transaction.tags || []
})

const saving = ref(false)

const isFormValid = computed(() => {
  return (
    form.value.category_id &&
    form.value.date &&
    form.value.amount &&
    form.value.description
  )
})

async function handleSubmit() {
  if (!isFormValid.value) return
  
  try {
    saving.value = true
    await transactionsStore.updateTransaction(props.transaction.id, {
      categoryId: form.value.category_id,
      subcategoryId: form.value.subcategory_id || null,
      amount: parseFloat(form.value.amount),
      description: form.value.description,
      date: new Date(form.value.date).toISOString(),
      tags: form.value.tags
    })
    emit('success', 'Transaction updated successfully')
    emit('close')
  } catch (err) {
    console.error('Error updating transaction:', err)
  } finally {
    saving.value = false
  }
}
</script>