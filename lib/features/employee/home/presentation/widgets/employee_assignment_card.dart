import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/widgets/buttons/buttons.dart';
import '../../../shared/helper/employee_enums.dart';
import '../../../shared/helper/employee_models.dart';

class EmployeeAssignmentCard extends StatelessWidget {
  const EmployeeAssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
    required this.onNavigate,
    required this.onStartTimer,
  });

  final EmployeeAssignmentModel assignment;
  final VoidCallback onTap;
  final VoidCallback onNavigate;
  final VoidCallback onStartTimer;

  Widget _activityChip(EmployeeActivityType activity) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: activity.backgroundColor,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Text(
        activity.label,
        style: TextStyle(
          fontSize: 15.sp,
          color: activity.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activity = assignment.activity;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _activityChip(activity),
                const Spacer(),
                Text(
                  assignment.formattedSchedule,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.h),
            Text(
              assignment.project,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 7.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    assignment.address,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              '${context.loc.manager}: ${assignment.siteManager}',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textTertiary,
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: AppOutlinedButton(
                    onPressed: onNavigate,
                    leadingIcon: Icons.directions_outlined,
                    text: context.loc.navigation,
                    foregroundColor: AppColors.textSecondary,
                    borderColor: AppColors.border,
                    borderRadius: 8.r,
                    textStyle: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 5,
                  child: AppButton(
                    onPressed: onStartTimer,
                    text: context.loc.startNewTimer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
