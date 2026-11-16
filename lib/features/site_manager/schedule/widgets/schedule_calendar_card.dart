import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../shared/mobile_dashboard/domain/entities/mobile_schedule_entity.dart';
import '../../../shared/mobile_dashboard/presentation/utils/mobile_phase_localizer.dart';

class ScheduleCalendarCard extends StatelessWidget {
  const ScheduleCalendarCard({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.eventsByDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, List<MobileSchedulePhaseEntity>> eventsByDay;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  static DateTime normalizeDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
        padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 10.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: TableCalendar<MobileSchedulePhaseEntity>(
          firstDay: DateTime(2020),
          lastDay: DateTime(2035),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          eventLoader: (day) => eventsByDay[normalizeDay(day)] ?? const [],
          onDaySelected: onDaySelected,
          onPageChanged: onPageChanged,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          daysOfWeekHeight: 28.h,
          rowHeight: 42.h,
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
            titleTextStyle: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            headerPadding: EdgeInsets.symmetric(vertical: 4.h),
            headerMargin: EdgeInsets.zero,
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            weekendStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            weekendTextStyle: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            selectedTextStyle: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.2),
            ),
            markersMaxCount: 3,
          ),
          calendarBuilders: CalendarBuilders<MobileSchedulePhaseEntity>(
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return null;
              final isSelected = isSameDay(selectedDay, day);
              return Positioned(
                bottom: 4.h,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final phase in events.take(3))
                      Container(
                        width: 6.w,
                        height: 6.w,
                        margin: EdgeInsets.symmetric(horizontal: 1.2.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.white
                              : MobilePhaseLocalizer.phaseColor(phase.type),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
