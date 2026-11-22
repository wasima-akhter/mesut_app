import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:construction_app/app/constants/route_constants.dart';
import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/localization/localization_provider.dart';
import '../../../../shared/widgets/language_selection_bottom_sheet.dart';
import '../../../../shared/notifications/presentation/providers/notification_settings_provider.dart';
import '../../../offline_sync/providers/employee_sync_provider.dart';
import '../../../offline_sync/widgets/employee_sync_details_sheet.dart';

class EmployeeSettingsCard extends ConsumerWidget {
  const EmployeeSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(notificationSettingsProvider);
    final syncState = ref.watch(employeeSyncProvider);
    final currentLang = ref.watch(appLanguageProvider);
    final langName = currentLang.label;

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
            context.loc.settings,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          _settingRow(
            icon: Icons.language_outlined,
            title: context.loc.language,
            trailing: langName,
            onTap: () => _changeLanguage(context, ref),
          ),
          _settingRow(
            icon: Icons.lock_outline,
            title: context.loc.changePassword,
            onTap: () => context.push(RouteConstants.changePassword),
          ),
          _settingRow(
            icon: notificationsEnabled
                ? Icons.notifications_outlined
                : Icons.notifications_off_outlined,
            title: context.loc.notifications,
            trailing: notificationsEnabled ? context.loc.on : context.loc.off,
            onTap: () {
              ref.read(notificationSettingsProvider.notifier).toggle();
            },
            showDivider: true,
          ),
          _settingRow(
            icon: Icons.sync_rounded,
            title: context.loc.sync,
            trailing: syncState.hasPending
                ? context.loc.pendingSyncCount('${syncState.totalPendingCount}')
                : (syncState.isOnline
                    ? context.loc.synced
                    : context.loc.get('common.offline', 'Offline')),
            onTap: () => EmployeeSyncDetailsSheet.show(context),
            showDivider: false,
          ),
        ],
      ),
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

  void _changeLanguage(BuildContext context, WidgetRef ref) {
    LanguageSelectionBottomSheet.show(context, ref);
  }
}
