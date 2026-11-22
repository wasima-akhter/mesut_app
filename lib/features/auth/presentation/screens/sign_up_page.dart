import 'package:construction_app/app/constants/route_constants.dart';
import 'package:construction_app/app/theme/app_text_styles.dart';
import 'package:construction_app/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/countries.dart';

import '../../../../core/enums/app_enum.dart';
import '../../../../core/helpers/phone_helper.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/widgets/fields/app_phone_field.dart';
import '../../../../core/widgets/fields/app_text_field.dart';
import '../../../../core/widgets/snack/app_snackbar.dart';
import '../providers/auth_provider.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_role_selector.dart';
import '../widgets/auth_screen_container.dart';
import 'otp_page.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _selectedRole = UserRole.employee;
  Country _selectedPhoneCountry = PhoneHelper.findCountryByIso(
    PhoneHelper.defaultCountryCode,
  );

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final loc = context.loc;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final firstNameError = AuthValidators.firstName(firstName);
    if (firstNameError != null) {
      AppSnackBar.error(firstNameError);
      return;
    }

    final lastNameError = AuthValidators.lastName(lastName);
    if (lastNameError != null) {
      AppSnackBar.error(lastNameError);
      return;
    }

    final phoneError = PhoneHelper.validate(
      nationalNumber: phone,
      country: _selectedPhoneCountry,
      languageCode: loc.localeCode,
    );
    if (phoneError != null) {
      AppSnackBar.error(phoneError);
      // return;
    }

    final formattedPhone = PhoneHelper.formatCompleteNumber(
      _selectedPhoneCountry,
      phone,
    );

    final emailError = AuthValidators.email(email);
    if (emailError != null) {
      AppSnackBar.error(emailError);
      return;
    }

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

    final otpPageToken = await ref
        .read(authProvider.notifier)
        .signUp(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: formattedPhone,
          password: password,
          role: _selectedRole,
        );

    if (!mounted) return;

    if (otpPageToken != null && otpPageToken.isNotEmpty) {
      AppSnackBar.success(loc.otpSentSuccess);
      context.push(
        RouteConstants.otp,
        extra: {
          'email': email,
          'purpose': OtpPurpose.signUp,
          'otpPageToken': otpPageToken,
        },
      );
    } else {
      final authState = ref.read(authProvider);
      AppSnackBar.error(
        authState.errorMessage ?? loc.error,
        title: authState.userMessage?.title,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final authState = ref.watch(authProvider);

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

          SizedBox(height: 20.h),

          _buildFieldLabel(loc.selectRole),

          SizedBox(height: 6.h),

          AuthRoleSelector(
            selectedRole: _selectedRole,
            onChanged: (role) {
              setState(() => _selectedRole = role);
            },
          ),

          SizedBox(height: 14.h),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(loc.firstName),
                    SizedBox(height: 5.h),
                    AppTextField(
                      controller: _firstNameController,
                      type: AppTextFieldType.name,
                      hint: loc.enterFirstName,
                      borderRadius: 5,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 9.h,
                      ),
                      textStyle: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.black87,
                      ),
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.black26,
                      ),
                      borderColor: Colors.black.withValues(alpha: 0.10),
                      focusedBorderColor: const Color(0xFFE7193F),
                      fillColor: Colors.white,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(loc.lastName),
                    SizedBox(height: 5.h),
                    AppTextField(
                      controller: _lastNameController,
                      type: AppTextFieldType.name,
                      hint: loc.enterLastName,
                      borderRadius: 5,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 9.h,
                      ),
                      textStyle: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.black87,
                      ),
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.black26,
                      ),
                      borderColor: Colors.black.withValues(alpha: 0.10),
                      focusedBorderColor: const Color(0xFFE7193F),
                      fillColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 11.h),

          _buildFieldLabel(loc.phone),

          SizedBox(height: 5.h),

          AppPhoneField(
            controller: _phoneController,
            initialCountryCode: _selectedPhoneCountry.code,
            hint: loc.enterPhone,
            borderRadius: 5,
            borderColor: Colors.black.withValues(alpha: 0.10),
            focusedBorderColor: const Color(0xFFE7193F),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 9.h,
            ),
            onCountryChanged: (country) {
              setState(() => _selectedPhoneCountry = country);
            },
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

          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: '${loc.createAccount}  →',
              isLoading: authState.isLoading,
              onPressed: authState.isLoading ? null : _signUp,
            ),
          ),

          SizedBox(height: 17.h),

          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                loc.alreadyHaveAccount,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.black38),
              ),
              GestureDetector(
                onTap: authState.isLoading
                    ? null
                    : () {
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
