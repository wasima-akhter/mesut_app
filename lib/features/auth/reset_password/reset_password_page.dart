// lib/features/auth/screens/change_password_screen.dart

import 'package:construction_app/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/localization/app_localization.dart';
import '../../../core/widgets/fields/app_text_field.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import '../auth_validators.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_screen_container.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    final passwordError = AuthValidators.password(_passwordController.text);

    if (passwordError != null) {
      AppSnackBar.error(passwordError);
      return;
    }

    final confirmError = AuthValidators.confirmPassword(
      _passwordController.text,
      _confirmPasswordController.text,
    );

    if (confirmError != null) {
      AppSnackBar.error(confirmError);
      return;
    }

    AppSnackBar.success(AppLocalization.current.passwordChangedSuccess);

    // TODO: call reset password API

    context.go(RouteConstants.signIn);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.current;

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

          _AuthButton(text: loc.saveChanges, onPressed: _changePassword),
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

class _AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _AuthButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppButton(onPressed: onPressed, text: text),
    );
  }
}
