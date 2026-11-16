import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProjectDatesSkeletonLoader extends StatelessWidget {
  const ProjectDatesSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 30.h),
      children: [
        _placeholder(width: double.infinity, height: 44.h, radius: 6.r),
        SizedBox(height: 12.h),
        _buildCardSkeleton(),
        SizedBox(height: 12.h),
        _buildCardSkeleton(),
      ],
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _placeholder(width: 32.w, height: 32.w, radius: 16.r),
              SizedBox(width: 8.w),
              _placeholder(width: 140.w, height: 18.h, radius: 4.r),
              const Spacer(),
              _placeholder(width: 60.w, height: 20.h, radius: 4.r),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _placeholder(width: 80.w, height: 15.h, radius: 4.r),
              _placeholder(width: 110.w, height: 18.h, radius: 4.r),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _placeholder(width: 80.w, height: 15.h, radius: 4.r),
              _placeholder(width: 90.w, height: 28.h, radius: 6.r),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _placeholder(width: 80.w, height: 15.h, radius: 4.r),
              _placeholder(width: 110.w, height: 18.h, radius: 4.r),
            ],
          ),
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
