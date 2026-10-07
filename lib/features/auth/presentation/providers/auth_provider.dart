import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

// DI Providers
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthLocalMockDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

// State
class AuthState {
  final bool isLoading;
  final AuthUser? user;
  final String? errorMessage;
  final UserRole selectedRole;
  final bool isSuccess;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.selectedRole = UserRole.employee,
    this.isSuccess = false,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    AuthUser? user,
    String? errorMessage,
    UserRole? selectedRole,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedRole: selectedRole ?? this.selectedRole,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Notifier
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    _checkPersistedUser();
    return const AuthState();
  }

  Future<void> _checkPersistedUser() async {
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(user: user, selectedRole: user.role);
      }
    } catch (_) {}
  }

  void selectRole(UserRole role) {
    state = state.copyWith(selectedRole: role, clearError: true);
  }

  Future<bool> signIn({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);
    try {
      final user = await _repository.signIn(
        email: email,
        password: password,
        role: role,
      );
      state = state.copyWith(
        isLoading: false,
        user: user,
        selectedRole: user.role,
        isSuccess: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
      return false;
    }
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);
    try {
      final user = await _repository.signUp(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      state = state.copyWith(
        isLoading: false,
        user: user,
        selectedRole: user.role,
        isSuccess: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
      return false;
    }
  }

  Future<bool> sendForgotPasswordOtp(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.sendForgotPasswordOtp(email: email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final valid = await _repository.verifyOtp(email: email, otp: otp);
      state = state.copyWith(isLoading: false);
      return valid;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.resetPassword(email: email, newPassword: newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authProvider).user;
});
