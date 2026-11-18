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

class ChooseLanguagePage extends ConsumerStatefulWidget {
  const ChooseLanguagePage({super.key});

  @override
  ConsumerState<ChooseLanguagePage> createState() => _ChooseLanguagePageState();
}

class _ChooseLanguagePageState extends ConsumerState<ChooseLanguagePage> {
  static const List<AppLanguage> _languages = AppLanguage.values;

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(appLanguageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              _buildLogo(),
              SizedBox(height: 28.h),
              Text(
                context.loc.chooseLanguageTitle,
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                context.loc.chooseLanguageSubtitle,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 32.h),
              for (int i = 0; i < _languages.length; i++) ...[
                if (i > 0) SizedBox(height: 14.h),
                _buildLanguageCard(
                  language: _languages[i],
                  title: _languages[i] == AppLanguage.german
                      ? 'Deutsch'
                      : 'English',
                  subtitle: _languages[i] == AppLanguage.german
                      ? 'German (DE/AT/CH)'
                      : 'English (US/UK)',
                  flagEmoji: _languages[i] == AppLanguage.german ? '🇩🇪' : '🇬🇧',
                  isSelected: currentLanguage == _languages[i],
                  onTap: () {
                    ref
                        .read(appLanguageProvider.notifier)
                        .setLanguage(_languages[i]);
                  },
                ),
              ],
              const Spacer(),
              AppButton(
                onPressed: () {
                  context.go(RouteConstants.onboarding);
                },
                text: context.loc.continueAction,
                trailingIcon: Icons.arrow_forward_rounded,
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return RepaintBoundary(
      child: Container(
        width: 58.r,
        height: 58.r,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.primary600,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
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
              size: 28,
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
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
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
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.neutral100,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(flagEmoji, style: TextStyle(fontSize: 24.sp)),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 22.r,
                  height: 22.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : AppColors.neutral300,
                      width: isSelected ? 6.5 : 1.5,
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
