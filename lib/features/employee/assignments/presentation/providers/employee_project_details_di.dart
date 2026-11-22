import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/network_providers.dart';
import '../../data/datasources/employee_project_details_datasource.dart';
import '../../data/repositories/employee_project_details_repository_impl.dart';
import '../../domain/repositories/employee_project_details_repository.dart';

final employeeProjectDetailsDataSourceProvider =
    Provider<EmployeeProjectDetailsDataSource>((ref) {
  return EmployeeProjectDetailsRemoteDataSourceImpl(
    ref.watch(apiClientProvider),
  );
});

final employeeProjectDetailsRepositoryProvider =
    Provider<EmployeeProjectDetailsRepository>((ref) {
  return EmployeeProjectDetailsRepositoryImpl(
    ref.watch(employeeProjectDetailsDataSourceProvider),
  );
});
