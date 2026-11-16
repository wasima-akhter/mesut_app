import '../entities/project_history_entity.dart';

abstract class ProjectHistoryRepository {
  Future<ProjectHistoryResponseEntity> getProjectHistory({
    required String projectId,
    int page = 1,
    int limit = 10,
  });
}
