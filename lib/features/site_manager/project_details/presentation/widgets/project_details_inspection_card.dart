import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../domain/entities/project_details_entity.dart';

class ProjectDetailsInspectionCard extends StatelessWidget {
  final NextSafetyInspection inspection;

  const ProjectDetailsInspectionCard({super.key, required this.inspection});

  @override
  Widget build(BuildContext context) {
    if (inspection.isEmpty) return const SizedBox.shrink();

    final dateStr = inspection.appointmentDate != null
        ? '${inspection.appointmentDate!.day.toString().padLeft(2, '0')}.${inspection.appointmentDate!.month.toString().padLeft(2, '0')}.${inspection.appointmentDate!.year}'
        : '--';

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
            children: [
              Flexible(
                child: Text(
                  context.loc.safetyInspection,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.5.sp,
                    color: const Color(0xFF111111),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5DD),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  context.loc.planned,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF79009),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: 18.sp,
                color: const Color(0xFF777777),
              ),
              SizedBox(width: 8.w),
              Text(
                '${context.loc.nextDueDate}: $dateStr',
                style: TextStyle(
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111111),
                ),
              ),
            ],
          ),
          if (inspection.siteTitle.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 18.sp,
                  color: const Color(0xFF777777),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    inspection.siteTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      color: const Color(0xFF555555),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (inspection.address.isNotEmpty || inspection.city.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18.sp,
                  color: const Color(0xFF777777),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '${inspection.address}${inspection.city.isNotEmpty ? ', ${inspection.city}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFF777777),
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
