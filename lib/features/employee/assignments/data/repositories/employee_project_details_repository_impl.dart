import '../../domain/entities/employee_project_details_entity.dart';
import '../../domain/repositories/employee_project_details_repository.dart';
import '../datasources/employee_project_details_datasource.dart';

class EmployeeProjectDetailsRepositoryImpl
    implements EmployeeProjectDetailsRepository {
  final EmployeeProjectDetailsDataSource _dataSource;

  EmployeeProjectDetailsRepositoryImpl(this._dataSource);

  @override
  Future<EmployeeProjectDetailsEntity> getProjectDetail(
    String projectId,
  ) {
    return _dataSource.fetchProjectDetail(projectId);
  }

  @override
  Future<List<EmployeeProjectPhotoEntity>> getProjectPhotos(
    String projectId, {
    int page = 1,
    int limit = 10,
  }) {
    return _dataSource.fetchProjectPhotos(projectId, page: page, limit: limit);
  }

  @override
  Future<List<EmployeeProjectTaskEntity>> getProjectTasks(
    String projectId, {
    String? status,
    int page = 1,
    int limit = 10,
  }) {
    return _dataSource.fetchProjectTasks(
      projectId,
      status: status,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<bool> toggleTask(String taskId) {
    return _dataSource.toggleTask(taskId);
  }
}
