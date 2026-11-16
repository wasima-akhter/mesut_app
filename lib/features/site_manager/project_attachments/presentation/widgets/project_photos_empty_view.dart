import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';

class ProjectPhotosEmptyView extends StatelessWidget {
  final VoidCallback onUploadPressed;

  const ProjectPhotosEmptyView({
    super.key,
    required this.onUploadPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24.h),
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      child: Column(
        children: [
          Icon(
            Icons.collections_outlined,
            size: 54.sp,
            color: const Color(0xFFB0B0B0),
          ),
          SizedBox(height: 12.h),
          Text(
            context.loc.noPhotos,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF222222),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            context.loc.noPhotosDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5.sp,
              color: const Color(0xFF777777),
            ),
          ),
          SizedBox(height: 18.h),
          AppButton.small(
            variant: AppButtonVariant.danger,
            onPressed: onUploadPressed,
            leadingIcon: Icons.upload_outlined,
            text: context.loc.uploadFiles,
            borderRadius: 6.r,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          ),
        ],
      ),
    );
  }
}
