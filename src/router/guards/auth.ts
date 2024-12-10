```typescript
import { NavigationGuardNext, RouteLocationNormalized } from 'vue-router';
import { supabase } from '@/supabase';

export async function requireAuth(
  to: RouteLocationNormalized,
  from: RouteLocationNormalized,
  next: NavigationGuardNext
) {
  try {
    const { data: { session } } = await supabase.auth.getSession();
    
    if (!session) {
      // Save the intended destination
      const redirect = to.fullPath;
      next({
        path: '/login',
        query: { redirect }
      });
      return;
    }
    
    next();
  } catch (error) {
    console.error('Auth guard error:', error);
    next('/login');
  }
}

export async function requireNoAuth(
  to: RouteLocationNormalized,
  from: RouteLocationNormalized,
  next: NavigationGuardNext
) {
  try {
    const { data: { session } } = await supabase.auth.getSession();
    
    if (session) {
      next('/dashboard');
      return;
    }
    
    next();
  } catch (error) {
    console.error('No auth guard error:', error);
    next();
  }
}
```