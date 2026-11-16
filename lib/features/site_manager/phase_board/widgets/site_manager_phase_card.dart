import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import '../../domain/entities/mobile_phase_entity.dart';
import '../models/backend_phase_status.dart';

class SiteManagerPhaseCard extends StatelessWidget {
  const SiteManagerPhaseCard({
    super.key,
    required this.phase,
    required this.onTapProject,
    required this.onUpdateStatus,
  });

  final MobilePhaseEntity phase;
  final VoidCallback onTapProject;
  final VoidCallback onUpdateStatus;

  Widget _priorityBadge(BuildContext context, String priority) {
    final color = MobilePhaseLocalizer.priorityColor(priority);
    final label = MobilePhaseLocalizer.priority(context, priority);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = BackendPhaseStatus.fromString(phase.status);

    return GestureDetector(
      onTap: onTapProject,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _priorityBadge(context, phase.priority),
                const Spacer(),
                if (phase.startDate != null) ...[
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    MobilePhaseLocalizer.formatDateRange(
                      phase.startDate,
                      phase.endDate,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              phase.project.name.isNotEmpty ? phase.project.name : phase.id,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 7.h),
            Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 15.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    MobilePhaseLocalizer.phaseType(context, phase.type),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            if (phase.project.address.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 15.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Text(
                      phase.project.address,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 11.h),
            Divider(height: 1, color: AppColors.border),
            SizedBox(height: 9.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(status.icon, size: 14.sp, color: status.color),
                      SizedBox(width: 5.w),
                      Text(
                        status.localizedName(context),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: status.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onUpdateStatus,
                    borderRadius: BorderRadius.circular(50.r),
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 17.sp,
                        color: AppColors.textSecondary,
                      ),
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
