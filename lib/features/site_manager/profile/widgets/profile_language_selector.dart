import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/context_extensions.dart';

class ProfileLanguageSelector extends StatelessWidget {
  const ProfileLanguageSelector({
    super.key,
    required this.selectedCode,
    required this.onLanguageChanged,
  });

  final String selectedCode;
  final ValueChanged<String> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    final isDe = selectedCode.toUpperCase() == 'DE';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.language,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 7.h),
        Row(
          children: [
            Expanded(
              child: _buildLangCard(
                context,
                title: context.loc.german,
                subtitle: 'Deutsch (DE)',
                flag: '🇩🇪',
                isSelected: isDe,
                onTap: () => onLanguageChanged('DE'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildLangCard(
                context,
                title: context.loc.english,
                subtitle: 'English (EN)',
                flag: '🇬🇧',
                isSelected: !isDe,
                onTap: () => onLanguageChanged('EN'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLangCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : AppColors.neutral400,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: 22.sp)),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 18.sp,
              ),
          ],
        ),
      ),
    );
  }
}
