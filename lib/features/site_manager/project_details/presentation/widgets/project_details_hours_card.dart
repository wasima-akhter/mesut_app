import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import '../../domain/entities/project_details_entity.dart';
import 'project_details_metrics_box.dart';

class ProjectDetailsHoursCard extends StatelessWidget {
  final ProjectDetailsEntity details;

  const ProjectDetailsHoursCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    if (details.totalLoggedHours == 0 && details.budgetedHours == 0) {
      return const SizedBox.shrink();
    }

    final isProfitable = details.isProfitable;
    final totalHours = details.totalLoggedHours;
    final remaining = details.remainingHours;
    final progress = details.budgetProgress;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: isProfitable
                      ? const Color(0xFFE9F8EF)
                      : const Color(0xFFFEE4E2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.access_time_filled_rounded,
                  size: 20.sp,
                  color: isProfitable
                      ? const Color(0xFF027A48)
                      : const Color(0xFFD92D20),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.loc.projectHoursLabor,
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111111),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      context.loc.hoursLoggedByCrew,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: const Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isProfitable
                      ? const Color(0xFFECFDF3)
                      : const Color(0xFFFEF3F2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isProfitable
                        ? const Color(0xFFA6F4C5)
                        : const Color(0xFFFECDCA),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isProfitable
                          ? Icons.check_circle_rounded
                          : Icons.warning_rounded,
                      size: 15.sp,
                      color: isProfitable
                          ? const Color(0xFF027A48)
                          : const Color(0xFFD92D20),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isProfitable
                          ? context.loc.profitable
                          : context.loc.lossRisk,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isProfitable
                            ? const Color(0xFF027A48)
                            : const Color(0xFFD92D20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ProjectDetailsMetricsBox(
            totalHours: details.formattedTotalHours,
            budgetHours: details.formattedBudgetHours,
            variance:
                '${isProfitable ? '+' : '-'}${remaining.abs().toStringAsFixed(1)}h',
            isProfitable: isProfitable,
          ),
          if (details.budgetedHours > 0) ...[
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.loc.budgetConsumedPercent(
                    (progress * 100).toInt().toString(),
                  ),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF344054),
                  ),
                ),
                Text(
                  '${details.formattedTotalHours} / ${details.formattedBudgetHours}',
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    color: const Color(0xFF667085),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 7.h,
                backgroundColor: const Color(0xFFEAECF0),
                valueColor: AlwaysStoppedAnimation(
                  isProfitable
                      ? (progress > 0.85
                            ? const Color(0xFFF79009)
                            : const Color(0xFF12B76A))
                      : const Color(0xFFD92D20),
                ),
              ),
            ),
          ],
          if (details.hoursByActivity.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Text(
              context.loc.hoursByActivity,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1D2939),
              ),
            ),
            SizedBox(height: 8.h),
            ...details.hoursByActivity.map((act) {
              final actPercent = totalHours > 0
                  ? ((act.hours / totalHours) * 100).toInt()
                  : 0;

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        MobilePhaseLocalizer.phaseType(
                          context,
                          act.activityType,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF344054),
                        ),
                      ),
                    ),
                    Text(
                      '${act.hours.toStringAsFixed(1)}h ($actPercent%)',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D2939),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
