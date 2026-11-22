import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/localization/context_extensions.dart';

class AssignmentDetailInstructionsCard extends StatelessWidget {
  final String? accessCode;
  final String? accessNotes;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const AssignmentDetailInstructionsCard({
    super.key,
    this.accessCode,
    this.accessNotes,
    this.isExpanded = true,
    this.onToggle,
  });

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            margin: EdgeInsets.only(top: 7.h, right: 10.w),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neutral700,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCode = accessCode != null && accessCode!.isNotEmpty;
    final hasNotes = accessNotes != null && accessNotes!.isNotEmpty;

    if (!hasCode && !hasNotes) {
      return const SizedBox.shrink();
    }

    final noteLines = hasNotes
        ? accessNotes!
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.key_outlined,
                size: 21.sp,
                color: AppColors.neutral700,
              ),
              SizedBox(width: 8.w),
              Text(
                context.loc.siteAccess,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (hasCode) _bullet('Code: $accessCode'),
          for (final line in noteLines) _bullet(line),
        ],
      ),
    );
  }
}
