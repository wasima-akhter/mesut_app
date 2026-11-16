import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/logger.dart';
import '../../data/repositories/project_measurements_repository_impl.dart';
import 'project_measurements_state.dart';

class ProjectMeasurementsNotifier extends Notifier<ProjectMeasurementsState> {
  static const int _pageSize = 10;

  @override
  ProjectMeasurementsState build() {
    return const ProjectMeasurementsState();
  }

  /// Initial load or pull-to-refresh of measurements for [projectId].
  Future<void> loadInitial(String projectId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      projectId: projectId,
      page: 1,
    );

    try {
      final repository = ref.read(projectMeasurementsRepositoryProvider);
      final response = await repository.getProjectMeasurements(
        projectId: projectId,
        page: 1,
        limit: _pageSize,
      );

      final hasMore =
          response.meta.totalPages > 1 && response.items.length >= _pageSize;

      state = state.copyWith(
        isLoading: false,
        items: response.items,
        totalArea: response.totalArea,
        page: 1,
        hasMore: hasMore,
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to load measurements',
        error: e,
        stackTrace: st,
        name: 'MEASUREMENTS',
      );
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Pagination loader: fetches the next page and appends to the current list.
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true);

    try {
      final repository = ref.read(projectMeasurementsRepositoryProvider);
      final response = await repository.getProjectMeasurements(
        projectId: state.projectId,
        page: nextPage,
        limit: _pageSize,
      );

      final existingIds = state.items.map((m) => m.id).toSet();
      final newItems = response.items
          .where((m) => !existingIds.contains(m.id))
          .toList();
      final combined = [...state.items, ...newItems];
      final hasMore =
          nextPage < response.meta.totalPages && response.items.isNotEmpty;

      state = state.copyWith(
        isLoadingMore: false,
        items: combined,
        totalArea: response.totalArea > 0
            ? response.totalArea
            : state.totalArea,
        page: nextPage,
        hasMore: hasMore,
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to load more measurements',
        error: e,
        stackTrace: st,
        name: 'MEASUREMENTS',
      );
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Creates a new measurement item on the backend and updates local state.
  Future<bool> createMeasurement({
    required String position,
    required double length,
    required double height,
    required int quantity,
    required String unit,
    String? remark,
  }) async {
    state = state.copyWith(isMutating: true);
    try {
      final repository = ref.read(projectMeasurementsRepositoryProvider);
      final created = await repository.createMeasurement(
        projectId: state.projectId,
        position: position,
        length: length,
        height: height,
        quantity: quantity,
        unit: unit,
        remark: remark,
      );

      final updatedItems = [created, ...state.items];
      final newTotalArea = state.totalArea + created.calculatedArea;

      state = state.copyWith(
        isMutating: false,
        items: updatedItems,
        totalArea: newTotalArea,
      );
      return true;
    } catch (e, st) {
      AppLogger.error(
        'Failed to create measurement',
        error: e,
        stackTrace: st,
        name: 'MEASUREMENTS',
      );
      state = state.copyWith(isMutating: false);
      return false;
    }
  }

  /// Updates an existing measurement item on the backend and updates local state.
  Future<bool> updateMeasurement({
    required String measurementId,
    required String position,
    required double length,
    required double height,
    required int quantity,
    required String unit,
    String? remark,
  }) async {
    state = state.copyWith(isMutating: true);
    try {
      final repository = ref.read(projectMeasurementsRepositoryProvider);
      final updated = await repository.updateMeasurement(
        projectId: state.projectId,
        measurementId: measurementId,
        position: position,
        length: length,
        height: height,
        quantity: quantity,
        unit: unit,
        remark: remark,
      );

      final updatedList = state.items.map((item) {
        return item.id == measurementId ? updated : item;
      }).toList();

      final newTotalArea = updatedList.fold<double>(
        0.0,
        (sum, item) => sum + item.calculatedArea,
      );

      state = state.copyWith(
        isMutating: false,
        items: updatedList,
        totalArea: newTotalArea,
      );
      return true;
    } catch (e, st) {
      AppLogger.error(
        'Failed to update measurement',
        error: e,
        stackTrace: st,
        name: 'MEASUREMENTS',
      );
      state = state.copyWith(isMutating: false);
      return false;
    }
  }

  /// Deletes a measurement item by ID with optimistic update and rollback on failure.
  Future<bool> deleteMeasurement(String measurementId) async {
    final previousItems = state.items;
    final targetIndex = state.items.indexWhere((m) => m.id == measurementId);
    if (targetIndex == -1) return false;

    final targetItem = state.items[targetIndex];
    final updatedList = state.items
        .where((m) => m.id != measurementId)
        .toList();
    final newTotalArea = (state.totalArea - targetItem.calculatedArea).clamp(
      0.0,
      double.infinity,
    );

    // Optimistic removal
    state = state.copyWith(items: updatedList, totalArea: newTotalArea);

    try {
      final repository = ref.read(projectMeasurementsRepositoryProvider);
      final success = await repository.deleteMeasurement(
        projectId: state.projectId,
        measurementId: measurementId,
      );

      if (!success) {
        state = state.copyWith(items: previousItems);
        return false;
      }
      return true;
    } catch (e, st) {
      AppLogger.error(
        'Failed to delete measurement',
        error: e,
        stackTrace: st,
        name: 'MEASUREMENTS',
      );
      state = state.copyWith(items: previousItems);
      return false;
    }
  }
}

final projectMeasurementsProvider =
    NotifierProvider<ProjectMeasurementsNotifier, ProjectMeasurementsState>(
      ProjectMeasurementsNotifier.new,
    );
