import '../../../../../core/widgets/states/app_data_state.dart';
import '../../../projects/enums.dart';
import '../../domain/entities/project_task_entity.dart';

class ProjectTasksState {
  final String projectId;
  final TaskStatusTab selectedTab;
  final AppDataStatus status;
  final List<ProjectTaskEntity> openTasks;
  final List<ProjectTaskEntity> completedTasks;
  final ProjectTasksPaginationMeta openMeta;
  final ProjectTasksPaginationMeta completedMeta;
  final bool isLoadingMore;
  final String? errorMessage;
  final Object? errorObject;

  const ProjectTasksState({
    this.projectId = '',
    this.selectedTab = TaskStatusTab.open,
    this.status = AppDataStatus.initial,
    this.openTasks = const [],
    this.completedTasks = const [],
    this.openMeta = const ProjectTasksPaginationMeta(),
    this.completedMeta = const ProjectTasksPaginationMeta(),
    this.isLoadingMore = false,
    this.errorMessage,
    this.errorObject,
  });

  List<ProjectTaskEntity> get currentTasks =>
      selectedTab == TaskStatusTab.open ? openTasks : completedTasks;

  int get openCount => openMeta.total > 0 ? openMeta.total : openTasks.length;

  int get completedCount =>
      completedMeta.total > 0 ? completedMeta.total : completedTasks.length;

  bool get hasMoreForCurrentTab {
    final meta = selectedTab == TaskStatusTab.open ? openMeta : completedMeta;
    return meta.hasMore;
  }

  bool get isEmpty => currentTasks.isEmpty;

  ProjectTasksState copyWith({
    String? projectId,
    TaskStatusTab? selectedTab,
    AppDataStatus? status,
    List<ProjectTaskEntity>? openTasks,
    List<ProjectTaskEntity>? completedTasks,
    ProjectTasksPaginationMeta? openMeta,
    ProjectTasksPaginationMeta? completedMeta,
    bool? isLoadingMore,
    String? errorMessage,
    Object? errorObject,
    bool clearError = false,
  }) {
    return ProjectTasksState(
      projectId: projectId ?? this.projectId,
      selectedTab: selectedTab ?? this.selectedTab,
      status: status ?? this.status,
      openTasks: openTasks ?? this.openTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      openMeta: openMeta ?? this.openMeta,
      completedMeta: completedMeta ?? this.completedMeta,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorObject: clearError ? null : (errorObject ?? this.errorObject),
    );
  }
}
