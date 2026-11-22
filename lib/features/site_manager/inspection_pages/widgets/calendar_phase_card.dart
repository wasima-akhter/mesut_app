import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/constants/route_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/widgets/buttons/buttons.dart';
import '../../../shared/mobile_dashboard/domain/entities/mobile_schedule_entity.dart';
import '../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';

class CalendarPhaseCard extends StatelessWidget {
  const CalendarPhaseCard({super.key, required this.phase});

  final MobileSchedulePhaseEntity phase;

  Color _getPhaseColor() {
    final type = phase.type.toUpperCase();
    if (type.contains('ERECTION')) return AppColors.success;
    if (type.contains('DISMANTLING')) return AppColors.warning;
    return AppColors.info;
  }

  String _formatPhaseType(BuildContext context) {
    final type = phase.type.toUpperCase();
    if (type.contains('ERECTION')) return context.loc.erectionPhase;
    if (type.contains('DISMANTLING')) return context.loc.dismantlingPhase;
    if (type.contains('STANDING')) return context.loc.standing;
    if (type.contains('MAINTENANCE')) return context.loc.maintenance;
    return phase.type;
  }

  String _formatDateRange(String locale) {
    if (phase.startDate == null && phase.endDate == null) return '-';
    final fmt = DateFormat('dd.MM.yyyy', locale);
    if (phase.startDate != null && phase.endDate != null) {
      return '${fmt.format(phase.startDate!)} - ${fmt.format(phase.endDate!)}';
    }
    if (phase.startDate != null) return fmt.format(phase.startDate!);
    return fmt.format(phase.endDate!);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPhaseColor();
    final locale = context.loc.localeCode;

    return Container(
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  _formatPhaseType(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (phase.priority.isNotEmpty) ...[
                SizedBox(width: 6.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    MobilePhaseLocalizer.priority(context, phase.priority),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Icon(
                Icons.calendar_today_outlined,
                size: 14.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 4.w),
              Text(
                _formatDateRange(locale),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            phase.project.name.isNotEmpty
                ? phase.project.name
                : context.loc.project,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          if (phase.project.address.isNotEmpty) ...[
            SizedBox(height: 5.h),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    phase.project.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 10.h),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SmallRedButton(
                text: context.loc.openProject,
                onTap: () {
                  context.push(
                    RouteConstants.siteManagerProjectDetail,
                    extra: phase.project.id,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
