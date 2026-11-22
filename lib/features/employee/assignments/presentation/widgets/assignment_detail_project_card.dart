import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/translation/translation_status_badge.dart';
import '../../../shared/helper/employee_models.dart';
import '../../domain/entities/employee_project_details_entity.dart';

class AssignmentDetailProjectCard extends StatelessWidget {
  final EmployeeProjectDetailsEntity? project;
  final EmployeeAssignmentModel? fallback;

  const AssignmentDetailProjectCard({
    super.key,
    this.project,
    this.fallback,
  });

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _activityChip(String type) {
    Color bg;
    Color fg;
    switch (type.toUpperCase()) {
      case 'DISMANTLING':
        bg = AppColors.errorLight;
        fg = AppColors.error;
        break;
      case 'STANDING':
        bg = AppColors.warningLight;
        fg = AppColors.warning;
        break;
      case 'ERECTION':
      default:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        type.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 19.sp, color: AppColors.textTertiary),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = project?.name.isNotEmpty == true
        ? project!.name
        : (fallback?.project ?? 'Project');
    final activityName = project?.phase?.type.isNotEmpty == true
        ? project!.phase!.type
        : (fallback?.activity.name.toUpperCase() ?? 'ERECTION');
    final area = project != null && project!.scaffoldArea > 0
        ? '${project!.scaffoldArea.toInt()} m²'
        : (project?.scaffoldLabel ?? fallback?.scaffoldArea ?? '-');
    final hours = project?.phase != null && project!.phase!.assignedHoursToday > 0
        ? '${project!.phase!.assignedHoursToday} ${context.loc.hrsShort}'
        : fallback?.schedule;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: _activityChip(activityName)),
              if (project?.localization != null) ...[
                SizedBox(width: 6.w),
                TranslationStatusBadge.fromMeta(project!.localization),
              ],
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          if (hours != null && hours.isNotEmpty) ...[
            _infoRow(
              Icons.access_time_outlined,
              '${context.loc.today}, $hours',
            ),
            SizedBox(height: 8.h),
          ],
          _infoRow(
            Icons.straighten_outlined,
            '${context.loc.scaffoldArea}: $area',
          ),
        ],
      ),
    );
  }
}
