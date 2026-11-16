import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../domain/entities/project_details_entity.dart';

class ProjectDetailsCrewCard extends StatelessWidget {
  final List<CrewBreakdownItem> crew;

  const ProjectDetailsCrewCard({super.key, required this.crew});

  @override
  Widget build(BuildContext context) {
    if (crew.isEmpty) return const SizedBox.shrink();

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
          Text(
            context.loc.crewBreakdown,
            style: TextStyle(
              fontSize: 18.5.sp,
              color: const Color(0xFF111111),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          ...crew.map((member) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: const Color(0xFFF3F4F6),
                    child: Text(
                      member.user.firstName.isNotEmpty
                          ? member.user.firstName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      member.user.fullName.isNotEmpty
                          ? member.user.fullName
                          : member.user.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111111),
                      ),
                    ),
                  ),
                  Text(
                    '${member.totalHours.toStringAsFixed(1)} ${context.loc.hrsShort}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  if (member.synced) ...[
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.cloud_done,
                      size: 17.sp,
                      color: const Color(0xFF10B981),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
