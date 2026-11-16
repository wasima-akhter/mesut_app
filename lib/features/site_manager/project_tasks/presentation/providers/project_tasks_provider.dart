import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/states/app_data_state.dart';
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
      state = state.copyWith(
        status: AppDataStatus.empty,
        clearError: true,
      );
      return;
    }

    final hasData = state.currentTasks.isNotEmpty;
    state = state.copyWith(
      projectId: projectId,
      status: (hasData && isRefresh)
          ? AppDataStatus.refreshing
          : AppDataStatus.loading,
      clearError: true,
    );

    try {
      final result = await _repository.getProjectTasks(
        projectId: projectId,
        page: 1,
        limit: 10,
      );

      final openCount = result.open.length;
      final completedCount = result.completed.length;
      final isCurrentEmpty = state.selectedTab == TaskStatusTab.open
          ? openCount == 0
          : completedCount == 0;

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
        final merged = [...state.openTasks, ...result.open];
        state = state.copyWith(
          openTasks: merged,
          openMeta: result.meta,
          isLoadingMore: false,
        );
      } else {
        final merged = [...state.completedTasks, ...result.completed];
        state = state.copyWith(
          completedTasks: merged,
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
    try {
      final priorityStr = priority == ProjectPriority.high
          ? 'HIGH'
          : priority == ProjectPriority.low
              ? 'LOW'
              : 'MEDIUM';

      final createdTask = await _repository.createProjectTask(
        projectId: projectId,
        description: description,
        employeeId: employeeId,
        priority: priorityStr,
        dueDate: dueDate,
      );

      final updatedOpen = [createdTask, ...state.openTasks];
      state = state.copyWith(
        openTasks: updatedOpen,
        status: AppDataStatus.success,
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  void selectTaskTab(TaskStatusTab tab) {
    if (state.selectedTab == tab) return;

    final targetList = tab == TaskStatusTab.open
        ? state.openTasks
        : state.completedTasks;
    final isTargetEmpty = targetList.isEmpty;

    state = state.copyWith(
      selectedTab: tab,
      status: isTargetEmpty ? AppDataStatus.empty : AppDataStatus.success,
    );
  }

  Future<void> toggleTask(String taskId) async {
    final openIndex = state.openTasks.indexWhere((t) => t.id == taskId);
    final completedIndex =
        state.completedTasks.indexWhere((t) => t.id == taskId);
    if (openIndex == -1 && completedIndex == -1) return;

    final isMovingToCompleted = openIndex != -1;
    final originalOpen = state.openTasks;
    final originalCompleted = state.completedTasks;

    if (isMovingToCompleted) {
      final task = state.openTasks[openIndex];
      final updatedTask = task.copyWith(isCompleted: true);
      final newOpen = List<ProjectTaskEntity>.from(state.openTasks)
        ..removeAt(openIndex);
      final newCompleted = [updatedTask, ...state.completedTasks];
      state = state.copyWith(
        openTasks: newOpen,
        completedTasks: newCompleted,
        status: (state.selectedTab == TaskStatusTab.open && newOpen.isEmpty)
            ? AppDataStatus.empty
            : AppDataStatus.success,
      );
    } else {
      final task = state.completedTasks[completedIndex];
      final updatedTask = task.copyWith(isCompleted: false);
      final newCompleted = List<ProjectTaskEntity>.from(state.completedTasks)
        ..removeAt(completedIndex);
      final newOpen = [updatedTask, ...state.openTasks];
      state = state.copyWith(
        openTasks: newOpen,
        completedTasks: newCompleted,
        status: (state.selectedTab == TaskStatusTab.completed &&
                newCompleted.isEmpty)
            ? AppDataStatus.empty
            : AppDataStatus.success,
      );
    }

    try {
      final updatedFromBackend = await _repository.toggleProjectTask(taskId);
      if (updatedFromBackend.isCompleted) {
        final newCompleted = state.completedTasks
            .map((t) => t.id == taskId ? updatedFromBackend : t)
            .toList();
        state = state.copyWith(completedTasks: newCompleted);
      } else {
        final newOpen = state.openTasks
            .map((t) => t.id == taskId ? updatedFromBackend : t)
            .toList();
        state = state.copyWith(openTasks: newOpen);
      }
    } catch (e) {
      state = state.copyWith(
        openTasks: originalOpen,
        completedTasks: originalCompleted,
      );
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    final originalOpen = state.openTasks;
    final originalCompleted = state.completedTasks;

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
    } catch (e) {
      state = state.copyWith(
        openTasks: originalOpen,
        completedTasks: originalCompleted,
        status: AppDataStatus.success,
      );
      rethrow;
    }
  }

  void addTask(ProjectTaskEntity task) {
    if (task.isCompleted) {
      final updated = [task, ...state.completedTasks];
      state = state.copyWith(
        completedTasks: updated,
        status: AppDataStatus.success,
      );
    } else {
      final updated = [task, ...state.openTasks];
      state = state.copyWith(openTasks: updated, status: AppDataStatus.success);
    }
  }
}

final projectTasksProvider =
    NotifierProvider<ProjectTasksNotifier, ProjectTasksState>(
  ProjectTasksNotifier.new,
);
