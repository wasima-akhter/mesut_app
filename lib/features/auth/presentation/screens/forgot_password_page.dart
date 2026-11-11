import 'package:construction_app/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants/route_constants.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/widgets/fields/app_text_field.dart';
import '../../../../core/widgets/snack/app_snackbar.dart';
import '../providers/password_recovery_provider.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_screen_container.dart';
import 'otp_page.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final loc = context.loc;
    final email = _emailController.text.trim();
    final error = AuthValidators.email(email);

    if (error != null) {
      AppSnackBar.error(error);
      return;
    }

    final recoverData = await ref
        .read(passwordRecoveryProvider.notifier)
        .sendRecoveryEmail(email);

    if (!mounted) return;

    if (recoverData != null) {
      AppSnackBar.success(loc.otpSentSuccess);
      context.push(
        RouteConstants.otp,
        extra: {
          'email': recoverData.email.isNotEmpty ? recoverData.email : email,
          'purpose': OtpPurpose.forgotPassword,
          'recoveryToken': recoverData.token,
        },
      );
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

          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: loc.sendResetLink,
              isLoading: state.isLoading,
              onPressed: state.isLoading ? null : _sendOtp,
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
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
