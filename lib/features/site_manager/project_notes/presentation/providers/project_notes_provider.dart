import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/utils/logger.dart';
import '../../../offline_sync/models/site_manager_sync_action.dart';
import '../../../offline_sync/providers/site_manager_sync_provider.dart';
import '../../data/models/project_note_model.dart';
import '../../data/repositories/project_notes_repository_impl.dart';
import '../../domain/entities/project_note_entity.dart';
import 'project_notes_state.dart';

class ProjectNotesNotifier extends Notifier<ProjectNotesState> {
  static const int _pageSize = 10;

  @override
  ProjectNotesState build() {
    return const ProjectNotesState();
  }

  /// Initial load or pull-to-refresh of notes for [projectId].
  Future<void> loadInitial(String projectId) async {
    final isDifferentProject = state.projectId != projectId;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      projectId: projectId,
      items: isDifferentProject ? const [] : state.items,
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
    final payload = {'category': category, 'content': content};

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
    } catch (_) {
      final localId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
      final offlineNote = ProjectNoteEntity(
        id: localId,
        projectId: state.projectId,
        category: ProjectNoteModel.parseCategory(category),
        content: content,
        createdAt: DateTime.now(),
      );

      final action = SiteManagerSyncAction(
        id: localId,
        actionType: SiteManagerSyncActionType.createNote,
        endpoint: ApiConstants.mobileProjectNotes(state.projectId),
        httpMethod: 'POST',
        projectId: state.projectId,
        displayTitle: 'Note: $category',
        createdAt: DateTime.now(),
        payload: payload,
      );
      await ref.read(siteManagerSyncProvider.notifier).enqueue(action);

      state = state.copyWith(
        isMutating: false,
        items: [offlineNote, ...state.items],
      );
      return true;
    }
  }

  /// Updates an existing note on the backend and updates local state.
  Future<bool> updateNote({
    required String noteId,
    required String category,
    required String content,
  }) async {
    state = state.copyWith(isMutating: true);
    final payload = {'category': category, 'content': content};
    final effectiveProjectId = state.projectId.isNotEmpty
        ? state.projectId
        : (state.items.where((i) => i.id == noteId).firstOrNull?.projectId ?? '');

    try {
      final repository = ref.read(projectNotesRepositoryProvider);
      final updated = await repository.updateNote(
        projectId: effectiveProjectId,
        noteId: noteId,
        category: category,
        content: content,
      );

      final updatedList = state.items.map((item) {
        return item.id == noteId ? updated : item;
      }).toList();

      state = state.copyWith(isMutating: false, items: updatedList);
      return true;
    } catch (_) {
      final updatedList = state.items.map((item) {
        if (item.id != noteId) return item;
        return item.copyWith(
          category: ProjectNoteModel.parseCategory(category),
          content: content,
        );
      }).toList();

      final action = SiteManagerSyncAction(
        id: 'update_note_${DateTime.now().millisecondsSinceEpoch}',
        actionType: SiteManagerSyncActionType.updateNote,
        endpoint: ApiConstants.mobileProjectNoteById(effectiveProjectId, noteId),
        httpMethod: 'PATCH',
        projectId: effectiveProjectId,
        displayTitle: 'Note: $category',
        createdAt: DateTime.now(),
        payload: payload,
      );
      await ref.read(siteManagerSyncProvider.notifier).enqueue(action);

      state = state.copyWith(isMutating: false, items: updatedList);
      return true;
    }
  }

  /// Deletes a note by ID with optimistic update.
  Future<bool> deleteNote(String noteId) async {
    final effectiveProjectId = state.projectId.isNotEmpty
        ? state.projectId
        : (state.items.where((i) => i.id == noteId).firstOrNull?.projectId ?? '');
    final updatedList = state.items.where((n) => n.id != noteId).toList();
    state = state.copyWith(items: updatedList);

    try {
      final repository = ref.read(projectNotesRepositoryProvider);
      await repository.deleteNote(
        projectId: effectiveProjectId,
        noteId: noteId,
      );
      return true;
    } catch (_) {
      final action = SiteManagerSyncAction(
        id: 'delete_note_${DateTime.now().millisecondsSinceEpoch}',
        actionType: SiteManagerSyncActionType.deleteNote,
        endpoint: ApiConstants.mobileProjectNoteById(effectiveProjectId, noteId),
        httpMethod: 'DELETE',
        projectId: effectiveProjectId,
        displayTitle: 'Delete Note',
        createdAt: DateTime.now(),
      );
      await ref.read(siteManagerSyncProvider.notifier).enqueue(action);
      return true;
    }
  }
}

final projectNotesProvider =
    NotifierProvider<ProjectNotesNotifier, ProjectNotesState>(
      ProjectNotesNotifier.new,
    );
