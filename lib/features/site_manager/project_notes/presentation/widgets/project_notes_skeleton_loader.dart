import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shimmer skeleton loader matching the project notes list cards.
class ProjectNotesSkeletonLoader extends StatelessWidget {
  const ProjectNotesSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 25.h),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _placeholder(width: 90.w, height: 32.h, radius: 6.r),
          ],
        ),
        SizedBox(height: 12.h),
        ...List.generate(4, (_) => _buildCardSkeleton()),
      ],
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      margin: EdgeInsets.only(bottom: 9.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _placeholder(width: 120.w, height: 18.h),
              _placeholder(width: 44.w, height: 16.h),
            ],
          ),
          SizedBox(height: 10.h),
          _placeholder(width: double.infinity, height: 14.h),
          SizedBox(height: 6.h),
          _placeholder(width: 240.w, height: 14.h),
          SizedBox(height: 12.h),
          _placeholder(width: 150.w, height: 12.h),
        ],
      ),
    );
  }

  Widget _placeholder({
    required double width,
    required double height,
    double? radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(radius ?? 4.r),
      ),
    );
  }
}
