import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../offline_sync/providers/site_manager_sync_provider.dart';
import '../../../offline_sync/services/site_manager_cache_service.dart';

abstract class CustomerDatasource {
  Future<Map<String, dynamic>> fetchCustomers({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
  });
}

class CustomerDatasourceImpl implements CustomerDatasource {
  final ApiClient _client;
  final SiteManagerCacheService? _cacheService;

  CustomerDatasourceImpl(this._client, [this._cacheService]);

  @override
  Future<Map<String, dynamic>> fetchCustomers({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (category != null && category.trim().isNotEmpty) {
      query['category'] = category.trim();
    }

    try {
      final response = await _client.get(
        ApiConstants.mobileCustomers,
        queryParameters: query,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (page == 1 && search == null && category == null) {
          await _cacheService?.cacheCustomers(data);
        }
        return data;
      }
    } catch (_) {
      final cached = _cacheService?.getCachedCustomers();
      if (cached is Map<String, dynamic>) {
        return cached;
      }
      rethrow;
    }
    return {};
  }
}

final customerDatasourceProvider = Provider<CustomerDatasource>((ref) {
  final client = ref.watch(apiClientProvider);
  final cache = ref.watch(siteManagerCacheServiceProvider);
  return CustomerDatasourceImpl(client, cache);
});
