import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/widgets/buttons/buttons.dart';
import '../../../shared/mobile_dashboard/domain/entities/mobile_dashboard_entity.dart';
import '../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';

class EmployeeUpcomingTaskCard extends StatelessWidget {
  const EmployeeUpcomingTaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onNavigate,
    required this.onStartTimer,
  });

  final UpcomingTaskEntity task;
  final VoidCallback onTap;
  final VoidCallback onNavigate;
  final VoidCallback onStartTimer;

  @override
  Widget build(BuildContext context) {
    final phaseColor = MobilePhaseLocalizer.phaseColor(task.type);
    final priorityColor = MobilePhaseLocalizer.priorityColor(task.priority);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Badge(
                  label: MobilePhaseLocalizer.phaseType(context, task.type),
                  color: phaseColor,
                ),
                SizedBox(width: 8.w),
                _Badge(
                  label: MobilePhaseLocalizer.priority(context, task.priority),
                  color: priorityColor,
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    MobilePhaseLocalizer.formatDateRange(
                      task.startDate,
                      task.endDate,
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              task.project.name.isEmpty ? task.phaseId : task.project.name,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            if (task.project.address.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      task.project.address,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: AppOutlinedButton(
                    onPressed: onNavigate,
                    leadingIcon: Icons.directions_outlined,
                    text: context.loc.navigation,
                    foregroundColor: AppColors.textSecondary,
                    borderColor: AppColors.border,
                    borderRadius: 8.r,
                    textStyle: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: AppButton(
                    onPressed: onStartTimer,
                    text: context.loc.startNewTimer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
