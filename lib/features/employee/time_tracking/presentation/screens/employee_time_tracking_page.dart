import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/pagination/app_pagination_footer.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import '../helper/employee_bottom_sheets.dart';
import '../presentation/providers/employee_time_tracking_provider.dart';
import 'widgets/employee_active_timer_card.dart';
import 'widgets/employee_add_time_sheet.dart';
import 'widgets/employee_start_timer_sheet.dart';
import 'widgets/employee_time_log_card.dart';
import 'widgets/employee_time_logs_placeholder.dart';
import 'widgets/employee_time_tracking_header.dart';
import 'widgets/employee_time_tracking_mappers.dart';
import 'widgets/employee_weekly_summary_card.dart';

class EmployeeTimeTrackingPage extends ConsumerStatefulWidget {
  const EmployeeTimeTrackingPage({super.key});

  @override
  ConsumerState<EmployeeTimeTrackingPage> createState() =>
      _EmployeeTimeTrackingPageState();
}

class _EmployeeTimeTrackingPageState
    extends ConsumerState<EmployeeTimeTrackingPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      ref.read(employeeTimeTrackingProvider.notifier).loadMoreLogs();
    }
  }

  void _finishTimer(String projectName, String totalLogged) {
    showFinishWorkSheet(
      context: context,
      projectName: projectName,
      totalLogged: totalLogged,
      onSave: () async {
        await ref.read(employeeTimeTrackingProvider.notifier).stopTimer();
        if (mounted) {
          AppSnackBar.showSuccess(context, context.loc.workFinished);
        }
      },
    );
  }

  void _openAddTime() {
    showEmployeeAddTimeSheet(context: context);
  }

  void _openStartTimer() {
    showEmployeeStartTimerSheet(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(employeeTimeTrackingProvider);
    final summary = tracking.summary;

    final isTimerRunning = tracking.isTimerRunning;
    final todayDuration = Duration(minutes: (summary.todayHours * 60).round());
    final weekDuration = Duration(minutes: (summary.weekHours * 60).round());
    final progressLogged = Duration(minutes: (summary.weekHours * 60).round());
    final progressTotal = summary.weeklyHoursTarget > 0
        ? Duration(minutes: (summary.weeklyHoursTarget * 60).round())
        : const Duration(hours: 40);
    final progressValue = summary.progressRatio;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(employeeTimeTrackingProvider.notifier).refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 8.h),
                sliver: SliverToBoxAdapter(
                  child: EmployeeTimeTrackingTopHeader(
                    onAddTime: _openAddTime,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                sliver: SliverToBoxAdapter(
                  child: EmployeeWeekLabel(summary: summary),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 14.h)),
              if (isTimerRunning) ...[
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  sliver: SliverToBoxAdapter(
                    child: EmployeeActiveTimerCard(
                      onFinish: () {
                        final name =
                            summary.activeTimer?.projectName.isNotEmpty == true
                                ? summary.activeTimer!.projectName
                                : 'Project';
                        final durationStr =
                            '${summary.activeTimer?.netHours.toStringAsFixed(1) ?? '0.0'} hrs';
                        _finishTimer(name, durationStr);
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
              ],
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                sliver: SliverToBoxAdapter(
                  child: EmployeeWeeklySummaryCard(
                    todayDuration: todayDuration,
                    weekDuration: weekDuration,
                    progressLogged: progressLogged,
                    progressTotal: progressTotal,
                    progressValue: progressValue,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 12.h)),
              if (!isTimerRunning)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  sliver: SliverToBoxAdapter(
                    child: AppButton(
                      onPressed: _openStartTimer,
                      height: 50.h,
                      text: context.loc.startNewTimer,
                    ),
                  ),
                ),
              if (!isTimerRunning)
                SliverToBoxAdapter(child: SizedBox(height: 18.h)),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                sliver: SliverToBoxAdapter(
                  child: EmployeeRecentLogsHeader(
                    showThisMonth: tracking.showThisMonth,
                    onTogglePeriod: () => ref
                        .read(employeeTimeTrackingProvider.notifier)
                        .togglePeriod(),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 10.h)),
              if (tracking.isLoading)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 30.h),
                  sliver: const SliverToBoxAdapter(
                    child: EmployeeTimeLogsLoadingPlaceholder(),
                  ),
                )
              else if (tracking.errorMessage != null &&
                  tracking.recentLogs.isEmpty)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 30.h),
                  sliver: SliverToBoxAdapter(
                    child: EmployeeTimeLogsErrorPlaceholder(
                      message: tracking.errorMessage,
                      onRetry: () => ref
                          .read(employeeTimeTrackingProvider.notifier)
                          .loadInitial(),
                    ),
                  ),
                )
              else if (tracking.recentLogs.isEmpty)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 30.h),
                  sliver: const SliverToBoxAdapter(
                    child: EmployeeTimeLogsEmptyPlaceholder(),
                  ),
                )
              else ...[
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 14.h),
                  sliver: SliverList.separated(
                    itemCount: tracking.recentLogs.length,
                    separatorBuilder: (_, _) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final log = EmployeeTimeTrackingMappers.toLogModel(
                        tracking.recentLogs[index],
                      );
                      return EmployeeTimeLogCard(
                        log: log,
                        onTap: () {
                          AppSnackBar.showInfo(
                            context,
                            '${log.project.fullName} · ${log.formattedDuration} ${context.loc.hrsShort}',
                          );
                          context.push(
                            RouteConstants.employeeAssignmentDetails,
                          );
                        },
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: AppPaginationFooter(
                    hasMore: tracking.hasMoreLogs,
                    isLoadingMore: tracking.isLoadingMoreLogs,
                    itemCount: tracking.recentLogs.length,
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 24.h)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
