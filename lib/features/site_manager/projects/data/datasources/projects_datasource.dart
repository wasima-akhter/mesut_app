import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../../../core/pagination/paginated_response.dart';
import '../../../offline_sync/providers/site_manager_sync_provider.dart';
import '../../../offline_sync/services/site_manager_cache_service.dart';
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
  final SiteManagerCacheService? _cacheService;

  ProjectsDatasourceImpl(this._client, [this._cacheService]);

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

    try {
      final response = await _client.get(
        ApiConstants.mobileProjects,
        queryParameters: query,
      );

      final rawData = response.data;
      if (rawData is Map<String, dynamic>) {
        if (page == 1 && search == null && priorities == null && categories == null) {
          await _cacheService?.cacheProjects(tab, rawData);
        }
        return _parseResponse(rawData, page);
      }
    } catch (_) {
      final cached = _cacheService?.getCachedProjects(tab);
      if (cached != null) {
        return _parseResponse(cached, page);
      }
      rethrow;
    }

    return PaginatedListResponse(
      items: const [],
      meta: PaginationMeta(total: 0, totalPages: 1, currentPage: page),
    );
  }

  PaginatedListResponse<ProjectPhaseCardEntity> _parseResponse(
    Map<String, dynamic> rawData,
    int page,
  ) {
    final itemsRaw = rawData['data'];
    final items = <ProjectPhaseCardEntity>[];
    if (itemsRaw is List) {
      for (final item in itemsRaw) {
        if (item is Map<String, dynamic>) {
          items.add(ProjectPhaseCardModel.fromJson(item));
        } else if (item is Map) {
          items.add(
            ProjectPhaseCardModel.fromJson(Map<String, dynamic>.from(item)),
          );
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
  final cache = ref.watch(siteManagerCacheServiceProvider);
  return ProjectsDatasourceImpl(client, cache);
});
