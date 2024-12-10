/**
 * Handles registration errors and returns user-friendly messages
 */
export function handleRegistrationError(error) {
  // Log the full error for debugging
  console.error('Registration error details:', error);

  // Handle specific Supabase error cases
  if (error.__isAuthError) {
    switch (error.status) {
      case 400:
        return 'Invalid registration data. Please check your inputs.';
      case 422:
        return 'This email is already registered.';
      case 500:
        if (error.message?.includes('saving new user')) {
          return 'Unable to create user profile. Please try again.';
        }
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return error.message || 'Registration failed. Please try again.';
    }
  }

  // Handle other error types
  return error.message || 'An unexpected error occurred during registration.';
}

/**
 * Validates and formats registration data
 */
export function prepareRegistrationData(data) {
  return {
    email: data.email?.trim().toLowerCase(),
    password: data.password,
    options: {
      data: {
        first_name: data.first_name?.trim() || '',
        last_name: data.last_name?.trim() || null
      },
      emailRedirectTo: `${window.location.origin}/login`
    }
  };
}