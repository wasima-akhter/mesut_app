import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/app_enum.dart';
import '../../../../core/errors/app_error_resolver.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/providers/common_provider.dart';
import 'auth_device_helper.dart';
import 'auth_di_providers.dart';
import 'auth_state.dart';

mixin AuthOtpMixin on Notifier<AuthState> {
  UserFriendlyMessage _resolveOtpError(Object error) {
    final langCode = ref.read(appLanguageProvider).code;
    return AppErrorResolver.resolve(error, languageCode: langCode);
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
      final userMsg = _resolveOtpError(e);
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
    try {
      final devCtx = await AuthDeviceContext.resolve(ref);
      final session = await ref.read(authRepositoryProvider).verifyOtp(
        otp: otp,
        deviceIdentifier: devCtx.deviceIdentifier,
        fcmToken: devCtx.fcmToken,
        lat: devCtx.lat,
        lng: devCtx.lng,
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
      final userMsg = _resolveOtpError(e);
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
      final userMsg = _resolveOtpError(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: userMsg.displayMessage,
        userMessage: userMsg,
      );
      return false;
    }
  }
}
