import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/extensions/date_time_extensions.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../helper/employee_enums.dart';
import '../helper/employee_models.dart';
import '../presentation/providers/employee_timer_provider.dart';

class ActiveTimerPage extends ConsumerWidget {
  const ActiveTimerPage({super.key});

  EmployeeAssignmentModel get assignment => fakeAssignments.last;

  void _finishWork(BuildContext context, WidgetRef ref, EmployeeTimerState timerState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _FinishWorkDialog(
          projectName: assignment.project,
          totalTime: timerState.formattedElapsed,
          onSave: () {
            ref.read(employeeTimerProvider.notifier).finishTimer();
            Navigator.of(context).pop();
            Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.loc.entrySaved,
                  style: TextStyle(fontSize: 17.sp),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(employeeTimerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 12.h),
              sliver: SliverToBoxAdapter(child: _buildHeader(context, timerState)),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildAssignmentCard()),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 12.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(
                child: _buildTimerCard(context, ref, timerState),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 25.h)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EmployeeTimerState timerState) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back, size: 23),
          ),
        ),

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

        _statusBadge(context, timerState),
      ],
    );
  }

  Widget _statusBadge(BuildContext context, EmployeeTimerState timerState) {
    final color = timerState.isOnBreak ? AppColors.warning : AppColors.success;

    final background = timerState.isOnBreak
        ? AppColors.warningLight
        : AppColors.successLight;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            timerState.isOnBreak ? context.loc.pauseBreak : context.loc.inProgress,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: assignment.activity.backgroundColor,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              assignment.activity.label,
              style: TextStyle(
                fontSize: 15.sp,
                color: assignment.activity.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 13.h),

          Text(
            assignment.project,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 8.h),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  assignment.address,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard(
    BuildContext context,
    WidgetRef ref,
    EmployeeTimerState timerState,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: timerState.isOnBreak ? const Color(0xFFFFF7E8) : AppColors.white,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(
          color: timerState.isOnBreak ? const Color(0xFFF9D89A) : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 4.h),

          Text(
            timerState.formattedElapsed,
            style: TextStyle(
              fontSize: 44.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: timerState.isOnBreak
                  ? const Color(0xFFC47A0A)
                  : AppColors.success,
            ),
          ),

          SizedBox(height: 14.h),

          Text(
            '${context.loc.today} · ${context.loc.startedAt(const TimeOfDay(hour: 7, minute: 30).formatLocalized())}',
            style: TextStyle(fontSize: 16.sp, color: AppColors.textTertiary),
          ),

          SizedBox(height: 5.h),

          Text(
            '${context.loc.breakTime}: ${const Duration(minutes: 45).formatCompactLocalized()}',
            style: TextStyle(
              fontSize: 16.sp,
              color: timerState.isOnBreak
                  ? AppColors.warningDark
                  : AppColors.textTertiary,
            ),
          ),

          SizedBox(height: 20.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(employeeTimerProvider.notifier).toggleBreak();
                  },
                  icon: Icon(
                    timerState.isOnBreak ? Icons.play_arrow : Icons.pause,
                    size: 22,
                  ),
                  label: Text(
                    timerState.isOnBreak
                        ? context.loc.resumeWork
                        : context.loc.pauseBreak,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: timerState.isOnBreak
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    side: BorderSide(
                      color: timerState.isOnBreak
                          ? AppColors.primary
                          : AppColors.borderDark,
                    ),
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: AppButton(
                  onPressed: () => _finishWork(context, ref, timerState),
                  height: 48.h,
                  text: context.loc.finishWork,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinishWorkDialog extends StatelessWidget {
  final String projectName;
  final String totalTime;
  final VoidCallback onSave;

  const _FinishWorkDialog({
    required this.projectName,
    required this.totalTime,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            SizedBox(height: 18.h),

            Container(
              width: 50.w,
              height: 50.w,
              decoration: const BoxDecoration(
                color: AppColors.infoLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.info,
                size: 30,
              ),
            ),

            SizedBox(height: 18.h),

            Text(
              '${context.loc.finishWork} $projectName?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 7.h),

            Text(
              '${context.loc.totalHoursLogged}: $totalTime',
              style: TextStyle(fontSize: 16.sp, color: AppColors.textTertiary),
            ),

            SizedBox(height: 20.h),

            SizedBox(
              width: double.infinity,
              child: AppButton(
                onPressed: onSave,
                height: 48.h,
                text: context.loc.saveEntry,
              ),
            ),

            SizedBox(height: 5.h),

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                context.loc.cancel,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
