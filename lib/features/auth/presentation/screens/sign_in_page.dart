import 'package:construction_app/app/constants/route_constants.dart';
import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/app/theme/app_text_styles.dart';
import 'package:construction_app/core/providers/common_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/app_enum.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/storage/storage_provider.dart';
import '../../../../core/widgets/buttons/buttons.dart';
import '../../../../core/widgets/fields/app_text_field.dart';
import '../../../../core/widgets/snack/app_snackbar.dart';
import '../providers/auth_provider.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_screen_container.dart';
import 'otp_page.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final UserRole _selectedRole = UserRole.employee;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    final storage = ref.read(storageServiceProvider);
    _rememberMe = storage.rememberMe;
    if (_rememberMe) {
      final savedEmail = storage.rememberedEmail;
      if (savedEmail != null && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final loc = context.loc;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

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

    final outcome = await ref
        .read(authProvider.notifier)
        .signIn(
          email: email,
          password: password,
          role: _selectedRole,
          rememberMe: _rememberMe,
        );

    if (!mounted) return;
    final authState = ref.read(authProvider);

    switch (outcome) {
      case LoginOutcome.authenticated:
        AppSnackBar.success(loc.success);
        context.go(RouteConstants.mainNav);
        break;
      case LoginOutcome.otpVerificationRequired:
        AppSnackBar.info(loc.otpSentSuccess);
        context.push(
          RouteConstants.otp,
          extra: {
            'email': email,
            'purpose': OtpPurpose.signUp,
            'otpPageToken': authState.otpPageToken,
          },
        );
        break;
      case LoginOutcome.suspended:
      case LoginOutcome.error:
        AppSnackBar.error(
          authState.errorMessage ?? loc.error,
          title: authState.userMessage?.title,
        );
        break;
    }
  }

  void _loginAs(UserRole role) {
    ref.read(userRoleProvider.notifier).setRole(role);
    context.pushReplacement(RouteConstants.mainNav);
  }

  void _loginAsNone() {
    ref.read(userRoleProvider.notifier).clearRole();
    context.pushReplacement(RouteConstants.signIn);
    AppSnackBar.error(
      "We couldn't determine your account role. Please log in again to continue.",
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final authState = ref.watch(authProvider);

    return AuthScreenContainer(
      showBack: false,
      child: Column(
        children: [
          Text(
            loc.signIn,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            loc.signInToAccount,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.black38),
          ),

          SizedBox(height: 24.h),

          _buildFieldLabel(loc.workEmail),

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

          _buildFieldLabel(loc.password),

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

          SizedBox(height: 6.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _rememberMe = !_rememberMe);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: const Color(0xFFE7193F),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (val) {
                          setState(() => _rememberMe = val ?? false);
                        },
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      loc.rememberMe,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              AppTextButton(
                text: loc.forgotPassword,
                onPressed: authState.isLoading
                    ? null
                    : () {
                        context.push(RouteConstants.forgotPassword);
                      },
                foregroundColor: const Color(0xFFE7193F),
                textStyle: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFFE7193F),
                ),
                padding: EdgeInsets.symmetric(vertical: 4.h),
              ),
            ],
          ),

          SizedBox(height: 22.h),

          AppButton(
            text: '${loc.signIn}  →',
            isLoading: authState.isLoading,
            onPressed: authState.isLoading ? null : _login,
          ),

          SizedBox(height: 20.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                loc.dontHaveAccount,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.black45),
              ),
              GestureDetector(
                onTap: authState.isLoading
                    ? null
                    : () {
                        context.push(RouteConstants.signUp);
                      },
                child: Text(
                  loc.signUp,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE7193F),
                  ),
                ),
              ),
            ],
          ),

          if (kDebugMode) ...[
            SizedBox(height: 28.h),
            Wrap(
              runSpacing: 10,
              children: [
                _DebugButton(
                  title: 'Login as Site Manager',
                  icon: Icons.engineering_outlined,
                  color: Colors.green,
                  onPressed: () => _loginAs(UserRole.siteManager),
                ),
                _DebugButton(
                  title: 'Login as Employee',
                  icon: Icons.person_outline,
                  color: Colors.blue,
                  onPressed: () => _loginAs(UserRole.employee),
                ),
                _DebugButton(
                  title: 'Continue as Unauthenticated',
                  icon: Icons.logout,
                  color: Colors.red,
                  outlined: true,
                  onPressed: _loginAsNone,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
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

class _DebugButton extends StatelessWidget {
  const _DebugButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.outlined = false,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return outlined
        ? AppOutlinedButton(
            text: title,
            leadingIcon: icon,
            onPressed: onPressed,
            foregroundColor: color,
            borderColor: color,
            borderRadius: 12.r,
          )
        : AppButton(
            text: title,
            leadingIcon: icon,
            onPressed: onPressed,
            backgroundColor: color,
            borderRadius: 12.r,
          );
  }
}
