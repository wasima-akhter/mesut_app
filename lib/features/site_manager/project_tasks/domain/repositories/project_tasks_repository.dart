import '../entities/project_task_entity.dart';

abstract class ProjectTasksRepository {
  Future<ProjectTasksGroupResult> getProjectTasks({
    required String projectId,
    String? status,
    int page = 1,
    int limit = 10,
  });

  Future<ProjectTaskEntity> createProjectTask({
    required String projectId,
    required String description,
    required String employeeId,
    required String priority,
    DateTime? dueDate,
  });

  Future<ProjectTaskEntity> toggleProjectTask(String taskId);

  Future<void> deleteProjectTask(String taskId);

  Future<List<ProjectTaskEmployeeEntity>> getProjectEmployees({
    required String projectId,
    String? search,
    int page = 1,
    int limit = 50,
  });
}
