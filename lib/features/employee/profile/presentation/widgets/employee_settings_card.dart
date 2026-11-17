import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants/route_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../shared/config/presentation/providers/mobile_config_provider.dart';
import '../../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../../shared/notifications/presentation/providers/notification_settings_provider.dart';
import '../../presentation/providers/employee_profile_provider.dart';

class EmployeeSettingsCard extends ConsumerWidget {
  const EmployeeSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(notificationSettingsProvider);
    final currentLang = ref.watch(appLanguageProvider);
    final langName = currentLang == AppLanguage.german
        ? context.loc.german
        : context.loc.english;

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
    final currentLang = ref.read(appLanguageProvider);
    final enabledLanguages = ref.read(enabledLanguagesProvider);

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
                      for (final lang in enabledLanguages)
                        ListTile(
                          onTap: () async {
                            Navigator.of(dialogContext).pop();
                            final langCode =
                                lang == AppLanguage.german ? 'DE' : 'EN';
                            await ref
                                .read(appLanguageProvider.notifier)
                                .setLanguage(lang);
                            try {
                              await ref
                                  .read(mobileProfileProvider.notifier)
                                  .updateProfile(language: langCode);
                            } catch (_) {}
                          },
                          title: Text(
                            lang == AppLanguage.german
                                ? context.loc.german
                                : context.loc.english,
                            style: TextStyle(fontSize: 17.sp),
                          ),
                          trailing: currentLang == lang
                              ? const Icon(Icons.check, color: AppColors.primary)
                              : null,
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
}
