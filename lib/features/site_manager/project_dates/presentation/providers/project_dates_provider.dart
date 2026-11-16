import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/logger.dart';
import '../../../project_details/presentation/providers/project_details_provider.dart';
import '../../data/repositories/project_dates_repository_impl.dart';
import '../../domain/repositories/project_dates_repository.dart';
import 'project_dates_state.dart';

class ProjectDatesNotifier extends Notifier<ProjectDatesState> {
  @override
  ProjectDatesState build() {
    return const ProjectDatesState();
  }

  ProjectDatesRepository get _repository =>
      ref.read(projectDatesRepositoryProvider);

  /// Load phases / schedule data for [projectId].
  Future<void> loadInitial(String projectId, {bool isRefresh = false}) async {
    state = state.copyWith(
      isLoading: !isRefresh,
      clearError: true,
      projectId: projectId,
    );

    try {
      final list = await _repository.getProjectPhases(projectId);
      state = state.copyWith(isLoading: false, items: list, clearError: true);
    } catch (e, st) {
      AppLogger.error(
        'Failed to load project phase dates',
        error: e,
        stackTrace: st,
        name: 'DATES',
      );
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Update dates for a specific phase [phaseId] via PATCH /api/v1/mobile/projects/{projectId}/phases/{phaseId}/dates.
  Future<bool> updatePhaseDates({
    required String phaseId,
    required DateTime startDate,
    required DateTime endDate,
    required int durationDays,
    bool? safetyInspectionComplete,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final updated = await _repository.updatePhaseDates(
        projectId: state.projectId,
        phaseId: phaseId,
        startDate: startDate,
        endDate: endDate,
        durationDays: durationDays,
        safetyInspectionComplete: safetyInspectionComplete,
      );

      final updatedList = state.items.map((item) {
        if (item.id == phaseId || item.id == updated.id) {
          return updated;
        }
        return item;
      }).toList();

      state = state.copyWith(
        items: updatedList,
        isSaving: false,
        clearError: true,
      );

      // Refresh project overview details so all tabs reflect updated dates
      ref
          .read(projectDetailsProvider.notifier)
          .loadOverview(state.projectId, forceRefresh: true);

      return true;
    } catch (e, st) {
      AppLogger.error(
        'Failed to update phase dates',
        error: e,
        stackTrace: st,
        name: 'DATES',
      );
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }
}

final projectDatesProvider =
    NotifierProvider<ProjectDatesNotifier, ProjectDatesState>(
      ProjectDatesNotifier.new,
    );
