import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ProjectDetailsSkeletonLoader extends StatelessWidget {
  const ProjectDetailsSkeletonLoader({super.key});

  Widget _shimmerCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE5E7EB),
        highlightColor: const Color(0xFFF3F4F6),
        child: child,
      ),
    );
  }

  Widget _box({
    required double width,
    required double height,
    double borderRadius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 32.h),
      children: [
        // 1. Hours Card Skeleton
        _shimmerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _box(width: 34.w, height: 34.h, borderRadius: 8),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(width: 150.w, height: 18.h),
                      SizedBox(height: 4.h),
                      _box(width: 100.w, height: 13.h),
                    ],
                  ),
                  const Spacer(),
                  _box(width: 75.w, height: 26.h, borderRadius: 20),
                ],
              ),
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        _box(width: 65.w, height: 22.h),
                        SizedBox(height: 4.h),
                        _box(width: 55.w, height: 12.h),
                      ],
                    ),
                    Column(
                      children: [
                        _box(width: 65.w, height: 22.h),
                        SizedBox(height: 4.h),
                        _box(width: 55.w, height: 12.h),
                      ],
                    ),
                    Column(
                      children: [
                        _box(width: 65.w, height: 22.h),
                        SizedBox(height: 4.h),
                        _box(width: 55.w, height: 12.h),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              _box(width: double.infinity, height: 7.h, borderRadius: 4),
            ],
          ),
        ),
        SizedBox(height: 10.h),

        // 2. Customer Card Skeleton
        _shimmerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _box(width: 80.w, height: 15.h),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _box(width: 20.w, height: 20.h, borderRadius: 3),
                  SizedBox(width: 7.w),
                  _box(width: 130.w, height: 18.h),
                  SizedBox(width: 6.w),
                  _box(width: 60.w, height: 14.h),
                ],
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _box(width: double.infinity, height: 14.h),
                    SizedBox(height: 8.h),
                    _box(width: double.infinity, height: 14.h),
                    SizedBox(height: 8.h),
                    _box(width: double.infinity, height: 14.h),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _box(
                      width: double.infinity,
                      height: 36.h,
                      borderRadius: 6,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _box(
                      width: double.infinity,
                      height: 36.h,
                      borderRadius: 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),

        // 3. Map & Address Card Skeleton
        _shimmerCard(
          child: Column(
            children: [
              _box(
                width: double.infinity,
                height: 145.h,
                borderRadius: 9,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _box(width: 18.w, height: 18.h, borderRadius: 9),
                  SizedBox(width: 6.w),
                  Expanded(child: _box(width: 180.w, height: 16.h)),
                ],
              ),
              SizedBox(height: 10.h),
              _box(
                width: double.infinity,
                height: 38.h,
                borderRadius: 7,
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),

        // 4. Scaffold Spec Skeleton
        _shimmerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _box(width: 150.w, height: 17.h),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(width: 80.w, height: 20.h),
                        SizedBox(height: 3.h),
                        _box(width: 60.w, height: 13.h),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(width: 80.w, height: 20.h),
                        SizedBox(height: 3.h),
                        _box(width: 60.w, height: 13.h),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _box(
                width: double.infinity,
                height: 32.h,
                borderRadius: 5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
