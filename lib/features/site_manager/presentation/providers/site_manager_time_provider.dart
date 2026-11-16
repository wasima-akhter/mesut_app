import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helper/site_manager_enums.dart';
import '../../helper/site_manager_models.dart';

class SiteManagerTimeState {
  final TimeTrackingTab selectedTab;
  final TimeEntryFilter selectedFilter;
  final String selectedProject;
  final bool isTimerRunning;
  final List<String> projects;
  final List<TimeEntryModel> entries;
  final List<CrewMemberModel> crewMembers;

  const SiteManagerTimeState({
    this.selectedTab = TimeTrackingTab.myTime,
    this.selectedFilter = TimeEntryFilter.thisWeek,
    this.selectedProject = '',
    this.isTimerRunning = false,
    this.projects = const [],
    this.entries = const [],
    this.crewMembers = const [],
  });

  SiteManagerTimeState copyWith({
    TimeTrackingTab? selectedTab,
    TimeEntryFilter? selectedFilter,
    String? selectedProject,
    bool? isTimerRunning,
    List<String>? projects,
    List<TimeEntryModel>? entries,
    List<CrewMemberModel>? crewMembers,
  }) {
    return SiteManagerTimeState(
      selectedTab: selectedTab ?? this.selectedTab,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedProject: selectedProject ?? this.selectedProject,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      projects: projects ?? this.projects,
      entries: entries ?? this.entries,
      crewMembers: crewMembers ?? this.crewMembers,
    );
  }
}

class SiteManagerTimeNotifier extends Notifier<SiteManagerTimeState> {
  @override
  SiteManagerTimeState build() {
    final now = DateTime.now();
    return SiteManagerTimeState(
      entries: [
        TimeEntryModel(
          id: '1',
          project: 'PRJ-0842 • Goldsteins Complex',
          activity: ActivityType.erection,
          date: now,
          startTime: '07:30 am',
          endTime: '04:15 pm',
          breakTime: '45m',
          employee: 'Tim Muller',
        ),
        TimeEntryModel(
          id: '2',
          project: 'PRJ-0842 • Goldsteins Complex',
          activity: ActivityType.dismantling,
          date: now.subtract(const Duration(days: 1)),
          startTime: '07:30 am',
          endTime: '04:15 pm',
          breakTime: '45m',
          employee: 'Tim Muller',
        ),
        TimeEntryModel(
          id: '3',
          project: 'PRJ-0912 • Riverside Tower',
          activity: ActivityType.standing,
          date: now.subtract(const Duration(days: 2)),
          startTime: '08:00 am',
          endTime: '04:00 pm',
          breakTime: '30m',
          employee: 'John Smith',
        ),
      ],
    );
  }

  void setTab(TimeTrackingTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void setFilter(TimeEntryFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void setSelectedProject(String project) {
    state = state.copyWith(selectedProject: project);
  }

  void toggleTimer() {
    state = state.copyWith(isTimerRunning: !state.isTimerRunning);
  }

  void addEntry(TimeEntryModel entry) {
    state = state.copyWith(entries: [entry, ...state.entries]);
  }
}

final siteManagerTimeProvider =
    NotifierProvider<SiteManagerTimeNotifier, SiteManagerTimeState>(
  SiteManagerTimeNotifier.new,
);
