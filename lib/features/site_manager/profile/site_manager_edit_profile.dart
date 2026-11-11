import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/countries.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/enums/app_enum.dart';
import '../../../core/helpers/phone_helper.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/providers/common_provider.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/widgets/fields/app_phone_field.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import '../../auth/presentation/validators/auth_validators.dart';
import '../../employee/presentation/providers/employee_profile_provider.dart';
import '../presentation/providers/site_manager_profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  late Country _selectedCountry;

  @override
  void initState() {
    super.initState();

    final role = ref.read(userRoleProvider);
    final initialName = role == UserRole.employee
        ? ref.read(employeeProfileProvider).name
        : ref.read(siteManagerProfileProvider).name;
    final initialRawPhone = role == UserRole.employee
        ? ref.read(employeeProfileProvider).phone
        : ref.read(siteManagerProfileProvider).phone;

    final parsed = PhoneHelper.parseInitialPhone(initialRawPhone);
    _selectedCountry = parsed.country;
    _nameController.text = initialName;
    _phoneController.text = parsed.nationalNumber;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 30.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameField(context),
                    SizedBox(height: 18.h),
                    _buildPhoneField(context),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 14.h),
              child: _buildSaveButton(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 0),
      child: Row(
        children: [
          AppBackButton(
            size: 39.w,
            iconSize: 19.sp,
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Center(
              child: Text(
                context.loc.editProfile,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 39.w),
        ],
      ),
    );
  }

  // ============================================================
  // NAME
  // ============================================================

  Widget _buildNameField(BuildContext context) {
    return _fieldSection(
      context,
      label: context.loc.fullName,
      child: TextField(
        controller: _nameController,
        style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: context.loc.enterFullName,
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textSecondary.withValues(alpha: .65),
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 13.w,
            vertical: 15.h,
          ),
          border: _inputBorder(),
          enabledBorder: _inputBorder(),
          focusedBorder: _inputBorder(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  // ============================================================
  // PHONE
  // ============================================================

  Widget _buildPhoneField(BuildContext context) {
    return _fieldSection(
      context,
      label: context.loc.phone,
      child: AppPhoneField(
        controller: _phoneController,
        initialCountryCode: _selectedCountry.code,
        hint: context.loc.enterPhone,
        borderRadius: 7.r,
        borderColor: AppColors.border,
        focusedBorderColor: AppColors.textPrimary,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
        onCountryChanged: (country) {
          setState(() => _selectedCountry = country);
        },
      ),
    );
  }

  Widget _fieldSection(
    BuildContext context, {
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 7.h),
        child,
      ],
    );
  }

  OutlineInputBorder _inputBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(7.r),
      borderSide: BorderSide(color: color ?? AppColors.border),
    );
  }

  // ============================================================
  // SAVE
  // ============================================================

  Widget _buildSaveButton() {
    return AppButton.danger(
      text: context.loc.saveChanges,
      onPressed: _saveChanges,
      borderRadius: 7.r,
      textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
    );
  }

  void _saveChanges() {
    final loc = context.loc;
    final name = _nameController.text.trim();
    final nameError = AuthValidators.name(name);
    if (nameError != null) {
      AppSnackBar.showError(context, nameError);
      return;
    }

    final phoneError = PhoneHelper.validate(
      nationalNumber: _phoneController.text,
      country: _selectedCountry,
      languageCode: loc.localeCode,
    );
    if (phoneError != null) {
      AppSnackBar.showError(context, phoneError);
      return;
    }

    final formattedPhone = PhoneHelper.formatCompleteNumber(
      _selectedCountry,
      _phoneController.text,
    );

    final role = ref.read(userRoleProvider);
    if (role == UserRole.employee) {
      ref
          .read(employeeProfileProvider.notifier)
          .updateProfile(name: name, phone: formattedPhone);
    } else {
      ref
          .read(siteManagerProfileProvider.notifier)
          .updateProfile(name: name, phone: formattedPhone);
    }

    AppSnackBar.showSuccess(context, loc.profileUpdatedSuccess);
    context.pop();
  }
}
