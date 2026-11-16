import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/logger.dart';
import '../../data/repositories/project_notes_repository_impl.dart';
import 'project_notes_state.dart';

class ProjectNotesNotifier extends Notifier<ProjectNotesState> {
  static const int _pageSize = 10;

  @override
  ProjectNotesState build() {
    return const ProjectNotesState();
  }

  /// Initial load or pull-to-refresh of notes for [projectId].
  Future<void> loadInitial(String projectId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      projectId: projectId,
      page: 1,
    );

    try {
      final repository = ref.read(projectNotesRepositoryProvider);
      final response = await repository.getProjectNotes(
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
        'Failed to load project notes',
        error: e,
        stackTrace: st,
        name: 'NOTES',
      );
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Pagination loader: fetches the next page and appends to current list.
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true);

    try {
      final repository = ref.read(projectNotesRepositoryProvider);
      final response = await repository.getProjectNotes(
        projectId: state.projectId,
        page: nextPage,
        limit: _pageSize,
      );

      final existingIds = state.items.map((n) => n.id).toSet();
      final newItems = response.items
          .where((n) => !existingIds.contains(n.id))
          .toList();
      final combined = [...state.items, ...newItems];
      final hasMore =
          nextPage < response.meta.totalPages && response.items.isNotEmpty;

      state = state.copyWith(
        isLoadingMore: false,
        items: combined,
        page: nextPage,
        hasMore: hasMore,
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to load more project notes',
        error: e,
        stackTrace: st,
        name: 'NOTES',
      );
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Creates a new note on the backend and updates local state.
  Future<bool> createNote({
    required String category,
    required String content,
  }) async {
    state = state.copyWith(isMutating: true);
    try {
      final repository = ref.read(projectNotesRepositoryProvider);
      final created = await repository.createNote(
        projectId: state.projectId,
        category: category,
        content: content,
      );

      state = state.copyWith(
        isMutating: false,
        items: [created, ...state.items],
      );
      return true;
    } catch (e, st) {
      AppLogger.error(
        'Failed to create project note',
        error: e,
        stackTrace: st,
        name: 'NOTES',
      );
      state = state.copyWith(isMutating: false);
      return false;
    }
  }

  /// Updates an existing note on the backend and updates local state.
  Future<bool> updateNote({
    required String noteId,
    required String category,
    required String content,
  }) async {
    state = state.copyWith(isMutating: true);
    try {
      final repository = ref.read(projectNotesRepositoryProvider);
      final updated = await repository.updateNote(
        projectId: state.projectId,
        noteId: noteId,
        category: category,
        content: content,
      );

      final updatedList = state.items.map((item) {
        return item.id == noteId ? updated : item;
      }).toList();

      state = state.copyWith(isMutating: false, items: updatedList);
      return true;
    } catch (e, st) {
      AppLogger.error(
        'Failed to update project note',
        error: e,
        stackTrace: st,
        name: 'NOTES',
      );
      state = state.copyWith(isMutating: false);
      return false;
    }
  }

  /// Deletes a note by ID with optimistic update and rollback on failure.
  Future<bool> deleteNote(String noteId) async {
    final previousItems = state.items;
    final updatedList = state.items.where((n) => n.id != noteId).toList();

    // Optimistic removal
    state = state.copyWith(items: updatedList);

    try {
      final repository = ref.read(projectNotesRepositoryProvider);
      final success = await repository.deleteNote(
        projectId: state.projectId,
        noteId: noteId,
      );

      if (!success) {
        state = state.copyWith(items: previousItems);
        return false;
      }
      return true;
    } catch (e, st) {
      AppLogger.error(
        'Failed to delete project note',
        error: e,
        stackTrace: st,
        name: 'NOTES',
      );
      state = state.copyWith(items: previousItems);
      return false;
    }
  }
}

final projectNotesProvider =
    NotifierProvider<ProjectNotesNotifier, ProjectNotesState>(
      ProjectNotesNotifier.new,
    );
