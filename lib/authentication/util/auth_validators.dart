String? validateEmail(String email) {
  if (email.isEmpty || !email.contains('@')) {
    return 'Please enter a valid email.';
  }
  return null;
}

String? validatePassword(String password) {
  if (password.length < 6) {
    return 'Password must be at least 6 characters.';
  }
  return null;
}

String? validateUsername(String username) {
  if (username.trim().isEmpty) {
    return 'Username is required.';
  }
  return null;
}

String? validateConfirmPassword(String password, String confirmPassword) {
  if (password != confirmPassword) {
    return 'Passwords do not match.';
  }
  return null;
}