import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';

abstract class CreateProjectDatasource {
  Future<Map<String, dynamic>> createProject(Map<String, dynamic> data);
}

class CreateProjectDatasourceImpl implements CreateProjectDatasource {
  final ApiClient _client;

  CreateProjectDatasourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> createProject(Map<String, dynamic> data) async {
    final response = await _client.post(
      ApiConstants.mobileProjects,
      data: data,
    );

    final resData = response.data;
    if (resData is Map<String, dynamic>) {
      return resData;
    }
    return {'success': true};
  }
}

final createProjectDatasourceProvider = Provider<CreateProjectDatasource>((ref) {
  final client = ref.watch(apiClientProvider);
  return CreateProjectDatasourceImpl(client);
});
