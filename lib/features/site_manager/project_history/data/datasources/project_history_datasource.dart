import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';

abstract class ProjectHistoryDatasource {
  Future<Map<String, dynamic>> fetchProjectHistory({
    required String projectId,
    int page = 1,
    int limit = 10,
  });
}

class ProjectHistoryDatasourceImpl implements ProjectHistoryDatasource {
  final ApiClient _client;

  ProjectHistoryDatasourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> fetchProjectHistory({
    required String projectId,
    int page = 1,
    int limit = 10,
  }) async {
    final endpoint = ApiConstants.mobileProjectHistory(projectId);
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
}

final projectHistoryDatasourceProvider =
    Provider<ProjectHistoryDatasource>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProjectHistoryDatasourceImpl(client);
});
