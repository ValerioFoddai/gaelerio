<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="bg-background-default dark:bg-background-default-dark w-full max-w-2xl rounded-lg shadow-xl p-6">
      <!-- Header with close button -->
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-2xl font-semibold text-foreground-primary dark:text-foreground-primary-dark">
          {{ t('transactions.add.title') }}
        </h2>
        <button
          @click="closeModal"
          class="text-foreground-tertiary dark:text-foreground-tertiary-dark hover:text-foreground-primary dark:hover:text-foreground-primary-dark"
        >
          <XMarkIcon class="h-6 w-6" />
        </button>
      </div>

      <!-- Progress bar -->
      <div class="mb-8">
        <div class="relative">
          <div class="h-2 bg-gray-200 rounded-full">
            <div
              class="h-2 bg-primary-600 rounded-full transition-all duration-300"
              :style="{ width: `${(currentStep / totalSteps) * 100}%` }"
            ></div>
          </div>
          <div class="absolute -top-6 w-full flex justify-between text-sm text-foreground-secondary dark:text-foreground-secondary-dark">
            <span>{{ currentStep }} {{ t('transactions.add.of') }} {{ totalSteps }}</span>
          </div>
        </div>
      </div>

      <!-- Form content -->
      <div class="mb-8">
        <p class="text-foreground-secondary dark:text-foreground-secondary-dark mb-6">
          {{ t('transactions.add.instructions') }}
        </p>

        <!-- Step 1: Transaction Type -->
        <div v-if="currentStep === 1" class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-2">
              {{ t('transactions.type') }} <span class="text-red-500">*</span>
            </label>
            <select
              v-model="formData.type"
              class="w-full rounded-md border border-gray-300 bg-background-default dark:bg-background-default-dark text-foreground-primary dark:text-foreground-primary-dark px-3 py-2"
              required
            >
              <option value="">{{ t('transactions.selectType') }}</option>
              <option value="deposit">{{ t('transactions.types.deposit') }}</option>
              <option value="withdrawal">{{ t('transactions.types.withdrawal') }}</option>
              <option value="transfer">{{ t('transactions.types.transfer') }}</option>
            </select>
          </div>
        </div>

        <!-- Step 2: Amount and Date -->
        <div v-if="currentStep === 2" class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-2">
              {{ t('transactions.date') }} <span class="text-red-500">*</span>
            </label>
            <input
              type="date"
              v-model="formData.date"
              class="w-full rounded-md border border-gray-300 bg-background-default dark:bg-background-default-dark text-foreground-primary dark:text-foreground-primary-dark px-3 py-2"
              required
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-2">
              {{ t('transactions.amount') }} <span class="text-red-500">*</span>
            </label>
            <input
              type="number"
              v-model="formData.amount"
              step="0.01"
              min="0"
              class="w-full rounded-md border border-gray-300 bg-background-default dark:bg-background-default-dark text-foreground-primary dark:text-foreground-primary-dark px-3 py-2"
              required
            />
          </div>
        </div>

        <!-- Step 3: Description -->
        <div v-if="currentStep === 3" class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-foreground-primary dark:text-foreground-primary-dark mb-2">
              {{ t('transactions.description') }} <span class="text-red-500">*</span>
            </label>
            <textarea
              v-model="formData.description"
              rows="4"
              class="w-full rounded-md border border-gray-300 bg-background-default dark:bg-background-default-dark text-foreground-primary dark:text-foreground-primary-dark px-3 py-2"
              required
            ></textarea>
          </div>
        </div>

        <!-- Error message -->
        <div v-if="error" class="mt-4 text-red-600 text-sm">
          {{ error }}
        </div>
      </div>

      <!-- Navigation buttons -->
      <div class="flex justify-between">
        <button
          v-if="currentStep > 1"
          @click="previousStep"
          class="px-4 py-2 border border-gray-300 rounded-md text-foreground-primary dark:text-foreground-primary-dark hover:bg-gray-50 dark:hover:bg-gray-800"
        >
          {{ t('transactions.add.back') }}
        </button>
        <div v-else class="w-20"></div>

        <button
          v-if="currentStep < totalSteps"
          @click="nextStep"
          class="btn-primary"
          :disabled="!canProceed"
        >
          {{ t('transactions.add.continue') }}
        </button>
        <button
          v-else
          @click="submitForm"
          class="btn-primary"
          :disabled="loading || !isFormValid"
        >
          {{ t('transactions.add.submit') }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { XMarkIcon } from '@heroicons/vue/24/outline'
import { useTransactionsStore } from '../stores/transactions'

const { t } = useI18n()
const transactionsStore = useTransactionsStore()

const emit = defineEmits(['close'])

const currentStep = ref(1)
const totalSteps = 3
const loading = ref(false)
const error = ref('')

const formData = ref({
  type: '',
  date: new Date().toISOString().split('T')[0],
  amount: '',
  description: ''
})

const canProceed = computed(() => {
  switch (currentStep.value) {
    case 1:
      return !!formData.value.type
    case 2:
      return !!formData.value.date && !!formData.value.amount && formData.value.amount > 0
    default:
      return true
  }
})

const isFormValid = computed(() => {
  return (
    !!formData.value.type &&
    !!formData.value.date &&
    !!formData.value.amount &&
    formData.value.amount > 0 &&
    !!formData.value.description
  )
})

function nextStep() {
  if (currentStep.value < totalSteps && canProceed.value) {
    currentStep.value++
  }
}

function previousStep() {
  if (currentStep.value > 1) {
    currentStep.value--
  }
}

async function submitForm() {
  if (!isFormValid.value) return

  try {
    loading.value = true
    error.value = ''

    await transactionsStore.createTransaction({
      type: formData.value.type,
      date: new Date(formData.value.date).toISOString(),
      amount: parseFloat(formData.value.amount),
      description: formData.value.description
    })

    closeModal()
  } catch (err) {
    error.value = t('transactions.add.error')
    console.error('Error creating transaction:', err)
  } finally {
    loading.value = false
  }
}

function closeModal() {
  emit('close')
}
</script>