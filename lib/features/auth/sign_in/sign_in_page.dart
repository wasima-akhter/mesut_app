// lib/features/auth/screens/sign_in_screen.dart

import 'package:construction_app/app/constants/route_constants.dart';
import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/app/theme/app_text_styles.dart';
import 'package:construction_app/core/providers/common_provider.dart';
import 'package:construction_app/core/widgets/buttons/app_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/app_enum.dart';
import '../../../core/widgets/fields/app_text_field.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import '../auth_validators.dart';
import '../otp/otp_page.dart';
import '../widgets/auth_screen_container.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole? _selectedRole;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
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

    // TODO: call login API

    AppSnackBar.success('Login successful');

    context.pushReplacement(RouteConstants.mainNav);
  }

  // ------------------------------------------------------------
  // DEBUG LOGIN
  // ------------------------------------------------------------

  void _loginAs(UserRole role) {
    setState(() {
      _selectedRole = role;
    });

    // Assign role to Riverpod provider.
    ref.read(userRoleProvider.notifier).setRole(role);

    // Go to main navigation.
    context.pushReplacement(RouteConstants.mainNav);
  }

  // ------------------------------------------------------------
  // DEBUG LOGOUT / NONE
  // ------------------------------------------------------------

  void _loginAsNone() {
    setState(() {
      _selectedRole = null;
    });

    // Clear authenticated role.
    ref.read(userRoleProvider.notifier).clearRole();
    context.pushReplacement(RouteConstants.signIn);
    AppSnackBar.error(
      "We couldn't determine your account role. Please log in again to continue.",
    );
    // Stay on / return to login.
    // If already on SignInScreen, nothing else is required.
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenContainer(
      showBack: false,
      child: Column(
        children: [
          Text(
            'Log In',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            'Sign in to access your assigned projects and daily schedule.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.black38),
          ),

          SizedBox(height: 30.h),

          _buildFieldLabel('Email'),

          SizedBox(height: 5.h),

          AppTextField(
            controller: _emailController,
            type: AppTextFieldType.email,
            hint: 'Email',
            borderRadius: 5,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 10.h,
            ),
          ),

          SizedBox(height: 14.h),

          _buildFieldLabel('Password'),

          SizedBox(height: 5.h),

          AppTextField(
            controller: _passwordController,
            type: AppTextFieldType.password,
            hint: 'Password',
            borderRadius: 5,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 10.h,
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                context.push(RouteConstants.forgotPassword);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot Password',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFFE7193F),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                context.push(
                  RouteConstants.otp,
                  extra: {
                    'email': "email@mail.com",
                    'purpose': OtpPurpose.forgotPassword,
                  },
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'verify otp',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFFE7193F),
                ),
              ),
            ),
          ),

          SizedBox(height: 22.h),

          _AuthButton(text: 'Log In  →', onPressed: _login),

          SizedBox(height: 20.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.black45),
              ),
              GestureDetector(
                onTap: () {
                  context.push(RouteConstants.signUp);
                },
                child: Text(
                  'Sign Up',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE7193F),
                  ),
                ),
              ),
            ],
          ),

          //
          //
          SizedBox(height: 30),
          if (kDebugMode)
            Wrap(
              runSpacing: 10,
              children: [
                // ------------------------------------------------
                // SITE MANAGER
                // ------------------------------------------------
                _DebugButton(
                  title: 'Login as Site Manager',
                  icon: Icons.engineering_outlined,
                  color: Colors.green,
                  onPressed: () {
                    _loginAs(UserRole.siteManager);
                  },
                ),

                const SizedBox(height: 14),

                // ------------------------------------------------
                // EMPLOYEE
                // ------------------------------------------------
                _DebugButton(
                  title: 'Login as Employee',
                  icon: Icons.person_outline,
                  color: Colors.blue,
                  onPressed: () {
                    _loginAs(UserRole.employee);
                  },
                ),

                const SizedBox(height: 14),

                // ------------------------------------------------
                // NONE
                // ------------------------------------------------
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

// ============================================================
// DEBUG BUTTON
// ============================================================

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
    return SizedBox(
      height: 56,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(title),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(title),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
    );
  }
}
