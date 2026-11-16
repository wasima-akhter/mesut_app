import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';

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
}

class ProjectTasksDatasourceImpl implements ProjectTasksDatasource {
  final ApiClient _client;

  ProjectTasksDatasourceImpl(this._client);

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
    final response = await _client.get(
      endpoint,
      queryParameters: query,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
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
}

final projectTasksDatasourceProvider = Provider<ProjectTasksDatasource>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProjectTasksDatasourceImpl(client);
});
