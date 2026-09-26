// lib/features/auth/auth_validators.dart

class AuthValidators {
  AuthValidators._();

  static String? name(String value) {
    final name = value.trim();

    if (name.isEmpty) {
      return 'Name is required';
    }

    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  static String? phone(String value) {
    final phone = value.trim();

    if (phone.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^[0-9+\-\s()]{7,20}$');

    if (!phoneRegex.hasMatch(phone)) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  static String? email(String value) {
    final email = value.trim();

    if (email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  static String? confirmPassword(String password, String confirmation) {
    if (confirmation.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmation) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? otp(String value) {
    if (value.length != 6) {
      return 'Enter the 6-digit verification code';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Enter a valid verification code';
    }

    return null;
  }
}
