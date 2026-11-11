import 'package:construction_app/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants/route_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/widgets/fields/app_text_field.dart';
import '../../../../core/widgets/snack/app_snackbar.dart';
import '../providers/password_recovery_provider.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_screen_container.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String? recoveryToken;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    this.recoveryToken,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final loc = context.loc;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final passwordError = AuthValidators.password(password);
    if (passwordError != null) {
      AppSnackBar.error(passwordError);
      return;
    }

    final confirmError = AuthValidators.confirmPassword(
      password,
      confirmPassword,
    );
    if (confirmError != null) {
      AppSnackBar.error(confirmError);
      return;
    }

    final success = await ref
        .read(passwordRecoveryProvider.notifier)
        .resetPassword(
          newPassword: password,
          confirmPassword: confirmPassword,
          token: widget.recoveryToken,
        );

    if (!mounted) return;

    if (success) {
      AppSnackBar.success(loc.passwordChangedSuccess);
      context.go(RouteConstants.signIn);
    } else {
      final state = ref.read(passwordRecoveryProvider);
      AppSnackBar.error(
        state.error ?? loc.error,
        title: state.userMessage?.title,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final state = ref.watch(passwordRecoveryProvider);

    return AuthScreenContainer(
      child: Column(
        children: [
          AuthHeader(
            title: loc.resetPassword,
            subtitle: loc.resetPasswordSubtitle,
          ),

          SizedBox(height: 32.h),

          _label(loc.createPassword),

          SizedBox(height: 5.h),

          AppTextField(
            controller: _passwordController,
            type: AppTextFieldType.password,
            hint: loc.enterPassword,
            borderRadius: 5,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 10.h,
            ),
          ),

          SizedBox(height: 14.h),

          _label(loc.confirmPassword),

          SizedBox(height: 5.h),

          AppTextField(
            controller: _confirmPasswordController,
            type: AppTextFieldType.password,
            hint: loc.reenterPassword,
            borderRadius: 5,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 10.h,
            ),
          ),

          SizedBox(height: 36.h),

          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: loc.saveChanges,
              isLoading: state.isLoading,
              onPressed: state.isLoading ? null : _changePassword,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

