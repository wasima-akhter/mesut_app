import '../entities/project_details_entity.dart';

abstract class ProjectDetailsRepository {
  Future<ProjectDetailsEntity> getProjectDetails(String projectId);
}
