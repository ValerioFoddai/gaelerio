<template>
  <Modal @close="$emit('close')">
    <div class="p-6">
      <h2 class="text-lg font-semibold text-foreground-primary dark:text-foreground-primary-dark mb-4">
        {{ modalTitle }}
      </h2>

      <form @submit.prevent="handleSubmit" class="space-y-4">
        <!-- Name -->
        <div>
          <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-1">
            {{ t('settings.tags.name') }}
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
import { useI18n } from 'vue-i18n'
import Modal from '../common/Modal.vue'
import { useTagsStore } from '../../stores/tags'

const props = defineProps({
  categoryId: {
    type: String,
    default: null
  },
  tag: {
    type: Object,
    default: null
  },
  category: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['close', 'success'])
const { t } = useI18n()
const tagsStore = useTagsStore()

const form = ref({
  name: props.tag?.name || props.category?.name || ''
})

const saving = ref(false)
const isSubTag = computed(() => !!props.categoryId)
const isEditing = computed(() => !!props.tag || !!props.category)

const modalTitle = computed(() => {
  if (isEditing.value) {
    return t('settings.tags.edit.title', { 
      type: props.category ? t('settings.tags.mainTag') : t('settings.tags.subTag')
    })
  }
  return t('settings.tags.edit.title', { 
    type: isSubTag.value ? t('settings.tags.subTag') : t('settings.tags.mainTag')
  })
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
    if (props.category) {
      await tagsStore.updateCategory({
        id: props.category.id,
        name: form.value.name.trim()
      })
      emit('success', 'Tag category updated successfully')
    } else if (props.tag) {
      await tagsStore.updateTag({
        id: props.tag.id,
        name: form.value.name.trim()
      })
      emit('success', 'Tag updated successfully')
    } else if (isSubTag.value) {
      await tagsStore.createTag({
        categoryId: props.categoryId,
        name: form.value.name.trim()
      })
      emit('success', 'Tag created successfully')
    } else {
      await tagsStore.createCategory({
        name: form.value.name.trim()
      })
      emit('success', 'Tag category created successfully')
    }
    emit('close')
  } catch (err) {
    console.error('Error saving tag:', err)
  } finally {
    saving.value = false
  }
}
</script>