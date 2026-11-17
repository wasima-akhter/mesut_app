import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../offline_sync/providers/site_manager_sync_provider.dart';
import '../../../offline_sync/services/site_manager_cache_service.dart';

abstract class ProjectAttachmentsDatasource {
  Future<Map<String, dynamic>> fetchAttachments({
    required String projectId,
    String? category,
    int page = 1,
    int limit = 50,
  });

  Future<Map<String, dynamic>> registerAttachment({
    required String projectId,
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> setCoverPhoto({
    required String projectId,
    required String attachmentId,
  });

  Future<Map<String, dynamic>> deleteAttachment({
    required String projectId,
    required String attachmentId,
  });
}

class ProjectAttachmentsDatasourceImpl implements ProjectAttachmentsDatasource {
  final ApiClient _client;
  final SiteManagerCacheService? _cacheService;

  ProjectAttachmentsDatasourceImpl(this._client, [this._cacheService]);

  @override
  Future<Map<String, dynamic>> fetchAttachments({
    required String projectId,
    String? category,
    int page = 1,
    int limit = 50,
  }) async {
    final endpoint = ApiConstants.mobileProjectAttachments(projectId);
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (category != null && category.isNotEmpty) {
      query['category'] = category;
    }

    try {
      final response = await _client.get(endpoint, queryParameters: query);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (page == 1 && (category == null || category.isEmpty)) {
          await _cacheService?.cacheAttachments(projectId, data);
        }
        return data;
      }
    } catch (_) {
      final cached = _cacheService?.getCachedAttachments(projectId);
      if (cached is Map<String, dynamic>) {
        return cached;
      }
      rethrow;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> registerAttachment({
    required String projectId,
    required Map<String, dynamic> body,
  }) async {
    final endpoint = ApiConstants.mobileProjectAttachments(projectId);
    final response = await _client.post(endpoint, data: body);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> setCoverPhoto({
    required String projectId,
    required String attachmentId,
  }) async {
    final endpoint =
        ApiConstants.mobileProjectAttachmentCover(projectId, attachmentId);
    final response = await _client.patch(endpoint);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> deleteAttachment({
    required String projectId,
    required String attachmentId,
  }) async {
    final endpoint =
        ApiConstants.mobileProjectAttachmentById(projectId, attachmentId);
    final response = await _client.delete(endpoint);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }
}

final projectAttachmentsDatasourceProvider =
    Provider<ProjectAttachmentsDatasource>((ref) {
  final client = ref.watch(apiClientProvider);
  final cache = ref.watch(siteManagerCacheServiceProvider);
  return ProjectAttachmentsDatasourceImpl(client, cache);
});
