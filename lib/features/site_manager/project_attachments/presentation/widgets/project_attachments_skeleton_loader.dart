import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProjectAttachmentsSkeletonLoader extends StatelessWidget {
  const ProjectAttachmentsSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 25.h),
      children: [
        Row(
          children: [
            _placeholder(width: 90.w, height: 32.h, radius: 5.r),
            SizedBox(width: 8.w),
            _placeholder(width: 100.w, height: 32.h, radius: 5.r),
            const Spacer(),
            _placeholder(width: 100.w, height: 32.h, radius: 6.r),
          ],
        ),
        SizedBox(height: 14.h),
        _placeholder(
          width: double.infinity,
          height: 180.h,
          radius: 10.r,
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 1.25,
          ),
          itemCount: 4,
          itemBuilder: (_, __) => _placeholder(
            width: double.infinity,
            height: double.infinity,
            radius: 8.r,
          ),
        ),
      ],
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
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(radius ?? 4.r),
      ),
    );
  }
}
