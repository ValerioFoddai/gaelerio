<template>
  <Modal @close="$emit('close')">
    <div class="p-6">
      <h2 class="text-lg font-semibold text-foreground-primary dark:text-foreground-primary-dark mb-4">
        {{ modalTitle }}
      </h2>

      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-1">
            Name
          </label>
          <input
            v-model="form.name"
            type="text"
            class="w-full px-3 py-2 bg-background-secondary dark:bg-[#1E1E1E] border border-gray-300 dark:border-gray-700 rounded-md shadow-sm text-foreground-primary dark:text-foreground-primary-dark"
            required
          />
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
            {{ submitButtonText }}
          </button>
        </div>
      </form>
    </div>
  </Modal>
</template>

<script setup>
import { ref, computed } from 'vue'
import Modal from '../common/Modal.vue'
import { useExpenseCategoriesStore } from '../../stores/expenseCategories'
import { supabase } from '../../supabase'

const props = defineProps({
  mainCategoryId: {
    type: String,
    default: null
  },
  category: {
    type: Object,
    default: null
  },
  subcategory: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['close', 'success'])
const categoriesStore = useExpenseCategoriesStore()

const form = ref({
  name: props.category?.name || props.subcategory?.name || ''
})

const saving = ref(false)
const isSubCategory = computed(() => !!props.mainCategoryId)
const isEditing = computed(() => !!props.category || !!props.subcategory)

const modalTitle = computed(() => {
  if (isEditing.value) {
    return `Edit ${props.category ? 'Category' : 'Subcategory'}`
  }
  return `Add ${isSubCategory.value ? 'Subcategory' : 'Category'}`
})

const submitButtonText = computed(() => {
  if (saving.value) return 'Saving...'
  return isEditing.value ? 'Save Changes' : 'Create'
})

const isFormValid = computed(() => {
  return form.value.name.trim() !== ''
})

async function handleSubmit() {
  if (!isFormValid.value) return
  
  try {
    saving.value = true
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) throw new Error('No authenticated user')

    if (props.category) {
      await categoriesStore.updateMainCategory({
        id: props.category.id,
        name: form.value.name.trim(),
        userId: user.id
      })
      emit('success', 'Category updated successfully')
    } else if (props.subcategory) {
      await categoriesStore.updateSubCategory({
        id: props.subcategory.id,
        name: form.value.name.trim(),
        userId: user.id
      })
      emit('success', 'Subcategory updated successfully')
    } else if (isSubCategory.value) {
      await categoriesStore.createSubCategory({
        name: form.value.name.trim(),
        mainCategoryId: props.mainCategoryId,
        userId: user.id
      })
      emit('success', 'Subcategory created successfully')
    } else {
      await categoriesStore.createMainCategory({
        name: form.value.name.trim(),
        userId: user.id
      })
      emit('success', 'Category created successfully')
    }
    emit('close')
  } catch (err) {
    console.error('Error saving category:', err)
  } finally {
    saving.value = false
  }
}
</script>