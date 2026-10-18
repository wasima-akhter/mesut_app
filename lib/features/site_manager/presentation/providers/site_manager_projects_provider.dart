import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/enums.dart';
import '../../projects/models.dart';

class ProjectFilterState {
  final List<String> phases;
  final List<String> cities;
  final String priority;
  final String customerCategory;
  final String sortBy;
  final String searchQuery;

  const ProjectFilterState({
    this.phases = const [],
    this.cities = const [],
    this.priority = 'All',
    this.customerCategory = 'All',
    this.sortBy = 'Date (Newest)',
    this.searchQuery = '',
  });

  ProjectFilterState copyWith({
    List<String>? phases,
    List<String>? cities,
    String? priority,
    String? customerCategory,
    String? sortBy,
    String? searchQuery,
  }) {
    return ProjectFilterState(
      phases: phases ?? this.phases,
      cities: cities ?? this.cities,
      priority: priority ?? this.priority,
      customerCategory: customerCategory ?? this.customerCategory,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class SiteManagerProjectsState {
  final ProjectTab selectedTab;
  final List<Project> allProjects;
  final ProjectFilterState filterState;

  const SiteManagerProjectsState({
    this.selectedTab = ProjectTab.all,
    this.allProjects = const [
      Project(
        id: 'Prj-0842',
        title: 'Goltsteins.Complex',
        company: 'Hochief AG',
        address: 'Goltsteinstraße 12, 50968 Köln',
        owner: 'Mesut Yilmaz',
        duration: 'Erection: Sept 18 – Sept 20 (2.5 days)',
        phase: ProjectPhase.erection,
        priority: ProjectPriority.high,
        status: ProjectStatus.inProgress,
        totalLoggedHours: 142.5,
        budgetHours: 160.0,
      ),
      Project(
        id: 'Prj-0842',
        title: 'Goltsteins.Complex',
        company: 'Hochief AG',
        address: 'Goltsteinstraße 12, 50968 Köln',
        owner: 'Mesut Yilmaz',
        duration: 'Dismantling: Sept 18 – Sept 20 (2.5 days)',
        phase: ProjectPhase.dismantling,
        priority: ProjectPriority.medium,
        status: ProjectStatus.notStarted,
        totalLoggedHours: 45.0,
        budgetHours: 80.0,
      ),
      Project(
        id: 'Prj-0842',
        title: 'Goltsteins.Complex',
        company: 'Hochief AG',
        address: 'Goltsteinstraße 12, 50968 Köln',
        owner: 'Mesut Yilmaz',
        duration: 'Inspection Due: Sept 18 – Sept 20 (2.5 days)',
        phase: ProjectPhase.standingScaffold,
        priority: ProjectPriority.medium,
        status: ProjectStatus.postponed,
        totalLoggedHours: 24.0,
        budgetHours: 30.0,
      ),
      Project(
        id: 'Prj-0842',
        title: 'Goltsteins.Complex',
        company: 'Hochief AG',
        address: 'Goltsteinstraße 12, 50968 Köln',
        owner: 'Mesut Yilmaz',
        duration: 'Finished On: Aug 28, 2026',
        phase: ProjectPhase.completed,
        priority: ProjectPriority.low,
        status: ProjectStatus.inProgress,
        totalLoggedHours: 210.0,
        budgetHours: 220.0,
      ),
      Project(
        id: 'Prj-0851',
        title: 'Riverside Tower',
        company: 'Hochief AG',
        address: 'Rheinstrasse 28, 50667 Köln',
        owner: 'Mesut Yilmaz',
        duration: 'Erection: Sept 20 – Sept 24 (4 days)',
        phase: ProjectPhase.erection,
        priority: ProjectPriority.low,
        status: ProjectStatus.inProgress,
        totalLoggedHours: 85.0,
        budgetHours: 120.0,
      ),
      Project(
        id: 'Prj-0858',
        title: 'Central Plaza',
        company: 'Hochief AG',
        address: 'Hohenzollernring 44, 50672 Köln',
        owner: 'Mesut Yilmaz',
        duration: 'Dismantling: Sept 21 – Sept 25 (4 days)',
        phase: ProjectPhase.dismantling,
        priority: ProjectPriority.high,
        status: ProjectStatus.notStarted,
        totalLoggedHours: 114.5,
        budgetHours: 100.0,
      ),
    ],
    this.filterState = const ProjectFilterState(),
  });

  List<Project> get filteredProjects {
    List<Project> list;
    switch (selectedTab) {
      case ProjectTab.all:
        list = allProjects;
      case ProjectTab.active:
        list = allProjects
            .where(
              (p) =>
                  p.status == ProjectStatus.inProgress ||
                  p.status == ProjectStatus.notStarted,
            )
            .toList();
      case ProjectTab.myProjects:
        list = allProjects.where((p) => p.owner == 'Mesut Yilmaz').toList();
      case ProjectTab.thisWeek:
        list = allProjects
            .where(
              (p) =>
                  p.phase == ProjectPhase.erection ||
                  p.phase == ProjectPhase.dismantling,
            )
            .toList();
      case ProjectTab.inspection:
        list = allProjects
            .where((p) => p.phase == ProjectPhase.standingScaffold)
            .toList();
    }

    if (filterState.searchQuery.isNotEmpty) {
      final q = filterState.searchQuery.toLowerCase();
      list = list
          .where(
            (p) =>
                p.title.toLowerCase().contains(q) ||
                p.company.toLowerCase().contains(q) ||
                p.address.toLowerCase().contains(q),
          )
          .toList();
    }

    return list;
  }

  SiteManagerProjectsState copyWith({
    ProjectTab? selectedTab,
    List<Project>? allProjects,
    ProjectFilterState? filterState,
  }) {
    return SiteManagerProjectsState(
      selectedTab: selectedTab ?? this.selectedTab,
      allProjects: allProjects ?? this.allProjects,
      filterState: filterState ?? this.filterState,
    );
  }
}

class SiteManagerProjectsNotifier extends Notifier<SiteManagerProjectsState> {
  @override
  SiteManagerProjectsState build() {
    return const SiteManagerProjectsState();
  }

  void selectTab(ProjectTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void setFilter({
    required List<String> phases,
    required List<String> cities,
    required String priority,
    required String customerCategory,
    required String sortBy,
  }) {
    state = state.copyWith(
      filterState: state.filterState.copyWith(
        phases: phases,
        cities: cities,
        priority: priority,
        customerCategory: customerCategory,
        sortBy: sortBy,
      ),
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      filterState: state.filterState.copyWith(searchQuery: query),
    );
  }

  void addProject(Project project) {
    state = state.copyWith(allProjects: [project, ...state.allProjects]);
  }
}

final siteManagerProjectsProvider =
    NotifierProvider<SiteManagerProjectsNotifier, SiteManagerProjectsState>(
  SiteManagerProjectsNotifier.new,
);
