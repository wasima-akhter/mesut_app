import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> signIn({
    required String email,
    required String password,
    required UserRole role,
  });

  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  });

  Future<void> sendForgotPasswordOtp({required String email});

  Future<bool> verifyOtp({
    required String email,
    required String otp,
  });

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  });

  Future<void> logout();

  Future<AuthUser?> getCurrentUser();
}
