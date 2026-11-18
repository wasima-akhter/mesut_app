import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:construction_app/core/constants/api_constants.dart';
import 'package:construction_app/core/network/api_client.dart';
import 'package:construction_app/core/network/network_providers.dart';
import '../../../offline_sync/providers/employee_sync_provider.dart';
import '../../../offline_sync/services/employee_cache_service.dart';
import '../../domain/entities/employee_dashboard_entity.dart';
import '../models/employee_dashboard_models.dart';

abstract class EmployeeDashboardDatasource {
  Future<EmployeeDashboardEntity> getDashboard({int page = 1, int limit = 10});
}

class EmployeeDashboardDatasourceImpl implements EmployeeDashboardDatasource {
  final ApiClient _client;
  final EmployeeCacheService? _cacheService;

  EmployeeDashboardDatasourceImpl(this._client, [this._cacheService]);

  @override
  Future<EmployeeDashboardEntity> getDashboard({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.mobileEmployeeDashboard,
        queryParameters: {'page': page, 'limit': limit},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final payload = data['data'];
        if (payload is Map<String, dynamic>) {
          if (page == 1) {
            await _cacheService?.cacheDashboard(payload);
          }
          return EmployeeDashboardModel.fromJson(payload);
        }
      }
    } catch (_) {
      final cached = _cacheService?.getCachedDashboard();
      if (cached != null) {
        return EmployeeDashboardModel.fromJson(cached);
      }
      rethrow;
    }
    return const EmployeeDashboardEntity();
  }
}

final employeeDashboardDatasourceProvider =
    Provider<EmployeeDashboardDatasource>((ref) {
  final client = ref.watch(apiClientProvider);
  final cache = ref.watch(employeeCacheServiceProvider);
  return EmployeeDashboardDatasourceImpl(client, cache);
});
