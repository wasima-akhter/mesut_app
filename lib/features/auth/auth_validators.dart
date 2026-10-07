// lib/features/auth/auth_validators.dart

import '../../core/localization/app_localization.dart';

class AuthValidators {
  AuthValidators._();

  static String? name(String value) {
    final name = value.trim();

    if (name.isEmpty) {
      return AppLocalization.current.nameRequired;
    }

    if (name.length < 2) {
      return AppLocalization.current.nameRequired;
    }

    return null;
  }

  static String? phone(String value) {
    final phone = value.trim();

    if (phone.isEmpty) {
      return AppLocalization.current.phoneRequired;
    }

    final phoneRegex = RegExp(r'^[0-9+\-\s()]{7,20}$');

    if (!phoneRegex.hasMatch(phone)) {
      return AppLocalization.current.phoneRequired;
    }

    return null;
  }

  static String? email(String value) {
    final email = value.trim();

    if (email.isEmpty) {
      return AppLocalization.current.emailRequired;
    }

    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(email)) {
      return AppLocalization.current.invalidEmail;
    }

    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) {
      return AppLocalization.current.passwordRequired;
    }

    if (value.length < 6) {
      return AppLocalization.current.passwordTooShort;
    }

    return null;
  }

  static String? confirmPassword(String password, String confirmation) {
    if (confirmation.isEmpty) {
      return AppLocalization.current.passwordConfirmRequired;
    }

    if (password != confirmation) {
      return AppLocalization.current.passwordsDoNotMatch;
    }

    return null;
  }

  static String? otp(String value) {
    if (value.length < 4) {
      return AppLocalization.current.otpRequired;
    }

    return null;
  }
}
