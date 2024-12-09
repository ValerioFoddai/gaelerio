import { createRouter, createWebHistory } from 'vue-router'
import { useAdminStore } from '../stores/admin'

// Admin Views
import AdminDashboard from '../views/admin/Dashboard.vue'
import AdminUsers from '../views/admin/Users.vue'
import AdminSettings from '../views/admin/Settings.vue'

const routes = [
  {
    path: '/admin',
    name: 'AdminDashboard',
    component: AdminDashboard,
    meta: { requiresAdmin: true }
  },
  {
    path: '/admin/users',
    name: 'AdminUsers',
    component: AdminUsers,
    meta: { requiresAdmin: true }
  },
  {
    path: '/admin/settings',
    name: 'AdminSettings',
    component: AdminSettings,
    meta: { requiresSuperAdmin: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to, from, next) => {
  const adminStore = useAdminStore()
  
  if (to.matched.some(record => record.meta.requiresAdmin)) {
    const isAdmin = await adminStore.checkAdminStatus()
    
    if (!isAdmin) {
      next('/login')
      return
    }

    if (to.matched.some(record => record.meta.requiresSuperAdmin) && !adminStore.isSuperAdmin) {
      next('/admin')
      return
    }

    next()
  } else {
    next()
  }
})

export default router