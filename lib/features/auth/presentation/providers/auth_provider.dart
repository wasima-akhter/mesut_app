import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/app_enum.dart';
import '../../../../core/errors/app_error_resolver.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/providers/common_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/notification_socket_service.dart';
import '../../../../core/session/session_invalidator.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/storage/storage_provider.dart';
import 'auth_device_helper.dart';
import 'auth_di_providers.dart';
import 'auth_otp_mixin.dart';
import 'auth_state.dart';

export 'auth_di_providers.dart';
export 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> with AuthOtpMixin {
  DateTime? _lastHeartbeatAt;
  bool _isHeartbeatRunning = false;

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
    try {
      ref.read(notificationSocketServiceProvider).disconnect();
    } catch (_) {}
    clearUserSessionState(ref);
    ref.read(userRoleProvider.notifier).clearRole();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Periodic / lifecycle heartbeat (`POST /auth/check`) syncing GPS and rotated FCM token.
  Future<void> heartbeatCheck({bool throttle = true}) async {
    if (_isHeartbeatRunning || !state.isAuthenticated) return;

    final now = DateTime.now();
    if (throttle &&
        _lastHeartbeatAt != null &&
        now.difference(_lastHeartbeatAt!).inSeconds < 60) {
      return;
    }

    _isHeartbeatRunning = true;
    try {
      final storageService = ref.read(storageServiceProvider);
      final hasValid = await storageService.hasValidAccessToken();
      if (!hasValid) return;

      final devCtx = await AuthDeviceContext.resolve(ref);
      final user = await ref
          .read(authRepositoryProvider)
          .checkSession(
            deviceIdentifier: devCtx.deviceIdentifier,
            fcmToken: devCtx.fcmToken,
            lat: devCtx.lat,
            lng: devCtx.lng,
          );

      _lastHeartbeatAt = DateTime.now();
      if (user != null && ref.mounted) {
        ref.read(userRoleProvider.notifier).setRole(user.role);
        state = state.copyWith(user: user, selectedRole: user.role);
      }
    } catch (e) {
      debugPrint('Heartbeat check warning: $e');
    } finally {
      _isHeartbeatRunning = false;
    }
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
      final hasValidToken = await storageService.hasValidAccessToken().timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () => false,
      );
      if (!hasValidToken) {
        final hasToken = await storageService.hasAccessToken().timeout(
          const Duration(milliseconds: 1000),
          onTimeout: () => false,
        );
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

      // Fast-path: If user has a valid unexpired token and cached user,
      // authenticate instantly without blocking the splash screen!
      final cachedUser = ref.read(authRepositoryProvider).getCurrentUser();
      final cachedRole =
          cachedUser?.role ??
          UserRoleExtension.fromString(storageService.getUserRole());

      if (cachedUser != null && cachedRole != null) {
        ref.read(userRoleProvider.notifier).setRole(cachedRole);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: cachedUser,
          selectedRole: cachedRole,
          isLoading: false,
        );
        unawaited(heartbeatCheck(throttle: false));
        return true;
      }

      state = state.copyWith(isLoading: true, clearError: true);
      final devCtx = await AuthDeviceContext.resolve(ref);
      final user = await ref
          .read(authRepositoryProvider)
          .checkSession(
            deviceIdentifier: devCtx.deviceIdentifier,
            fcmToken: devCtx.fcmToken,
            lat: devCtx.lat,
            lng: devCtx.lng,
          )
          .timeout(const Duration(seconds: 3), onTimeout: () => null);

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
      final devCtx = await AuthDeviceContext.resolve(ref);
      final session = await ref
          .read(authRepositoryProvider)
          .login(
            email: email,
            password: password,
            role: role,
            deviceIdentifier: devCtx.deviceIdentifier,
            rememberMe: rememberMe,
            fcmToken: devCtx.fcmToken,
            lat: devCtx.lat,
            lng: devCtx.lng,
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
          AppErrorResolver.resolve({
            'errorType': 'USER_SUSPENDED',
          }, languageCode: ref.read(appLanguageProvider).code),
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

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).logout();
    } finally {
      try {
        ref.read(notificationSocketServiceProvider).disconnect();
      } catch (_) {}
      try {
        await ref.read(pushNotificationServiceProvider).clearTokenOnLogout();
      } catch (_) {}
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
