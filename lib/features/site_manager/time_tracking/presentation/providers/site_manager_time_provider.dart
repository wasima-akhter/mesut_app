import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/mobile_dashboard/domain/entities/mobile_project_entity.dart';
import '../../../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../../helper/site_manager_enums.dart';
import '../../../helper/site_manager_models.dart';
import '../../../project_details/data/repositories/project_details_repository_impl.dart';

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
    return const SiteManagerTimeState(
      projects: [],
      selectedProject: '',
      crewMembers: [],
      entries: [],
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

final projectPhasesProvider =
    FutureProvider.family<List<MobileProjectPhaseEntity>, String>((
      ref,
      projectId,
    ) async {
      if (projectId.trim().isEmpty) return const [];
      try {
        final repository = ref.read(projectDetailsRepositoryProvider);
        final details = await repository.getProjectDetails(projectId);
        final phases = details.phases
            .where((p) => p.id.isNotEmpty)
            .map(
              (p) => MobileProjectPhaseEntity(
                id: p.id,
                type: p.type,
                status: p.status,
                priority: p.priority,
                startDate: p.startDate,
                endDate: p.endDate,
              ),
            )
            .toList();
        if (phases.isNotEmpty) return phases;
      } catch (e) {
        debugPrint('[projectPhasesProvider] Details error for $projectId: $e');
      }

      final projects =
          ref.read(mobileProjectsProvider).asData?.value ?? const [];
      final matched = projects.where((p) => p.id == projectId).firstOrNull;
      return matched?.phases ?? const [];
    });
