import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../offline_sync/providers/site_manager_sync_provider.dart';
import '../../../offline_sync/services/site_manager_cache_service.dart';

abstract class ProjectTasksDatasource {
  Future<Map<String, dynamic>> fetchProjectTasks({
    required String projectId,
    String? status,
    int page = 1,
    int limit = 10,
  });

  Future<Map<String, dynamic>> createProjectTask({
    required String projectId,
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> toggleProjectTask(String taskId);

  Future<Map<String, dynamic>> deleteProjectTask(String taskId);

  Future<List<Map<String, dynamic>>> fetchProjectEmployees({
    required String projectId,
    String? search,
    int page = 1,
    int limit = 50,
  });
}

class ProjectTasksDatasourceImpl implements ProjectTasksDatasource {
  final ApiClient _client;
  final SiteManagerCacheService? _cacheService;

  ProjectTasksDatasourceImpl(this._client, [this._cacheService]);

  @override
  Future<Map<String, dynamic>> fetchProjectTasks({
    required String projectId,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null && status.trim().isNotEmpty) {
      query['status'] = status.trim().toUpperCase();
    }

    final endpoint = ApiConstants.mobileProjectTasks(projectId);
    try {
      final response = await _client.get(
        endpoint,
        queryParameters: query,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (page == 1 && status == null) {
          await _cacheService?.cacheProjectTasks(projectId, data);
        }
        return data;
      }
    } catch (_) {
      final cached = _cacheService?.getCachedProjectTasks(projectId);
      if (cached is Map<String, dynamic>) {
        return cached;
      }
      rethrow;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> createProjectTask({
    required String projectId,
    required Map<String, dynamic> body,
  }) async {
    final endpoint = ApiConstants.mobileProjectTasks(projectId);
    final response = await _client.post(
      endpoint,
      data: body,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> toggleProjectTask(String taskId) async {
    final endpoint = ApiConstants.mobileTaskToggle(taskId);
    final response = await _client.patch(endpoint);

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> deleteProjectTask(String taskId) async {
    final endpoint = ApiConstants.mobileTaskDelete(taskId);
    final response = await _client.delete(endpoint);

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  @override
  Future<List<Map<String, dynamic>>> fetchProjectEmployees({
    required String projectId,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    final endpoint = ApiConstants.mobileProjectEmployees(projectId);
    final response = await _client.get(endpoint, queryParameters: query);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final list = data['data'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().toList();
      }
    } else if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }
}

final projectTasksDatasourceProvider = Provider<ProjectTasksDatasource>((ref) {
  final client = ref.watch(apiClientProvider);
  final cache = ref.watch(siteManagerCacheServiceProvider);
  return ProjectTasksDatasourceImpl(client, cache);
});
