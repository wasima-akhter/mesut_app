import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/context_extensions.dart';

/// Informative non-blocking banner notifying the user that location permission is disabled.
class MapPermissionBanner extends StatelessWidget {
  final VoidCallback onEnable;

  const MapPermissionBanner({super.key, required this.onEnable});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFFD54F)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Color(0xFFF57F17)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              context.loc.mapPermissionNotice,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFE65100),
              ),
            ),
          ),
          TextButton(
            onPressed: onEnable,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 24),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              context.loc.mapEnable,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
