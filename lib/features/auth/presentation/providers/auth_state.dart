import '../../../../core/enums/app_enum.dart';
import '../../../../core/errors/app_error_resolver.dart';
import '../../domain/entities/auth_user.dart';

enum AuthStatus {
  initial,
  unauthenticated,
  otpPending,
  authenticated,
  suspended,
  error,
}

enum LoginOutcome {
  authenticated,
  otpVerificationRequired,
  suspended,
  error,
}

class AuthState {
  final AuthStatus status;
  final bool isLoading;
  final AuthUser? user;
  final String? accessToken;
  final String? otpPageToken;
  final String? errorMessage;
  final UserFriendlyMessage? userMessage;
  final UserRole selectedRole;
  final bool rememberMe;
  final bool isSuccess;

  const AuthState({
    this.status = AuthStatus.initial,
    this.isLoading = false,
    this.user,
    this.accessToken,
    this.otpPageToken,
    this.errorMessage,
    this.userMessage,
    this.selectedRole = UserRole.employee,
    this.rememberMe = false,
    this.isSuccess = false,
  });

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    AuthUser? user,
    bool clearUser = false,
    String? accessToken,
    String? otpPageToken,
    String? errorMessage,
    UserFriendlyMessage? userMessage,
    UserRole? selectedRole,
    bool? rememberMe,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      accessToken: accessToken ?? this.accessToken,
      otpPageToken: otpPageToken ?? this.otpPageToken,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      userMessage: clearError ? null : (userMessage ?? this.userMessage),
      selectedRole: selectedRole ?? this.selectedRole,
      rememberMe: rememberMe ?? this.rememberMe,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
