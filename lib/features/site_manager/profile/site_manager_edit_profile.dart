import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _nameController.text = 'Mesut Rahman';
    _phoneController.text = '0125456566';
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
          _circleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => context.pop(),
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

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50.r),
        child: Container(
          width: 39.w,
          height: 39.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 19.sp),
        ),
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
      child: Container(
        height: 49.h,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(7.r),
        ),
        child: Row(
          children: [
            SizedBox(width: 10.w),

            Text('🇧🇩', style: TextStyle(fontSize: 18.sp)),

            SizedBox(width: 7.w),

            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 17.sp,
              color: AppColors.textSecondary,
            ),

            SizedBox(width: 7.w),

            Container(width: 1, height: 25.h, color: AppColors.border),

            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: context.loc.enterPhone,
                  hintStyle: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary.withValues(alpha: .65),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                ),
              ),
            ),
          ],
        ),
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
    return SizedBox(
      width: double.infinity,

      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.r),
          ),
        ),
        child: Text(
          context.loc.saveChanges,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _saveChanges() {
    context.pop();
  }
}
