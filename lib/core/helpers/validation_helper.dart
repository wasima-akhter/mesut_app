class ValidationHelper {
  ValidationHelper._();

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, fieldName: 'Email');

    if (requiredError != null) {
      return requiredError;
    }

    final emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');

    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? password(String? value, {int minimumLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minimumLength) {
      return 'Password must be at least $minimumLength characters';
    }

    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }
}
