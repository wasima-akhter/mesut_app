import 'package:construction_app/app/constants/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/localization_provider.dart';
import '../../auth/logout/logout.dart';
import '../projects/overview_modules.dart';

class SiteManagerMorePage extends ConsumerStatefulWidget {
  const SiteManagerMorePage({super.key});

  @override
  ConsumerState<SiteManagerMorePage> createState() =>
      _SiteManagerMorePageState();
}

class _SiteManagerMorePageState extends ConsumerState<SiteManagerMorePage> {
  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(appLanguageProvider);
    final langName = currentLang == AppLanguage.german
        ? context.loc.german
        : context.loc.english;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 30.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildProfileCard(),
                  SizedBox(height: 14.h),

                  _buildSection(
                    title: context.loc.smOverview,
                    children: [
                      _buildSettingsTile(
                        icon: Icons.assignment_outlined,
                        title: context.loc.inspections,
                        subtitle: context.loc.performInspection,
                        onTap: () {
                          context.push(
                            RouteConstants.siteManagerSiteInspection,
                          );
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.account_tree_outlined,
                        title: context.loc.phaseBoard,
                        subtitle: context.loc.projects,
                        onTap: () {
                          context.push(RouteConstants.siteManagerPhaseBoard);
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.calendar_month_outlined,
                        title: context.loc.calendar,
                        subtitle: context.loc.scheduleAndDuration,
                        onTap: () {
                          context.push(
                            RouteConstants.siteManagerInspectionCalendarPage,
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  _buildSection(
                    title: context.loc.settings,
                    children: [
                      _buildSettingsTile(
                        icon: Icons.sync_rounded,
                        title: context.loc.synced,
                        trailing: Text(
                          context.loc.synced,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.success),
                        ),
                        onTap: () {},
                      ),
                      _buildSettingsTile(
                        icon: Icons.translate_rounded,
                        title: context.loc.language,
                        subtitle: langName,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              langName,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18.sp,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                        onTap: _showLanguageOptions,
                      ),
                      _buildSettingsTile(
                        icon: Icons.notifications_outlined,
                        title: context.loc.notifications,
                        onTap: () {
                          context.push(RouteConstants.notifications);
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: context.loc.changePassword,
                        onTap: () {
                          context.push(RouteConstants.changePassword);
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  _buildSection(
                    title: context.loc.legalNotice,
                    children: [
                      _buildSettingsTile(
                        icon: Icons.policy_outlined,
                        title: context.loc.privacyPolicy,
                        onTap: () {
                          context.push(RouteConstants.privacyPolicy);
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.gavel_outlined,
                        title: context.loc.termsAndConditions,
                        onTap: () {
                          context.push(RouteConstants.termsAndConditions);
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 32.h),

                  _buildLogoutButton(),

                  SizedBox(height: 20.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.siteManagerProfileEdit),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.medium,
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neutral200,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/profile.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return Icon(
                      Icons.person,
                      color: AppColors.textSecondary,
                      size: 25.sp,
                    );
                  },
                ),
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tim Muller',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    context.loc.siteManagerRole,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    context.loc.inProgress,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              size: 22.sp,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.medium,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
              child: Text(title, style: Theme.of(context).textTheme.titleSmall),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 11.h),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border, width: .7)),
          ),
          child: Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: AppColors.surfaceTertiary,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 17.sp, color: AppColors.textSecondary),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyMedium),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ],
                ),
              ),

              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.sp,
                    color: AppColors.textSecondary,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.error),
        borderRadius: AppRadii.medium,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _logout,
          borderRadius: AppRadii.medium,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, size: 17.sp, color: AppColors.error),
              SizedBox(width: 7.w),
              Text(
                context.loc.logout,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageOptions() {
    final currentLang = ref.read(appLanguageProvider);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.loc.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(context.loc.english),
                trailing: currentLang == AppLanguage.english
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : const Icon(Icons.circle_outlined, color: AppColors.border),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  await ref
                      .read(appLanguageProvider.notifier)
                      .setLanguage(AppLanguage.english);
                },
              ),
              ListTile(
                title: Text(context.loc.german),
                trailing: currentLang == AppLanguage.german
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : const Icon(Icons.circle_outlined, color: AppColors.border),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  await ref
                      .read(appLanguageProvider.notifier)
                      .setLanguage(AppLanguage.german);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _logout() {
    LogoutConfirmation.show(
      context: context,
      onLogout: () {
        showMessage(context.loc.loggedOutSuccess);
        context.go(RouteConstants.signIn);
      },
    );
  }
}
