import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/app_enum.dart';
import '../../../../core/errors/app_error_resolver.dart';
import '../../../../core/helpers/device_location_helper.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/providers/common_provider.dart';
import '../../../../core/session/session_invalidator.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/storage/storage_provider.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

// DI Providers
final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    apiClient: ref.watch(apiClientProvider),
    config: ref.watch(appConfigProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authDataSourceProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

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

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final repository = ref.watch(authRepositoryProvider);
    final storageService = ref.watch(storageServiceProvider);
    final sessionManager = ref.watch(sessionManagerProvider);

    sessionManager.registerAuthResetCallback(_onSessionExpired);
    ref.onDispose(() {
      sessionManager.unregisterAuthResetCallback(_onSessionExpired);
    });

    final cachedUser = repository.getCurrentUser();
    final rememberMe = storageService.rememberMe;

    if (cachedUser != null) {
      return AuthState(
        status: AuthStatus.authenticated,
        user: cachedUser,
        selectedRole: cachedUser.role,
        rememberMe: rememberMe,
      );
    }

    return AuthState(
      status: AuthStatus.unauthenticated,
      rememberMe: rememberMe,
    );
  }

  void _onSessionExpired() {
    clearUserSessionState(ref);
    ref.read(userRoleProvider.notifier).clearRole();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  UserFriendlyMessage _resolveError(Object error) {
    final langCode = ref.read(appLanguageProvider).code;
    return AppErrorResolver.resolve(error, languageCode: langCode);
  }

  void selectRole(UserRole role) {
    state = state.copyWith(selectedRole: role, clearError: true);
  }

  Future<bool> checkSession() async {
    final storageService = ref.read(storageServiceProvider);
    try {
      final hasValidToken = await storageService
          .hasValidAccessToken()
          .timeout(const Duration(seconds: 2), onTimeout: () => false);
      if (!hasValidToken) {
        final hasToken = await storageService
            .hasAccessToken()
            .timeout(const Duration(seconds: 2), onTimeout: () => false);
        if (hasToken) {
          await storageService.clearAuthentication();
        }
        ref.read(userRoleProvider.notifier).clearRole();
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          isLoading: false,
        );
        return false;
      }

      state = state.copyWith(isLoading: true, clearError: true);

      final deviceId = await storageService.getOrCreateDeviceIdentifier();
      final fcmToken = await storageService.getFcmToken();
      final coords = await DeviceLocationHelper.tryGetCoordinates();

      final user = await ref.read(authRepositoryProvider).checkSession(
        deviceIdentifier: deviceId,
        fcmToken: fcmToken,
        lat: coords?.lat,
        lng: coords?.lng,
      );

      if (user != null) {
        ref.read(userRoleProvider.notifier).setRole(user.role);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          selectedRole: user.role,
          isLoading: false,
        );
        return true;
      }

      ref.read(userRoleProvider.notifier).clearRole();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        isLoading: false,
      );
      return false;
    } catch (e) {
      final userMsg = _resolveError(e);
      ref.read(userRoleProvider.notifier).clearRole();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
        isLoading: false,
      );
      return false;
    }
  }

  Future<LoginOutcome> signIn({
    required String email,
    required String password,
    required UserRole role,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);
    final storageService = ref.read(storageServiceProvider);
    try {
      final deviceId = await storageService.getOrCreateDeviceIdentifier();
      final fcmToken = await storageService.getFcmToken();
      final coords = await DeviceLocationHelper.tryGetCoordinates();

      final session = await ref.read(authRepositoryProvider).login(
        email: email,
        password: password,
        role: role,
        deviceIdentifier: deviceId,
        rememberMe: rememberMe,
        fcmToken: fcmToken,
        lat: coords?.lat,
        lng: coords?.lng,
      );

      ref.read(userRoleProvider.notifier).setRole(session.user.role);

      if (session.user.isInactive) {
        if (session.accessToken.isNotEmpty) {
          await storageService.saveOtpPageToken(session.accessToken);
        }
        try {
          await ref.read(authRepositoryProvider).resendOtp();
          state = state.copyWith(
            status: AuthStatus.otpPending,
            user: session.user,
            selectedRole: session.user.role,
            otpPageToken: session.accessToken,
            isLoading: false,
          );
          return LoginOutcome.otpVerificationRequired;
        } catch (resendError) {
          final userMsg = _resolveError(resendError);
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: userMsg.displayMessage,
            userMessage: userMsg,
            isLoading: false,
          );
          return LoginOutcome.error;
        }
      }

      if (session.user.isSuspended) {
        final userMsg = _resolveError(
          AppErrorResolver.resolve(
            {'errorType': 'USER_SUSPENDED'},
            languageCode: ref.read(appLanguageProvider).code,
          ),
        );
        state = state.copyWith(
          status: AuthStatus.suspended,
          user: session.user,
          selectedRole: session.user.role,
          errorMessage: userMsg.displayMessage,
          userMessage: userMsg,
          isLoading: false,
        );
        return LoginOutcome.suspended;
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: session.user,
        selectedRole: session.user.role,
        accessToken: session.accessToken,
        rememberMe: rememberMe,
        isLoading: false,
        isSuccess: true,
      );
      return LoginOutcome.authenticated;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
        isLoading: false,
        isSuccess: false,
      );
      return LoginOutcome.error;
    }
  }

  Future<String?> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);
    try {
      final otpPageToken = await ref.read(authRepositoryProvider).signUp(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      state = state.copyWith(
        status: AuthStatus.otpPending,
        otpPageToken: otpPageToken,
        selectedRole: role,
        isLoading: false,
        isSuccess: true,
      );
      return otpPageToken;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
        isLoading: false,
        isSuccess: false,
      );
      return null;
    }
  }

  Future<bool> verifyOtp({
    required String otp,
    String? otpPageToken,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);
    final storageService = ref.read(storageServiceProvider);
    try {
      final deviceId = await storageService.getOrCreateDeviceIdentifier();
      final fcmToken = await storageService.getFcmToken();
      final coords = await DeviceLocationHelper.tryGetCoordinates();

      final session = await ref.read(authRepositoryProvider).verifyOtp(
        otp: otp,
        deviceIdentifier: deviceId,
        fcmToken: fcmToken,
        lat: coords?.lat,
        lng: coords?.lng,
        otpPageToken: otpPageToken ?? state.otpPageToken,
      );

      ref.read(userRoleProvider.notifier).setRole(session.user.role);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: session.user,
        selectedRole: session.user.role,
        accessToken: session.accessToken,
        isLoading: false,
        isSuccess: true,
      );
      return true;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
        isLoading: false,
        isSuccess: false,
      );
      return false;
    }
  }

  Future<bool> resendOtp({String? otpPageToken}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).resendOtp(
        otpPageToken: otpPageToken ?? state.otpPageToken,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).logout();
    } finally {
      clearUserSessionState(ref);
      ref.read(userRoleProvider.notifier).clearRole();
      state = AuthState(
        status: AuthStatus.unauthenticated,
        rememberMe: ref.read(storageServiceProvider).rememberMe,
      );
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authProvider).user;
});
