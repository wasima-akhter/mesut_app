import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';

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

  ProjectAttachmentsDatasourceImpl(this._client);

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

    final response = await _client.get(endpoint, queryParameters: query);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
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
  return ProjectAttachmentsDatasourceImpl(client);
});
