import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/widgets/buttons/buttons.dart';

class EmployeeTimeLogsLoadingPlaceholder extends StatelessWidget {
  const EmployeeTimeLogsLoadingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(height: 12.h),
          Text(
            context.loc.loading,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeTimeLogsErrorPlaceholder extends StatelessWidget {
  const EmployeeTimeLogsErrorPlaceholder({
    super.key,
    required this.onRetry,
    this.message,
  });

  final VoidCallback onRetry;
  final String? message;

  String _formatMessage(BuildContext context, String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return context.loc.somethingWentWrong;
    }
    final lower = raw.toLowerCase();
    if (lower.contains('dioexception') ||
        lower.contains('socketexception') ||
        lower.contains('connection') ||
        lower.contains('network') ||
        lower.contains('timeout') ||
        lower.contains('failed host lookup') ||
        lower.contains('no address associated') ||
        lower.contains('errno') ||
        lower.contains('offline') ||
        lower.contains('unreachable')) {
      return context.loc.checkInternetConnection;
    }
    if (lower.contains('status code') ||
        lower.contains('500') ||
        lower.contains('502') ||
        lower.contains('503') ||
        lower.contains('504') ||
        lower.contains('server')) {
      return context.loc.somethingWentWrong;
    }
    if (lower.contains('not found') || lower.contains('404')) {
      return context.loc.noTimeLogs;
    }
    if (lower.contains('exception') ||
        lower.contains('bad response') ||
        lower.contains('stacktrace') ||
        lower.contains('error:')) {
      return context.loc.somethingWentWrong;
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 36,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 10.h),
          Text(
            _formatMessage(context, message),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 14.h),
          AppOutlinedButton(
            fullWidth: false,
            onPressed: onRetry,
            leadingIcon: Icons.refresh_rounded,
            text: context.loc.retry,
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          ),
        ],
      ),
    );
  }
}

class EmployeeTimeLogsEmptyPlaceholder extends StatelessWidget {
  const EmployeeTimeLogsEmptyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_toggle_off_rounded,
              size: 28,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            context.loc.noRecentLogs,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            context.loc.noOtherItemsAvailable,
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
