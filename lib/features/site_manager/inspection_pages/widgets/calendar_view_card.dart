import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../shared/mobile_dashboard/domain/entities/mobile_schedule_entity.dart';

class CalendarViewCard extends StatelessWidget {
  const CalendarViewCard({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.scheduleDays,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<MobileScheduleDayEntity> scheduleDays;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  String _dateKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  MobileScheduleDayEntity? _findDayData(DateTime day) {
    final key = _dateKey(day);
    for (final d in scheduleDays) {
      if (d.date.length >= 10 && d.date.substring(0, 10) == key) {
        return d;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: TableCalendar<dynamic>(
        firstDay: DateTime(2020),
        lastDay: DateTime(2035),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
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
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ) ??
                  TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
          headerPadding: EdgeInsets.symmetric(vertical: 4.h),
          headerMargin: EdgeInsets.zero,
        ),
        daysOfWeekHeight: 30.h,
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          weekendStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        rowHeight: 44.h,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          weekendTextStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
          selectedTextStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.black,
            shape: BoxShape.circle,
          ),
          todayDecoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          cellMargin: EdgeInsets.all(2.w),
          cellPadding: EdgeInsets.zero,
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            final dayData = _findDayData(day);
            if (dayData == null || dayData.totalEvents == 0) {
              return null;
            }

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

            if (dayData.inspections.isNotEmpty &&
                !dots.contains(AppColors.primary)) {
              dots.add(AppColors.primary);
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
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                    ),
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
