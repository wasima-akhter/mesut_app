import 'package:construction_app/app/constants/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/localization/pending_refetch_controller.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../auth/presentation/widgets/logout_dialog.dart';
import '../../auth/presentation/widgets/logout_loading_overlay.dart';
import '../../shared/widgets/language_selection_bottom_sheet.dart';
import '../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../shared/notifications/presentation/providers/notification_settings_provider.dart';
import '../offline_sync/providers/site_manager_sync_provider.dart';
import '../offline_sync/widgets/site_manager_sync_details_sheet.dart';
import '../projects/overview_modules.dart';
import 'widgets/site_manager_more_tiles.dart';
import 'widgets/site_manager_profile_card.dart';

class SiteManagerMorePage extends ConsumerStatefulWidget {
  const SiteManagerMorePage({super.key});

  @override
  ConsumerState<SiteManagerMorePage> createState() =>
      _SiteManagerMorePageState();
}

class _SiteManagerMorePageState extends ConsumerState<SiteManagerMorePage> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(appLanguageProvider);
    final profile = ref.watch(mobileProfileProvider).asData?.value;
    final syncState = ref.watch(siteManagerSyncProvider);
    final notificationsEnabled = ref.watch(notificationSettingsProvider);
    final langName = currentLang.label;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: PendingPollEffect(
          hasPending: profile?.localization?.isPending == true,
          onPoll: () => ref.read(mobileProfileProvider.notifier).refresh(),
          child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 30.h),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SiteManagerProfileCard(),
                  SizedBox(height: 14.h),

                  SiteManagerSection(
                    title: context.loc.smOverview,
                    children: [
                      SiteManagerSettingsTile(
                        icon: Icons.assignment_outlined,
                        title: context.loc.inspections,
                        subtitle: context.loc.performInspection,
                        onTap: () {
                          context.push(
                            RouteConstants.siteManagerSiteInspection,
                          );
                        },
                      ),
                      SiteManagerSettingsTile(
                        icon: Icons.account_tree_outlined,
                        title: context.loc.phaseBoard,
                        subtitle: context.loc.projects,
                        onTap: () {
                          context.push(RouteConstants.siteManagerPhaseBoard);
                        },
                      ),
                      SiteManagerSettingsTile(
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

                  SiteManagerSection(
                    title: context.loc.settings,
                    children: [
                      SiteManagerSettingsTile(
                        icon: Icons.sync_rounded,
                        title: syncState.hasPending
                            ? context.loc.pendingSyncCount(
                                '${syncState.totalPendingCount}',
                              )
                            : context.loc.synced,
                        trailing: Text(
                          syncState.isSyncing
                              ? context.loc.syncingInProgress
                              : (syncState.hasPending
                                    ? context.loc.syncNow
                                    : context.loc.synced),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: syncState.hasPending
                                    ? AppColors.warning
                                    : AppColors.success,
                              ),
                        ),
                        onTap: () => SiteManagerSyncDetailsSheet.show(context),
                      ),
                      SiteManagerSettingsTile(
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
                      SiteManagerSettingsTile(
                        icon: notificationsEnabled
                            ? Icons.notifications_outlined
                            : Icons.notifications_off_outlined,
                        title: context.loc.notifications,
                        subtitle: notificationsEnabled
                            ? context.loc.on
                            : context.loc.off,
                        trailing: Switch.adaptive(
                          value: notificationsEnabled,
                          activeColor: AppColors.primary,
                          onChanged: (_) {
                            ref
                                .read(notificationSettingsProvider.notifier)
                                .toggle();
                          },
                        ),
                        onTap: () {
                          ref
                              .read(notificationSettingsProvider.notifier)
                              .toggle();
                        },
                      ),
                      SiteManagerSettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: context.loc.changePassword,
                        onTap: () {
                          context.push(RouteConstants.changePassword);
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  SiteManagerSection(
                    title: context.loc.legalNotice,
                    children: [
                      SiteManagerSettingsTile(
                        icon: Icons.policy_outlined,
                        title: context.loc.privacyPolicy,
                        onTap: () {
                          context.push(RouteConstants.privacyPolicy);
                        },
                      ),
                      SiteManagerSettingsTile(
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
        if (_isLoggingOut) const LogoutLoadingOverlay(),
      ],
    ),
  ),
  ),
);
  }

  Widget _buildLogoutButton() {
    return AppOutlinedButton(
      fullWidth: true,
      isLoading: _isLoggingOut,
      onPressed: _isLoggingOut ? null : _logout,
      leadingIcon: Icons.logout_rounded,
      text: context.loc.logout,
      foregroundColor: AppColors.error,
      borderColor: AppColors.error,
      borderRadius: 8.r,
      textStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.error,
      ),
    );
  }

  void _showLanguageOptions() {
    LanguageSelectionBottomSheet.show(context, ref);
  }

  void _logout() {
    LogoutConfirmation.show(
      context: context,
      onLogout: () async {
        setState(() => _isLoggingOut = true);
        try {
          await ref.read(authProvider.notifier).logout();
          if (mounted) {
            showMessage(context.loc.loggedOutSuccess);
            context.go(RouteConstants.signIn);
          }
        } catch (_) {
          if (mounted) {
            setState(() => _isLoggingOut = false);
          }
        }
      },
    );
  }
}
