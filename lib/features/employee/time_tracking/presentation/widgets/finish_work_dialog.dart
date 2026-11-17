import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/widgets/buttons/buttons.dart';

class FinishWorkDialog extends StatelessWidget {
  const FinishWorkDialog({
    super.key,
    required this.projectName,
    required this.totalTime,
    required this.onSave,
  });

  final String projectName;
  final String totalTime;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 18.h),
            Container(
              width: 50.w,
              height: 50.w,
              decoration: const BoxDecoration(
                color: AppColors.infoLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.info,
                size: 30,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              '${context.loc.finishWork} $projectName?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 7.h),
            Text(
              '${context.loc.totalHoursLogged}: $totalTime',
              style: TextStyle(fontSize: 16.sp, color: AppColors.textTertiary),
            ),
            SizedBox(height: 20.h),
            AppButton(
              onPressed: onSave,
              text: context.loc.saveEntry,
            ),
            SizedBox(height: 5.h),
            AppTextButton(
              onPressed: () => Navigator.of(context).pop(),
              text: context.loc.cancel,
              textStyle: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
