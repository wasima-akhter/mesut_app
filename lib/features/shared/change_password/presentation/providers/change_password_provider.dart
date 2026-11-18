import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/app_error_resolver.dart';
import '../../domain/repositories/change_password_repository.dart';
import '../../data/repositories/change_password_repository_impl.dart';

class ChangePasswordState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const ChangePasswordState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ChangePasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isSuccess,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ChangePasswordNotifier extends Notifier<ChangePasswordState> {
  ChangePasswordRepository get _repository =>
      ref.read(changePasswordRepositoryProvider);

  @override
  ChangePasswordState build() => const ChangePasswordState();

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      final userMsg = AppErrorResolver.resolve(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: userMsg.displayMessage,
        isSuccess: false,
      );
      return false;
    }
  }

  void reset() {
    state = const ChangePasswordState();
  }
}

final changePasswordProvider = NotifierProvider.autoDispose<
    ChangePasswordNotifier, ChangePasswordState>(
  ChangePasswordNotifier.new,
);
