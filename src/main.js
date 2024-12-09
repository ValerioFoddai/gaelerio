import { createApp } from 'vue'
import { createPinia } from 'pinia'
import i18n from './i18n'
import App from './App.vue'
import router from './router'
import './style.css'

const pinia = createPinia()
const app = createApp(App)

// Set initial language from localStorage or default to 'en'
const savedLanguage = localStorage.getItem('language')
if (savedLanguage) {
  i18n.global.locale.value = savedLanguage
}

app.use(pinia)
app.use(router)
app.use(i18n)

// Error handler
app.config.errorHandler = (err, instance, info) => {
  console.error('Global error:', err)
  console.error('Error info:', info)
}

// Warning handler
app.config.warnHandler = (msg, instance, trace) => {
  console.warn('Global warning:', msg)
  console.warn('Warning trace:', trace)
}

app.mount('#app')