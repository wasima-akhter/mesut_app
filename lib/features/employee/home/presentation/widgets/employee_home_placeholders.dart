import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/widgets/buttons/buttons.dart';

class EmployeeHomeLoadingPlaceholder extends StatelessWidget {
  const EmployeeHomeLoadingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (index) => Container(
          width: double.infinity,
          height: 190.h,
          margin: EdgeInsets.only(bottom: 14.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 90.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(7.r),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 110.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              Container(
                width: 200.w,
                height: 22.h,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                height: 16.h,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmployeeHomeErrorPlaceholder extends StatelessWidget {
  const EmployeeHomeErrorPlaceholder({
    super.key,
    required this.onRetry,
    this.message,
  });

  final VoidCallback onRetry;
  final String? message;

  String _formatMessage(BuildContext context, String? raw) {
    if (raw == null || raw.trim().isEmpty) return context.loc.somethingWentWrong;
    final lower = raw.toLowerCase();
    if (lower.contains('dioexception') ||
        lower.contains('socketexception') ||
        lower.contains('connection') ||
        lower.contains('network') ||
        lower.contains('timeout') ||
        lower.contains('failed host lookup') ||
        lower.contains('no address associated') ||
        lower.contains('offline')) {
      return context.loc.checkInternetConnection;
    }
    if (lower.contains('exception') ||
        lower.contains('bad response') ||
        lower.contains('status code') ||
        lower.contains('error:')) {
      return context.loc.somethingWentWrong;
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 38,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 12.h),
          Text(
            _formatMessage(context, message),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
          AppOutlinedButton(
            fullWidth: false,
            onPressed: onRetry,
            leadingIcon: Icons.refresh_rounded,
            text: context.loc.retry,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          ),
        ],
      ),
    );
  }
}

class EmployeeHomeEmptyPlaceholder extends StatelessWidget {
  const EmployeeHomeEmptyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 38.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: const BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 28,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            context.loc.noUpcomingTasks,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            context.loc.noAssignments,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
