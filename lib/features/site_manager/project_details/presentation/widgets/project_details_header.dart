import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';
import '../../domain/entities/project_details_entity.dart';

class ProjectDetailsHeader extends StatelessWidget {
  final ProjectDetailsEntity details;
  final VoidCallback? onEdit;

  const ProjectDetailsHeader({
    super.key,
    required this.details,
    this.onEdit,
  });

  Widget _statusTag(String text, {required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.5.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = details.primaryPhase;
    final phaseType = primary?.type ?? 'ERECTION';
    final status = primary?.status ?? 'ENQUIRY';
    final priority = primary?.priority ?? 'MEDIUM';

    final phaseColor = MobilePhaseLocalizer.phaseColor(phaseType);
    final statusColor = MobilePhaseLocalizer.statusColor(status);
    final priorityColor = MobilePhaseLocalizer.priorityColor(priority);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIconButton.circle(
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => context.pop(),
                size: 34.w,
                border: Border.all(color: const Color(0xFFE5E5E5)),
                iconColor: const Color(0xFF333333),
                iconSize: 17.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  context.loc.projectDetails,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                ),
              ),
              if (onEdit != null)
                AppIconButton.circle(
                  icon: Icons.edit_outlined,
                  onPressed: onEdit!,
                  size: 34.w,
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                  iconColor: const Color(0xFF333333),
                  iconSize: 17.sp,
                )
              else
                SizedBox(width: 34.w),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            details.name.isNotEmpty ? details.name : details.id,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              _statusTag(
                MobilePhaseLocalizer.phaseType(context, phaseType),
                color: phaseColor,
              ),
              _statusTag(
                MobilePhaseLocalizer.status(context, status),
                color: statusColor,
              ),
              _statusTag(
                MobilePhaseLocalizer.priority(context, priority),
                color: priorityColor,
              ),
              if (details.totalLoggedHours > 0)
                _statusTag(
                  '⏱ ${details.formattedTotalHours} hrs',
                  color: details.isProfitable
                      ? const Color(0xFF027A48)
                      : const Color(0xFFB42318),
                ),
            ],
          ),
          if (details.formattedAddress.isNotEmpty &&
              details.formattedAddress != '--') ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 17.sp,
                  color: const Color(0xFF777777),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    details.formattedAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF555555),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
