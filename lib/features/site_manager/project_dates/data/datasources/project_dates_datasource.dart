import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../offline_sync/providers/site_manager_sync_provider.dart';
import '../../../offline_sync/services/site_manager_cache_service.dart';

abstract class ProjectDatesDatasource {
  Future<Map<String, dynamic>> fetchProjectPhases(String projectId);

  Future<Map<String, dynamic>> updatePhaseDates({
    required String projectId,
    required String phaseId,
    required Map<String, dynamic> body,
  });
}

class ProjectDatesDatasourceImpl implements ProjectDatesDatasource {
  final ApiClient _client;
  final SiteManagerCacheService? _cacheService;

  ProjectDatesDatasourceImpl(this._client, [this._cacheService]);

  @override
  Future<Map<String, dynamic>> fetchProjectPhases(String projectId) async {
    final endpoint = ApiConstants.mobileProjectById(projectId);
    try {
      final response = await _client.get(endpoint);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        await _cacheService?.cacheDates(projectId, data);
        return data;
      }
    } catch (_) {
      final cached = _cacheService?.getCachedDates(projectId);
      if (cached is Map<String, dynamic>) {
        return cached;
      }
      rethrow;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> updatePhaseDates({
    required String projectId,
    required String phaseId,
    required Map<String, dynamic> body,
  }) async {
    final endpoint = ApiConstants.mobileProjectPhaseDates(projectId, phaseId);
    final response = await _client.patch(endpoint, data: body);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }
}

final projectDatesDatasourceProvider = Provider<ProjectDatesDatasource>((ref) {
  final client = ref.watch(apiClientProvider);
  final cache = ref.watch(siteManagerCacheServiceProvider);
  return ProjectDatesDatasourceImpl(client, cache);
});
