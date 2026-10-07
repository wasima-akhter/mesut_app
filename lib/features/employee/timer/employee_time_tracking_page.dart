import 'dart:async';

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/context_extensions.dart';
import '../helper/employee_bottom_sheets.dart' hide EmployeeProjectModel;
import '../helper/employee_enums.dart';
import '../helper/employee_models.dart';

class EmployeeTimeTrackingPage extends StatefulWidget {
  const EmployeeTimeTrackingPage({super.key});

  @override
  State<EmployeeTimeTrackingPage> createState() =>
      _EmployeeTimeTrackingPageState();
}

class _EmployeeTimeTrackingPageState extends State<EmployeeTimeTrackingPage> {
  bool isTimerRunning = false;
  bool isOnBreak = false;

  bool showThisMonth = false;

  Timer? _timer;

  Duration elapsed = const Duration(hours: 2, minutes: 45, seconds: 20);

  final List<EmployeeTimeLogModel> _logs = [
    EmployeeTimeLogModel(
      date: 'Today, Sept 18',
      project: EmployeeProjectModel(
        id: 'Prj-0842',
        name: 'Goltsteins.Complex',
        address: 'Goltsteinstraße 12, 50968 Köln',
        activity: EmployeeActivityType.erection,
        startTime: '07:30 am',
        endTime: '04:15 pm',
        siteManager: 'Mesut Rahaman',
      ),
      duration: '8.0',
      breakTime: '45m',
      synced: true,
    ),
    EmployeeTimeLogModel(
      date: 'Today, Sept 18',
      project: EmployeeProjectModel(
        id: 'Prj-0842',
        name: 'Goltsteins.Complex',
        address: 'Goltsteinstraße 12, 50968 Köln',
        activity: EmployeeActivityType.dismantling,
        startTime: '07:30 am',
        endTime: '04:15 pm',
        siteManager: 'Mesut Rahaman',
      ),
      duration: '8.0',
      breakTime: '45m',
      synced: true,
    ),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ============================================================
  // TIMER
  // ============================================================

  void _startTimer() {
    setState(() {
      isTimerRunning = true;
      isOnBreak = false;
    });

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !isTimerRunning || isOnBreak) {
        return;
      }

      setState(() {
        elapsed += const Duration(seconds: 1);
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      isOnBreak = true;
    });
  }

  void _resumeTimer() {
    setState(() {
      isOnBreak = false;
    });
  }

