import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/employee_time_tracking_datasource.dart';
import '../../domain/entities/employee_time_tracking_entities.dart';

class EmployeeProjectGroup {
  final String id;
  final String name;
  final List<EmployeeAssignedProjectEntity> phases;

  EmployeeProjectGroup({
    required this.id,
    required this.name,
    required List<EmployeeAssignedProjectEntity> phases,
  }) : phases = List.unmodifiable(phases);

  String get displayName => name.isNotEmpty ? name : id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeProjectGroup &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'EmployeeProjectGroup(id: $id, name: $name, phases: ${phases.length})';
}

class EmployeeTimerProjectsState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<EmployeeAssignedProjectEntity> projectAssignments;
  final int page;
  final bool hasMore;

  const EmployeeTimerProjectsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.projectAssignments = const [],
    this.page = 1,
    this.hasMore = false,
  });

  List<EmployeeProjectGroup> get uniqueProjects {
    final map =
        <String, ({String name, List<EmployeeAssignedProjectEntity> phases})>{};
    for (final assignment in projectAssignments) {
      if (!map.containsKey(assignment.id)) {
        map[assignment.id] = (name: assignment.name, phases: [assignment]);
      } else {
        final existing = map[assignment.id]!;
        if (!existing.phases.any((p) => p.phaseType == assignment.phaseType)) {
          existing.phases.add(assignment);
        }
      }
    }
    return map.entries
        .map(
          (e) => EmployeeProjectGroup(
            id: e.key,
            name: e.value.name,
            phases: e.value.phases,
          ),
        )
        .toList();
  }

  EmployeeTimerProjectsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    List<EmployeeAssignedProjectEntity>? projectAssignments,
    int? page,
    bool? hasMore,
  }) {
    return EmployeeTimerProjectsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      projectAssignments: projectAssignments ?? this.projectAssignments,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class EmployeeTimerProjectsNotifier
    extends AutoDisposeNotifier<EmployeeTimerProjectsState> {
  EmployeeTimeTrackingDatasource get _datasource =>
      ref.read(employeeTimeTrackingDatasourceProvider);

  bool _mounted = true;

  @override
  EmployeeTimerProjectsState build() {
    _mounted = true;
    ref.onDispose(() {
      _mounted = false;
    });
    Future.microtask(loadInitial);
    return const EmployeeTimerProjectsState(isLoading: true);
  }

  Future<void> loadInitial() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _datasource.getProjects(page: 1, limit: 20);
      if (!_mounted) return;
      state = state.copyWith(
        isLoading: false,
        projectAssignments: list,
        page: 1,
        hasMore: list.length >= 20,
        clearError: true,
      );
    } catch (e) {
      if (!_mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async => loadInitial();

  Future<void> loadMore() async {
    if (!_mounted || state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }
    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true);
    try {
      final more = await _datasource.getProjects(page: nextPage, limit: 20);
      if (!_mounted) return;
      state = state.copyWith(
        isLoadingMore: false,
        projectAssignments: [...state.projectAssignments, ...more],
        page: nextPage,
        hasMore: more.length >= 20,
      );
    } catch (_) {
      if (!_mounted) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final employeeTimerProjectsProvider = NotifierProvider.autoDispose<
    EmployeeTimerProjectsNotifier, EmployeeTimerProjectsState>(
  EmployeeTimerProjectsNotifier.new,
);
