import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_error_resolver.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../data/dtos/recovery_dtos.dart';
import 'auth_provider.dart';

class PasswordRecoveryState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final UserFriendlyMessage? userMessage;
  final String? token;
  final String? email;
  final RecoverUserData? userData;
  final bool isOtpVerified;

  const PasswordRecoveryState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.userMessage,
    this.token,
    this.email,
    this.userData,
    this.isOtpVerified = false,
  });

  PasswordRecoveryState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    UserFriendlyMessage? userMessage,
    bool clearError = false,
    String? token,
    String? email,
    RecoverUserData? userData,
    bool? isOtpVerified,
  }) {
    return PasswordRecoveryState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: clearError ? null : (error ?? this.error),
      userMessage: clearError ? null : (userMessage ?? this.userMessage),
      token: token ?? this.token,
      email: email ?? this.email,
      userData: userData ?? this.userData,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
    );
  }
}

final passwordRecoveryProvider =
    NotifierProvider<PasswordRecoveryNotifier, PasswordRecoveryState>(
      PasswordRecoveryNotifier.new,
    );

class PasswordRecoveryNotifier extends Notifier<PasswordRecoveryState> {
  @override
  PasswordRecoveryState build() => const PasswordRecoveryState();

  UserFriendlyMessage _resolveError(Object error) {
    final langCode = ref.read(appLanguageProvider).code;
    return AppErrorResolver.resolve(error, languageCode: langCode);
  }

  void clear() {
    state = const PasswordRecoveryState();
  }

  Future<RecoverUserData?> sendRecoveryEmail(String email) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);
    try {
      final userData = await ref
          .read(authRepositoryProvider)
          .findUserForRecovery(email: email);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        token: userData.token,
        email: userData.email,
        userData: userData,
      );
      return userData;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        isLoading: false,
        error: userMsg.displayMessage,
        userMessage: userMsg,
      );
      return null;
    }
  }

  Future<bool> resendRecoveryOtp({String? token}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final effectiveToken = token ?? state.token;
      await ref
          .read(authRepositoryProvider)
          .resendRecoveryOtp(recoveryToken: effectiveToken);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        isLoading: false,
        error: userMsg.displayMessage,
        userMessage: userMsg,
      );
      return false;
    }
  }

  Future<bool> verifyRecoveryOtp(String otp, {String? token}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final effectiveToken = token ?? state.token;
      final success = await ref
          .read(authRepositoryProvider)
          .verifyRecoveryOtp(otp: otp, recoveryToken: effectiveToken);
      state = state.copyWith(isLoading: false, isOtpVerified: success);
      return success;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        isLoading: false,
        error: userMsg.displayMessage,
        userMessage: userMsg,
      );
      return false;
    }
  }

  Future<bool> resetPassword({
    required String newPassword,
    required String confirmPassword,
    String? token,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);
    try {
      final effectiveToken = token ?? state.token;
      await ref
          .read(authRepositoryProvider)
          .resetPasswordWithRecoveryToken(
            password: newPassword,
            confirmPassword: confirmPassword,
            recoveryToken: effectiveToken,
          );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      final userMsg = _resolveError(e);
      state = state.copyWith(
        isLoading: false,
        error: userMsg.displayMessage,
        userMessage: userMsg,
      );
      return false;
    }
  }
}

