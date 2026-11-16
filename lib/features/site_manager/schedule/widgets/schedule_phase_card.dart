import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../shared/mobile_dashboard/domain/entities/mobile_schedule_entity.dart';
import '../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';

class SchedulePhaseCard extends StatelessWidget {
  const SchedulePhaseCard({
    super.key,
    required this.phase,
    required this.onTap,
  });

  final MobileSchedulePhaseEntity phase;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final phaseColor = MobilePhaseLocalizer.phaseColor(phase.type);
    final priorityColor = MobilePhaseLocalizer.priorityColor(phase.priority);

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          leading: CircleAvatar(
            backgroundColor: phaseColor.withValues(alpha: 0.14),
            child: Icon(Icons.engineering_outlined, color: phaseColor),
          ),
          title: Text(
            phase.project.name.isEmpty ? phase.id : phase.project.name,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${MobilePhaseLocalizer.phaseType(context, phase.type)} • ${phase.project.address}',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              MobilePhaseLocalizer.priority(context, phase.priority),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: priorityColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
