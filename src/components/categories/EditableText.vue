<template>
  <div class="relative">
    <div
      v-if="!isEditing"
      @click="startEdit"
      class="cursor-pointer hover:bg-opacity-10 hover:bg-primary-500 rounded px-1 -mx-1"
    >
      {{ modelValue }}
    </div>
    <input
      v-else
      ref="inputRef"
      v-model="editValue"
      type="text"
      class="w-full px-1 -mx-1 bg-background-default dark:bg-[#1E1E1E] border border-primary-500 rounded text-sm"
      @blur="saveEdit"
      @keyup.enter="saveEdit"
      @keyup.esc="cancelEdit"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'

const props = defineProps({
  modelValue: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['update:modelValue', 'save'])

const isEditing = ref(false)
const editValue = ref('')
const inputRef = ref(null)

function startEdit() {
  editValue.value = props.modelValue
  isEditing.value = true
  nextTick(() => {
    inputRef.value?.focus()
  })
}

function saveEdit() {
  if (editValue.value.trim() && editValue.value !== props.modelValue) {
    emit('save', editValue.value.trim())
  }
  isEditing.value = false
}

function cancelEdit() {
  isEditing.value = false
}
</script>