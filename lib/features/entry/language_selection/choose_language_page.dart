import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/asset_constants.dart';
import '../../../app/constants/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../shared/config/presentation/providers/mobile_config_provider.dart';

class ChooseLanguagePage extends ConsumerStatefulWidget {
  const ChooseLanguagePage({super.key});

  @override
  ConsumerState<ChooseLanguagePage> createState() => _ChooseLanguagePageState();
}

class _ChooseLanguagePageState extends ConsumerState<ChooseLanguagePage> {
  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(appLanguageProvider);
    final languages = ref.watch(enabledLanguagesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogo(),
              SizedBox(height: 18.h),
              Text(
                context.loc.chooseLanguageTitle,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                context.loc.chooseLanguageSubtitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.separated(
                  itemCount: languages.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, i) {
                    final lang = languages[i];
                    return _buildLanguageCard(
                      language: lang,
                      title: lang.label,
                      subtitle: lang.subtitle,
                      flagEmoji: lang.flagEmoji,
                      isSelected: currentLanguage == lang,
                      onTap: () {
                        ref
                            .read(appLanguageProvider.notifier)
                            .setLanguage(lang);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 12.h),
              AppButton(
                onPressed: () {
                  context.go(RouteConstants.onboarding);
                },
                text: context.loc.continueAction,
                trailingIcon: Icons.arrow_forward_rounded,
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return RepaintBoundary(
      child: Container(
        width: 50.r,
        height: 50.r,
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: AppColors.primary600,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(
          AssetConstants.appLogo,
          fit: BoxFit.contain,
          cacheWidth: 120,
          cacheHeight: 120,
          errorBuilder: (_, _, _) {
            return const Icon(
              Icons.translate_rounded,
              size: 24,
              color: Colors.white,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required AppLanguage language,
    required String title,
    required String subtitle,
    required String flagEmoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return RepaintBoundary(
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2.0 : 1.0,
              ),
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.04)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.neutral100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(flagEmoji, style: TextStyle(fontSize: 20.sp)),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 20.r,
                  height: 20.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : AppColors.neutral300,
                      width: isSelected ? 6.0 : 1.5,
                    ),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
