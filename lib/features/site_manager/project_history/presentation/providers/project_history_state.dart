import '../../domain/entities/project_history_entity.dart';

class ProjectHistoryState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<ProjectHistoryEntity> items;
  final int page;
  final bool hasMore;
  final String projectId;

  const ProjectHistoryState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.projectId = '',
  });

  bool get isEmpty => !isLoading && items.isEmpty;

  ProjectHistoryState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    List<ProjectHistoryEntity>? items,
    int? page,
    bool? hasMore,
    String? projectId,
  }) {
    return ProjectHistoryState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      projectId: projectId ?? this.projectId,
    );
  }
}