  void _finishTimer() {
    _timer?.cancel();

    setState(() {
      isTimerRunning = false;
      isOnBreak = false;
    });

    showFinishWorkSheet(
      context: context,
      projectName: 'PRJ-0842 · Goltsteins.Complex',
      totalLogged: '8.0 hrs',
      onSave: () {
        setState(() {
          isTimerRunning = false;
          isOnBreak = false;
        });

        _showMessage(context.loc.workFinished);
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');

    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  // ============================================================
  // SAMPLE DATA
  // ============================================================

  final List<EmployeeProjectModel> _availableProjects = const [
    EmployeeProjectModel(
      id: 'PRJ-0842',
      name: 'Goltstein Complex',
      address: 'Goltsteinstraße 12, 50968 Köln',
      activity: EmployeeActivityType.erection,
      startTime: '07:30 am',
      endTime: '04:30 pm',
      siteManager: 'Mesut Rahaman',
    ),
    EmployeeProjectModel(
      id: 'PRJ-0845',
      name: 'Riverside Tower',
      address: 'Rheinstrasse 28, 50667 Köln',
      activity: EmployeeActivityType.dismantling,
      startTime: '07:30 am',
      endTime: '04:30 pm',
      siteManager: 'David Miller',
    ),
  ];

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 8.h),
              sliver: SliverToBoxAdapter(child: _buildHeader()),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildWeekLabel()),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 14.h)),

            if (isTimerRunning) ...[
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                sliver: SliverToBoxAdapter(child: _buildActiveTimerCard()),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            ],

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildWeeklySummary()),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 12.h)),

            if (!isTimerRunning)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                sliver: SliverToBoxAdapter(
                  child: AppButton(
                    onPressed: () => showStartNewTimerSheet(
                      context: context,
                      onStart: () {
                        setState(() {
                          isTimerRunning = true;
                        });

                        _showMessage(context.loc.timerRunning);
                      },
                    ),
                    height: 50.h,
                    text: context.loc.startNewTimer,
                  ),
                ),
              ),

            if (!isTimerRunning)
              SliverToBoxAdapter(child: SizedBox(height: 18.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildRecentLogsHeader()),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 10.h)),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 30.h),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    for (final log in _visibleLogs) ...[
                      _buildTimeLogCard(log),
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

  List<EmployeeTimeLogModel> get _visibleLogs {
    if (!showThisMonth) {
      return _logs;
    }

    return [..._logs, ..._logs];
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
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

        OutlinedButton.icon(
          onPressed: () => showAddTimeEntrySheet(
            context: context,
            onSaved: () {
              setState(() {
                // Add the newly created entry to your logs.
              });

              _showMessage(context.loc.entrySaved);
            },
          ),
          icon: const Icon(Icons.add, size: 19),
          label: Text(
            context.loc.addTime,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: const BorderSide(color: AppColors.border),
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekLabel() {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Text(
        'Week 38 · Sept 14 – Sept 20',
        style: TextStyle(fontSize: 16.sp, color: AppColors.textTertiary),
      ),
    );
  }

  // ============================================================
  // ACTIVE TIMER
  // ============================================================

  Widget _buildActiveTimerCard() {
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
                isOnBreak ? Icons.pause_circle_outline : Icons.more_horiz,
                color: Colors.white,
              ),
            ],
          ),

          SizedBox(height: 13.h),

          Text(
            'PRJ-0842 · Goltsteins.Complex',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            _formatDuration(elapsed),
            style: TextStyle(
              fontSize: 42.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            'Started at 07:30 am',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white.withValues(alpha: .65),
            ),
          ),

          SizedBox(height: 18.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isOnBreak ? _resumeTimer : _pauseTimer,
                  icon: Icon(
                    isOnBreak ? Icons.play_arrow : Icons.pause,
                    size: 20,
                  ),
                  label: Text(
                    isOnBreak ? context.loc.resumeWork : context.loc.pauseBreak,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: .5)),
                    minimumSize: Size(double.infinity, 46.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.r),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 9.w),

              Expanded(
                child: AppButton(
                  onPressed: _finishTimer,
                  height: 46.h,
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

  Widget _buildWeeklySummary() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  title: context.loc.today.toUpperCase(),
                  value: '7h 30min',
                ),
              ),

              Expanded(
                child: _summaryItem(
                  title: context.loc.thisWeek.toUpperCase(),
                  value: '35h 30min',
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
              context.loc.weekProgress('34h 15m', '40h'),
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
            fontSize: 15.sp,
            color: Colors.white.withValues(alpha: .55),
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

  Widget _buildRecentLogsHeader() {
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
                setState(() {
                  showThisMonth = false;
                });
              },
              child: _filterChip(context.loc.thisWeek, !showThisMonth),
            ),

            SizedBox(width: 8.w),

            GestureDetector(
              onTap: () {
                setState(() {
                  showThisMonth = true;
                });
              },
              child: _filterChip(context.loc.thisMonth, showThisMonth),
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

  Widget _buildTimeLogCard(EmployeeTimeLogModel log) {
    final activity = log.project.activity;

    return GestureDetector(
      onTap: () {
        _showMessage('${log.project.fullName} · ${log.duration} hrs');
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
                    log.date,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),

                Text(
                  log.duration,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(width: 5.w),

                Text(
                  'hrs',
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
                    '${log.project.startTime} – ${log.project.endTime} · ${context.loc.breakTime}: ${log.breakTime}',
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(fontSize: 17.sp)),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
