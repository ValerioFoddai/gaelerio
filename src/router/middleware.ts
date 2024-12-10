import { NavigationGuardNext, RouteLocationNormalized } from 'vue-router';
import { supabase } from '../supabase';

export async function authMiddleware(
  to: RouteLocationNormalized,
  from: RouteLocationNormalized,
  next: NavigationGuardNext
) {
  try {
    const { data: { session } } = await supabase.auth.getSession();
    const requiresAuth = to.matched.some(record => record.meta.requiresAuth);

    if (requiresAuth && !session) {
      next('/login');
      return;
    }

    if (to.path === '/login' && session) {
      next('/dashboard');
      return;
    }

    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    next('/login');
  }
}