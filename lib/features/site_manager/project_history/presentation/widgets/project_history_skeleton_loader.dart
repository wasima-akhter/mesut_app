import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProjectHistorySkeletonLoader extends StatelessWidget {
  const ProjectHistorySkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h),
      itemCount: 5,
      itemBuilder: (_, index) => _buildSkeletonItem(isLast: index == 4),
    );
  }

  Widget _buildSkeletonItem({required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42.w,
            child: Column(
              children: [
                _placeholder(width: 36.w, height: 36.w, radius: 18.r),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFEBEBEB),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h, top: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _placeholder(width: 180.w, height: 18.h, radius: 4.r),
                  SizedBox(height: 8.h),
                  _placeholder(width: 240.w, height: 26.h, radius: 6.r),
                  SizedBox(height: 8.h),
                  _placeholder(width: 130.w, height: 14.h, radius: 4.r),
                  SizedBox(height: 5.h),
                  _placeholder(width: 100.w, height: 12.h, radius: 4.r),
                ],
              ),
            ),
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
