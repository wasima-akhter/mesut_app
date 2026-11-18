import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:construction_app/app/constants/route_constants.dart';
import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/extensions/date_time_extensions.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/widgets/images/app_avatar.dart';
import '../../domain/entities/employee_dashboard_entity.dart';

class EmployeeHomeHeader extends StatelessWidget {
  const EmployeeHomeHeader({super.key, required this.user});

  final EmployeeDashboardUserEntity user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
          ),
          child: AppAvatar(
            imageUrl: user.avatarUrl,
            name: user.fullName,
            size: 50.w,
            backgroundColor: AppColors.neutral200,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.loc.welcomeBack,
                style: TextStyle(
                  fontSize: 17.sp,
                  color: AppColors.textTertiary,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                user.firstName.isNotEmpty ? user.firstName : 'Employee',
                style: TextStyle(
                  fontSize: 23.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.push(RouteConstants.notifications),
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 25,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class EmployeeHomeDateHeader extends StatelessWidget {
  const EmployeeHomeDateHeader({super.key, required this.dashboard});

  final EmployeeDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    final dateStr = dashboard.date != null
        ? dashboard.date!.toLocal().formatLocalized(style: 'weekday_full')
        : (dashboard.formattedDate.isNotEmpty
            ? dashboard.formattedDate
            : DateTime.now().formatLocalized(style: 'weekday_full'));

    return Padding(
      padding: EdgeInsets.only(top: 18.h),
      child: Text(
        dateStr,
        style: TextStyle(
          fontSize: 17.sp,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class EmployeeHomeTasksSectionHeader extends StatelessWidget {
  const EmployeeHomeTasksSectionHeader({super.key, required this.taskCount});

  final int taskCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.loc.upcomingTasks,
            style: TextStyle(
              fontSize: 23.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '$taskCount ${context.loc.smTasks}',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
