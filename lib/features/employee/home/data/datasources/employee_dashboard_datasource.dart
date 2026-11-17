import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:construction_app/core/constants/api_constants.dart';
import 'package:construction_app/core/network/api_client.dart';
import 'package:construction_app/core/network/network_providers.dart';
import '../../domain/entities/employee_dashboard_entity.dart';
import '../models/employee_dashboard_models.dart';

abstract class EmployeeDashboardDatasource {
  Future<EmployeeDashboardEntity> getDashboard({int page = 1, int limit = 10});
}

class EmployeeDashboardDatasourceImpl implements EmployeeDashboardDatasource {
  final ApiClient _client;

  EmployeeDashboardDatasourceImpl(this._client);

  @override
  Future<EmployeeDashboardEntity> getDashboard({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _client.get(
      ApiConstants.mobileEmployeeDashboard,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final payload = data['data'];
      if (payload is Map<String, dynamic>) {
        return EmployeeDashboardModel.fromJson(payload);
      }
    }
    return const EmployeeDashboardEntity();
  }
}

final employeeDashboardDatasourceProvider =
    Provider<EmployeeDashboardDatasource>((ref) {
  final client = ref.watch(apiClientProvider);
  return EmployeeDashboardDatasourceImpl(client);
});
