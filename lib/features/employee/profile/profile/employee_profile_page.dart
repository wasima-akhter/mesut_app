import 'package:construction_app/app/constants/route_constants.dart';
import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/widgets/buttons/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/services/launcher_service.dart';
import '../../../../core/widgets/snack/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/logout_dialog.dart';
import '../../presentation/providers/employee_profile_provider.dart';

class EmployeeProfilePage extends ConsumerWidget {
  const EmployeeProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(employeeProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 20.h),
              sliver: SliverToBoxAdapter(child: _buildHeader(context)),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(
                child: _buildProfileHeader(context, profileState),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildStats(context)),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 14.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(
                child: _buildContactInformation(context, profileState),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 14.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(
                child: _buildSettings(context, ref, profileState),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 14.h)),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 30.h),
              sliver: SliverToBoxAdapter(
                child: _buildLegalAndLogout(context, ref),
              ),
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

        _circleButton(Icons.edit_outlined, () => _editProfile(context)),
      ],
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader(
    BuildContext context,
    EmployeeProfileState profileState,
  ) {
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
                onTap: () => _changeProfilePhoto(context),
                child: Container(
                  width: 31.w,
                  height: 31.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        Text(
          profileState.name,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        SizedBox(height: 4.h),

        Text(
          profileState.roleTitle,
          style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
        ),

        SizedBox(height: 8.h),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Text(
            context.loc.get('profile.active', 'Active'),
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem(context.loc.assignedProjects, '2'),
          _divider(),
          _statItem(context.loc.completed, '14'),
          _divider(),
          _statItem(
            context.loc.get('employee.hoursThisWeek', 'Hours this Week'),
            '35.5h',
          ),
        ],
      ),
    );
  }

  Widget _statItem(String title, String value) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
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

  Widget _buildContactInformation(
    BuildContext context,
    EmployeeProfileState profileState,
  ) {
    return _section(
      title: context.loc.contactInformation,
      children: [
        _contactRow(context, Icons.phone_outlined, profileState.phone),
        _contactRow(context, Icons.mail_outline_rounded, profileState.email),
        _contactRow(
          context,
          Icons.badge_outlined,
          'Employee ID: emp-042',
          showDivider: false,
        ),
      ],
    );
  }

  Widget _contactRow(
    BuildContext context,
    IconData icon,
    String text, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            if (icon == Icons.phone_outlined) {
              final success = await AppLauncherService.makePhoneCall(text);
              if (!success && context.mounted) {
                _showMessage(context, text);
              }
            } else if (icon == Icons.mail_outline_rounded) {
              final success = await AppLauncherService.sendEmail(email: text);
              if (!success && context.mounted) {
                _showMessage(context, text);
              }
            } else {
              _showMessage(context, text);
            }
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

  Widget _buildSettings(
    BuildContext context,
    WidgetRef ref,
    EmployeeProfileState profileState,
  ) {
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
          onTap: () => _changeLanguage(context, ref),
        ),

        _settingRow(
          icon: Icons.lock_outline,
          title: context.loc.changePassword,
          onTap: () => _changePassword(context),
        ),

        _settingRow(
          icon: profileState.notificationsEnabled
              ? Icons.notifications_outlined
              : Icons.notifications_off_outlined,
          title: context.loc.notifications,
          trailing: profileState.notificationsEnabled ? 'On' : 'Off',
          onTap: () {
            ref.read(employeeProfileProvider.notifier).toggleNotifications();
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

  Widget _buildLegalAndLogout(BuildContext context, WidgetRef ref) {
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

        AppOutlinedButton(
          fullWidth: true,
          onPressed: () => _logout(context, ref),
          leadingIcon: Icons.logout,
          text: context.loc.logout,
          foregroundColor: AppColors.primary,
          borderColor: AppColors.primary,
          borderRadius: 7.r,
          textStyle: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _logout(BuildContext context, WidgetRef ref) {
    LogoutConfirmation.show(
      context: context,
      onLogout: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) {
          AppSnackBar.success(context.loc.loggedOutSuccess);
          context.go(RouteConstants.signIn);
        }
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

  void _editProfile(BuildContext context) {
    context.push(RouteConstants.siteManagerProfileEdit);
  }

  void _changeProfilePhoto(BuildContext context) {
    _showMessage(context, context.loc.cameraPermissionMessage);
  }

  void _changeLanguage(BuildContext context, WidgetRef ref) {
    final currentLang = ref.read(appLanguageProvider);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (dialogContext) {
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
                        context: dialogContext,
                        ref: ref,
                        title: context.loc.english,
                        language: AppLanguage.english,
                        isSelected: currentLang == AppLanguage.english,
                      ),
                      _languageOption(
                        context: dialogContext,
                        ref: ref,
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
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required AppLanguage language,
    required bool isSelected,
  }) {
    return ListTile(
      onTap: () async {
        Navigator.of(context).pop();
        await ref.read(appLanguageProvider.notifier).setLanguage(language);
      },
      title: Text(title, style: TextStyle(fontSize: 17.sp)),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
    );
  }

  void _changePassword(BuildContext context) {
    context.push(RouteConstants.changePassword);
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return AppIconButton.circle(
      icon: icon,
      onPressed: onTap,
      size: 46.w,
      border: Border.all(color: AppColors.border),
      backgroundColor: AppColors.white,
      iconColor: AppColors.textPrimary,
      iconSize: 22,
    );
  }

  void _showMessage(BuildContext context, String message) {
    AppSnackBar.showInfo(context, message);
  }
}
