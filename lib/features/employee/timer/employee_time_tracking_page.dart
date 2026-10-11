import 'package:construction_app/app/constants/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/extensions/date_time_extensions.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/utils/app_date_time_formatter.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import '../helper/employee_bottom_sheets.dart' hide EmployeeProjectModel;
import '../helper/employee_enums.dart';
import '../helper/employee_models.dart';
import '../presentation/providers/employee_timer_provider.dart';

class EmployeeTimeTrackingPage extends ConsumerWidget {
  const EmployeeTimeTrackingPage({super.key});

  void _showMessage(BuildContext context, String message) {
    AppSnackBar.showInfo(context, message);
  }

  void _finishTimer(
    BuildContext context,
    WidgetRef ref,
    EmployeeTimerState state,
  ) {
    ref.read(employeeTimerProvider.notifier).finishTimer();

    showFinishWorkSheet(
      context: context,
      projectName: state.currentProject.fullName,
      totalLogged: AppDateTimeFormatter.formatShortUnit(
        double.parse((state.elapsed.inMinutes / 60).toStringAsFixed(1)),
        'hrs',
      ),
      onSave: () {
        ref.read(employeeTimerProvider.notifier).finishTimer();
        _showMessage(context, context.loc.workFinished);
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

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
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 8.h),
              sliver: SliverToBoxAdapter(child: _buildHeader(context, ref)),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildWeekLabel(context)),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 14.h)),

            if (timerState.isTimerRunning) ...[
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                sliver: SliverToBoxAdapter(
                  child: _buildActiveTimerCard(context, ref, timerState),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            ],

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildWeeklySummary(context)),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 12.h)),

            if (!timerState.isTimerRunning)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                sliver: SliverToBoxAdapter(
                  child: AppButton(
                    onPressed: () => showStartNewTimerSheet(
                      context: context,
                      onStart: () {
                        ref.read(employeeTimerProvider.notifier).startTimer();
                        _showMessage(context, context.loc.timerRunning);
                      },
                    ),
                    height: 50.h,
                    text: context.loc.startNewTimer,
                  ),
                ),
              ),

            if (!timerState.isTimerRunning)
              SliverToBoxAdapter(child: SizedBox(height: 18.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(
                child: _buildRecentLogsHeader(context, ref, timerState),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 10.h)),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 30.h),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    for (final log in timerState.visibleLogs) ...[
                      _buildTimeLogCard(context, log),
                      SizedBox(height: 10.h),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.loc.smTimeTracking,
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        AppOutlinedButton(
          fullWidth: false,
          onPressed: () => showAddTimeEntrySheet(
            context: context,
            onSaved: () {
              _showMessage(context, context.loc.entrySaved);
            },
          ),
          leadingIcon: Icons.add,
          text: context.loc.addTime,
          foregroundColor: AppColors.textSecondary,
          borderColor: AppColors.border,
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
          borderRadius: 7.r,
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildWeekLabel(BuildContext context) {
    final weekStart = DateTime.utc(2026, 9, 14);
    final weekEnd = DateTime.utc(2026, 9, 20);
    final formattedRange = AppDateTimeFormatter.formatDateRange(
      weekStart,
      weekEnd,
    );
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Text(
        context.loc.weekRange('38', formattedRange),
        style: TextStyle(fontSize: 16.sp, color: AppColors.textTertiary),
      ),
    );
  }

  // ============================================================
  // ACTIVE TIMER
  // ============================================================

  Widget _buildActiveTimerCard(
    BuildContext context,
    WidgetRef ref,
    EmployeeTimerState state,
  ) {
    return Container(
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
                  state.isOnBreak
                      ? context.loc.pauseBreak
                      : context.loc.inProgress,
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
                  context.loc.scaffoldErection,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              Icon(
                state.isOnBreak ? Icons.pause_circle_outline : Icons.more_horiz,
                color: Colors.white,
              ),
            ],
          ),

          SizedBox(height: 13.h),

          Text(
            state.currentProject.fullName,
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            state.formattedElapsed,
            style: TextStyle(
              fontSize: 42.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            context.loc.startedAt(state.currentProject.formattedStartTime),
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
                    if (state.isOnBreak) {
                      ref.read(employeeTimerProvider.notifier).resumeTimer();
                    } else {
                      ref.read(employeeTimerProvider.notifier).pauseTimer();
                    }
                  },
                  leadingIcon: state.isOnBreak ? Icons.play_arrow : Icons.pause,
                  text: state.isOnBreak
                      ? context.loc.resumeWork
                      : context.loc.pauseBreak,
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
                  onPressed: () => _finishTimer(context, ref, state),
                  text: context.loc.finishWork,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WEEKLY SUMMARY
  // ============================================================

  Widget _buildWeeklySummary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  title: context.loc.today.toUpperCase(),
                  value: const Duration(
                    hours: 7,
                    minutes: 30,
                  ).formatCompactLocalized(),
                ),
              ),

              Expanded(
                child: _summaryItem(
                  title: context.loc.thisWeek.toUpperCase(),
                  value: const Duration(
                    hours: 35,
                    minutes: 30,
                  ).formatCompactLocalized(),
                ),
              ),
            ],
          ),

          SizedBox(height: 13.h),

          ClipRRect(
            borderRadius: BorderRadius.circular(5.r),
            child: LinearProgressIndicator(
              minHeight: 4.h,
              value: .84,
              backgroundColor: Colors.white.withValues(alpha: .2),
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),

          SizedBox(height: 7.h),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              context.loc.weekProgress(
                const Duration(hours: 34, minutes: 15).formatCompactLocalized(),
                const Duration(hours: 40).formatCompactLocalized(),
              ),
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white.withValues(alpha: .55),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white.withValues(alpha: .5),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RECENT LOGS
  // ============================================================

  Widget _buildRecentLogsHeader(
    BuildContext context,
    WidgetRef ref,
    EmployeeTimerState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.recentLogs,
          style: TextStyle(
            fontSize: 21.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        SizedBox(height: 10.h),

        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (state.showThisMonth) {
                  ref
                      .read(employeeTimerProvider.notifier)
                      .toggleShowThisMonth();
                }
              },
              child: _filterChip(context.loc.thisWeek, !state.showThisMonth),
            ),

            SizedBox(width: 8.w),

            GestureDetector(
              onTap: () {
                if (!state.showThisMonth) {
                  ref
                      .read(employeeTimerProvider.notifier)
                      .toggleShowThisMonth();
                }
              },
              child: _filterChip(context.loc.thisMonth, state.showThisMonth),
            ),
          ],
        ),
      ],
    );
  }

  Widget _filterChip(String title, bool selected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.neutral100,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          color: selected ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTimeLogCard(BuildContext context, EmployeeTimeLogModel log) {
    final activity = log.project.activity;

    return GestureDetector(
      onTap: () {
        _showMessage(
          context,
          '${log.project.fullName} · ${log.formattedDuration} ${context.loc.hrsShort}',
        );
        context.push(RouteConstants.employeeAssignmentDetails);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    log.formattedDate,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),

                Text(
                  log.formattedDuration,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(width: 5.w),

                Text(
                  context.loc.hrsShort,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 7.h),

            Text(
              log.project.fullName,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 8.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: activity.backgroundColor,
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Text(
                activity.label,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: activity.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 9.h),

            Row(
              children: [
                Expanded(
                  child: Text(
                    '${log.project.formattedTimeRange} · ${context.loc.breakTime}: ${log.formattedBreakTime}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),

                if (log.synced)
                  Text(
                    context.loc.synced,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
