import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';

class ProjectDetailsMetricsBox extends StatelessWidget {
  final String totalHours;
  final String budgetHours;
  final String variance;
  final bool isProfitable;

  const ProjectDetailsMetricsBox({
    super.key,
    required this.totalHours,
    required this.budgetHours,
    required this.variance,
    required this.isProfitable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalHours,
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF101828),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  context.loc.consumedHours,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF667085),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 38.h, color: const Color(0xFFE4E7EC)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                children: [
                  Text(
                    budgetHours,
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF344054),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    context.loc.targetBudget,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFF667085),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 38.h, color: const Color(0xFFE4E7EC)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    variance,
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      color: isProfitable
                          ? const Color(0xFF027A48)
                          : const Color(0xFFD92D20),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isProfitable
                        ? context.loc.underBudget
                        : context.loc.overBudget,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isProfitable
                          ? const Color(0xFF027A48)
                          : const Color(0xFFD92D20),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
