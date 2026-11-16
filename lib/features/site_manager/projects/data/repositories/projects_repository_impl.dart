import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/pagination/paginated_response.dart';
import '../../domain/entities/project_phase_card_entity.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_datasource.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsDatasource _datasource;

  ProjectsRepositoryImpl(this._datasource);

  @override
  Future<PaginatedListResponse<ProjectPhaseCardEntity>> getProjects({
    String tab = 'ALL',
    List<String>? phaseTypes,
    List<String>? phaseStatuses,
    String? search,
    double? lat,
    double? lng,
    double? radiusKm,
    List<String>? priorities,
    List<String>? categories,
    String sortBy = 'NEWEST',
    int page = 1,
    int limit = 10,
  }) {
    return _datasource.getProjects(
      tab: tab,
      phaseTypes: phaseTypes,
      phaseStatuses: phaseStatuses,
      search: search,
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      priorities: priorities,
      categories: categories,
      sortBy: sortBy,
      page: page,
      limit: limit,
    );
  }
}

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  final datasource = ref.watch(projectsDatasourceProvider);
  return ProjectsRepositoryImpl(datasource);
});
