import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/extensions/date_time_extensions.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/widgets/buttons/buttons.dart';
import '../../../shared/helper/employee_enums.dart';
import '../providers/employee_time_tracking_provider.dart';
import '../providers/employee_timer_provider.dart';

class EmployeeActiveTimerCard extends ConsumerWidget {
  const EmployeeActiveTimerCard({
    super.key,
    required this.onFinish,
  });

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(employeeTimeTrackingProvider);
    final fallbackState = ref.watch(employeeTimerProvider);

    final isApiActive = trackingState.isTimerRunning;
    final activeTimer = trackingState.summary.activeTimer;

    final isOnBreak = isApiActive ? trackingState.isOnBreak : fallbackState.isOnBreak;
    final formattedElapsed = isApiActive
        ? trackingState.formattedElapsed
        : fallbackState.formattedElapsed;

    final projectName = isApiActive
        ? (activeTimer?.projectName.isNotEmpty == true
            ? activeTimer!.projectName
            : 'Project')
        : fallbackState.currentProject.fullName;

    final isDismantling = isApiActive
        ? (activeTimer?.activityType.toUpperCase() == 'DISMANTLING')
        : (fallbackState.currentActivity == EmployeeActivityType.dismantling);

    final startedAtText = isApiActive
        ? (activeTimer != null ? activeTimer.startTime.toLocal().formatLocalized() : '--')
        : fallbackState.currentProject.formattedStartTime;

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.timeDarkGreen,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  isOnBreak ? context.loc.pauseBreak : context.loc.inProgress,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 7.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  isDismantling
                      ? context.loc.scaffoldDismantling
                      : context.loc.scaffoldErection,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                isOnBreak ? Icons.pause_circle_outline : Icons.more_horiz,
                color: Colors.white,
              ),
            ],
          ),
          SizedBox(height: 13.h),
          Text(
            projectName,
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            formattedElapsed,
            style: TextStyle(
              fontSize: 42.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            context.loc.startedAt(startedAtText),
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white.withValues(alpha: .65),
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  onPressed: () {
                    if (isApiActive) {
                      ref.read(employeeTimeTrackingProvider.notifier).toggleBreak();
                    } else {
                      if (fallbackState.isOnBreak) {
                        ref.read(employeeTimerProvider.notifier).resumeTimer();
                      } else {
                        ref.read(employeeTimerProvider.notifier).pauseTimer();
                      }
                    }
                  },
                  leadingIcon: isOnBreak ? Icons.play_arrow : Icons.pause,
                  text: stateText(context, isOnBreak),
                  foregroundColor: Colors.white,
                  borderColor: Colors.white.withValues(alpha: .5),
                  borderRadius: 7.r,
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: AppButton(
                  onPressed: onFinish,
                  text: context.loc.finishWork,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  String stateText(BuildContext context, bool isOnBreak) {
    return isOnBreak ? context.loc.resumeWork : context.loc.pauseBreak;
  }
}
