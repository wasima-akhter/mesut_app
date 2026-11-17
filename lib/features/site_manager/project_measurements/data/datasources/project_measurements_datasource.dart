import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../offline_sync/providers/site_manager_sync_provider.dart';
import '../../../offline_sync/services/site_manager_cache_service.dart';

abstract class ProjectMeasurementsDatasource {
  Future<Map<String, dynamic>> fetchProjectMeasurements({
    required String projectId,
    int page = 1,
    int limit = 10,
  });

  Future<Map<String, dynamic>> createProjectMeasurement({
    required String projectId,
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> updateProjectMeasurement({
    required String projectId,
    required String measurementId,
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> deleteProjectMeasurement({
    required String projectId,
    required String measurementId,
  });
}

class ProjectMeasurementsDatasourceImpl implements ProjectMeasurementsDatasource {
  final ApiClient _client;
  final SiteManagerCacheService? _cacheService;

  ProjectMeasurementsDatasourceImpl(this._client, [this._cacheService]);

  @override
  Future<Map<String, dynamic>> fetchProjectMeasurements({
    required String projectId,
    int page = 1,
    int limit = 10,
  }) async {
    final endpoint = ApiConstants.mobileProjectMeasurements(projectId);
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
          await _cacheService?.cacheMeasurements(projectId, data);
        }
        return data;
      }
    } catch (_) {
      final cached = _cacheService?.getCachedMeasurements(projectId);
      if (cached is Map<String, dynamic>) {
        return cached;
      }
      rethrow;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> createProjectMeasurement({
    required String projectId,
    required Map<String, dynamic> body,
  }) async {
    final endpoint = ApiConstants.mobileProjectMeasurements(projectId);
    final response = await _client.post(endpoint, data: body);

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> updateProjectMeasurement({
    required String projectId,
    required String measurementId,
    required Map<String, dynamic> body,
  }) async {
    final endpoint = ApiConstants.mobileProjectMeasurementById(
      projectId,
      measurementId,
    );
    final response = await _client.patch(endpoint, data: body);

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> deleteProjectMeasurement({
    required String projectId,
    required String measurementId,
  }) async {
    final endpoint = ApiConstants.mobileProjectMeasurementById(
      projectId,
      measurementId,
    );
    final response = await _client.delete(endpoint);

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }
}

final projectMeasurementsDatasourceProvider =
    Provider<ProjectMeasurementsDatasource>((ref) {
  final client = ref.watch(apiClientProvider);
  final cache = ref.watch(siteManagerCacheServiceProvider);
  return ProjectMeasurementsDatasourceImpl(client, cache);
});
