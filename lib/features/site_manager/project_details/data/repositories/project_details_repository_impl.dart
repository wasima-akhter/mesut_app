import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project_details_entity.dart';
import '../../domain/repositories/project_details_repository.dart';
import '../datasources/project_details_datasource.dart';

class ProjectDetailsRepositoryImpl implements ProjectDetailsRepository {
  final ProjectDetailsDatasource _datasource;

  ProjectDetailsRepositoryImpl(this._datasource);

  @override
  Future<ProjectDetailsEntity> getProjectDetails(String projectId) {
    return _datasource.getProjectDetails(projectId);
  }
}

final projectDetailsRepositoryProvider =
    Provider<ProjectDetailsRepository>((ref) {
  final datasource = ref.watch(projectDetailsDatasourceProvider);
  return ProjectDetailsRepositoryImpl(datasource);
});
