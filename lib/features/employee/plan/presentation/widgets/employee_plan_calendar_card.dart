import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import '../../domain/entities/employee_schedule_entity.dart';

class EmployeePlanCalendarCard extends StatelessWidget {
  const EmployeePlanCalendarCard({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.days,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<EmployeeScheduleDayEntity> days;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  String _dateKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  EmployeeScheduleDayEntity? _findDayData(DateTime day) {
    final key = _dateKey(day);
    for (final d in days) {
      if (d.date.length >= 10 && d.date.substring(0, 10) == key) {
        return d;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border),
      ),
      child: TableCalendar<dynamic>(
        firstDay: DateTime(2020),
        lastDay: DateTime(2035),
        focusedDay: focusedDay,
        calendarFormat: CalendarFormat.week,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableCalendarFormats: const {CalendarFormat.week: 'Week'},
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          headerPadding: EdgeInsets.symmetric(vertical: 6.h),
          leftChevronIcon: const Icon(Icons.chevron_left),
          rightChevronIcon: const Icon(Icons.chevron_right),
          titleTextStyle: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        daysOfWeekHeight: 30.h,
        daysOfWeekStyle: TextStyle(
          fontSize: 14.sp,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ).let((s) => DaysOfWeekStyle(weekdayStyle: s, weekendStyle: s)),
        rowHeight: 46.h,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: TextStyle(
            fontSize: 15.sp,
            color: AppColors.textPrimary,
          ),
          weekendTextStyle: TextStyle(
            fontSize: 15.sp,
            color: AppColors.textSecondary,
          ),
          selectedTextStyle: TextStyle(
            fontSize: 15.sp,
            color: AppColors.white,
            fontWeight: FontWeight.w700,
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
            fontSize: 15.sp,
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          cellMargin: EdgeInsets.all(2.w),
          cellPadding: EdgeInsets.zero,
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            final dayData = _findDayData(day);
            if (dayData == null || dayData.phases.isEmpty) return null;

            final dots = <Color>[];
            for (final p in dayData.phases) {
              final type = p.type.toUpperCase();
              Color dotColor = AppColors.info;
              if (type.contains('ERECTION')) {
                dotColor = AppColors.success;
              } else if (type.contains('DISMANTLING')) {
                dotColor = AppColors.warning;
              }
              if (!dots.contains(dotColor)) {
                dots.add(dotColor);
              }
            }

            return Positioned(
              bottom: 4.h,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: dots.take(3).map((c) {
                  return Container(
                    width: 5.w,
                    height: 5.w,
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}

extension<T> on T {
  R let<R>(R Function(T) op) => op(this);
}

