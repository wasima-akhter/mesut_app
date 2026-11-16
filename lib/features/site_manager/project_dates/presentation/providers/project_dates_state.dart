import '../../domain/entities/project_phase_dates_entity.dart';

class ProjectDatesState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final List<ProjectPhaseDateItemEntity> items;
  final String projectId;

  const ProjectDatesState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.items = const [],
    this.projectId = '',
  });

  bool get isEmpty => !isLoading && items.isEmpty;

  ProjectDatesState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    List<ProjectPhaseDateItemEntity>? items,
    String? projectId,
  }) {
    return ProjectDatesState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      items: items ?? this.items,
      projectId: projectId ?? this.projectId,
    );
  }
}
