import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/widgets/translation/translation_status_badge.dart';
import '../../../shared/helper/employee_enums.dart';
import '../../../shared/helper/employee_models.dart';

class EmployeeTimeLogCard extends StatelessWidget {
  const EmployeeTimeLogCard({
    super.key,
    required this.log,
    required this.onTap,
  });

  final EmployeeTimeLogModel log;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activity = log.project.activity;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    log.formattedDate,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                Text(
                  log.formattedDuration,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  context.loc.hrsShort,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 7.h),
            Text(
              log.project.fullName,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 4.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: activity.backgroundColor,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    activity.label,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: activity.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (log.localization != null)
                  TranslationStatusBadge.fromMeta(log.localization),
              ],
            ),
            SizedBox(height: 9.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${log.project.formattedTimeRange} · ${context.loc.breakTime}: ${log.formattedBreakTime}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                if (log.synced)
                  Text(
                    context.loc.synced,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}
