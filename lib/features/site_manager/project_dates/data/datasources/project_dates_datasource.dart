import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';

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

  ProjectDatesDatasourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> fetchProjectPhases(String projectId) async {
    final endpoint = ApiConstants.mobileProjectById(projectId);
    final response = await _client.get(endpoint);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
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
  return ProjectDatesDatasourceImpl(client);
});
