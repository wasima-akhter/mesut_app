import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/utils/logger.dart';
import '../../../offline_sync/models/site_manager_sync_action.dart';
import '../../../offline_sync/providers/site_manager_sync_provider.dart';
import '../../data/repositories/project_measurements_repository_impl.dart';
import '../../domain/entities/project_measurement_entity.dart';
import 'project_measurements_state.dart';

class ProjectMeasurementsNotifier extends Notifier<ProjectMeasurementsState> {
  static const int _pageSize = 10;

  @override
  ProjectMeasurementsState build() => const ProjectMeasurementsState();

  /// Initial load or pull-to-refresh of measurements for [projectId].
  Future<void> loadInitial(String projectId) async {
    final isDifferentProject = state.projectId != projectId;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      projectId: projectId,
      items: isDifferentProject ? const [] : state.items,
      totalArea: isDifferentProject ? 0.0 : state.totalArea,
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
      AppLogger.error('Failed to load measurements',
          error: e, stackTrace: st, name: 'MEASUREMENTS');
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
      final newItems =
          response.items.where((m) => !existingIds.contains(m.id)).toList();
      final combined = [...state.items, ...newItems];
      final hasMore =
          nextPage < response.meta.totalPages && response.items.isNotEmpty;

      state = state.copyWith(
        isLoadingMore: false,
        items: combined,
        totalArea:
            response.totalArea > 0 ? response.totalArea : state.totalArea,
        page: nextPage,
        hasMore: hasMore,
      );
    } catch (e, st) {
      AppLogger.error('Failed to load more measurements',
          error: e, stackTrace: st, name: 'MEASUREMENTS');
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
    final payload = {
      'position': position,
      'length': length,
      'height': height,
      'quantity': quantity,
      'unit': unit,
      'remark': ?remark,
    };

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

      state = state.copyWith(
        isMutating: false,
        items: [created, ...state.items],
        totalArea: state.totalArea + created.calculatedArea,
      );
      return true;
    } catch (_) {
      final calculated = length * height * quantity;
      final localId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
      final offlineItem = ProjectMeasurementEntity(
        id: localId,
        projectId: state.projectId,
        position: position,
        length: length,
        height: height,
        quantity: quantity,
        unit: unit,
        remark: remark ?? '',
        area: calculated,
        createdAt: DateTime.now(),
      );

      await ref.read(siteManagerSyncProvider.notifier).enqueue(
            SiteManagerSyncAction(
              id: localId,
              actionType: SiteManagerSyncActionType.saveMeasurements,
              endpoint: ApiConstants.mobileProjectMeasurements(state.projectId),
              httpMethod: 'POST',
              projectId: state.projectId,
              displayTitle: 'Measurement: $position',
              createdAt: DateTime.now(),
              payload: payload,
            ),
          );

      state = state.copyWith(
        isMutating: false,
        items: [offlineItem, ...state.items],
        totalArea: state.totalArea + calculated,
      );
      return true;
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
    final payload = {
      'position': position,
      'length': length,
      'height': height,
      'quantity': quantity,
      'unit': unit,
      'remark': ?remark,
    };
    final effectiveProjectId = state.projectId.isNotEmpty
        ? state.projectId
        : (state.items.where((i) => i.id == measurementId).firstOrNull?.projectId ?? '');

    try {
      final repository = ref.read(projectMeasurementsRepositoryProvider);
      final updated = await repository.updateMeasurement(
        projectId: effectiveProjectId,
        measurementId: measurementId,
        position: position,
        length: length,
        height: height,
        quantity: quantity,
        unit: unit,
        remark: remark,
      );

      final updatedList =
          state.items.map((i) => i.id == measurementId ? updated : i).toList();
      state = state.copyWith(
        isMutating: false,
        items: updatedList,
        totalArea: updatedList.fold<double>(0.0, (s, i) => s + i.calculatedArea),
      );
      return true;
    } catch (_) {
      final calculated = length * height * quantity;
      final updatedList = state.items.map((i) {
        if (i.id != measurementId) return i;
        return i.copyWith(
          position: position,
          length: length,
          height: height,
          quantity: quantity,
          unit: unit,
          remark: remark ?? i.remark,
          area: calculated,
        );
      }).toList();

      await ref.read(siteManagerSyncProvider.notifier).enqueue(
            SiteManagerSyncAction(
              id: 'update_meas_${DateTime.now().millisecondsSinceEpoch}',
              actionType: SiteManagerSyncActionType.updateMeasurement,
              endpoint: ApiConstants.mobileProjectMeasurementById(
                effectiveProjectId,
                measurementId,
              ),
              httpMethod: 'PATCH',
              projectId: effectiveProjectId,
              displayTitle: 'Measurement: $position',
              createdAt: DateTime.now(),
              payload: payload,
            ),
          );

      state = state.copyWith(
        isMutating: false,
        items: updatedList,
        totalArea: updatedList.fold<double>(0.0, (s, i) => s + i.calculatedArea),
      );
      return true;
    }
  }

  /// Deletes a measurement item by ID with optimistic update.
  Future<bool> deleteMeasurement(String measurementId) async {
    final targetIndex = state.items.indexWhere((m) => m.id == measurementId);
    if (targetIndex == -1) return false;

    final targetItem = state.items[targetIndex];
    final effectiveProjectId = state.projectId.isNotEmpty
        ? state.projectId
        : targetItem.projectId;
    final updatedList =
        state.items.where((m) => m.id != measurementId).toList();
    final newTotalArea =
        (state.totalArea - targetItem.calculatedArea).clamp(0.0, double.infinity);

    state = state.copyWith(items: updatedList, totalArea: newTotalArea);

    try {
      final repository = ref.read(projectMeasurementsRepositoryProvider);
      await repository.deleteMeasurement(
        projectId: effectiveProjectId,
        measurementId: measurementId,
      );
      return true;
    } catch (_) {
      await ref.read(siteManagerSyncProvider.notifier).enqueue(
            SiteManagerSyncAction(
              id: 'delete_meas_${DateTime.now().millisecondsSinceEpoch}',
              actionType: SiteManagerSyncActionType.deleteMeasurement,
              endpoint: ApiConstants.mobileProjectMeasurementById(
                effectiveProjectId,
                measurementId,
              ),
              httpMethod: 'DELETE',
              projectId: effectiveProjectId,
              displayTitle: 'Delete Measurement',
              createdAt: DateTime.now(),
            ),
          );
      return true;
    }
  }
}

final projectMeasurementsProvider =
    NotifierProvider<ProjectMeasurementsNotifier, ProjectMeasurementsState>(
  ProjectMeasurementsNotifier.new,
);
