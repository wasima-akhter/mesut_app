import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  const AuthRepositoryImpl(this._dataSource);

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
    required UserRole role,
  }) {
    return _dataSource.signIn(
      email: email,
      password: password,
      role: role,
    );
  }

  @override
  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) {
    return _dataSource.signUp(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      role: role,
    );
  }

  @override
  Future<void> sendForgotPasswordOtp({required String email}) {
    return _dataSource.sendForgotPasswordOtp(email: email);
  }

  @override
  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) {
    return _dataSource.verifyOtp(email: email, otp: otp);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) {
    return _dataSource.resetPassword(
      email: email,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> logout() {
    return _dataSource.logout();
  }

  @override
  Future<AuthUser?> getCurrentUser() {
    return _dataSource.getPersistedUser();
  }
}
