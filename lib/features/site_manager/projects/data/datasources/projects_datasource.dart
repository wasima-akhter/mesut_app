import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../../../core/pagination/paginated_response.dart';
import '../../domain/entities/project_phase_card_entity.dart';
import '../models/project_phase_card_model.dart';

abstract class ProjectsDatasource {
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

class ProjectsDatasourceImpl implements ProjectsDatasource {
  final ApiClient _client;

  ProjectsDatasourceImpl(this._client);

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
  }) async {
    final query = <String, dynamic>{
      'tab': tab,
      'sortBy': sortBy,
      'page': page,
      'limit': limit,
    };

    if (phaseTypes != null && phaseTypes.isNotEmpty) {
      query['phaseTypes'] = phaseTypes.join(',');
    }
    if (phaseStatuses != null && phaseStatuses.isNotEmpty) {
      query['phaseStatuses'] = phaseStatuses.join(',');
    }
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (lat != null && lng != null && (lat != 0 || lng != 0)) {
      query['lat'] = lat;
      query['lng'] = lng;
      query['radiusKm'] = radiusKm ?? 25;
    }
    if (priorities != null && priorities.isNotEmpty) {
      query['priorities'] = priorities.join(',');
    }
    if (categories != null && categories.isNotEmpty) {
      query['categories'] = categories.join(',');
    }

    final response = await _client.get(
      ApiConstants.mobileProjects,
      queryParameters: query,
    );

    final rawData = response.data;
    if (rawData is! Map<String, dynamic>) {
      return PaginatedListResponse(
        items: const [],
        meta: PaginationMeta(total: 0, totalPages: 1, currentPage: page),
      );
    }

    final itemsRaw = rawData['data'];
    final items = <ProjectPhaseCardEntity>[];
    if (itemsRaw is List) {
      for (final item in itemsRaw) {
        if (item is Map<String, dynamic>) {
          items.add(ProjectPhaseCardModel.fromJson(item));
        }
      }
    }

    final metaJson = rawData['meta'] as Map<String, dynamic>? ?? const {};
    final meta = PaginationMeta.fromJson(metaJson, page);

    return PaginatedListResponse(items: items, meta: meta);
  }
}

final projectsDatasourceProvider = Provider<ProjectsDatasource>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProjectsDatasourceImpl(client);
});
