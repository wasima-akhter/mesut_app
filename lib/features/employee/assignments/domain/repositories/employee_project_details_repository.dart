import '../entities/employee_project_details_entity.dart';

abstract class EmployeeProjectDetailsRepository {
  Future<EmployeeProjectDetailsEntity> getProjectDetail(String projectId);

  Future<List<EmployeeProjectPhotoEntity>> getProjectPhotos(
    String projectId, {
    int page = 1,
    int limit = 10,
  });

  Future<List<EmployeeProjectTaskEntity>> getProjectTasks(
    String projectId, {
    String? status,
    int page = 1,
    int limit = 10,
  });

  Future<bool> toggleTask(String taskId);
}
