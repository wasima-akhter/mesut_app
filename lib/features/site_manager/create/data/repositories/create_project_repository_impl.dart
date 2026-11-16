import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/create_project_entity.dart';
import '../../domain/repositories/create_project_repository.dart';
import '../datasources/create_project_datasource.dart';

class CreateProjectRepositoryImpl implements CreateProjectRepository {
  final CreateProjectDatasource _datasource;

  CreateProjectRepositoryImpl(this._datasource);

  @override
  Future<Map<String, dynamic>> createProject(
      CreateProjectPayload payload) async {
    return _datasource.createProject(payload.toJson());
  }
}

final createProjectRepositoryProvider = Provider<CreateProjectRepository>((ref) {
  final datasource = ref.watch(createProjectDatasourceProvider);
  return CreateProjectRepositoryImpl(datasource);
});
