import { createRouter, createWebHistory } from 'vue-router'
import { supabase } from '../supabase'

// Views
import Assets from '../views/Assets.vue'
import Analytics from '../views/Analytics.vue'
import Settings from '../views/Settings.vue'
import Profile from '../views/Profile.vue'
import Login from '../views/auth/Login.vue'
import Register from '../views/auth/Register.vue'
import ResetPassword from '../views/auth/ResetPassword.vue'
import UpdatePassword from '../views/auth/UpdatePassword.vue'
import Transactions from '../views/Transactions.vue'
import NewTransaction from '../views/transactions/NewTransaction.vue'
import Budget from '../views/Budget.vue'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: Login,
    meta: { requiresAuth: false }
  },
  {
    path: '/register',
    name: 'Register',
    component: Register,
    meta: { requiresAuth: false }
  },
  {
    path: '/reset-password',
    name: 'ResetPassword',
    component: ResetPassword,
    meta: { requiresAuth: false }
  },
  {
    path: '/update-password',
    name: 'UpdatePassword',
    component: UpdatePassword,
    meta: { requiresAuth: false }
  },
  {
    path: '/profile',
    name: 'Profile',
    component: Profile,
    meta: { requiresAuth: true }
  },
  {
    path: '/assets',
    name: 'Assets',
    component: Assets,
    meta: { requiresAuth: true }
  },
  {
    path: '/analytics',
    name: 'Analytics',
    component: Analytics,
    meta: { requiresAuth: true }
  },
  {
    path: '/transactions',
    name: 'Transactions',
    component: Transactions,
    meta: { requiresAuth: true }
  },
  {
    path: '/transactions/new',
    name: 'NewTransaction',
    component: NewTransaction,
    meta: { requiresAuth: true }
  },
  {
    path: '/budget',
    name: 'Budget',
    component: Budget,
    meta: { requiresAuth: true }
  },
  {
    path: '/settings',
    name: 'Settings',
    component: Settings,
    meta: { requiresAuth: true }
  },
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/login'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to, from, next) => {
  try {
    const { data: { session } } = await supabase.auth.getSession()
    const requiresAuth = to.matched.some(record => record.meta.requiresAuth)

    if (requiresAuth && !session) {
      next('/login')
      return
    }

    if (to.path === '/login' && session) {
      next('/assets')
      return
    }

    next()
  } catch (error) {
    console.error('Router navigation error:', error)
    next('/login')
  }
})

export default router