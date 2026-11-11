import 'package:construction_app/app/theme/app_text_styles.dart';
import 'package:construction_app/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../app/constants/route_constants.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/widgets/snack/app_snackbar.dart';
import '../providers/otp_provider.dart';
import '../providers/password_recovery_provider.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_screen_container.dart';

enum OtpPurpose { signUp, forgotPassword }

class OtpVerifyScreen extends ConsumerStatefulWidget {
  final String email;
  final OtpPurpose purpose;
  final String? otpPageToken;
  final String? recoveryToken;

  const OtpVerifyScreen({
    super.key,
    required this.email,
    this.purpose = OtpPurpose.signUp,
    this.otpPageToken,
    this.recoveryToken,
  });

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _otpController = PinInputController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final loc = context.loc;
    final code = _otpController.text.trim();
    final error = AuthValidators.otp(code);

    if (error != null) {
      AppSnackBar.error(error);
      return;
    }

    final notifier = ref.read(otpControllerProvider.notifier);
    notifier.updateOtp(code);

    final success = await notifier.verifyOtp(
      widget.purpose,
      otpPageToken: widget.otpPageToken,
      recoveryToken: widget.recoveryToken,
    );

    if (!mounted) return;

    if (!success) {
      final otpState = ref.read(otpControllerProvider);
      AppSnackBar.error(otpState.error ?? loc.error);
      return;
    }

    AppSnackBar.success(loc.success);

    switch (widget.purpose) {
      case OtpPurpose.signUp:
        context.go(RouteConstants.mainNav);
        break;
      case OtpPurpose.forgotPassword:
        final effectiveRecoveryToken =
            widget.recoveryToken ?? ref.read(passwordRecoveryProvider).token;
        context.push(
          RouteConstants.resetPassword,
          extra: {
            'email': widget.email,
            'recoveryToken': effectiveRecoveryToken,
          },
        );
        break;
    }
  }

  Future<void> _resendOtp() async {
    final loc = context.loc;
    final success = await ref
        .read(otpControllerProvider.notifier)
        .resendOtp(
          widget.purpose,
          otpPageToken: widget.otpPageToken,
          recoveryToken: widget.recoveryToken,
        );

    if (!mounted) return;

    if (success) {
      AppSnackBar.success(loc.verificationResentSuccess);
    } else {
      final otpState = ref.read(otpControllerProvider);
      if (otpState.error != null) {
        AppSnackBar.error(otpState.error!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final otpState = ref.watch(otpControllerProvider);

    return AuthScreenContainer(
      child: Column(
        children: [
          Text(
            loc.enterOtp,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            loc.enterOtpSubtitle(widget.email),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.black38),
          ),

          SizedBox(height: 28.h),

          PinInputFormField(
            length: 6,
            pinController: _otpController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autoFocus: true,
            enablePaste: true,
            enableAutofill: true,
            autofillHints: const [AutofillHints.oneTimeCode],
            onCompleted: (value) {
              ref.read(otpControllerProvider.notifier).updateOtp(value);
              _verifyOtp();
            },
            onChanged: (value) {
              ref.read(otpControllerProvider.notifier).updateOtp(value);
            },
            pinBuilder: (context, cells) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(cells.length, (index) {
                  final cell = cells[index];

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: SizedBox(
                        height: 60.h,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.r),
                            border: Border.all(
                              color: cell.isFocused
                                  ? const Color(0xFFE7193F)
                                  : Colors.black.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cell.character ?? '',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),

          SizedBox(height: 30.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                loc.didNotReceiveCode,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.black38),
              ),
              if (otpState.canResend)
                GestureDetector(
                  onTap: otpState.isResending ? null : _resendOtp,
                  child: Text(
                    otpState.isResending ? loc.loading : loc.resendCode,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFFE7193F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Text(
                  loc.resendInSeconds('${otpState.timerSeconds}'),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),

          SizedBox(height: 20.h),

          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: '${loc.verifyCode} →',
              isLoading: otpState.isVerifying,
              onPressed: otpState.isVerifying ? null : _verifyOtp,
            ),
          ),
        ],
      ),
    );
  }
}
