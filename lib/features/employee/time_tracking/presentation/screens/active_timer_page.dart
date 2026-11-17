import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/extensions/date_time_extensions.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import '../helper/employee_enums.dart';
import '../helper/employee_models.dart';
import '../presentation/providers/employee_timer_provider.dart';
import 'widgets/finish_work_dialog.dart';

class ActiveTimerPage extends ConsumerWidget {
  const ActiveTimerPage({super.key});

  EmployeeAssignmentModel get assignment => fakeAssignments.last;

  void _finishWork(BuildContext context, WidgetRef ref) {
    final timerState = ref.read(employeeTimerProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return FinishWorkDialog(
          projectName: assignment.project,
          totalTime: timerState.formattedElapsed,
          onSave: () {
            ref.read(employeeTimerProvider.notifier).finishTimer();
            Navigator.of(context).pop();
            Navigator.of(context).pop();

            AppSnackBar.showSuccess(context, context.loc.entrySaved);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnBreak = ref.watch(
      employeeTimerProvider.select((s) => s.isOnBreak),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 12.h),
              sliver: SliverToBoxAdapter(
                child: _buildHeader(context, isOnBreak),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildAssignmentCard()),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(
                child: _buildTimerCard(context, ref, isOnBreak),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 25.h)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isOnBreak) {
    return Row(
      children: [
        const AppBackButton(),
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
        _statusBadge(context, isOnBreak),
      ],
    );
  }

  Widget _statusBadge(BuildContext context, bool isOnBreak) {
    final color = isOnBreak ? AppColors.warning : AppColors.success;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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
            isOnBreak ? context.loc.pauseBreak : context.loc.inProgress,
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
    bool isOnBreak,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: isOnBreak ? const Color(0xFFFFF7E8) : AppColors.white,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(
          color: isOnBreak ? const Color(0xFFF9D89A) : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 4.h),
          _ActiveTimerElapsedView(isOnBreak: isOnBreak),
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
              color: isOnBreak
                  ? AppColors.warningDark
                  : AppColors.textTertiary,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  onPressed: () {
                    ref.read(employeeTimerProvider.notifier).toggleBreak();
                  },
                  leadingIcon: isOnBreak ? Icons.play_arrow : Icons.pause,
                  text: isOnBreak
                      ? context.loc.resumeWork
                      : context.loc.pauseBreak,
                  foregroundColor: isOnBreak
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  borderColor: isOnBreak
                      ? AppColors.primary
                      : AppColors.borderDark,
                  borderRadius: 8.r,
                  textStyle: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AppButton(
                  onPressed: () => _finishWork(context, ref),
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

class _ActiveTimerElapsedView extends ConsumerWidget {
  const _ActiveTimerElapsedView({required this.isOnBreak});

  final bool isOnBreak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatted = ref.watch(
      employeeTimerProvider.select((s) => s.formattedElapsed),
    );

    return RepaintBoundary(
      child: Text(
        formatted,
        style: TextStyle(
          fontSize: 44.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: isOnBreak ? const Color(0xFFC47A0A) : AppColors.success,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
