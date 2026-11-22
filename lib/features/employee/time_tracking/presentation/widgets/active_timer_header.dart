import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/widgets/buttons/buttons.dart';

class ActiveTimerHeader extends StatelessWidget {
  const ActiveTimerHeader({
    super.key,
    required this.isOnBreak,
    required this.isRunning,
    required this.canCancel,
    required this.onBack,
  });

  final bool isOnBreak;
  final bool isRunning;
  final bool canCancel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final statusColor = isOnBreak ? AppColors.warning : AppColors.success;

    return Row(
      children: [
        AppBackButton(onPressed: onBack),
        SizedBox(width: 14.w),
        Expanded(
          child: Text(
            context.loc.activeTimer,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7.w,
                height: 7.w,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                isOnBreak ? context.loc.pauseBreak : context.loc.inProgress,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
