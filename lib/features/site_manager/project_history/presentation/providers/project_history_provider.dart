import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/logger.dart';
import '../../data/repositories/project_history_repository_impl.dart';
import 'project_history_state.dart';

class ProjectHistoryNotifier extends Notifier<ProjectHistoryState> {
  static const int _pageSize = 10;

  @override
  ProjectHistoryState build() {
    return const ProjectHistoryState();
  }

  /// Initial load or pull-to-refresh of audit log history for [projectId].
  Future<void> loadInitial(String projectId, {bool isRefresh = false}) async {
    final isDifferentProject = state.projectId != projectId;

    state = state.copyWith(
      isLoading: isDifferentProject || !isRefresh,
      clearError: true,
      projectId: projectId,
      items: isDifferentProject ? const [] : state.items,
      page: 1,
    );

    try {
      final repository = ref.read(projectHistoryRepositoryProvider);
      final response = await repository.getProjectHistory(
        projectId: projectId,
        page: 1,
        limit: _pageSize,
      );

      final hasMore =
          response.meta.totalPages > 1 && response.items.length >= _pageSize;

      state = state.copyWith(
        isLoading: false,
        items: response.items,
        page: 1,
        hasMore: hasMore,
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to load project history',
        error: e,
        stackTrace: st,
        name: 'HISTORY',
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
      final repository = ref.read(projectHistoryRepositoryProvider);
      final response = await repository.getProjectHistory(
        projectId: state.projectId,
        page: nextPage,
        limit: _pageSize,
      );

      final hasMore = response.meta.totalPages > nextPage &&
          response.items.length >= _pageSize;

      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...response.items],
        page: nextPage,
        hasMore: hasMore,
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to load more project history',
        error: e,
        stackTrace: st,
        name: 'HISTORY',
      );
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final projectHistoryProvider =
    NotifierProvider<ProjectHistoryNotifier, ProjectHistoryState>(
  ProjectHistoryNotifier.new,
);
