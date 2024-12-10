/**
 * Validates registration form data
 * @param {Object} data Registration form data
 * @returns {Object} Validation result with errors if any
 */
export function validateRegistration(data) {
  const errors = {};

  if (!data.email?.trim()) {
    errors.email = 'Email is required';
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email)) {
    errors.email = 'Please enter a valid email address';
  }

  if (!data.password?.trim()) {
    errors.password = 'Password is required';
  } else if (data.password.length < 6) {
    errors.password = 'Password must be at least 6 characters';
  }

  if (!data.firstName?.trim()) {
    errors.firstName = 'First name is required';
  }

  return {
    isValid: Object.keys(errors).length === 0,
    errors
  };
}

/**
 * Formats auth error messages for display
 * @param {Error} error Auth error object
 * @returns {string} Formatted error message
 */
export function formatAuthError(error) {
  if (!error) return '';

  // Handle Supabase specific errors
  if (error.__isAuthError) {
    switch (error.status) {
      case 400:
        return 'Invalid email or password format';
      case 422:
        return 'Email already registered';
      case 500:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return error.message || 'Authentication failed';
    }
  }

  // Handle other error types
  switch (error.code) {
    case 'auth/email-already-in-use':
      return 'This email is already registered';
    case 'auth/invalid-email':
      return 'Please enter a valid email address';
    case 'auth/weak-password':
      return 'Password must be at least 6 characters';
    case 'auth/user-disabled':
      return 'This account has been disabled';
    case 'auth/user-not-found':
    case 'auth/wrong-password':
      return 'Invalid email or password';
    default:
      return error.message || 'An unexpected error occurred';
  }
}

/**
 * Sanitizes user data for registration
 * @param {Object} data User registration data
 * @returns {Object} Sanitized data
 */
export function sanitizeUserData(data) {
  return {
    email: data.email?.trim().toLowerCase(),
    password: data.password,
    first_name: data.firstName?.trim(),
    last_name: data.lastName?.trim()
  };
}