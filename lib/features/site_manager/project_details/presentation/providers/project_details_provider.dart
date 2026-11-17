import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/states/app_data_state.dart';
import '../../../offline_sync/providers/site_manager_sync_provider.dart';
import '../../../offline_sync/services/site_manager_cache_service.dart';
import '../../../projects/enums.dart';
import '../../data/models/project_details_model.dart';
import '../../data/repositories/project_details_repository_impl.dart';
import '../../domain/repositories/project_details_repository.dart';
import 'project_details_state.dart';

export 'project_details_state.dart';

class ProjectDetailsNotifier extends Notifier<ProjectDetailsState> {
  ProjectDetailsRepository get _repository =>
      ref.read(projectDetailsRepositoryProvider);
  SiteManagerCacheService get _cacheService =>
      ref.read(siteManagerCacheServiceProvider);

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
        clearDetails: true,
      );
      return;
    }

    final isDifferentProject = state.projectId != projectId ||
        (state.details != null && state.details!.id != projectId);

    if (isDifferentProject) {
      // 1. Check if the newly requested project has cached details solely for this project
      final cachedJson = _cacheService.getCachedProjectDetails(projectId);
      if (cachedJson != null) {
        try {
          final cachedModel = ProjectDetailsModel.fromJson(cachedJson);
          state = ProjectDetailsState(
            projectId: projectId,
            details: cachedModel,
            overviewStatus: AppDataStatus.success,
            selectedTab: state.selectedTab,
          );
        } catch (_) {
          state = ProjectDetailsState(
            projectId: projectId,
            overviewStatus: AppDataStatus.loading,
            selectedTab: state.selectedTab,
          );
        }
      } else {
        // No cached details for this project -> show placeholder/loading, never leak previous project!
        state = ProjectDetailsState(
          projectId: projectId,
          overviewStatus: AppDataStatus.loading,
          selectedTab: state.selectedTab,
        );
      }
    } else {
      final hasData = state.details != null && state.details!.id == projectId;
      state = state.copyWith(
        projectId: projectId,
        overviewStatus: (hasData && forceRefresh)
            ? AppDataStatus.refreshing
            : AppDataStatus.loading,
        clearError: true,
      );
    }

    try {
      final details = await _repository.getProjectDetails(projectId);
      state = state.copyWith(
        projectId: projectId,
        overviewStatus: AppDataStatus.success,
        details: details,
        clearError: true,
      );
    } catch (e, st) {
      debugPrint('[ProjectDetails] Error loading project $projectId: $e\n$st');
      final hasValidDataForThisProject =
          state.details != null && state.details!.id == projectId;

      state = state.copyWith(
        projectId: projectId,
        overviewStatus: hasValidDataForThisProject
            ? AppDataStatus.success
            : AppDataStatus.error,
        clearDetails: !hasValidDataForThisProject,
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
