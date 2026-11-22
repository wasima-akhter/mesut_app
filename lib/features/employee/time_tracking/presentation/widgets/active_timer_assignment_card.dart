import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/features/employee/shared/helper/employee_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/employee_timer_state.dart';

class ActiveTimerAssignmentCard extends StatelessWidget {
  const ActiveTimerAssignmentCard({super.key, required this.state});

  final EmployeeTimerState state;

  @override
  Widget build(BuildContext context) {
    final project = state.currentProject;
    final activity = state.currentActivity;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: activity.backgroundColor,
              borderRadius: BorderRadius.circular(6.r),
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
          SizedBox(height: 13.h),
          Text(
            project.fullName,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  project.address.isNotEmpty ? project.address : '---',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
