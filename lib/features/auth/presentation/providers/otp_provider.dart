import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_error_resolver.dart';
import '../../../../core/localization/localization_provider.dart';
import '../screens/otp_page.dart';
import 'auth_provider.dart';
import 'password_recovery_provider.dart';

class OtpState {
  final String otp;
  final int timerSeconds;
  final bool canResend;
  final bool isVerifying;
  final bool isResending;
  final String? error;

  const OtpState({
    this.otp = '',
    this.timerSeconds = 59,
    this.canResend = false,
    this.isVerifying = false,
    this.isResending = false,
    this.error,
  });

  OtpState copyWith({
    String? otp,
    int? timerSeconds,
    bool? canResend,
    bool? isVerifying,
    bool? isResending,
    String? error,
    bool clearError = false,
  }) {
    return OtpState(
      otp: otp ?? this.otp,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      canResend: canResend ?? this.canResend,
      isVerifying: isVerifying ?? this.isVerifying,
      isResending: isResending ?? this.isResending,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final otpControllerProvider =
    NotifierProvider.autoDispose<OtpController, OtpState>(OtpController.new);

class OtpController extends Notifier<OtpState> {
  Timer? _timer;

  @override
  OtpState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });

    _startCountdownTimer();
    return const OtpState(timerSeconds: 59, canResend: false);
  }

  void _startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timerSeconds > 1) {
        state = state.copyWith(timerSeconds: state.timerSeconds - 1);
      } else {
        timer.cancel();
        state = state.copyWith(timerSeconds: 0, canResend: true);
      }
    });
  }

  void resetTimer() {
    state = state.copyWith(timerSeconds: 59, canResend: false);
    _startCountdownTimer();
  }

  void updateOtp(String code) {
    state = state.copyWith(otp: code, clearError: true);
  }

  Future<bool> resendOtp(
    OtpPurpose purpose, {
    String? otpPageToken,
    String? recoveryToken,
  }) async {
    if (!state.canResend || state.isResending) return false;
    state = state.copyWith(isResending: true, clearError: true);
    try {
      if (purpose == OtpPurpose.signUp) {
        final success = await ref
            .read(authProvider.notifier)
            .resendOtp(otpPageToken: otpPageToken);
        if (!success) {
          state = state.copyWith(error: ref.read(authProvider).errorMessage);
          return false;
        }
      } else {
        final token = recoveryToken ?? ref.read(passwordRecoveryProvider).token;
        final success = await ref
            .read(passwordRecoveryProvider.notifier)
            .resendRecoveryOtp(token: token);
        if (!success) {
          state = state.copyWith(
            error: ref.read(passwordRecoveryProvider).error,
          );
          return false;
        }
      }
      resetTimer();
      return true;
    } catch (e) {
      final msg = AppErrorResolver.resolve(
        e,
        languageCode: ref.read(appLanguageProvider).code,
      );
      state = state.copyWith(error: msg.displayMessage);
      return false;
    } finally {
      state = state.copyWith(isResending: false);
    }
  }

  Future<bool> verifyOtp(
    OtpPurpose purpose, {
    String? otpPageToken,
    String? recoveryToken,
  }) async {
    final code = state.otp.trim();
    if (code.length != 6) return false;

    state = state.copyWith(isVerifying: true, clearError: true);
    try {
      if (purpose == OtpPurpose.signUp) {
        final success = await ref
            .read(authProvider.notifier)
            .verifyOtp(otp: code, otpPageToken: otpPageToken);
        if (!success) {
          state = state.copyWith(
            isVerifying: false,
            error: ref.read(authProvider).errorMessage,
          );
          return false;
        }
        state = state.copyWith(isVerifying: false);
        return true;
      } else {
        final token = recoveryToken ?? ref.read(passwordRecoveryProvider).token;
        final success = await ref
            .read(passwordRecoveryProvider.notifier)
            .verifyRecoveryOtp(code, token: token);
        if (!success) {
          state = state.copyWith(
            isVerifying: false,
            error: ref.read(passwordRecoveryProvider).error,
          );
          return false;
        }
        state = state.copyWith(isVerifying: false);
        return true;
      }
    } catch (e) {
      final msg = AppErrorResolver.resolve(
        e,
        languageCode: ref.read(appLanguageProvider).code,
      );
      state = state.copyWith(isVerifying: false, error: msg.displayMessage);
      return false;
    }
  }
}
