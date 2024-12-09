<template>
  <Multiselect
    v-model="selectedTags"
    mode="tags"
    :options="formattedTags"
    :searchable="true"
    :createTag="false"
    :canClear="true"
    :closeOnSelect="false"
    placeholder="Select tags"
    class="multiselect-blue"
  />
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import Multiselect from '@vueform/multiselect'
import { useTagsStore } from '../../stores/tags'

const props = defineProps({
  modelValue: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue'])

const tagsStore = useTagsStore()
const selectedTags = ref([])

const formattedTags = computed(() => {
  return tagsStore.tags.map(tag => ({
    value: tag.id,
    label: `${tag.name} (${tag.category?.name || 'Uncategorized'})`
  }))
})

watch(selectedTags, (newTags) => {
  emit('update:modelValue', newTags.map(tag => tag.value))
})

watch(() => props.modelValue, (newValue) => {
  if (newValue) {
    selectedTags.value = newValue.map(tagId => {
      const tag = tagsStore.tags.find(t => t.id === tagId)
      return tag ? { 
        value: tag.id, 
        label: `${tag.name} (${tag.category?.name || 'Uncategorized'})` 
      } : null
    }).filter(Boolean)
  }
}, { immediate: true })

onMounted(async () => {
  await Promise.all([
    tagsStore.fetchCategories(),
    tagsStore.fetchTags()
  ])
})
</script>

<style src="@vueform/multiselect/themes/default.css"></style>

<style>
.multiselect-blue {
  --ms-tag-bg: #3b82f6;
  --ms-tag-color: #ffffff;
  --ms-ring-color: #93c5fd;
  --ms-bg: #ffffff;
  --ms-border: #d1d5db;
}

.dark .multiselect-blue {
  --ms-bg: #1E1E1E;
  --ms-border: #374151;
  --ms-dropdown-bg: #1E1E1E;
  --ms-option-bg-selected: #374151;
  --ms-option-bg-selected-pointed: #4B5563;
  --ms-option-bg-pointed: #374151;
  --ms-option-color: #ffffff;
  --ms-placeholder-color: #9CA3AF;
}
</style>