import 'package:construction_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/extensions/date_time_extensions.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import '../helper/employee_enums.dart';
import '../helper/employee_models.dart';
import '../presentation/providers/employee_plan_provider.dart';

class EmployeePlanPage extends ConsumerWidget {
  const EmployeePlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planState = ref.watch(employeePlanProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 10.h),
              sliver: SliverToBoxAdapter(child: _buildHeader(context, ref)),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(
                child: _buildCalendarCard(context, ref, planState),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 14.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(child: _buildLegend(context)),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 16.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              sliver: SliverToBoxAdapter(
                child: _buildScheduleHeader(context, planState),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 10.h)),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 30.h),
              sliver: SliverToBoxAdapter(
                child: _buildSchedule(context, planState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.loc.mySchedule,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            final now = DateTime.now();
            ref.read(employeePlanProvider.notifier).selectDay(now, now);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Text(
              context.loc.today,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard(
    BuildContext context,
    WidgetRef ref,
    EmployeePlanState state,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: TableCalendar<EmployeeCalendarEventModel>(
        firstDay: DateTime(2020),
        lastDay: DateTime(2035),
        focusedDay: state.focusedDay,
        calendarFormat: CalendarFormat.week,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableCalendarFormats: const {CalendarFormat.week: 'Week'},
        selectedDayPredicate: (day) {
          return isSameDay(state.selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          ref
              .read(employeePlanProvider.notifier)
              .selectDay(selectedDay, focusedDay);
        },
        onPageChanged: (focusedDay) {
          ref.read(employeePlanProvider.notifier).updateFocusedDay(focusedDay);
        },
        eventLoader: (day) {
          return state.events.where((event) {
            return isSameDay(event.date, day);
          }).toList();
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          headerPadding: EdgeInsets.symmetric(vertical: 6.h),
          leftChevronIcon: const Icon(Icons.chevron_left),
          rightChevronIcon: const Icon(Icons.chevron_right),
          titleTextStyle: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        daysOfWeekHeight: 30.h,
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 15.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: TextStyle(
            fontSize: 15.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        rowHeight: 46.h,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textPrimary,
          ),
          weekendTextStyle: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
          selectedTextStyle: TextStyle(
            fontSize: 16.sp,
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            fontSize: 16.sp,
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          markerDecoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          markerSize: 5.w,
          markerMargin: EdgeInsets.only(top: 3.h),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      children: [
        _legendItem(AppColors.success, context.loc.scaffoldErection),
        SizedBox(width: 18.w),
        _legendItem(AppColors.warning, context.loc.scaffoldDismantling),
        SizedBox(width: 18.w),
        _legendItem(AppColors.info, context.loc.otherActivity),
      ],
    );
  }

  Widget _legendItem(Color color, String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          title,
          style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildScheduleHeader(BuildContext context, EmployeePlanState state) {
    final dayName = _dayName(state.selectedDay);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${context.loc.mySchedule.toUpperCase()} - $dayName',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '(${state.selectedEvents.length} ${context.loc.smTasks.toUpperCase()})',
            style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedule(BuildContext context, EmployeePlanState state) {
    if (state.selectedEvents.isEmpty) {
      return _emptySchedule(context);
    }

    return Column(
      children: [
        for (final event in state.selectedEvents) ...[
          _buildEventCard(context, event),
          SizedBox(height: 10.h),
        ],
      ],
    );
  }

  Widget _emptySchedule(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_available_outlined,
            size: 34,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 10.h),
          Text(
            context.loc.noScheduleToday,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4.h),
          Text(
            context.loc.noAssignments,
            style: TextStyle(fontSize: 15.sp, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    EmployeeCalendarEventModel event,
  ) {
    final project = event.project;
    final activity = project.activity;

    return GestureDetector(
      onTap: () {
        _showMessage(context, 'Selected ${project.fullName}');
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(13.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  project.fullName,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
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
              ],
            ),

            SizedBox(height: 8.h),

            Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  size: 19,
                  color: AppColors.textTertiary,
                ),
                SizedBox(width: 6.w),
                Text(
                  '${project.startTime} – ${project.endTime}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            Text(
              '${context.loc.manager}: ${project.siteManager}',
              style: TextStyle(fontSize: 15.sp, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  String _dayName(DateTime date) {
    return date.formatDayHeader();
  }

  void _showMessage(BuildContext context, String message) {
    AppSnackBar.showInfo(context, message);
  }
}
