import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/states/app_data_state.dart';
import '../../../projects/enums.dart';
import '../../data/repositories/project_details_repository_impl.dart';
import '../../domain/repositories/project_details_repository.dart';
import 'project_details_state.dart';

export 'project_details_state.dart';

class ProjectDetailsNotifier extends Notifier<ProjectDetailsState> {
  ProjectDetailsRepository get _repository =>
      ref.read(projectDetailsRepositoryProvider);

  @override
  ProjectDetailsState build() {
    return const ProjectDetailsState(overviewStatus: AppDataStatus.loading);
  }

  Future<void> loadOverview(
    String projectId, {
    bool forceRefresh = false,
  }) async {
    if (projectId.isEmpty) {
      debugPrint('[ProjectDetails] loadOverview skipped: empty projectId');
      state = state.copyWith(
        overviewStatus: AppDataStatus.empty,
        clearError: true,
      );
      return;
    }

    final hasData = state.details != null;
    debugPrint(
      '[ProjectDetails] loadOverview starting for: $projectId (hasData: $hasData, forceRefresh: $forceRefresh)',
    );
    state = state.copyWith(
      projectId: projectId,
      overviewStatus: (hasData && forceRefresh)
          ? AppDataStatus.refreshing
          : AppDataStatus.loading,
      clearError: true,
    );

    try {
      final details = await _repository.getProjectDetails(projectId);
      state = state.copyWith(
        overviewStatus: AppDataStatus.success,
        details: details,
        clearError: true,
      );
    } catch (e, st) {
      debugPrint('[ProjectDetails] Error loading project $projectId: $e\n$st');
      state = state.copyWith(
        overviewStatus: AppDataStatus.error,
        errorMessage: e.toString(),
        errorObject: e,
      );
    }
  }

  Future<void> load(String projectId, {bool forceRefresh = false}) =>
      loadOverview(projectId, forceRefresh: forceRefresh);

  Future<void> refresh() => loadOverview(state.projectId, forceRefresh: true);

  Future<void> retry() => loadOverview(state.projectId, forceRefresh: true);

  void selectTab(ProjectDetailsTab tab) {
    if (state.selectedTab == tab) return;
    state = state.copyWith(selectedTab: tab);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final projectDetailsProvider =
    NotifierProvider<ProjectDetailsNotifier, ProjectDetailsState>(
  ProjectDetailsNotifier.new,
);
