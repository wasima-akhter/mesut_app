import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';

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

  CustomerDatasourceImpl(this._client);

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

    final response = await _client.get(
      ApiConstants.mobileCustomers,
      queryParameters: query,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }
}

final customerDatasourceProvider = Provider<CustomerDatasource>((ref) {
  final client = ref.watch(apiClientProvider);
  return CustomerDatasourceImpl(client);
});
