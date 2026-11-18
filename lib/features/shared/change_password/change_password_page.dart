import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import 'presentation/providers/change_password_provider.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentPass = _currentPasswordController.text;
    final newPass = _newPasswordController.text;

    final success = await ref
        .read(changePasswordProvider.notifier)
        .changePassword(
          currentPassword: currentPass,
          newPassword: newPass,
        );

    if (!mounted) return;

    if (success) {
      AppSnackBar.showSuccess(context, context.loc.passwordChangedSuccess);
      context.pop();
    } else {
      final error = ref.read(changePasswordProvider).errorMessage;
      AppSnackBar.showError(
        context,
        error?.isNotEmpty == true ? error! : context.loc.changePasswordFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final state = ref.watch(changePasswordProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 30.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48.h,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(loc),
                        SizedBox(height: 28.h),
                        _buildPasswordField(
                          label: loc.currentPassword,
                          hint: loc.enterCurrentPassword,
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrent,
                          onToggle: () => setState(
                            () => _obscureCurrent = !_obscureCurrent,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return loc.passwordRequired;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 18.h),
                        _buildPasswordField(
                          label: loc.newPassword,
                          hint: loc.enterPassword,
                          controller: _newPasswordController,
                          obscureText: _obscureNew,
                          onToggle: () =>
                              setState(() => _obscureNew = !_obscureNew),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return loc.passwordRequired;
                            }
                            if (value.length < 6) {
                              return loc.passwordTooShort;
                            }
                            if (value == _currentPasswordController.text) {
                              return loc.newPasswordMustBeDifferent;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 18.h),
                        _buildPasswordField(
                          label: loc.confirmNewPassword,
                          hint: loc.confirmPassword,
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          onToggle: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return loc.passwordConfirmRequired;
                            }
                            if (value != _newPasswordController.text) {
                              return loc.passwordsDoNotMatch;
                            }
                            return null;
                          },
                        ),
                        const Spacer(),
                        SizedBox(height: 32.h),
                        AppButton(
                          text: loc.saveChanges,
                          isLoading: state.isLoading,
                          onPressed: state.isLoading ? null : _changePassword,
                          borderRadius: 7.r,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic loc) {
    return Row(
      children: [
        AppBackButton(size: 38.w, iconSize: 19.sp),
        SizedBox(width: 14.w),
        Text(
          loc.changePassword,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    required FormFieldValidator<String> validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        SizedBox(height: 7.h),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 19.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
