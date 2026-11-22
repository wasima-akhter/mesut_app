import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/backend_enums.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import '../../../shared/mobile_time_tracking/domain/entities/mobile_time_log_entity.dart';
import '../bottom_sheet_container.dart';

/// Card, progress indicator, and modal sheet for site crew member entries.
class SiteManagerCrewCard extends StatelessWidget {
  const SiteManagerCrewCard({super.key, required this.member});

  final MobileCrewMemberSummaryEntity member;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: () => showCrewDetails(context, member),
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.user.fullName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      '${member.totalHours.toStringAsFixed(1)}h',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${context.loc.loggedTime}: ${member.totalHours.toStringAsFixed(1)}h',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      member.synced ? context.loc.synced : context.loc.pending,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: member.synced ? AppColors.success : AppColors.warning,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget crewProgress(
    BuildContext context, {
    required BackendActivityType activity,
    required String hours,
    required double progress,
  }) {
    final color = activityColor(activity);
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 7.w, height: 7.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  MobilePhaseLocalizer.phaseType(
                    context,
                    activity.serializedName,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.white),
                ),
              ),
              Text(hours, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.neutral300)),
            ],
          ),
          SizedBox(height: 5.h),
          LinearProgressIndicator(
            value: progress,
            minHeight: 4.h,
            backgroundColor: AppColors.neutral700,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ],
      ),
    );
  }

  static void showCrewDetails(BuildContext context, MobileCrewMemberSummaryEntity member) {
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => BottomSheetContainer(
        title: context.loc.crewMember,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(context, context.loc.employee, member.user.fullName),
            _detailRow(context, context.loc.total, '${member.totalHours.toStringAsFixed(1)}h'),
            _detailRow(context, context.loc.status, member.synced ? context.loc.synced : context.loc.pending),
            SizedBox(height: 20.h),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(sheetCtx),
                child: Text(context.loc.close, style: Theme.of(context).textTheme.labelLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _detailRow(BuildContext context, String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120.w, child: Text(title, style: Theme.of(context).textTheme.bodySmall)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }

  static Color activityColor(BackendActivityType activity) => switch (activity) {
        BackendActivityType.erection => AppColors.success,
        BackendActivityType.dismantling => AppColors.warning,
        BackendActivityType.transport => AppColors.info,
        BackendActivityType.maintenance => AppColors.timePurple,
        BackendActivityType.other => AppColors.neutral600,
      };
}
