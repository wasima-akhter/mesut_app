import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';

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

  ProjectNotesDatasourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> fetchProjectNotes({
    required String projectId,
    int page = 1,
    int limit = 10,
  }) async {
    final endpoint = ApiConstants.mobileProjectNotes(projectId);
    final response = await _client.get(
      endpoint,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
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
  return ProjectNotesDatasourceImpl(client);
});
