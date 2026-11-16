import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';

/// Top header card showing total calculated scaffold area and "+ Add Line" action button.
class ProjectMeasurementHeaderCard extends StatelessWidget {
  final double totalArea;
  final VoidCallback onAddLine;

  const ProjectMeasurementHeaderCard({
    super.key,
    required this.totalArea,
    required this.onAddLine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.loc.totalCalculatedArea,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF777777),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${totalArea.toStringAsFixed(0)} m²',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          AppButton.small(
            text: context.loc.addLine,
            leadingIcon: Icons.add,
            onPressed: onAddLine,
            borderRadius: 6.r,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            textStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
