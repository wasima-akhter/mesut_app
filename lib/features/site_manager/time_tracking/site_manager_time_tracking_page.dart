import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../core/extensions/date_time_extensions.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import '../../../core/utils/app_date_time_formatter.dart';
import '../helper/site_manager_enums.dart';
import '../helper/site_manager_models.dart';
import '../presentation/providers/site_manager_time_provider.dart';
import 'bottom_sheet_container.dart';

class SiteManagerTimeTrackingPage extends ConsumerStatefulWidget {
  const SiteManagerTimeTrackingPage({super.key});

  @override
  ConsumerState<SiteManagerTimeTrackingPage> createState() =>
      _SiteManagerTimeTrackingPageState();
}

class _SiteManagerTimeTrackingPageState
    extends ConsumerState<SiteManagerTimeTrackingPage> {
  TimeTrackingTab get _selectedTab =>
      ref.watch(siteManagerTimeProvider).selectedTab;

  TimeEntryFilter get _selectedFilter =>
      ref.watch(siteManagerTimeProvider).selectedFilter;

  String get _selectedProject =>
      ref.watch(siteManagerTimeProvider).selectedProject;

  bool get _isTimerRunning => ref.watch(siteManagerTimeProvider).isTimerRunning;

  List<String> get _projects => ref.watch(siteManagerTimeProvider).projects;

  List<TimeEntryModel> get _entries =>
      ref.watch(siteManagerTimeProvider).entries;

  List<CrewMemberModel> get _crewMembers =>
      ref.watch(siteManagerTimeProvider).crewMembers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            _buildMainTabs(),

            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  if (_selectedTab == TimeTrackingTab.myTime)
                    ..._buildMyTimeSlivers()
                  else
                    ..._buildCrewTimeSlivers(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.loc.timeTracking,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 4.h),
                Text(
                  context.loc.weekRange(
                    '38',
                    AppDateTimeFormatter.formatDateRange(
                      DateTime.utc(2026, 9, 14),
                      DateTime.utc(2026, 9, 20),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          _buildHeaderAction(
            icon: Icons.add,
            label: context.loc.addTime,
            onTap: _showAddTimeSheet,
          ),
        ],
      ),
    );
  }

  void _showStartTimerSheet() {
    ActivityType selectedActivity = ActivityType.erection;
    String? selectedProject;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              padding: EdgeInsets.fromLTRB(
                20.w,
                12.h,
                20.w,
                MediaQuery.of(context).viewInsets.bottom + 20.h,
              ),
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppColors.neutral300,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Center(
                        child: Text(
                          context.loc.startNewTimer,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Center(
                        child: Text(
                          context.loc.selectAssignedProject,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),

                      SizedBox(height: 24.h),

                      Text(
                        context.loc.assignedProject,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),

                      SizedBox(height: 8.h),

                      DropdownButtonFormField<String>(
                        initialValue: selectedProject,
                        decoration: InputDecoration(
                          hintText: context.loc.selectProject,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'PRJ-0842',
                            child: Text('PRJ-0842 • Goldstein Complex'),
                          ),
                          DropdownMenuItem(
                            value: 'PRJ-0912',
                            child: Text('PRJ-0912 • City Center'),
                          ),
                        ],
                        onChanged: (value) {
                          setSheetState(() {
                            selectedProject = value;
                          });
                        },
                      ),

                      SizedBox(height: 18.h),

                      Text(
                        context.loc.activityType,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),

                      SizedBox(height: 8.h),

                      DropdownButtonFormField<ActivityType>(
                        initialValue: selectedActivity,
                        decoration: const InputDecoration(),
                        items: ActivityType.values.map((activity) {
                          return DropdownMenuItem(
                            value: activity,
                            child: Text(activity.label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setSheetState(() {
                            selectedActivity = value;
                          });
                        },
                      ),

                      SizedBox(height: 12.h),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceTertiary,
                          borderRadius: AppRadii.medium,
                        ),
                        child: Text(
                          context.loc.timerWillStartFromNow,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      AppButton(
                        text: context.loc.startNewTimer,
                        onPressed: selectedProject == null
                            ? null
                            : () {
                                ref
                                    .read(siteManagerTimeProvider.notifier)
                                    .toggleTimer();

                                Navigator.pop(sheetContext);

                                _showMessage(
                                  context.loc.timerStartedFor(
                                    selectedActivity.label,
                                  ),
                                );
                              },
                        borderRadius: 8.r,
                      ),

                      SizedBox(height: 8.h),

                      Center(
                        child: AppTextButton(
                          text: context.loc.cancel,
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddTimeSheet() {
    TimeEntryTab selectedTab = TimeEntryTab.myTime;

    String? selectedEmployee = 'Tim Muller';
    String? selectedProject = 'PRJ-0842 • Goldstein Complex';

    ActivityType selectedActivity = ActivityType.erection;

    DateTime selectedDate = DateTime(2026, 10, 12);

    TimeOfDay startTime = const TimeOfDay(hour: 7, minute: 30);

    TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 30);

    TimeOfDay breakTime = const TimeOfDay(hour: 18, minute: 30);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              padding: EdgeInsets.fromLTRB(
                20.w,
                12.h,
                20.w,
                MediaQuery.of(context).viewInsets.bottom + 20.h,
              ),
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppColors.neutral300,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),

                      SizedBox(height: 18.h),

                      Center(
                        child: Text(
                          context.loc.addTimeEntry,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),

                      SizedBox(height: 18.h),

                      _buildTimeEntryTabs(
                        selectedTab: selectedTab,
                        onChanged: (tab) {
                          setSheetState(() {
                            selectedTab = tab;
                          });
                        },
                      ),

                      SizedBox(height: 18.h),

                      if (selectedTab == TimeEntryTab.siteCrewTime) ...[
                        Text(
                          context.loc.selectEmployee,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),

                        SizedBox(height: 8.h),

                        DropdownButtonFormField<String>(
                          initialValue: selectedEmployee,
                          decoration: const InputDecoration(),
                          items: const [
                            DropdownMenuItem(
                              value: 'Tim Muller',
                              child: Text('Tim Muller'),
                            ),
                            DropdownMenuItem(
                              value: 'Alex Brown',
                              child: Text('Alex Brown'),
                            ),
                            DropdownMenuItem(
                              value: 'John Smith',
                              child: Text('John Smith'),
                            ),
                          ],
                          onChanged: (value) {
                            setSheetState(() {
                              selectedEmployee = value;
                            });
                          },
                        ),

                        SizedBox(height: 18.h),
                      ],

                      Text(
                        context.loc.date,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),

                      SizedBox(height: 8.h),

                      _buildDateField(
                        context: context,
                        date: selectedDate,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );

                          if (date != null) {
                            setSheetState(() {
                              selectedDate = date;
                            });
                          }
                        },
                      ),

                      SizedBox(height: 18.h),

                      Text(
                        context.loc.project,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),

                      SizedBox(height: 8.h),

                      DropdownButtonFormField<String>(
                        initialValue: selectedProject,
                        decoration: const InputDecoration(),
                        items: const [
                          DropdownMenuItem(
                            value: 'PRJ-0842 • Goldstein Complex',
                            child: Text('PRJ-0842 • Goldstein Complex'),
                          ),
                          DropdownMenuItem(
                            value: 'PRJ-0912 • City Center',
                            child: Text('PRJ-0912 • City Center'),
                          ),
                        ],
                        onChanged: (value) {
                          setSheetState(() {
                            selectedProject = value;
                          });
                        },
                      ),

                      SizedBox(height: 18.h),

                      Text(
                        context.loc.activityType,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),

                      SizedBox(height: 8.h),

                      DropdownButtonFormField<ActivityType>(
                        initialValue: selectedActivity,
                        decoration: const InputDecoration(),
                        items: ActivityType.values.map((activity) {
                          return DropdownMenuItem(
                            value: activity,
                            child: Text(activity.label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setSheetState(() {
                            selectedActivity = value;
                          });
                        },
                      ),

                      SizedBox(height: 18.h),

                      Text(
                        context.loc.startTime,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),

                      SizedBox(height: 8.h),

                      _buildTimeField(
                        context: context,
                        time: startTime,
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: startTime,
                          );

                          if (time != null) {
                            setSheetState(() {
                              startTime = time;
                            });
                          }
                        },
                      ),

                      SizedBox(height: 18.h),

                      Text(
                        context.loc.endTime,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),

                      SizedBox(height: 8.h),

                      _buildTimeField(
                        context: context,
                        time: endTime,
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                          );

                          if (time != null) {
                            setSheetState(() {
                              endTime = time;
                            });
                          }
                        },
                      ),

                      SizedBox(height: 18.h),

                      Text(
                        context.loc.breakTime,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),

                      SizedBox(height: 8.h),

                      _buildTimeField(
                        context: context,
                        time: breakTime,
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: breakTime,
                          );

                          if (time != null) {
                            setSheetState(() {
                              breakTime = time;
                            });
                          }
                        },
                      ),

                      SizedBox(height: 12.h),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceTertiary,
                          borderRadius: AppRadii.medium,
                        ),
                        child: Text(
                          context.loc.workingTimeDeductBreak,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      AppButton(
                        text: context.loc.saveEntry,
                        onPressed: () {
                          ref
                              .read(siteManagerTimeProvider.notifier)
                              .addEntry(
                                TimeEntryModel(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  project:
                                      selectedProject ?? _selectedProject,
                                  activity: selectedActivity,
                                  date: DateTime.now(),
                                  startTime: startTime.format(context),
                                  endTime: endTime.format(context),
                                  breakTime:
                                      '${breakTime.hour * 60 + breakTime.minute}m',
                                  employee: 'Tim Muller',
                                ),
                              );

                          Navigator.pop(sheetContext);

                          _showMessage(context.loc.timeEntryAdded);
                        },
                        borderRadius: 8.r,
                      ),

                      SizedBox(height: 8.h),

                      Center(
                        child: AppTextButton(
                          text: context.loc.cancel,
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.medium,
      child: InputDecorator(
        decoration: const InputDecoration(
          suffixIcon: Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          '${date.day.toString().padLeft(2, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.year}',
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required BuildContext context,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.medium,
      child: InputDecorator(
        decoration: const InputDecoration(
          suffixIcon: Icon(Icons.access_time_outlined),
        ),
        child: Text(time.format(context)),
      ),
    );
  }

  Widget _buildTimeEntryTabs({
    required TimeEntryTab selectedTab,
    required ValueChanged<TimeEntryTab> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadii.medium,
      ),
      padding: EdgeInsets.all(3.w),
      child: Row(
        children: TimeEntryTab.values.map((tab) {
          final selected = tab == selectedTab;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: selected ? AppColors.black : Colors.transparent,
                  borderRadius: AppRadii.small,
                ),
                child: Text(
                  tab.label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17.sp, color: AppColors.textSecondary),
              SizedBox(width: 4.w),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: _tabItem(
                label: context.loc.myTime,
                selected: _selectedTab == TimeTrackingTab.myTime,
                onTap: () {
                  ref
                      .read(siteManagerTimeProvider.notifier)
                      .setTab(TimeTrackingTab.myTime);
                },
              ),
            ),
            Expanded(
              child: _tabItem(
                label: context.loc.siteCrewTime,
                selected: _selectedTab == TimeTrackingTab.siteCrewTime,
                onTap: () {
                  ref
                      .read(siteManagerTimeProvider.notifier)
                      .setTab(TimeTrackingTab.siteCrewTime);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItem({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? AppColors.black : Colors.transparent,
      borderRadius: BorderRadius.circular(7.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 12.w),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMyTimeSlivers() {
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
        sliver: SliverToBoxAdapter(child: _buildMyTimeSummary()),
      ),

      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
        sliver: SliverToBoxAdapter(child: _buildStartTimerButton()),
      ),

      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 0),
        sliver: SliverToBoxAdapter(child: _buildRecentLogsHeader()),
      ),

      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 30.h),
        sliver: SliverToBoxAdapter(child: _buildFilterChips()),
      ),

      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 30.h),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final entry = _entries[index];

            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildTimeEntryCard(entry),
            );
          }, childCount: _entries.length),
        ),
      ),
    ];
  }

  List<Widget> _buildCrewTimeSlivers() {
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
        sliver: SliverToBoxAdapter(child: _buildProjectSelector()),
      ),

      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
        sliver: SliverToBoxAdapter(child: _buildCrewSummary()),
      ),

      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 0),
        sliver: SliverToBoxAdapter(
          child: Text(
            context.loc.crewBreakdown,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),

      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 30.h),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _buildCrewCard(_crewMembers[index]),
            );
          }, childCount: _crewMembers.length),
        ),
      ),
    ];
  }

  Widget _buildMyTimeSummary() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.timeDarkSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _summaryValue(
                  title: context.loc.today,
                  value: const Duration(
                    hours: 7,
                    minutes: 30,
                  ).formatCompactLocalized(),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _summaryValue(
                    title: context.loc.thisWeek,
                    value: const Duration(
                      hours: 35,
                      minutes: 30,
                    ).formatCompactLocalized(),
                    alignRight: true,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 15.h),

          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: LinearProgressIndicator(
              value: .86,
              minHeight: 5.h,
              backgroundColor: AppColors.neutral600,
              valueColor: const AlwaysStoppedAnimation(AppColors.white),
            ),
          ),

          SizedBox(height: 8.h),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              context.loc.loggedThisWeek(
                const Duration(hours: 34, minutes: 15).formatCompactLocalized(),
                const Duration(hours: 40).formatCompactLocalized(),
              ),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.neutral300),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryValue({
    required String title,
    required String value,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.neutral400),
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.white),
        ),
      ],
    );
  }

  Widget _buildStartTimerButton() {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: _isTimerRunning ? _stopTimer : _showStartTimerSheet,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
          child: Center(
            child: Text(
              _isTimerRunning
                  ? context.loc.stopTimer
                  : context.loc.startNewTimer,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentLogsHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.loc.recentLogs,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: [
        _filterChip(TimeEntryFilter.thisWeek),
        SizedBox(width: 7.w),
        _filterChip(TimeEntryFilter.thisMonth),
      ],
    );
  }

  Widget _filterChip(TimeEntryFilter filter) {
    final selected = _selectedFilter == filter;

    return Material(
      color: selected ? AppColors.primary : AppColors.surfaceTertiary,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: () {
          ref.read(siteManagerTimeProvider.notifier).setFilter(filter);
        },
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Text(
            filter.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeEntryCard(TimeEntryModel entry) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: () => _showEntryDetails(entry),
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today, Sep 18',
                style: Theme.of(context).textTheme.bodySmall,
              ),

              SizedBox(height: 5.h),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.project,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    entry.duration,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              _activityBadge(entry.activity),

              SizedBox(height: 12.h),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${entry.startTime} – ${entry.endTime} • Break: ${entry.breakTime}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    entry.isSynced ? context.loc.synced : context.loc.pending,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: entry.isSynced
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityBadge(ActivityType activity) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _activityColor(activity).withValues(alpha: .10),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        activity.label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: _activityColor(activity)),
      ),
    );
  }

  Color _activityColor(ActivityType activity) {
    switch (activity) {
      case ActivityType.erection:
        return AppColors.success;
      case ActivityType.dismantling:
        return AppColors.warning;
      case ActivityType.standing:
        return AppColors.info;
      case ActivityType.others:
        return AppColors.timePurple;
    }
  }

  Widget _buildProjectSelector() {
    return _selectField(
      label: context.loc.project,
      value: _selectedProject,
      onTap: _showProjectSelector,
    );
  }

  Widget _buildCrewSummary() {
    String projectTotalHours = '142.5h';
    String targetBudget = '160h';
    String erectionHours = '82.5h';
    String dismantlingHours = '36.0h';
    String otherHours = '24.0h';
    double erectionProgress = 0.58;
    double dismantlingProgress = 0.25;
    double otherProgress = 0.17;
    bool isProfitable = true;

    if (_selectedProject.contains('0912')) {
      projectTotalHours = '85.0h';
      targetBudget = '120h';
      erectionHours = '50.0h';
      dismantlingHours = '20.0h';
      otherHours = '15.0h';
      erectionProgress = 0.59;
      dismantlingProgress = 0.24;
      otherProgress = 0.17;
      isProfitable = true;
    } else if (_selectedProject.contains('0731')) {
      projectTotalHours = '114.5h';
      targetBudget = '100h';
      erectionHours = '65.0h';
      dismantlingHours = '30.0h';
      otherHours = '19.5h';
      erectionProgress = 0.57;
      dismantlingProgress = 0.26;
      otherProgress = 0.17;
      isProfitable = false;
    }

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.timeDarkSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.loc.totalProjectHours,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppColors.neutral400),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: isProfitable
                      ? AppColors.success.withValues(alpha: .2)
                      : AppColors.error.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  isProfitable ? context.loc.profitable : context.loc.lossRisk,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isProfitable ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),

          SizedBox(height: 5.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                projectTotalHours,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              SizedBox(width: 8.w),
              Text(
                '/ $targetBudget budget',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.neutral400),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          _crewProgress(
            activity: ActivityType.erection,
            hours: erectionHours,
            progress: erectionProgress,
          ),

          _crewProgress(
            activity: ActivityType.dismantling,
            hours: dismantlingHours,
            progress: dismantlingProgress,
          ),

          _crewProgress(
            activity: ActivityType.others,
            hours: otherHours,
            progress: otherProgress,
          ),
        ],
      ),
    );
  }

  Widget _crewProgress({
    required ActivityType activity,
    required String hours,
    required double progress,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 7.w,
                height: 7.w,
                decoration: BoxDecoration(
                  color: _activityColor(activity),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  activity.label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.white),
                ),
              ),
              Text(
                hours,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.neutral300),
              ),
            ],
          ),

          SizedBox(height: 5.h),

          LinearProgressIndicator(
            value: progress,
            minHeight: 4.h,
            backgroundColor: AppColors.neutral700,
            valueColor: AlwaysStoppedAnimation(_activityColor(activity)),
          ),
        ],
      ),
    );
  }

  Widget _buildCrewCard(CrewMemberModel member) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: () => _showCrewDetails(member),
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 21.r,
                backgroundColor: AppColors.primary100,
                child: Text(
                  member.name.substring(0, 1),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: AppColors.primary700),
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            member.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        SizedBox(width: 7.w),
                      ],
                    ),

                    SizedBox(height: 4.h),
                    Text(
                      member.activity.label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: 4.h),

                    Text(
                      '${member.startTime} – ${member.endTime}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Break: ${member.breakTime}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    context.loc.synced,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: AppColors.success),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    member.totalHours,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _clickableField({
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Icon(icon, size: 18.sp, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _secondaryAction({
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          child: Center(
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
        ),
      ),
    );
  }

  Widget _selectField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        SizedBox(height: 7.h),
        _clickableField(
          value: value,
          icon: Icons.keyboard_arrow_down_rounded,
          onTap: onTap,
        ),
      ],
    );
  }

  void _showProjectSelector() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.loc.selectProject,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                SizedBox(height: 18.h),

                ..._projects.map((project) {
                  final selected = project == _selectedProject;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Material(
                      color: selected ? AppColors.primary50 : AppColors.surface,
                      borderRadius: BorderRadius.circular(8.r),
                      child: InkWell(
                        onTap: () {
                          ref
                              .read(siteManagerTimeProvider.notifier)
                              .setSelectedProject(project);

                          Navigator.pop(sheetContext);
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Padding(
                          padding: EdgeInsets.all(14.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  project,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              if (selected)
                                Icon(
                                  Icons.check,
                                  color: AppColors.primary,
                                  size: 20.sp,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEntryDetails(TimeEntryModel entry) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return BottomSheetContainer(
          title: context.loc.timeEntry,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(context.loc.project, entry.project),
              _detailRow(context.loc.activityType, entry.activity.label),
              _detailRow(context.loc.date, 'Sep 18, 2026'),
              _detailRow(
                context.loc.workingTime,
                '${entry.startTime} – ${entry.endTime}',
              ),
              _detailRow(context.loc.breakTime, entry.breakTime),
              _detailRow(context.loc.total, entry.duration),
              _detailRow(context.loc.employee, entry.employee),

              SizedBox(height: 20.h),

              _secondaryAction(
                label: context.loc.close,
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCrewDetails(CrewMemberModel member) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return BottomSheetContainer(
          title: member.name,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(context.loc.activityType, member.activity.label),
              _detailRow(
                context.loc.workingTime,
                '${member.startTime} – ${member.endTime}',
              ),
              _detailRow(context.loc.breakTime, member.breakTime),
              _detailRow(context.loc.total, member.totalHours),

              SizedBox(height: 20.h),

              _secondaryAction(
                label: context.loc.close,
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(title, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }

  void _stopTimer() {
    ref.read(siteManagerTimeProvider.notifier).toggleTimer();

    _showMessage('Timer stopped');
  }

  void _showMessage(String message) {
    AppSnackBar.showInfo(context, message);
  }
}
