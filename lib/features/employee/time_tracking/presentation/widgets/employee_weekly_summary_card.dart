import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/localization/context_extensions.dart';

class EmployeeWeeklySummaryCard extends StatelessWidget {
  const EmployeeWeeklySummaryCard({
    super.key,
    this.todayDuration = Duration.zero,
    this.weekDuration = Duration.zero,
    this.progressLogged = Duration.zero,
    this.progressTotal = const Duration(hours: 40),
    this.progressValue = 0.0,
  });

  final Duration todayDuration;
  final Duration weekDuration;
  final Duration progressLogged;
  final Duration progressTotal;
  final double progressValue;

  Widget _summaryItem({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white.withValues(alpha: .5),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  title: context.loc.today.toUpperCase(),
                  value: todayDuration.formatCompactLocalized(),
                ),
              ),
              Expanded(
                child: _summaryItem(
                  title: context.loc.thisWeek.toUpperCase(),
                  value: weekDuration.formatCompactLocalized(),
                ),
              ),
            ],
          ),
          SizedBox(height: 13.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(5.r),
            child: LinearProgressIndicator(
              minHeight: 4.h,
              value: progressValue.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: .2),
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
          SizedBox(height: 7.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              context.loc.weekProgress(
                progressLogged.formatCompactLocalized(),
                progressTotal.formatCompactLocalized(),
              ),
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white.withValues(alpha: .55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
