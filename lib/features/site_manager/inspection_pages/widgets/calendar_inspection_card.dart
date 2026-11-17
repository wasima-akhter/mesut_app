import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/constants/route_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/widgets/buttons/buttons.dart';
import '../../../shared/mobile_dashboard/domain/entities/mobile_schedule_entity.dart';

class CalendarInspectionCard extends StatelessWidget {
  const CalendarInspectionCard({super.key, required this.inspection});

  final MobileScheduleInspectionEntity inspection;

  String _formatAppointmentTime(String locale) {
    if (inspection.appointmentDate == null) return '';
    return DateFormat.jm(locale).format(inspection.appointmentDate!);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.loc.localeCode;
    final timeStr = _formatAppointmentTime(locale);
    final addressStr = [
      inspection.address,
      inspection.postalCode,
      inspection.city,
    ].where((s) => s.isNotEmpty).join(' ');

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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  context.loc.inspections,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (timeStr.isNotEmpty) ...[
                Icon(
                  Icons.access_time_rounded,
                  size: 14.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  timeStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            inspection.siteTitle.isNotEmpty
                ? inspection.siteTitle
                : context.loc.inspections,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          if (addressStr.isNotEmpty) ...[
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
                    addressStr,
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
          if (inspection.customerName.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 14.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    inspection.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
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
                text: inspection.projectId.isNotEmpty
                    ? context.loc.openProject
                    : context.loc.inspections,
                onTap: () {
                  if (inspection.projectId.isNotEmpty) {
                    context.push(
                      RouteConstants.siteManagerProjectDetail,
                      extra: inspection.projectId,
                    );
                  } else {
                    context.push(RouteConstants.siteManagerSiteInspection);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
