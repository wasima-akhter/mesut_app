import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/widgets/loading/app_loader.dart';
import '../../../core/widgets/states/app_empty_widget.dart';
import '../../../core/widgets/states/app_error_widget.dart';
import '../../shared/mobile_dashboard/domain/entities/mobile_schedule_entity.dart';
import '../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import 'widgets/calendar_inspection_card.dart';
import 'widgets/calendar_legend.dart';
import 'widgets/calendar_phase_card.dart';
import 'widgets/calendar_view_card.dart';
import 'widgets/inspection_header.dart';

class InspectionCalendarPage extends ConsumerStatefulWidget {
  const InspectionCalendarPage({super.key});

  @override
  ConsumerState<InspectionCalendarPage> createState() =>
      _InspectionCalendarPageState();
}

class _InspectionCalendarPageState
    extends ConsumerState<InspectionCalendarPage> {
  late DateTime _selectedDate;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _focusedDay = DateTime(now.year, now.month, now.day);
  }

  String _dateKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  MobileScheduleDayEntity? _findDay(
    List<MobileScheduleDayEntity> days,
    DateTime target,
  ) {
    final key = _dateKey(target);
    for (final d in days) {
      if (d.date.length >= 10 && d.date.substring(0, 10) == key) {
        return d;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(mobileScheduleProvider);
    final days = scheduleAsync.asData?.value ?? const [];
    final selectedDayData = _findDay(days, _selectedDate);
    final totalEvents = selectedDayData?.totalEvents ?? 0;
    final locale = context.loc.localeCode;
    final dateTitle = DateFormat(
      'EEEE, MMM d',
      locale,
    ).format(_selectedDate).toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            InspectionHeader(title: context.loc.calendar),
            SizedBox(height: 12.h),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref
                    .read(mobileScheduleProvider.notifier)
                    .loadMonth(_focusedDay),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 24.h),
                  children: [
                    CalendarViewCard(
                      focusedDay: _focusedDay,
                      selectedDay: _selectedDate,
                      scheduleDays: days,
                      onDaySelected: (selected, focused) {
                        setState(() {
                          _selectedDate = selected;
                          _focusedDay = focused;
                        });
                      },
                      onPageChanged: (focused) {
                        setState(() => _focusedDay = focused);
                        ref
                            .read(mobileScheduleProvider.notifier)
                            .loadMonth(focused);
                      },
                    ),
                    SizedBox(height: 12.h),
                    const CalendarLegend(),
                    SizedBox(height: 14.h),
                    _buildScheduleBanner(dateTitle, totalEvents),
                    SizedBox(height: 10.h),
                    if (scheduleAsync.isLoading && days.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: const Center(child: AppLoader()),
                      )
                    else if (scheduleAsync.hasError && days.isEmpty)
                      AppErrorWidget(
                        message: context.loc.somethingWentWrong,
                        onRetry: () => ref
                            .read(mobileScheduleProvider.notifier)
                            .loadMonth(_focusedDay),
                      )
                    else if (selectedDayData == null || totalEvents == 0)
                      AppEmptyWidget(
                        icon: Icons.event_busy_outlined,
                        title: context.loc.noInspections,
                      )
                    else ...[
                      for (final phase in selectedDayData.phases)
                        Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: CalendarPhaseCard(phase: phase),
                        ),
                      for (final inspection in selectedDayData.inspections)
                        Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: CalendarInspectionCard(inspection: inspection),
                        ),
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

  Widget _buildScheduleBanner(String dateTitle, int eventCount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.loc.scheduleForDate(dateTitle),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            context.loc.eventCount(eventCount),
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
}
