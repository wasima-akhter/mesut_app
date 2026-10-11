import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/app_localization.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/widgets/snack/app_snackbar.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.current;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 30.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),

                  SizedBox(height: 28.h),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPasswordField(
                          label: loc.currentPassword,
                          hint: loc.enterCurrentPassword,
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrent,
                          onToggle: () {
                            setState(() {
                              _obscureCurrent = !_obscureCurrent;
                            });
                          },
                        ),

                        SizedBox(height: 18.h),

                        _buildPasswordField(
                          label: loc.newPassword,
                          hint: loc.enterPassword,
                          controller: _newPasswordController,
                          obscureText: _obscureNew,
                          onToggle: () {
                            setState(() {
                              _obscureNew = !_obscureNew;
                            });
                          },
                        ),

                        SizedBox(height: 18.h),

                        _buildPasswordField(
                          label: loc.confirmNewPassword,
                          hint: loc.confirmPassword,
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          onToggle: () {
                            setState(() {
                              _obscureConfirm = !_obscureConfirm;
                            });
                          },
                        ),

                        SizedBox(height: 285.h),

                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildBackButton(),
        SizedBox(width: 14.w),
        Text(
          AppLocalization.current.changePassword,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return AppBackButton(
      size: 38.w,
      iconSize: 19.sp,
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        SizedBox(height: 7.h),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalization.current.passwordRequired;
            }

            return null;
          },
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

  Widget _buildSaveButton() {
    return AppButton(
      text: AppLocalization.current.saveChanges,
      onPressed: _changePassword,
      borderRadius: 7.r,
    );
  }

  void _changePassword() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      AppSnackBar.showError(
        context,
        AppLocalization.current.passwordsDoNotMatch,
      );
      return;
    }

    // API call here.
  }
}
