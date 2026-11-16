import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/widgets/states/app_empty_widget.dart';
import '../../shared/mobile_dashboard/domain/entities/mobile_schedule_entity.dart';
import '../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import 'widgets/schedule_calendar_card.dart';
import 'widgets/schedule_phase_card.dart';

class SiteManagerSchedulePage extends ConsumerStatefulWidget {
  const SiteManagerSchedulePage({super.key});

  @override
  ConsumerState<SiteManagerSchedulePage> createState() =>
      _SiteManagerSchedulePageState();
}

class _SiteManagerSchedulePageState
    extends ConsumerState<SiteManagerSchedulePage> {
  int _selectedPreset = 0;
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = ScheduleCalendarCard.normalizeDay(now);
    _focusedDay = _selectedDay;
  }

  Future<void> _selectPreset(int preset) async {
    setState(() {
      _selectedPreset = preset;
      final now = DateTime.now();
      _selectedDay = ScheduleCalendarCard.normalizeDay(now);
      _focusedDay = _selectedDay;
    });
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month, now.day);
    final days = preset == 0 ? 7 : 14;
    final end = start.add(
      Duration(days: days, hours: 23, minutes: 59, seconds: 59),
    );
    await ref
        .read(mobileScheduleProvider.notifier)
        .loadRange(startDate: start, endDate: end);
  }

  Future<void> _pickCustomRange() async {
    final notifier = ref.read(mobileScheduleProvider.notifier);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: notifier.startDate.toLocal(),
        end: notifier.endDate.toLocal(),
      ),
    );
    if (picked == null) return;
    setState(() {
      _selectedPreset = 2;
      _selectedDay = ScheduleCalendarCard.normalizeDay(picked.start);
      _focusedDay = _selectedDay;
    });
    final start = DateTime.utc(
      picked.start.year,
      picked.start.month,
      picked.start.day,
    );
    final end = DateTime.utc(
      picked.end.year,
      picked.end.month,
      picked.end.day,
      23,
      59,
      59,
    );
    await notifier.loadRange(startDate: start, endDate: end);
  }

  Future<void> _onMonthChanged(DateTime focusedDay) async {
    setState(() {
      _focusedDay = focusedDay;
      _selectedPreset = 2;
    });
    final start = DateTime.utc(focusedDay.year, focusedDay.month, 1);
    final end = DateTime.utc(focusedDay.year, focusedDay.month + 1, 0, 23, 59, 59);
    await ref
        .read(mobileScheduleProvider.notifier)
        .loadRange(startDate: start, endDate: end);
  }

  Map<DateTime, List<MobileSchedulePhaseEntity>> _groupByDay(
    List<MobileScheduleDayEntity> days,
  ) {
    final map = <DateTime, List<MobileSchedulePhaseEntity>>{};
    for (final day in days) {
      final parsed = DateTime.tryParse(day.date);
      if (parsed == null) continue;
      final key = ScheduleCalendarCard.normalizeDay(parsed.toLocal());
      map.putIfAbsent(key, () => []).addAll(day.phases);
    }
    return map;
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider);
    final scheduleAsync = ref.watch(mobileScheduleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.scheduleTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_outlined),
            onPressed: _pickCustomRange,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(context.loc.thisWeek),
                  selected: _selectedPreset == 0,
                  selectedColor: AppColors.primary.withValues(alpha: 0.16),
                  onSelected: (_) => _selectPreset(0),
                ),
                SizedBox(width: 8.w),
                ChoiceChip(
                  label: Text(context.loc.next14Days),
                  selected: _selectedPreset == 1,
                  selectedColor: AppColors.primary.withValues(alpha: 0.16),
                  onSelected: (_) => _selectPreset(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(mobileScheduleProvider.notifier).refresh(),
              child: scheduleAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.loc.somethingWentWrong),
                      SizedBox(height: 12.h),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(mobileScheduleProvider.notifier).refresh(),
                        child: Text(context.loc.mapRetry),
                      ),
                    ],
                  ),
                ),
                data: (days) {
                  final eventsByDay = _groupByDay(days);
                  final selectedPhases =
                      eventsByDay[_selectedDay] ?? const [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScheduleCalendarCard(
                        focusedDay: _focusedDay,
                        selectedDay: _selectedDay,
                        eventsByDay: eventsByDay,
                        onDaySelected: (selected, focused) {
                          setState(() {
                            _selectedDay =
                                ScheduleCalendarCard.normalizeDay(selected);
                            _focusedDay = focused;
                          });
                        },
                        onPageChanged: _onMonthChanged,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 8.h),
                        child: Text(
                          '${_formatDate(_selectedDay)} (${selectedPhases.length})',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: selectedPhases.isEmpty
                            ? ListView(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                children: [
                                  SizedBox(height: 16.h),
                                  AppEmptyWidget(
                                    icon: Icons.event_busy_outlined,
                                    title: context.loc.noScheduleItems,
                                    onRetry: () => ref
                                        .read(mobileScheduleProvider.notifier)
                                        .refresh(),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: EdgeInsets.fromLTRB(
                                  16.w,
                                  0,
                                  16.w,
                                  20.h,
                                ),
                                itemCount: selectedPhases.length,
                                itemBuilder: (context, index) =>
                                    SchedulePhaseCard(
                                  phase: selectedPhases[index],
                                  onTap: () => context.push(
                                    RouteConstants.siteManagerProjectDetail,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
