// lib/features/auth/screens/sign_up_screen.dart

import 'package:construction_app/app/constants/route_constants.dart';
import 'package:construction_app/app/theme/app_text_styles.dart';
import 'package:construction_app/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localization.dart';
import '../../../core/widgets/fields/app_text_field.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import '../auth_validators.dart';
import '../otp/otp_page.dart';
import '../widgets/auth_screen_container.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    final nameError = AuthValidators.name(_nameController.text);

    if (nameError != null) {
      AppSnackBar.error(nameError);
      return;
    }

    final phoneError = AuthValidators.phone(_phoneController.text);

    if (phoneError != null) {
      AppSnackBar.error(phoneError);
      return;
    }

    final emailError = AuthValidators.email(_emailController.text);

    if (emailError != null) {
      AppSnackBar.error(emailError);
      return;
    }

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

    AppSnackBar.success(AppLocalization.current.success);

    // TODO: call signup API

    context.push(
      RouteConstants.otp,
      extra: {'email': "email@mail.com", 'purpose': OtpPurpose.forgotPassword},
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.current;

    return AuthScreenContainer(
      child: Column(
        children: [
          Text(
            loc.createAccount,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            loc.startJourney,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.black38),
          ),

          SizedBox(height: 24.h),

          _buildFieldLabel(loc.fullName),

          SizedBox(height: 5.h),

          AppTextField(
            controller: _nameController,
            type: AppTextFieldType.name,
            hint: loc.enterFullName,
            borderRadius: 5,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 9.h,
            ),
            textStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.black87),
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.black26),
            borderColor: Colors.black.withValues(alpha: 0.10),
            focusedBorderColor: const Color(0xFFE7193F),
            fillColor: Colors.white,
          ),

          SizedBox(height: 11.h),

          _buildFieldLabel(loc.phone),

          SizedBox(height: 5.h),

          AppTextField(
            controller: _phoneController,
            type: AppTextFieldType.phone,
            hint: loc.enterPhone,
            borderRadius: 5,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 9.h,
            ),
            textStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.black87),
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.black26),
            borderColor: Colors.black.withValues(alpha: 0.10),
            focusedBorderColor: const Color(0xFFE7193F),
            fillColor: Colors.white,
          ),

          SizedBox(height: 11.h),

          _buildFieldLabel(loc.workEmail),

          SizedBox(height: 5.h),

          AppTextField(
            controller: _emailController,
            type: AppTextFieldType.email,
            hint: loc.enterEmail,
            borderRadius: 5,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 9.h,
            ),
            textStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.black87),
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.black26),
            borderColor: Colors.black.withValues(alpha: 0.10),
            focusedBorderColor: const Color(0xFFE7193F),
            fillColor: Colors.white,
          ),

          SizedBox(height: 11.h),

          _buildFieldLabel(loc.password),

          SizedBox(height: 5.h),

          AppTextField(
            controller: _passwordController,
            type: AppTextFieldType.password,
            hint: loc.enterPassword,
            borderRadius: 5,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 9.h,
            ),
            textStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.black87),
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.black26),
            borderColor: Colors.black.withValues(alpha: 0.10),
            focusedBorderColor: const Color(0xFFE7193F),
            fillColor: Colors.white,
          ),

          SizedBox(height: 11.h),

          _buildFieldLabel(loc.confirmPassword),

          SizedBox(height: 5.h),

          AppTextField(
            controller: _confirmPasswordController,
            type: AppTextFieldType.password,
            hint: loc.reenterPassword,
            borderRadius: 5,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 9.h,
            ),
            textStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.black87),
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.black26),
            borderColor: Colors.black.withValues(alpha: 0.10),
            focusedBorderColor: const Color(0xFFE7193F),
            fillColor: Colors.white,
          ),

          SizedBox(height: 28.h),

          _AuthButton(text: '${loc.createAccount}  →', onPressed: _signUp),

          SizedBox(height: 17.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                loc.alreadyHaveAccount,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.black38),
              ),
              GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Text(
                  loc.signIn,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE7193F),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
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
