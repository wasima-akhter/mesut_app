import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/utils/app_date_time_formatter.dart';
import 'package:construction_app/core/widgets/buttons/buttons.dart';
import '../../domain/entities/employee_time_tracking_entities.dart';

class EmployeeTimeTrackingTopHeader extends StatelessWidget {
  const EmployeeTimeTrackingTopHeader({super.key, required this.onAddTime});

  final VoidCallback onAddTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.loc.smTimeTracking,
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        AppOutlinedButton(
          fullWidth: false,
          onPressed: onAddTime,
          leadingIcon: Icons.add,
          text: context.loc.addTime,
          foregroundColor: AppColors.textSecondary,
          borderColor: AppColors.border,
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
          borderRadius: 7.r,
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class EmployeeWeekLabel extends StatelessWidget {
  const EmployeeWeekLabel({super.key, required this.summary});

  final EmployeeTimeSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final start = summary.weekStartDate ??
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    final end = summary.weekEndDate ?? start.add(const Duration(days: 6));
    final weekNum = summary.weekNumber > 0
        ? summary.weekNumber
        : ((DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays) / 7).ceil();
    final formattedRange = AppDateTimeFormatter.formatDateRange(start, end);

    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Text(
        context.loc.weekRange('$weekNum', formattedRange),
        style: TextStyle(fontSize: 16.sp, color: AppColors.textTertiary),
      ),
    );
  }
}

class EmployeeRecentLogsHeader extends StatelessWidget {
  const EmployeeRecentLogsHeader({
    super.key,
    required this.showThisMonth,
    required this.onTogglePeriod,
  });

  final bool showThisMonth;
  final VoidCallback onTogglePeriod;

  Widget _filterChip(String title, bool selected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.neutral100,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          color: selected ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.recentLogs,
          style: TextStyle(
            fontSize: 21.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (showThisMonth) onTogglePeriod();
              },
              child: _filterChip(context.loc.thisWeek, !showThisMonth),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                if (!showThisMonth) onTogglePeriod();
              },
              child: _filterChip(context.loc.thisMonth, showThisMonth),
            ),
          ],
        ),
      ],
    );
  }
}
