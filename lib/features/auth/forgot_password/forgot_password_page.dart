// lib/features/auth/screens/forgot_password_screen.dart

import 'package:construction_app/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/route_constants.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/localization/app_localization.dart';
import '../../../core/widgets/fields/app_text_field.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import '../auth_validators.dart';
import '../otp/otp_page.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_screen_container.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final error = AuthValidators.email(_emailController.text);

    if (error != null) {
      AppSnackBar.error(error);
      return;
    }

    AppSnackBar.success(AppLocalization.current.success);

    context.push(
      RouteConstants.otp,
      extra: {'email': _emailController.text.trim(), 'purpose': OtpPurpose.forgotPassword},
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.current;

    return AuthScreenContainer(
      child: Column(
        children: [
          AuthHeader(
            title: loc.forgotPasswordTitle,
            subtitle: loc.forgotPasswordSubtitle,
          ),

          SizedBox(height: 34.h),

          _label(loc.workEmail),

          SizedBox(height: 5.h),

          AppTextField(
            controller: _emailController,
            type: AppTextFieldType.email,
            hint: loc.enterEmail,
            borderRadius: 5,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 10.h,
            ),
          ),

          SizedBox(height: 14.h),

          _AuthButton(text: loc.sendResetLink, onPressed: _sendOtp),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
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
