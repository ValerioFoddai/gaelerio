import { createClientComponentClient } from '@supabase/auth-helpers-nextjs';
import type { AuthError, User } from '@supabase/supabase-js';

export interface SignUpData {
  first_name: string;
  last_name: string;
  email: string;
  password: string;
}

export interface AuthResponse {
  user: User | null;
  error: AuthError | null;
}

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

const supabase = createClientComponentClient({
  supabaseUrl,
  supabaseKey: supabaseAnonKey,
});

export async function signUpUser(data: SignUpData): Promise<AuthResponse> {
  try {
    // Create auth user
    const { data: authData, error: signUpError } = await supabase.auth.signUp({
      email: data.email,
      password: data.password,
      options: {
        data: {
          first_name: data.first_name,
          last_name: data.last_name
        }
      }
    });

    if (signUpError) throw signUpError;

    return { user: authData.user, error: null };
  } catch (error) {
    console.error('SignUp error:', error);
    return { user: null, error: error as AuthError };
  }
}

export async function signInUser(email: string, password: string): Promise<AuthResponse> {
  try {
    const { data: { user }, error } = await supabase.auth.signInWithPassword({
      email,
      password
    });

    if (error) throw error;
    return { user, error: null };
  } catch (error) {
    console.error('SignIn error:', error);
    return { user: null, error: error as AuthError };
  }
}

export async function resetPassword(email: string): Promise<{ error: AuthError | null }> {
  try {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/auth/update-password`
    });

    if (error) throw error;
    return { error: null };
  } catch (error) {
    console.error('Reset password error:', error);
    return { error: error as AuthError };
  }
}

export async function updatePassword(password: string): Promise<{ error: AuthError | null }> {
  try {
    const { error } = await supabase.auth.updateUser({
      password
    });

    if (error) throw error;
    return { error: null };
  } catch (error) {
    console.error('Update password error:', error);
    return { error: error as AuthError };
  }
}

export async function signOut(): Promise<{ error: AuthError | null }> {
  try {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
    return { error: null };
  } catch (error) {
    console.error('SignOut error:', error);
    return { error: error as AuthError };
  }
}

export function formatAuthError(error: AuthError): string {
  if (!error) return '';

  switch (error.message) {
    case 'Invalid login credentials':
      return 'Invalid email or password';
    case 'User already registered':
      return 'Email already registered';
    case 'Password should be at least 6 characters':
      return 'Password must be at least 6 characters';
    default:
      return error.message;
  }
}
