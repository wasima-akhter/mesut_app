import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants/route_constants.dart';
import '../enums/backend_enums.dart';
import '../errors/app_error_resolver.dart';
import '../storage/storage_provider.dart';
import '../storage/storage_service.dart';
import '../widgets/snack/app_snackbar.dart';

/// Centralized Session Manager responsible for managing auth session lifecycle,
/// detecting session expiration, wiping local auth data, notifying controllers,
/// showing user-friendly notifications, and redirecting to Sign In.
class SessionManager {
  SessionManager({required this.storageService});

  final StorageService storageService;
  bool _isHandlingSessionExpiry = false;
  DateTime? _lastSessionExpiryHandledAt;

  final List<VoidCallback> _authResetCallbacks = [];
  final List<Future<void> Function()> _asyncSessionCleanupCallbacks = [];
  GoRouter? _router;

  void attachRouter(GoRouter router) {
    _router = router;
  }

  void registerAuthResetCallback(VoidCallback callback) {
    if (!_authResetCallbacks.contains(callback)) {
      _authResetCallbacks.add(callback);
    }
  }

  void unregisterAuthResetCallback(VoidCallback callback) {
    _authResetCallbacks.remove(callback);
  }

  void registerAsyncCleanupCallback(Future<void> Function() callback) {
    if (!_asyncSessionCleanupCallbacks.contains(callback)) {
      _asyncSessionCleanupCallbacks.add(callback);
    }
  }

  void unregisterAsyncCleanupCallback(Future<void> Function() callback) {
    _asyncSessionCleanupCallbacks.remove(callback);
  }

  bool _isAlreadyOnAuthScreen() {
    try {
      final path = _router?.routerDelegate.currentConfiguration.uri.path;
      if (path == null) return false;
      return path == RouteConstants.splash ||
          path == RouteConstants.chooseLanguage ||
          path == RouteConstants.onboarding ||
          path == RouteConstants.signIn ||
          path == RouteConstants.signUp ||
          path == RouteConstants.forgotPassword ||
          path == RouteConstants.otp ||
          path == RouteConstants.resetPassword;
    } catch (_) {
      return false;
    }
  }

  @visibleForTesting
  void resetDebounce() {
    _isHandlingSessionExpiry = false;
    _lastSessionExpiryHandledAt = null;
  }

  Future<void> handleSessionExpired({
    String? customMessage,
    String? languageCode,
  }) async {
    final now = DateTime.now();
    if (_isHandlingSessionExpiry ||
        (_lastSessionExpiryHandledAt != null &&
            now.difference(_lastSessionExpiryHandledAt!).inMilliseconds <
                1500)) {
      return;
    }
    _isHandlingSessionExpiry = true;
    _lastSessionExpiryHandledAt = now;

    try {
      if (_isAlreadyOnAuthScreen()) {
        return;
      }

      await storageService.clearAuthentication();
      await storageService.clearFcmToken();

      for (final callback in List<Future<void> Function()>.from(
        _asyncSessionCleanupCallbacks,
      )) {
        try {
          await callback();
        } catch (e) {
          debugPrint('SessionManager: Error executing async cleanup: $e');
        }
      }

      for (final callback in List<VoidCallback>.from(_authResetCallbacks)) {
        try {
          callback();
        } catch (e) {
          debugPrint('SessionManager: Error executing auth reset callback: $e');
        }
      }

      final effectiveLang =
          languageCode ?? storageService.selectedLanguage ?? 'en';
      final resolved = AppErrorResolver.resolve(
        customMessage ?? ApiErrorType.sessionExpired,
        languageCode: effectiveLang,
      );

      AppSnackBar.error(resolved.displayMessage, title: resolved.title);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          if (_router != null) {
            _router!.go(RouteConstants.signIn);
          } else if (appNavigatorKey.currentContext != null) {
            GoRouter.of(
              appNavigatorKey.currentContext!,
            ).go(RouteConstants.signIn);
          }
        } catch (navError) {
          debugPrint('SessionManager: Navigation error: $navError');
        }
      });
    } finally {
      _isHandlingSessionExpiry = false;
    }
  }
}

final sessionManagerProvider = Provider<SessionManager>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SessionManager(storageService: storage);
});
