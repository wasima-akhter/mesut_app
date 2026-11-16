import 'package:construction_app/app/constants/route_constants.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/widgets/states/app_empty_widget.dart';
import '../presentation/providers/site_manager_inspections_provider.dart';
import 'site_manager_inspections_page.dart';
import 'widgets/inspection_header.dart';

class InspectionCalendarPage extends ConsumerStatefulWidget {
  const InspectionCalendarPage({super.key});

  @override
  ConsumerState<InspectionCalendarPage> createState() =>
      _InspectionCalendarPageState();
}

class _InspectionCalendarPageState
    extends ConsumerState<InspectionCalendarPage> {
  DateTime get _selectedDate =>
      ref.watch(siteInspectionProvider).selectedCalendarDate;
  DateTime get _focusedDay =>
      ref.watch(siteInspectionProvider).focusedCalendarDate;
  List<CalendarEventModel> get _events =>
      ref.watch(siteInspectionProvider).calendarEvents;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            InspectionHeader(title: context.loc.calendar),

            SizedBox(height: 12.h),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 24.h),
                children: [
                  _buildCalendarCard(),

                  SizedBox(height: 11.h),

                  _buildLegend(),

                  SizedBox(height: 14.h),

                  _buildScheduleTitle(),

                  SizedBox(height: 9.h),

                  if (_events.isEmpty)
                    AppEmptyWidget(
                      icon: Icons.event_busy_outlined,
                      title: context.loc.noInspections,
                    )
                  else
                    ..._events.map(
                      (event) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: _buildEventCard(event),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ----------------------------------------------------------
  // CALENDAR CARD
  // ----------------------------------------------------------

  Widget _buildCalendarCard() {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: TableCalendar<CalendarEventModel>(
        firstDay: DateTime(2020),
        lastDay: DateTime(2035),
        focusedDay: _focusedDay,

        selectedDayPredicate: (day) {
          return isSameDay(_selectedDate, day);
        },

        onDaySelected: (selectedDay, focusedDay) {
          ref.read(siteInspectionProvider.notifier).setCalendarDates(
                selectedDay: selectedDay,
                focusedDay: focusedDay,
              );
        },

        onPageChanged: (focusedDay) {
          ref.read(siteInspectionProvider.notifier).setCalendarDates(
                selectedDay: _selectedDate,
                focusedDay: focusedDay,
              );
        },

        startingDayOfWeek: StartingDayOfWeek.monday,

        calendarFormat: CalendarFormat.month,

        availableCalendarFormats: const {CalendarFormat.month: 'Month'},

        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            size: 22.sp,
            color: AppColors.textSecondary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            size: 22.sp,
            color: AppColors.textSecondary,
          ),
          titleTextStyle:
              Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 19.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ) ??
              TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w600),
          headerPadding: EdgeInsets.symmetric(vertical: 4.h),
          headerMargin: EdgeInsets.zero,
        ),

        daysOfWeekHeight: 32.h,

        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle:
              Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 17.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ) ??
              TextStyle(fontSize: 17.sp, color: AppColors.textSecondary),
          weekendStyle:
              Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 17.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ) ??
              TextStyle(fontSize: 17.sp, color: AppColors.textSecondary),
        ),

        rowHeight: 42.h,

        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,

          // Normal dates
          defaultTextStyle:
              Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ) ??
              TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),

          // Saturday / Sunday
          weekendTextStyle:
              Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ) ??
              TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),

          // Selected date
          selectedTextStyle:
              Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ) ??
              TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),

          selectedDecoration: BoxDecoration(
            color: AppColors.black,
            shape: BoxShape.circle,
          ),

          // Today
          todayDecoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),

          todayTextStyle:
              Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ) ??
              TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),

          cellMargin: EdgeInsets.all(3.w),
          cellPadding: EdgeInsets.zero,

          markersMaxCount: 1,

          markerDecoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),

          markerSize: 5.w,
          markerMargin: EdgeInsets.only(top: 2.h),
        ),
        eventLoader: (day) {
          return _events.where((event) {
            return day.day == 18 && day.month == 9 && day.year == 2026;
          }).toList();
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // LEGEND
  // ----------------------------------------------------------

  Widget _buildLegend() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        children: [
          _legendItem(AppColors.success, context.loc.erectionPhase),

          SizedBox(width: 18.w),

          _legendItem(AppColors.warning, context.loc.dismantlingPhase),

          SizedBox(width: 18.w),

          _legendItem(AppColors.info, context.loc.halfDay),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String title) {
    return Row(
      children: [
        Container(
          width: 7.w,
          height: 7.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        SizedBox(width: 5.w),

        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: 15.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
  // ----------------------------------------------------------
  // SCHEDULE
  // ----------------------------------------------------------

  Widget _buildScheduleTitle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.loc.scheduleForDate('FRIDAY, SEPT 18'),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            context.loc.eventCount(2),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(CalendarEventModel event) {
    return Container(
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: event.color.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  event.type,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: event.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(),

              Icon(
                Icons.access_time_outlined,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),

              SizedBox(width: 5.w),

              Text(
                event.time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 15.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          Text(
            '${event.projectId} · ${event.title}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 7.h),

          Text(
            event.address,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 17.sp,
              color: AppColors.textSecondary,
            ),
          ),

          SizedBox(height: 9.h),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 16.sp,
                  color: AppColors.textSecondary,
                ),

                SizedBox(width: 6.w),

                Expanded(
                  child: Text(
                    '${event.type}: ${event.dateRange}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 9.h),

          Divider(height: 1, color: AppColors.border),

          SizedBox(height: 9.h),

          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 21.sp,
                color: AppColors.textSecondary,
              ),

              SizedBox(width: 6.w),

              Expanded(
                child: Text(
                  event.assignee,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 17.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              SmallRedButton(
                text: context.loc.openProject,
                onTap: () {
                  context.push(
                    RouteConstants.siteManagerProjectDetail,
                    extra: event.projectId,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
