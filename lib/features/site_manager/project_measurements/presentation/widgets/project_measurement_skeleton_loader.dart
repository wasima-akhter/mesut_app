import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shimmer skeleton loader matching the measurements header and line cards.
class ProjectMeasurementSkeletonLoader extends StatelessWidget {
  const ProjectMeasurementSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 20.h),
      children: [
        _buildHeaderSkeleton(),
        SizedBox(height: 10.h),
        ...List.generate(4, (_) => _buildCardSkeleton()),
      ],
    );
  }

  Widget _buildHeaderSkeleton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _placeholder(width: 130.w, height: 14.h),
              SizedBox(height: 8.h),
              _placeholder(width: 80.w, height: 22.h),
            ],
          ),
          _placeholder(width: 90.w, height: 36.h, radius: 6.r),
        ],
      ),
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
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
              _placeholder(width: 140.w, height: 14.h),
              _placeholder(width: 44.w, height: 16.h),
            ],
          ),
          SizedBox(height: 8.h),
          _placeholder(width: 110.w, height: 18.h),
          SizedBox(height: 6.h),
          _placeholder(width: 200.w, height: 14.h),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _placeholder(width: 160.w, height: 13.h),
              _placeholder(width: 50.w, height: 20.h, radius: 4.r),
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
