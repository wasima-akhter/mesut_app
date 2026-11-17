import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../offline_sync/providers/site_manager_sync_provider.dart';
import '../../../offline_sync/services/site_manager_cache_service.dart';

abstract class ProjectNotesDatasource {
  Future<Map<String, dynamic>> fetchProjectNotes({
    required String projectId,
    int page = 1,
    int limit = 10,
  });

  Future<Map<String, dynamic>> createProjectNote({
    required String projectId,
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> updateProjectNote({
    required String projectId,
    required String noteId,
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> deleteProjectNote({
    required String projectId,
    required String noteId,
  });
}

class ProjectNotesDatasourceImpl implements ProjectNotesDatasource {
  final ApiClient _client;
  final SiteManagerCacheService? _cacheService;

  ProjectNotesDatasourceImpl(this._client, [this._cacheService]);

  @override
  Future<Map<String, dynamic>> fetchProjectNotes({
    required String projectId,
    int page = 1,
    int limit = 10,
  }) async {
    final endpoint = ApiConstants.mobileProjectNotes(projectId);
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
          await _cacheService?.cacheNotes(projectId, data);
        }
        return data;
      }
    } catch (_) {
      final cached = _cacheService?.getCachedNotes(projectId);
      if (cached is Map<String, dynamic>) {
        return cached;
      }
      rethrow;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> createProjectNote({
    required String projectId,
    required Map<String, dynamic> body,
  }) async {
    final endpoint = ApiConstants.mobileProjectNotes(projectId);
    final response = await _client.post(endpoint, data: body);

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> updateProjectNote({
    required String projectId,
    required String noteId,
    required Map<String, dynamic> body,
  }) async {
    final endpoint = ApiConstants.mobileProjectNoteById(projectId, noteId);
    final response = await _client.patch(endpoint, data: body);

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> deleteProjectNote({
    required String projectId,
    required String noteId,
  }) async {
    final endpoint = ApiConstants.mobileProjectNoteById(projectId, noteId);
    final response = await _client.delete(endpoint);

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }
}

final projectNotesDatasourceProvider = Provider<ProjectNotesDatasource>((ref) {
  final client = ref.watch(apiClientProvider);
  final cache = ref.watch(siteManagerCacheServiceProvider);
  return ProjectNotesDatasourceImpl(client, cache);
});
