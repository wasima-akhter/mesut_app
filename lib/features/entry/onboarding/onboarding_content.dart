// lib/features/onboarding/presentation/widgets/onboarding_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radii.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/buttons/buttons.dart';

class OnboardingContent extends StatelessWidget {
  const OnboardingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 14.h, 10.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              'Your Daily Jobs at a\nGlance',
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.white,
                fontSize: 18.sp,
                height: 1.02,
              ),
            ),
          ),
          SizedBox(height: 5.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              'See your assigned job locations and daily timings, '
              'access notes, and get one-tap site navigation.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white.withValues(alpha: 0.82),
                fontSize: 7.5.sp,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          AppButton(
            onPressed: () {},
            backgroundColor: AppColors.primary400,
            borderRadius: AppRadii.sm,
            verticalPadding: 6.h,
            text: 'Next  →',
            textStyle: AppTextStyles.button.copyWith(fontSize: 9.sp),
          ),
          SizedBox(height: 7.h),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4.r,
                  height: 4.r,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 3.w),
                Container(
                  width: 4.r,
                  height: 4.r,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 3.w),
                Container(
                  width: 4.r,
                  height: 4.r,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
