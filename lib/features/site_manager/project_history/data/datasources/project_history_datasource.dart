import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../offline_sync/providers/site_manager_sync_provider.dart';
import '../../../offline_sync/services/site_manager_cache_service.dart';

abstract class ProjectHistoryDatasource {
  Future<Map<String, dynamic>> fetchProjectHistory({
    required String projectId,
    int page = 1,
    int limit = 10,
  });
}

class ProjectHistoryDatasourceImpl implements ProjectHistoryDatasource {
  final ApiClient _client;
  final SiteManagerCacheService? _cacheService;

  ProjectHistoryDatasourceImpl(this._client, [this._cacheService]);

  @override
  Future<Map<String, dynamic>> fetchProjectHistory({
    required String projectId,
    int page = 1,
    int limit = 10,
  }) async {
    final endpoint = ApiConstants.mobileProjectHistory(projectId);
    try {
      final response = await _client.get(
        endpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (page == 1) {
          await _cacheService?.cacheHistory(projectId, data);
        }
        return data;
      }
    } catch (_) {
      final cached = _cacheService?.getCachedHistory(projectId);
      if (cached is Map<String, dynamic>) {
        return cached;
      }
      rethrow;
    }
    return {};
  }
}

final projectHistoryDatasourceProvider =
    Provider<ProjectHistoryDatasource>((ref) {
  final client = ref.watch(apiClientProvider);
  final cache = ref.watch(siteManagerCacheServiceProvider);
  return ProjectHistoryDatasourceImpl(client, cache);
});
