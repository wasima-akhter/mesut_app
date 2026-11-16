import '../entities/customer_entity.dart';

abstract class CustomerRepository {
  Future<CustomerListResult> getCustomers({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
  });
}
