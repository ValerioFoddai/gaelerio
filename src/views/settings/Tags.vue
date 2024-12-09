<template>
  <div class="space-y-6">
    <!-- Loading State -->
    <div v-if="loading" class="text-center py-4">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="text-red-600 text-center py-4">
      {{ error }}
    </div>

    <!-- Empty State -->
    <div v-else-if="!categories.length" class="text-center py-12">
      <TagIcon class="mx-auto h-12 w-12 text-gray-400" />
      <h3 class="mt-2 text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
        {{ t('settings.tags.empty.title') }}
      </h3>
      <p class="mt-1 text-sm text-foreground-secondary dark:text-foreground-secondary-dark">
        {{ t('settings.tags.empty.description') }}
      </p>
      <div class="mt-6">
        <button
          type="button"
          class="btn-primary"
          @click="() => handleAddCategory()"
        >
          <PlusIcon class="h-5 w-5 mr-2" />
          {{ t('settings.tags.add.category') }}
        </button>
      </div>
    </div>

    <!-- Categories List -->
    <div v-else class="space-y-6">
      <!-- Add Category Button -->
      <div class="flex justify-between items-center">
        <div class="flex items-center">
          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
            Beta
          </span>
        </div>
        <button
          type="button"
          class="btn-primary"
          @click="() => handleAddCategory()"
        >
          <PlusIcon class="h-5 w-5 mr-2" />
          {{ t('settings.tags.add.category') }}
        </button>
      </div>

      <!-- Categories -->
      <div v-for="category in categories" :key="category.id" class="bg-white dark:bg-[#1E1E1E] rounded-lg shadow">
        <!-- Category Header -->
        <div class="px-4 py-3 flex items-center justify-between">
          <div class="flex items-center space-x-3">
            <TagIcon class="h-5 w-5 text-gray-400" />
            <h3 class="text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark">
              {{ category.name }}
            </h3>
          </div>
          <div class="flex items-center space-x-2">
            <button
              type="button"
              class="p-1 text-gray-400 hover:text-gray-500"
              @click="() => handleAddTag(category.id)"
            >
              <PlusIcon class="h-5 w-5" />
            </button>
            <button
              type="button"
              class="p-1 text-gray-400 hover:text-gray-500"
              @click="() => handleEditCategory(category)"
            >
              <PencilIcon class="h-5 w-5" />
            </button>
            <button
              type="button"
              class="p-1 text-gray-400 hover:text-gray-500"
              @click="() => handleDeleteCategory(category)"
            >
              <TrashIcon class="h-5 w-5" />
            </button>
          </div>
        </div>

        <!-- Tags -->
        <div class="border-t border-gray-200 dark:border-gray-700">
          <div class="divide-y divide-gray-200 dark:divide-gray-700">
            <div
              v-for="tag in getTagsByCategory(category.id)"
              :key="tag.id"
              class="px-4 py-3 flex items-center justify-between hover:bg-gray-50 dark:hover:bg-[#2E2E2E]"
            >
              <span class="text-sm text-gray-500 dark:text-gray-400">{{ tag.name }}</span>
              <div class="flex items-center space-x-2">
                <button
                  type="button"
                  class="p-1 text-gray-400 hover:text-gray-500"
                  @click="() => handleEditTag(tag)"
                >
                  <PencilIcon class="h-4 w-4" />
                </button>
                <button
                  type="button"
                  class="p-1 text-gray-400 hover:text-gray-500"
                  @click="() => handleDeleteTag(tag)"
                >
                  <TrashIcon class="h-4 w-4" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Create/Edit Modal -->
    <Modal v-if="showCreateModal" @close="closeCreateModal">
      <div class="p-6">
        <h2 class="text-lg font-semibold text-foreground-primary dark:text-foreground-primary-dark mb-4">
          {{ getModalTitle() }}
        </h2>

        <form @submit.prevent="handleSubmit" class="space-y-4">
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
              @click="closeCreateModal"
            >
              {{ t('common.cancel') }}
            </button>
            <button
              type="submit"
              :disabled="!isFormValid || saving"
              class="btn-primary"
            >
              {{ saving ? t('common.saving') : (editingTag || editingCategory ? t('common.save') : t('common.create')) }}
            </button>
          </div>
        </form>
      </div>
    </Modal>

    <!-- Delete Confirmation Modal -->
    <Modal v-if="showDeleteModal" @close="closeDeleteModal">
      <div class="p-6">
        <div class="text-center">
          <ExclamationTriangleIcon class="mx-auto h-12 w-12 text-red-500" />
          <h3 class="mt-4 text-lg font-medium text-foreground-primary dark:text-foreground-primary-dark">
            {{ t('settings.tags.delete.title', { type: deletingCategory ? 'Category' : 'Tag' }) }}
          </h3>
          <p class="mt-2 text-sm text-foreground-secondary dark:text-foreground-secondary-dark">
            {{ t('settings.tags.delete.message', { type: deletingCategory ? 'category' : 'tag' }) }}
          </p>
        </div>
        <div class="mt-6 flex justify-end space-x-3">
          <button
            type="button"
            class="px-4 py-2 text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md"
            @click="closeDeleteModal"
          >
            {{ t('common.cancel') }}
          </button>
          <button
            type="button"
            class="px-4 py-2 text-sm font-medium text-white bg-red-600 hover:bg-red-700 rounded-md"
            @click="handleDeleteConfirm"
          >
            {{ t('common.delete') }}
          </button>
        </div>
      </div>
    </Modal>

    <!-- Toast -->
    <Toast ref="toast" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { 
  TagIcon,
  PlusIcon,
  PencilIcon,
  TrashIcon,
  ExclamationTriangleIcon
} from '@heroicons/vue/24/outline'
import { useTagsStore } from '../../stores/tags'
import Modal from '../../components/common/Modal.vue'
import Toast from '../../components/common/Toast.vue'

