import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project_task_entity.dart';
import '../../domain/repositories/project_tasks_repository.dart';
import '../datasources/project_tasks_datasource.dart';
import '../models/project_task_model.dart';

class ProjectTasksRepositoryImpl implements ProjectTasksRepository {
  final ProjectTasksDatasource _datasource;

  ProjectTasksRepositoryImpl(this._datasource);

  @override
  Future<ProjectTasksGroupResult> getProjectTasks({
    required String projectId,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _datasource.fetchProjectTasks(
      projectId: projectId,
      status: status,
      page: page,
      limit: limit,
    );

    final rawData = response['data'];
    final openTasks = <ProjectTaskEntity>[];
    final completedTasks = <ProjectTaskEntity>[];

    if (rawData is Map<String, dynamic>) {
      if (rawData['open'] is List) {
        final list = rawData['open'] as List<dynamic>;
        openTasks.addAll(
          list
              .whereType<Map<String, dynamic>>()
              .map(ProjectTaskModel.fromJson),
        );
      }

      if (rawData['completed'] is List) {
        final list = rawData['completed'] as List<dynamic>;
        completedTasks.addAll(
          list
              .whereType<Map<String, dynamic>>()
              .map(ProjectTaskModel.fromJson),
        );
      }

      // Fallback for single list in map
      if (openTasks.isEmpty && completedTasks.isEmpty) {
        final genericList =
            rawData['items'] ?? rawData['tasks'] ?? rawData['list'];
        if (genericList is List) {
          _distributeTasks(genericList, openTasks, completedTasks, status);
        }
      }
    } else if (rawData is List) {
      _distributeTasks(rawData, openTasks, completedTasks, status);
    }

    final metaJson = response['meta'] as Map<String, dynamic>? ?? {};
    final meta = ProjectTasksPaginationMetaModel.fromJson(metaJson, page);

    return ProjectTasksGroupResult(
      open: openTasks,
      completed: completedTasks,
      meta: meta,
    );
  }

  @override
  Future<ProjectTaskEntity> createProjectTask({
    required String projectId,
    required String description,
    required String employeeId,
    required String priority,
    DateTime? dueDate,
  }) async {
    final body = <String, dynamic>{
      'description': description.trim(),
      'employeeId': employeeId.trim(),
      'priority': priority.toUpperCase(),
    };
    if (dueDate != null) {
      body['dueDate'] = dueDate.toUtc().toIso8601String();
    }

    final response = await _datasource.createProjectTask(
      projectId: projectId,
      body: body,
    );

    final rawData = response['data'];
    if (rawData is Map<String, dynamic>) {
      return ProjectTaskModel.fromJson(rawData);
    }

    throw Exception('Invalid response format for created task');
  }

  @override
  Future<ProjectTaskEntity> toggleProjectTask(String taskId) async {
    final response = await _datasource.toggleProjectTask(taskId);
    final rawData = response['data'];
    if (rawData is Map<String, dynamic>) {
      return ProjectTaskModel.fromJson(rawData);
    }
    throw Exception('Invalid response format for toggled task');
  }

  @override
  Future<void> deleteProjectTask(String taskId) async {
    await _datasource.deleteProjectTask(taskId);
  }

  void _distributeTasks(
    List<dynamic> list,
    List<ProjectTaskEntity> openTasks,
    List<ProjectTaskEntity> completedTasks,
    String? requestedStatus,
  ) {
    for (final item in list) {
      if (item is! Map<String, dynamic>) continue;
      final task = ProjectTaskModel.fromJson(item);
      if (requestedStatus == 'OPEN') {
        openTasks.add(task);
      } else if (requestedStatus == 'COMPLETED') {
        completedTasks.add(task);
      } else if (task.isCompleted) {
        completedTasks.add(task);
      } else {
        openTasks.add(task);
      }
    }
  }
}

final projectTasksRepositoryProvider = Provider<ProjectTasksRepository>((ref) {
  final datasource = ref.watch(projectTasksDatasourceProvider);
  return ProjectTasksRepositoryImpl(datasource);
});
