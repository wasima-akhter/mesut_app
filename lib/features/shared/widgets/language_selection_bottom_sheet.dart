import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/localization_provider.dart';
import '../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';

class LanguageSelectionBottomSheet {
  static Future<AppLanguage?> show(
    BuildContext context,
    WidgetRef ref, {
    bool syncProfile = true,
  }) {
    final currentLang = ref.read(appLanguageProvider);
    final languages = AppLanguage.values;

    return showModalBottomSheet<AppLanguage>(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (dialogContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(18.w, 16.h, 12.w, 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.loc.selectLanguage,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: languages.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (_, index) {
                    final lang = languages[index];
                    final isSelected = currentLang == lang;
                    return ListTile(
                      onTap: () async {
                        Navigator.of(dialogContext).pop(lang);
                        await ref
                            .read(appLanguageProvider.notifier)
                            .setLanguage(lang);
                        if (syncProfile) {
                          try {
                            await ref
                                .read(mobileProfileProvider.notifier)
                                .updateProfile(
                                  language: lang.code.toUpperCase(),
                                );
                          } catch (_) {}
                        }
                      },
                      leading: Text(
                        lang.flagEmoji,
                        style: TextStyle(fontSize: 22.sp),
                      ),
                      title: Text(
                        lang.label,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        lang.subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                            )
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