const { t } = useI18n()
const tagsStore = useTagsStore()

const showCreateModal = ref(false)
const showDeleteModal = ref(false)
const selectedCategoryId = ref(null)
const editingTag = ref(null)
const editingCategory = ref(null)
const deletingTag = ref(null)
const deletingCategory = ref(null)
const toast = ref(null)
const saving = ref(false)

const form = ref({
  name: ''
})

const categories = computed(() => tagsStore.categories)
const loading = computed(() => tagsStore.loading)
const error = computed(() => tagsStore.error)

const isFormValid = computed(() => {
  return form.value.name.trim() !== ''
})

function getTagsByCategory(categoryId) {
  return tagsStore.getTagsByCategory(categoryId)
}

function getModalTitle() {
  if (editingCategory) {
    return t('settings.tags.edit.title', { type: 'Category' })
  }
  if (editingTag) {
    return t('settings.tags.edit.title', { type: 'Tag' })
  }
  if (selectedCategoryId.value) {
    return t('settings.tags.add.subcategory')
  }
  return t('settings.tags.add.category')
}

function handleAddCategory() {
  selectedCategoryId.value = null
  editingTag.value = null
  editingCategory.value = null
  form.value.name = ''
  showCreateModal.value = true
}

function handleAddTag(categoryId) {
  selectedCategoryId.value = categoryId
  editingTag.value = null
  editingCategory.value = null
  form.value.name = ''
  showCreateModal.value = true
}

function handleEditCategory(category) {
  editingCategory.value = category
  editingTag.value = null
  selectedCategoryId.value = null
  form.value.name = category.name
  showCreateModal.value = true
}

function handleEditTag(tag) {
  editingTag.value = tag
  editingCategory.value = null
  selectedCategoryId.value = null
  form.value.name = tag.name
  showCreateModal.value = true
}

function handleDeleteCategory(category) {
  deletingCategory.value = category
  deletingTag.value = null
  showDeleteModal.value = true
}

function handleDeleteTag(tag) {
  deletingTag.value = tag
  deletingCategory.value = null
  showDeleteModal.value = true
}

function closeCreateModal() {
  showCreateModal.value = false
  selectedCategoryId.value = null
  editingTag.value = null
  editingCategory.value = null
  form.value.name = ''
}

function closeDeleteModal() {
  showDeleteModal.value = false
  deletingCategory.value = null
  deletingTag.value = null
}

async function handleSubmit() {
  if (!isFormValid.value) return
  
  try {
    saving.value = true
    if (editingCategory.value) {
      await tagsStore.updateCategory({
        id: editingCategory.value.id,
        name: form.value.name.trim()
      })
      toast.value.addToast('Category updated successfully', 'success')
    } else if (editingTag.value) {
      await tagsStore.updateTag({
        id: editingTag.value.id,
        name: form.value.name.trim()
      })
      toast.value.addToast('Tag updated successfully', 'success')
    } else if (selectedCategoryId.value) {
      await tagsStore.createTag({
        categoryId: selectedCategoryId.value,
        name: form.value.name.trim()
      })
      toast.value.addToast('Tag created successfully', 'success')
    } else {
      await tagsStore.createCategory({
        name: form.value.name.trim()
      })
      toast.value.addToast('Category created successfully', 'success')
    }
    closeCreateModal()
  } catch (err) {
    toast.value.addToast(
      editingCategory.value ? 'Failed to update category' :
      editingTag.value ? 'Failed to update tag' :
      selectedCategoryId.value ? 'Failed to create tag' :
      'Failed to create category',
      'error'
    )
  } finally {
    saving.value = false
  }
}

async function handleDeleteConfirm() {
  try {
    if (deletingCategory.value) {
      const deletedCategory = { ...deletingCategory.value }
      await tagsStore.deleteCategory(deletingCategory.value.id)
      
      toast.value.addToast(
        'Category deleted',
        'error',
        async () => {
          try {
            await tagsStore.createCategory({
              name: deletedCategory.name
            })
            toast.value.addToast('Category restored', 'success')
          } catch (err) {
            toast.value.addToast('Failed to restore category', 'error')
          }
        }
      )
    } else {
      const deletedTag = { ...deletingTag.value }
      await tagsStore.deleteTag(deletingTag.value.id)
      
      toast.value.addToast(
        'Tag deleted',
        'error',
        async () => {
          try {
            await tagsStore.createTag({
              categoryId: deletedTag.category_id,
              name: deletedTag.name
            })
            toast.value.addToast('Tag restored', 'success')
          } catch (err) {
            toast.value.addToast('Failed to restore tag', 'error')
          }
        }
      )
    }
  } catch (err) {
    toast.value.addToast(
      `Failed to delete ${deletingCategory.value ? 'category' : 'tag'}`,
      'error'
    )
  } finally {
    closeDeleteModal()
  }
}

onMounted(async () => {
  await Promise.all([
    tagsStore.fetchCategories(),
    tagsStore.fetchTags()
  ])
})
</script>