import 'package:construction_app/app/constants/route_constants.dart';
import 'package:construction_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../auth/logout/logout.dart';

class EmployeeProfilePage extends ConsumerStatefulWidget {
  const EmployeeProfilePage({super.key});

  @override
  ConsumerState<EmployeeProfilePage> createState() =>
      _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends ConsumerState<EmployeeProfilePage> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 20.h),
              sliver: SliverToBoxAdapter(child: _buildHeader()),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildProfileHeader()),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildStats()),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 14.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildContactInformation()),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 14.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildSettings()),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 14.h)),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 30.h),
              sliver: SliverToBoxAdapter(child: _buildLegalAndLogout()),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        SizedBox(width: 50.w),

        Expanded(
          child: Center(
            child: Text(
              context.loc.profile,
              style: TextStyle(
                fontSize: 21.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),

        _circleButton(Icons.edit_outlined, _editProfile),
      ],
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 92.w,
              height: 92.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neutral200,
              ),
              child: ClipOval(
                child: Image.network(
                  'https://i.pravatar.cc/300?img=12',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return const Icon(
                      Icons.person,
                      size: 45,
                      color: AppColors.textSecondary,
                    );
                  },
                ),
              ),
            ),

            Positioned(
              right: 0,
              bottom: 1,
              child: GestureDetector(
                onTap: _changeProfilePhoto,
                child: Container(
                  width: 31.w,
                  height: 31.w,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.white,
                    size: 17,
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        Text(
          'Mesut Rahman',
          style: TextStyle(
            fontSize: 23.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        SizedBox(height: 4.h),

        Text(
          context.loc.employeeRole,
          style: TextStyle(fontSize: 17.sp, color: AppColors.textSecondary),
        ),

        SizedBox(height: 9.h),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7.w,
                height: 7.w,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),

              SizedBox(width: 6.w),

              Text(
                context.loc.inProgress,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats() {
    return Container(
      height: 88.h,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          _stat(
            title: context.loc.thisWeek,
            value: '30 hrs',
          ),

          _divider(),

          _stat(
            title: context.loc.assignedProjects,
            value: '2 projects',
          ),
        ],
      ),
    );
  }

  Widget _stat({required String title, required String value}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white.withValues(alpha: .55),
              ),
            ),

            SizedBox(height: 5.h),

            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 50.h,
      color: Colors.white.withValues(alpha: .15),
    );
  }

  // ============================================================
  // CONTACT
  // ============================================================

  Widget _buildContactInformation() {
    return _section(
      title: context.loc.contactInformation,
      children: [
        _contactRow(Icons.phone_outlined, '+49 170 1234567'),

        _contactRow(Icons.mail_outline_rounded, 'mesut.rahman@allround.de'),

        _contactRow(
          Icons.badge_outlined,
          'Employee ID: emp-042',
          showDivider: false,
        ),
      ],
    );
  }

  Widget _contactRow(IconData icon, String text, {bool showDivider = true}) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            _showMessage(text);
          },
          borderRadius: BorderRadius.circular(7.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.textSecondary),

                SizedBox(width: 10.w),

                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (showDivider) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  Widget _buildSettings() {
    final currentLang = ref.watch(appLanguageProvider);
    final langName = currentLang == AppLanguage.german
        ? context.loc.german
        : context.loc.english;

    return _section(
      title: context.loc.settings,
      children: [
        _settingRow(
          icon: Icons.language_outlined,
          title: context.loc.language,
          trailing: langName,
          onTap: _changeLanguage,
        ),

        _settingRow(
          icon: Icons.lock_outline,
          title: context.loc.changePassword,
          onTap: _changePassword,
        ),

        _settingRow(
          icon: notificationsEnabled
              ? Icons.notifications_outlined
              : Icons.notifications_off_outlined,
          title: context.loc.notifications,
          trailing: notificationsEnabled ? 'On' : 'Off',
          onTap: () {
            setState(() {
              notificationsEnabled = !notificationsEnabled;
            });
          },
          showDivider: false,
        ),
      ],
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.textSecondary),

                SizedBox(width: 10.w),

                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                if (trailing != null)
                  Text(
                    trailing,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),

                SizedBox(width: 5.w),

                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),

        if (showDivider) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }

  // ============================================================
  // LEGAL
  // ============================================================

  Widget _buildLegalAndLogout() {
    return Column(
      children: [
        _section(
          title: context.loc.legalNotice,
          children: [
            _settingRow(
              icon: Icons.privacy_tip_outlined,
              title: context.loc.privacyPolicy,
              onTap: () {
                context.push(RouteConstants.privacyPolicy);
              },
            ),

            _settingRow(
              icon: Icons.description_outlined,
              title: context.loc.termsAndConditions,
              onTap: () {
                context.push(RouteConstants.termsAndConditions);
              },
              showDivider: false,
            ),
          ],
        ),

        SizedBox(height: 14.h),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, size: 20),
            label: Text(
              context.loc.logout,
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _logout() {
    LogoutConfirmation.show(
      context: context,
      onLogout: () {
        context.go(RouteConstants.signIn);
      },
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _section({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(13.w, 13.h, 13.w, 3.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 4.h),

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _editProfile() {
    context.push(RouteConstants.siteManagerProfileEdit);
  }

  void _changeProfilePhoto() {
    _showMessage(context.loc.cameraPermissionMessage);
  }

  void _changeLanguage() {
    final currentLang = ref.read(appLanguageProvider);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) {
        return SafeArea(
          child: CustomScrollView(
            shrinkWrap: true,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(18.w),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.loc.selectLanguage,
                        style: TextStyle(
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 14.h),

                      _languageOption(
                        title: context.loc.english,
                        language: AppLanguage.english,
                        isSelected: currentLang == AppLanguage.english,
                      ),
                      _languageOption(
                        title: context.loc.german,
                        language: AppLanguage.german,
                        isSelected: currentLang == AppLanguage.german,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _languageOption({
    required String title,
    required AppLanguage language,
    required bool isSelected,
  }) {
    return ListTile(
      onTap: () {
        ref.read(appLanguageProvider.notifier).setLanguage(language);
        Navigator.of(context).pop();
      },
      title: Text(title, style: TextStyle(fontSize: 17.sp)),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
    );
  }

  void _changePassword() {
    context.push(RouteConstants.changePassword);
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46.w,
        height: 46.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          color: AppColors.white,
        ),
        child: Icon(icon, size: 22, color: AppColors.textPrimary),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(fontSize: 17.sp)),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
