import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:construction_app/core/localization/pending_refetch_controller.dart';
import 'package:construction_app/core/pagination/app_pagination_footer.dart';
import 'package:construction_app/core/widgets/loading/app_loader.dart';
import 'package:construction_app/core/widgets/states/app_empty_widget.dart';
import 'package:construction_app/core/widgets/states/app_error_widget.dart';
import '../providers/employee_schedule_provider.dart';
import '../widgets/employee_plan_calendar_card.dart';
import '../widgets/employee_plan_card.dart';
import '../widgets/employee_plan_legend.dart';

class EmployeePlanPage extends ConsumerStatefulWidget {
  const EmployeePlanPage({super.key});

  @override
  ConsumerState<EmployeePlanPage> createState() => _EmployeePlanPageState();
}

class _EmployeePlanPageState extends ConsumerState<EmployeePlanPage> {
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
      ref.read(employeeScheduleProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(employeeScheduleProvider);
    final selectedPhases = scheduleState.selectedPhases;
    final locale = context.loc.localeCode;
    final dateFormatted = DateFormat(
      'EEEE, MMM d',
      locale,
    ).format(scheduleState.selectedDay).toUpperCase();

    final hasPendingTranslations = anyLocalizationPending(
      scheduleState.days.expand((d) => d.phases).map((p) => p.localization),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: PendingPollEffect(
          hasPending: hasPendingTranslations,
          onPoll: () => ref.read(employeeScheduleProvider.notifier).refresh(),
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(employeeScheduleProvider.notifier).refresh(),
            child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 10.h),
                sliver: SliverToBoxAdapter(child: _buildHeader(context)),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                sliver: SliverToBoxAdapter(
                  child: EmployeePlanCalendarCard(
                    focusedDay: scheduleState.focusedDay,
                    selectedDay: scheduleState.selectedDay,
                    days: scheduleState.days,
                    onDaySelected: (selected, focused) {
                      ref
                          .read(employeeScheduleProvider.notifier)
                          .selectDay(selected, focused);
                    },
                    onPageChanged: (focused) {
                      ref
                          .read(employeeScheduleProvider.notifier)
                          .updateFocusedDay(focused);
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 14.h)),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                sliver: const SliverToBoxAdapter(child: EmployeePlanLegend()),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 16.h)),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                sliver: SliverToBoxAdapter(
                  child: _buildScheduleHeader(
                    context,
                    dateFormatted,
                    selectedPhases.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 10.h)),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 30.h),
                sliver: SliverToBoxAdapter(
                  child: _buildContent(context, scheduleState),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.loc.mySchedule,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            ref.read(employeeScheduleProvider.notifier).selectDay(today, today);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Text(
              context.loc.today,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleHeader(
    BuildContext context,
    String dateFormatted,
    int count,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${context.loc.mySchedule.toUpperCase()} - $dateFormatted',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '($count ${context.loc.smTasks.toUpperCase()})',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    EmployeeScheduleState state,
  ) {
    if (state.isLoading && state.days.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 36.h),
        child: const Center(child: AppLoader()),
      );
    }

    if (state.errorMessage != null && state.days.isEmpty) {
      return AppErrorWidget(
        message: context.loc.somethingWentWrong,
        onRetry: () => ref.read(employeeScheduleProvider.notifier).refresh(),
      );
    }

    if (state.selectedPhases.isEmpty) {
      return AppEmptyWidget(
        icon: Icons.event_available_outlined,
        title: context.loc.noScheduleToday,
        message: context.loc.noAssignments,
      );
    }

    return Column(
      children: [
        for (final phase in state.selectedPhases) ...[
          EmployeePlanCard(phase: phase),
          SizedBox(height: 10.h),
        ],
        AppPaginationFooter(
          hasMore: state.hasMore,
          isLoadingMore: state.isLoadingMore,
          itemCount: state.selectedPhases.length,
        ),
      ],
    );
  }
}
