// lib/features/auth/screens/otp_verify_screen.dart

import 'package:construction_app/app/theme/app_text_styles.dart';
import 'package:construction_app/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../app/constants/route_constants.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import '../auth_validators.dart';
import '../widgets/auth_screen_container.dart';

enum OtpPurpose { signUp, forgotPassword }

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  final OtpPurpose purpose;

  const OtpVerifyScreen({
    super.key,
    required this.email,
    this.purpose = OtpPurpose.signUp,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpController = PinInputController();

  @override
  void initState() {
    // TODO: implement initState

    debugPrint('email: ${widget.email}');
    debugPrint('purpose ${widget.purpose}');
    super.initState();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    final error = AuthValidators.otp(_otpController.text);

    if (error != null) {
      AppSnackBar.error(context, error);
      return;
    }

    AppSnackBar.success(context, 'OTP verified successfully');

    switch (widget.purpose) {
      case OtpPurpose.signUp:
        // TODO: Navigate to the next signup step/home screen.
        context.pushReplacement(RouteConstants.mainNav);
        break;

      case OtpPurpose.forgotPassword:
        context.push(RouteConstants.changePassword);
        break;
    }
  }

  void _resendOtp() {
    AppSnackBar.info(context, 'A new OTP has been sent');

    // TODO: resend OTP API
    AppSnackBar.success(context, 'OTP resent successfully');
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenContainer(
      child: Column(
        children: [
          Text(
            'Verify Otp',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            'We sent an otp to your email. Enter it below to continue.',
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
              _verifyOtp();
            },
            onChanged: (_) {},
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
                "Didn't get the code? ",
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.black38),
              ),
              GestureDetector(
                onTap: _resendOtp,
                child: Text(
                  'Resend OTP',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFFE7193F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          _AuthButton(text: 'Verify OTP →', onPressed: _verifyOtp),
        ],
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
