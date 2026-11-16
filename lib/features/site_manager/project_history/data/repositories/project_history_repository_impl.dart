import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project_history_entity.dart';
import '../../domain/repositories/project_history_repository.dart';
import '../datasources/project_history_datasource.dart';
import '../models/project_history_model.dart';

class ProjectHistoryRepositoryImpl implements ProjectHistoryRepository {
  final ProjectHistoryDatasource _datasource;

  ProjectHistoryRepositoryImpl(this._datasource);

  @override
  Future<ProjectHistoryResponseEntity> getProjectHistory({
    required String projectId,
    int page = 1,
    int limit = 10,
  }) async {
    final json = await _datasource.fetchProjectHistory(
      projectId: projectId,
      page: page,
      limit: limit,
    );
    return ProjectHistoryResponseModel.fromJson(
      json,
      requestedPage: page,
    );
  }
}

final projectHistoryRepositoryProvider =
    Provider<ProjectHistoryRepository>((ref) {
  final ds = ref.watch(projectHistoryDatasourceProvider);
  return ProjectHistoryRepositoryImpl(ds);
});
