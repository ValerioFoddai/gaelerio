```typescript
import { createRouter, createWebHistory } from 'vue-router';
import { requireAuth, requireNoAuth } from './guards/auth';

// Views
import Login from '../views/auth/Login.vue';
import Register from '../views/auth/Register.vue';
import ResetPassword from '../views/auth/ResetPassword.vue';
import UpdatePassword from '../views/auth/UpdatePassword.vue';
import Dashboard from '../views/Dashboard.vue';
import Assets from '../views/Assets.vue';
import Analytics from '../views/Analytics.vue';
import Transactions from '../views/Transactions.vue';
import Budget from '../views/Budget.vue';
import Settings from '../views/Settings.vue';
import Profile from '../views/Profile.vue';

const routes = [
  // Public routes
  {
    path: '/login',
    name: 'Login',
    component: Login,
    beforeEnter: requireNoAuth
  },
  {
    path: '/register',
    name: 'Register',
    component: Register,
    beforeEnter: requireNoAuth
  },
  {
    path: '/reset-password',
    name: 'ResetPassword',
    component: ResetPassword,
    beforeEnter: requireNoAuth
  },
  {
    path: '/update-password',
    name: 'UpdatePassword',
    component: UpdatePassword,
    beforeEnter: requireNoAuth
  },

  // Protected routes
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: Dashboard,
    beforeEnter: requireAuth
  },
  {
    path: '/assets',
    name: 'Assets',
    component: Assets,
    beforeEnter: requireAuth
  },
  {
    path: '/analytics',
    name: 'Analytics',
    component: Analytics,
    beforeEnter: requireAuth
  },
  {
    path: '/transactions',
    name: 'Transactions',
    component: Transactions,
    beforeEnter: requireAuth
  },
  {
    path: '/budget',
    name: 'Budget',
    component: Budget,
    beforeEnter: requireAuth
  },
  {
    path: '/settings',
    name: 'Settings',
    component: Settings,
    beforeEnter: requireAuth
  },
  {
    path: '/profile',
    name: 'Profile',
    component: Profile,
    beforeEnter: requireAuth
  },

  // Default routes
  {
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/login'
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

// Global navigation guard for session handling
router.beforeEach(async (to, from, next) => {
  try {
    // Check if route requires auth
    const requiresAuth = to.matched.some(record => record.beforeEnter === requireAuth);
    
    if (!requiresAuth) {
      next();
      return;
    }

    const { data: { session } } = await supabase.auth.getSession();
    if (!session) {
      next({
        path: '/login',
        query: { redirect: to.fullPath }
      });
      return;
    }

    next();
  } catch (error) {
    console.error('Navigation guard error:', error);
    next('/login');
  }
});

export default router;
```