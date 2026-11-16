import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/pagination/paginated_response.dart';
import '../../../../../core/widgets/states/app_data_state.dart';
import '../../data/repositories/projects_repository_impl.dart';
import '../../domain/entities/project_phase_card_entity.dart';
import '../../domain/repositories/projects_repository.dart';
import '../../enums.dart';

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
    this.sortBy = 'Newest',
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
  final ProjectFilterState filterState;
  final AppDataStatus status;
  final List<ProjectPhaseCardEntity> items;
  final PaginationMeta meta;
  final bool isLoadingMore;
  final String? errorMessage;
  final Object? errorObject;

  const SiteManagerProjectsState({
    this.selectedTab = ProjectTab.all,
    this.filterState = const ProjectFilterState(),
    this.status = AppDataStatus.initial,
    this.items = const [],
    this.meta = const PaginationMeta(total: 0, totalPages: 1, currentPage: 1),
    this.isLoadingMore = false,
    this.errorMessage,
    this.errorObject,
  });

  bool get hasMore => meta.hasMore;
  bool get isEmpty => items.isEmpty;

  SiteManagerProjectsState copyWith({
    ProjectTab? selectedTab,
    ProjectFilterState? filterState,
    AppDataStatus? status,
    List<ProjectPhaseCardEntity>? items,
    PaginationMeta? meta,
    bool? isLoadingMore,
    String? errorMessage,
    Object? errorObject,
    bool clearError = false,
  }) {
    return SiteManagerProjectsState(
      selectedTab: selectedTab ?? this.selectedTab,
      filterState: filterState ?? this.filterState,
      status: status ?? this.status,
      items: items ?? this.items,
      meta: meta ?? this.meta,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorObject: clearError ? null : (errorObject ?? this.errorObject),
    );
  }
}

class SiteManagerProjectsNotifier extends Notifier<SiteManagerProjectsState> {
  ProjectsRepository get _repository => ref.read(projectsRepositoryProvider);

  @override
  SiteManagerProjectsState build() {
    Future.microtask(() => loadInitial());
    return const SiteManagerProjectsState();
  }

  String _mapTab(ProjectTab tab) {
    switch (tab) {
      case ProjectTab.all:
        return 'ALL';
      case ProjectTab.active:
        return 'ACTIVE';
      case ProjectTab.myProjects:
        return 'MY_PROJECTS';
      case ProjectTab.thisWeek:
        return 'THIS_WEEK';
      case ProjectTab.inspection:
        return 'INSPECTION';
    }
  }

  (List<String> phaseTypes, List<String> phaseStatuses) _mapPhases(
      List<String> phases) {
    final types = <String>[];
    final statuses = <String>[];
    for (final p in phases) {
      final norm = p.trim().toLowerCase();
      if (norm.contains('erection')) types.add('ERECTION');
      if (norm.contains('dismantling')) types.add('DISMANTLING');
      if (norm.contains('standing')) types.add('STANDING');
      if (norm.contains('maintenance')) types.add('MAINTENANCE');
      if (norm.contains('completed')) statuses.add('COMPLETED');
      if (norm.contains('preconstruction') || norm.contains('enquiry')) {
        statuses.add('ENQUIRY');
      }
    }
    return (types, statuses);
  }

  String _mapSortBy(String sortBy) {
    final norm = sortBy.trim().toLowerCase();
    if (norm.contains('inspection')) return 'NEXT_INSPECTION';
    if (norm.contains('name') || norm.contains('a-z')) return 'NAME_AZ';
    return 'NEWEST';
  }

  List<String>? _mapPriorities(String priority) {
    if (priority == 'All' || priority.isEmpty) return null;
    return [priority.toUpperCase()];
  }

  List<String>? _mapCategories(String category) {
    if (category == 'All' || category.isEmpty) return null;
    return [category.toUpperCase()];
  }

  Future<void> loadInitial({bool isRefresh = false}) async {
    state = state.copyWith(
      status: isRefresh ? AppDataStatus.refreshing : AppDataStatus.loading,
      clearError: true,
    );

    final (phaseTypes, phaseStatuses) = _mapPhases(state.filterState.phases);

    try {
      final response = await _repository.getProjects(
        tab: _mapTab(state.selectedTab),
        phaseTypes: phaseTypes.isNotEmpty ? phaseTypes : null,
        phaseStatuses: phaseStatuses.isNotEmpty ? phaseStatuses : null,
        search: state.filterState.searchQuery.isNotEmpty
            ? state.filterState.searchQuery
            : (state.filterState.cities.isNotEmpty
                ? state.filterState.cities.first
                : null),
        priorities: _mapPriorities(state.filterState.priority),
        categories: _mapCategories(state.filterState.customerCategory),
        sortBy: _mapSortBy(state.filterState.sortBy),
        page: 1,
        limit: 10,
      );

      state = state.copyWith(
        status: response.items.isEmpty
            ? AppDataStatus.empty
            : AppDataStatus.success,
        items: response.items,
        meta: response.meta,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: AppDataStatus.error,
        errorMessage: e.toString(),
        errorObject: e,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.meta.currentPage + 1;
    final (phaseTypes, phaseStatuses) = _mapPhases(state.filterState.phases);

    try {
      final response = await _repository.getProjects(
        tab: _mapTab(state.selectedTab),
        phaseTypes: phaseTypes.isNotEmpty ? phaseTypes : null,
        phaseStatuses: phaseStatuses.isNotEmpty ? phaseStatuses : null,
        search: state.filterState.searchQuery.isNotEmpty
            ? state.filterState.searchQuery
            : null,
        priorities: _mapPriorities(state.filterState.priority),
        categories: _mapCategories(state.filterState.customerCategory),
        sortBy: _mapSortBy(state.filterState.sortBy),
        page: nextPage,
        limit: 10,
      );

      final combined = [...state.items, ...response.items];
      state = state.copyWith(
        items: combined,
        meta: response.meta,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void selectTab(ProjectTab tab) {
    if (state.selectedTab == tab) return;
    state = state.copyWith(selectedTab: tab);
    loadInitial();
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
    loadInitial();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      filterState: state.filterState.copyWith(searchQuery: query.trim()),
    );
    loadInitial();
  }
}

final siteManagerProjectsProvider =
    NotifierProvider<SiteManagerProjectsNotifier, SiteManagerProjectsState>(
  SiteManagerProjectsNotifier.new,
);
