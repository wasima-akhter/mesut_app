import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerDatasource _datasource;

  CustomerRepositoryImpl(this._datasource);

  @override
  Future<CustomerListResult> getCustomers({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
  }) async {
    final response = await _datasource.fetchCustomers(
      page: page,
      limit: limit,
      search: search,
      category: category,
    );

    final rawList = response['data'] as List<dynamic>? ?? [];
    final items = rawList
        .whereType<Map<String, dynamic>>()
        .map(CustomerModel.fromJson)
        .toList();

    final metaJson = response['meta'] as Map<String, dynamic>? ?? {};
    final meta = CustomerMetaModel.fromJson(metaJson, page);

    return CustomerListResult(
      items: items,
      meta: meta,
    );
  }
}

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final datasource = ref.watch(customerDatasourceProvider);
  return CustomerRepositoryImpl(datasource);
});
