import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/widgets/states/app_data_state.dart';
import '../../../offline_sync/models/site_manager_sync_action.dart';
import '../../../offline_sync/providers/site_manager_sync_provider.dart';
import '../../../projects/enums.dart';
import '../../data/repositories/project_tasks_repository_impl.dart';
import '../../domain/entities/project_task_entity.dart';
import '../../domain/repositories/project_tasks_repository.dart';
import 'project_tasks_state.dart';

export 'project_tasks_state.dart';

class ProjectTasksNotifier extends Notifier<ProjectTasksState> {
  ProjectTasksRepository get _repository =>
      ref.read(projectTasksRepositoryProvider);

  @override
  ProjectTasksState build() {
    return const ProjectTasksState();
  }

  Future<void> loadInitial(
    String projectId, {
    bool isRefresh = false,
  }) async {
    if (projectId.isEmpty) {
      state = state.copyWith(status: AppDataStatus.empty, clearError: true);
      return;
    }

    final isDifferentProject = state.projectId != projectId;
    final hasData = !isDifferentProject && state.currentTasks.isNotEmpty;
    state = state.copyWith(
      projectId: projectId,
      status: (hasData && isRefresh)
          ? AppDataStatus.refreshing
          : AppDataStatus.loading,
      openTasks: isDifferentProject ? const [] : state.openTasks,
      completedTasks: isDifferentProject ? const [] : state.completedTasks,
      clearError: true,
    );

    try {
      final result = await _repository.getProjectTasks(
        projectId: projectId,
        page: 1,
        limit: 10,
      );

      final isCurrentEmpty = state.selectedTab == TaskStatusTab.open
          ? result.open.isEmpty
          : result.completed.isEmpty;

      state = state.copyWith(
        status: isCurrentEmpty ? AppDataStatus.empty : AppDataStatus.success,
        openTasks: result.open,
        completedTasks: result.completed,
        openMeta: result.meta,
        completedMeta: result.meta,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: AppDataStatus.error,
        errorMessage: e.toString(),
        errorObject: e,
        isLoadingMore: false,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMoreForCurrentTab) return;
    if (state.projectId.isEmpty) return;

    state = state.copyWith(isLoadingMore: true);

    final isTabOpen = state.selectedTab == TaskStatusTab.open;
    final activeMeta = isTabOpen ? state.openMeta : state.completedMeta;
    final nextPage = activeMeta.currentPage + 1;
    final statusParam = isTabOpen ? 'OPEN' : 'COMPLETED';

    try {
      final result = await _repository.getProjectTasks(
        projectId: state.projectId,
        status: statusParam,
        page: nextPage,
        limit: 10,
      );

      if (isTabOpen) {
        state = state.copyWith(
          openTasks: [...state.openTasks, ...result.open],
          openMeta: result.meta,
          isLoadingMore: false,
        );
      } else {
        state = state.copyWith(
          completedTasks: [...state.completedTasks, ...result.completed],
          completedMeta: result.meta,
          isLoadingMore: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<bool> createTask({
    required String projectId,
    required String description,
    required String employeeId,
    required ProjectPriority priority,
    DateTime? dueDate,
  }) async {
    final priorityStr = priority == ProjectPriority.high
        ? 'HIGH'
        : priority == ProjectPriority.low
            ? 'LOW'
            : 'MEDIUM';

    try {
      final createdTask = await _repository.createProjectTask(
        projectId: projectId,
        description: description,
        employeeId: employeeId,
        priority: priorityStr,
        dueDate: dueDate,
      );

      state = state.copyWith(
        openTasks: [createdTask, ...state.openTasks],
        status: AppDataStatus.success,
      );
      return true;
    } catch (e) {
      final localId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
      final offlineTask = ProjectTaskEntity(
        id: localId,
        projectId: projectId,
        description: description,
        priority: priority,
        isCompleted: false,
        dueDate: dueDate,
      );
      final action = SiteManagerSyncAction(
        id: localId,
        actionType: SiteManagerSyncActionType.createTask,
        endpoint: ApiConstants.mobileProjectTasks(projectId),
        httpMethod: 'POST',
        projectId: projectId,
        displayTitle: 'Task: $description',
        createdAt: DateTime.now(),
        payload: {
          'description': description,
          'employeeId': employeeId,
          'priority': priorityStr,
          if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        },
      );
      await ref.read(siteManagerSyncProvider.notifier).enqueue(action);
      state = state.copyWith(
        openTasks: [offlineTask, ...state.openTasks],
        status: AppDataStatus.success,
      );
      return true;
    }
  }

  void selectTaskTab(TaskStatusTab tab) {
    if (state.selectedTab == tab) return;

    final targetList = tab == TaskStatusTab.open
        ? state.openTasks
        : state.completedTasks;

    state = state.copyWith(
      selectedTab: tab,
      status: targetList.isEmpty ? AppDataStatus.empty : AppDataStatus.success,
    );
  }

  Future<void> toggleTask(String taskId) async {
    final openIndex = state.openTasks.indexWhere((t) => t.id == taskId);
    final completedIndex =
        state.completedTasks.indexWhere((t) => t.id == taskId);
    if (openIndex == -1 && completedIndex == -1) return;

    if (openIndex != -1) {
      final task = state.openTasks[openIndex];
      final newOpen = List<ProjectTaskEntity>.from(state.openTasks)..removeAt(openIndex);
      final newCompleted = [task.copyWith(isCompleted: true), ...state.completedTasks];
      state = state.copyWith(
        openTasks: newOpen,
        completedTasks: newCompleted,
        status: (state.selectedTab == TaskStatusTab.open && newOpen.isEmpty)
            ? AppDataStatus.empty
            : AppDataStatus.success,
      );
    } else {
      final task = state.completedTasks[completedIndex];
      final newCompleted = List<ProjectTaskEntity>.from(state.completedTasks)..removeAt(completedIndex);
      final newOpen = [task.copyWith(isCompleted: false), ...state.openTasks];
      state = state.copyWith(
        openTasks: newOpen,
        completedTasks: newCompleted,
        status: (state.selectedTab == TaskStatusTab.completed && newCompleted.isEmpty)
            ? AppDataStatus.empty
            : AppDataStatus.success,
      );
    }

    try {
      final updated = await _repository.toggleProjectTask(taskId);
      if (updated.isCompleted) {
        state = state.copyWith(
          completedTasks: state.completedTasks.map((t) => t.id == taskId ? updated : t).toList(),
        );
      } else {
        state = state.copyWith(
          openTasks: state.openTasks.map((t) => t.id == taskId ? updated : t).toList(),
        );
      }
    } catch (_) {
      final action = SiteManagerSyncAction(
        id: 'toggle_${DateTime.now().millisecondsSinceEpoch}',
        actionType: SiteManagerSyncActionType.toggleTask,
        endpoint: ApiConstants.mobileTaskToggle(taskId),
        httpMethod: 'PATCH',
        projectId: state.projectId,
        displayTitle: 'Toggle Task',
        createdAt: DateTime.now(),
      );
      await ref.read(siteManagerSyncProvider.notifier).enqueue(action);
    }
  }

  Future<void> deleteTask(String taskId) async {
    final newOpen = state.openTasks.where((t) => t.id != taskId).toList();
    final newCompleted =
        state.completedTasks.where((t) => t.id != taskId).toList();

    final isCurrentEmpty = state.selectedTab == TaskStatusTab.open
        ? newOpen.isEmpty
        : newCompleted.isEmpty;

    state = state.copyWith(
      openTasks: newOpen,
      completedTasks: newCompleted,
      status: isCurrentEmpty ? AppDataStatus.empty : AppDataStatus.success,
    );

    try {
      await _repository.deleteProjectTask(taskId);
    } catch (_) {
      final action = SiteManagerSyncAction(
        id: 'delete_task_${DateTime.now().millisecondsSinceEpoch}',
        actionType: SiteManagerSyncActionType.deleteTask,
        endpoint: ApiConstants.mobileTaskDelete(taskId),
        httpMethod: 'DELETE',
        projectId: state.projectId,
        displayTitle: 'Delete Task',
        createdAt: DateTime.now(),
      );
      await ref.read(siteManagerSyncProvider.notifier).enqueue(action);
    }
  }

  void addTask(ProjectTaskEntity task) {
    if (task.isCompleted) {
      state = state.copyWith(
        completedTasks: [task, ...state.completedTasks],
        status: AppDataStatus.success,
      );
    } else {
      state = state.copyWith(
        openTasks: [task, ...state.openTasks],
        status: AppDataStatus.success,
      );
    }
  }
}

final projectTasksProvider =
    NotifierProvider<ProjectTasksNotifier, ProjectTasksState>(
  ProjectTasksNotifier.new,
);
