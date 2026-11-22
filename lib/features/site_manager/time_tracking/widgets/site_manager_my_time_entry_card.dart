import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/backend_enums.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/utils/app_date_time_formatter.dart';
import '../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import '../../../shared/mobile_time_tracking/domain/entities/mobile_time_log_entity.dart';
import '../bottom_sheet_container.dart';

/// Card and detail sheet representing a single logged entry in "My Time".
class SiteManagerMyTimeEntryCard extends StatelessWidget {
  const SiteManagerMyTimeEntryCard({super.key, required this.entry});

  final MobileTimeLogEntity entry;

  @override
  Widget build(BuildContext context) {
    final startStr = entry.startTime != null
        ? AppDateTimeFormatter.formatTime(entry.startTime!.toLocal())
        : '--:--';
    final endStr = entry.endTime != null
        ? AppDateTimeFormatter.formatTime(entry.endTime!.toLocal())
        : context.loc.running;
    final dateStr = entry.createdAt != null
        ? AppDateTimeFormatter.formatDate(entry.createdAt!.toLocal())
        : '';

    return RepaintBoundary(
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: () => _showEntryDetails(context, entry),
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
              SizedBox(height: 5.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      MobilePhaseLocalizer.phaseType(
                        context,
                        entry.activityType.serializedName,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${entry.netHours.toStringAsFixed(1)}h',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _activityBadge(context, entry.activityType),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$startStr – $endStr • ${context.loc.breakLabel}: ${entry.breakMinutes}m',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    MobilePhaseLocalizer.status(context, entry.status),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: entry.status == 'APPROVED'
                              ? AppColors.success
                              : AppColors.warning,
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

  Widget _activityBadge(BuildContext context, BackendActivityType activity) {
    final color = _activityColor(activity);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        MobilePhaseLocalizer.phaseType(context, activity.serializedName),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  static Color _activityColor(BackendActivityType activity) => switch (activity) {
        BackendActivityType.erection => AppColors.success,
        BackendActivityType.dismantling => AppColors.warning,
        BackendActivityType.transport => AppColors.info,
        BackendActivityType.maintenance => AppColors.timePurple,
        BackendActivityType.other => AppColors.neutral600,
      };

  static void _showEntryDetails(BuildContext context, MobileTimeLogEntity entry) {
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => BottomSheetContainer(
        title: context.loc.timeEntry,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(
              context,
              context.loc.activityType,
              MobilePhaseLocalizer.phaseType(
                context,
                entry.activityType.serializedName,
              ),
            ),
            _detailRow(context, context.loc.phase, entry.phaseId),
            _detailRow(
              context,
              context.loc.status,
              MobilePhaseLocalizer.status(context, entry.status),
            ),
            _detailRow(context, context.loc.breakTime, '${entry.breakMinutes}m'),
            _detailRow(context, context.loc.total, '${entry.netHours.toStringAsFixed(1)}h'),
            if (entry.user != null)
              _detailRow(context, context.loc.employee, entry.user!.fullName),
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
}
