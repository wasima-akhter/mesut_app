import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../offline_sync/providers/site_manager_sync_provider.dart';
import '../../../offline_sync/services/site_manager_cache_service.dart';
import '../models/project_details_model.dart';

abstract class ProjectDetailsDatasource {
  Future<ProjectDetailsModel> getProjectDetails(String projectId);
}

class ProjectDetailsDatasourceImpl implements ProjectDetailsDatasource {
  final ApiClient _client;
  final SiteManagerCacheService? _cacheService;

  ProjectDetailsDatasourceImpl(this._client, [this._cacheService]);

  @override
  Future<ProjectDetailsModel> getProjectDetails(String projectId) async {
    final endpoint = ApiConstants.mobileProjectById(projectId);
    debugPrint('[ProjectDetails] Requesting: GET $endpoint');

    try {
      final response = await _client.get(endpoint);

      dynamic rawData = response.data;
      if (rawData is String) {
        try {
          rawData = jsonDecode(rawData);
        } catch (_) {}
      }

      if (rawData is Map<String, dynamic>) {
        final data = rawData['data'] ?? rawData;
        if (data is Map<String, dynamic>) {
          debugPrint(
            '[ProjectDetails] Successfully loaded project details for: $projectId',
          );
          await _cacheService?.cacheProjectDetails(projectId, data);
          return ProjectDetailsModel.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('[ProjectDetails] Network error, attempting cache fallback: $e');
      final cached = _cacheService?.getCachedProjectDetails(projectId);
      if (cached != null) {
        debugPrint('[ProjectDetails] Loaded cached project details for $projectId');
        return ProjectDetailsModel.fromJson(cached);
      }
      rethrow;
    }

    throw Exception(
      'Failed to load project details for $projectId: Invalid response payload',
    );
  }
}

final projectDetailsDatasourceProvider =
    Provider<ProjectDetailsDatasource>((ref) {
  final client = ref.watch(apiClientProvider);
  final cache = ref.watch(siteManagerCacheServiceProvider);
  return ProjectDetailsDatasourceImpl(client, cache);
});
