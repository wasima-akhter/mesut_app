import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/project_history_entity.dart';

class ProjectHistoryItemCard extends StatelessWidget {
  final ProjectHistoryEntity item;
  final bool isLast;

  const ProjectHistoryItemCard({
    super.key,
    required this.item,
    this.isLast = false,
  });

  Widget _buildDetailsView() {
    final entries = item.formattedDetailEntries;
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 6.h, bottom: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries.map((entry) {
          if (entry.key.isEmpty) {
            return Text(
              entry.value,
              style: TextStyle(
                fontSize: 15.5.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
                height: 1.3,
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key}: ',
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42.w,
            child: Column(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: item.actionColor.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    item.iconData,
                    size: 19.sp,
                    color: item.actionColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h, top: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                      height: 1.25,
                    ),
                  ),
                  if (item.hasDetails) _buildDetailsView(),
                  SizedBox(height: 5.h),
                  Text(
                    item.userDescription,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  if (item.formattedDate.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      item.formattedDate,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
