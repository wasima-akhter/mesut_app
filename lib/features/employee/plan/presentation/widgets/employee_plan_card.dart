import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/widgets/translation/translation_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/employee_schedule_entity.dart';

class EmployeePlanCard extends StatelessWidget {
  const EmployeePlanCard({super.key, required this.phase});

  final EmployeeSchedulePhaseEntity phase;

  Color _getBadgeColor() {
    final type = phase.type.toUpperCase();
    if (type.contains('ERECTION')) return AppColors.success;
    if (type.contains('DISMANTLING')) return AppColors.warning;
    return AppColors.info;
  }

  String _formatType(BuildContext context) {
    final type = phase.type.toUpperCase();
    if (type.contains('ERECTION')) return context.loc.scaffoldErection;
    if (type.contains('DISMANTLING')) return context.loc.scaffoldDismantling;
    if (type.contains('STANDING')) return context.loc.standingScaffold;
    if (type.contains('MAINTENANCE')) return context.loc.maintenance;
    return phase.type.isNotEmpty ? phase.type : context.loc.otherActivity;
  }

  String _formatTimeRange(String locale) {
    if (phase.startDate == null && phase.endDate == null) {
      if (phase.assignedHours > 0)
        return '${phase.assignedHours.toStringAsFixed(0)}h';
      return '-';
    }
    final fmt = DateFormat.jm(locale);
    final startStr = phase.startDate != null
        ? fmt.format(phase.startDate!)
        : '';
    final endStr = phase.endDate != null ? fmt.format(phase.endDate!) : '';
    final hoursSuffix = phase.assignedHours > 0
        ? ' (${phase.assignedHours.toStringAsFixed(0)}h)'
        : '';

    if (startStr.isNotEmpty && endStr.isNotEmpty) {
      return '$startStr – $endStr$hoursSuffix';
    }
    if (startStr.isNotEmpty) return '$startStr$hoursSuffix';
    return '$endStr$hoursSuffix';
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _getBadgeColor();
    final locale = context.loc.localeCode;
    final timeStr = _formatTimeRange(locale);
    final projectName = phase.project.name.isNotEmpty
        ? phase.project.name
        : context.loc.project;

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  projectName,
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  _formatType(context),
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: badgeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (phase.localization != null) ...[
                SizedBox(width: 6.w),
                TranslationStatusBadge.fromMeta(phase.localization),
              ],
            ],
          ),
          if (phase.project.address.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    phase.project.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.access_time_outlined,
                size: 16.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 6.w),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 18.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  '${context.loc.siteLead}: ${phase.siteManagerNames}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.textTertiary,
                  ),
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
