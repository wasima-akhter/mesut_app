import '../../../../../core/pagination/paginated_response.dart';
import '../entities/project_phase_card_entity.dart';

abstract class ProjectsRepository {
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
  });
}
