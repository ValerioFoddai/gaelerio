<template>
  <div class="flex justify-between items-center mb-8">
    <h1 class="text-2xl font-semibold text-foreground-primary dark:text-foreground-primary-dark">
      Budget Management
    </h1>
    <input
      type="month"
      :value="modelValue"
      @input="$emit('update:modelValue', $event.target.value)"
      @change="$emit('change')"
      class="px-3 py-2 bg-background-default dark:bg-background-default-dark border border-gray-300 dark:border-gray-700 rounded-md shadow-sm text-foreground-primary dark:text-foreground-primary-dark"
    />
  </div>
</template>

<script setup>
defineProps({
  modelValue: {
    type: String,
    required: true
  }
})

defineEmits(['update:modelValue', 'change'])
</script>