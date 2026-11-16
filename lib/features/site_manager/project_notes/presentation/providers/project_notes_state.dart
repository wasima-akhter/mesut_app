import '../../domain/entities/project_note_entity.dart';

class ProjectNotesState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool isMutating;
  final String? errorMessage;
  final List<ProjectNoteEntity> items;
  final int page;
  final bool hasMore;
  final String projectId;

  const ProjectNotesState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isMutating = false,
    this.errorMessage,
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.projectId = '',
  });

  bool get isEmpty => !isLoading && items.isEmpty;

  ProjectNotesState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isMutating,
    String? errorMessage,
    bool clearError = false,
    List<ProjectNoteEntity>? items,
    int? page,
    bool? hasMore,
    String? projectId,
  }) {
    return ProjectNotesState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      projectId: projectId ?? this.projectId,
    );
  }
}
