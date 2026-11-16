import '../entities/create_project_entity.dart';

abstract class CreateProjectRepository {
  Future<Map<String, dynamic>> createProject(CreateProjectPayload payload);
}
