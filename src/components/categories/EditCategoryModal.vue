<template>
  <Modal @close="$emit('close')">
    <div class="p-6">
      <h2 class="text-lg font-semibold text-foreground-primary dark:text-foreground-primary-dark mb-4">
        {{ t('categories.edit.title', { type: isMainCategory ? t('categories.mainCategory') : t('categories.subCategory') }) }}
      </h2>

      <form @submit.prevent="handleSubmit" class="space-y-4">
        <!-- Name -->
        <div>
          <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-1">
            {{ t('categories.name') }}
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
            {{ t('common.cancel') }}
          </button>
          <button
            type="submit"
            :disabled="!isFormValid || saving"
            class="btn-primary"
          >
            {{ saving ? t('common.saving') : t('common.save') }}
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

const props = defineProps({
  category: {
    type: Object,
    required: true
  },
  isMainCategory: {
    type: Boolean,
    required: true
  }
})

const emit = defineEmits(['save', 'close'])
const { t } = useI18n()

const form = ref({
  name: props.category.name
})

const saving = ref(false)

const isFormValid = computed(() => {
  return form.value.name.trim() !== '' && form.value.name !== props.category.name
})

async function handleSubmit() {
  if (!isFormValid.value) return
  
  try {
    saving.value = true
    const updates = {
      name: form.value.name.trim()
    }

    emit('save', updates)
    emit('close')
  } catch (err) {
    console.error(`Error saving ${props.isMainCategory ? 'main category' : 'subcategory'}:`, err)
  } finally {
    saving.value = false
  }
}
</script>