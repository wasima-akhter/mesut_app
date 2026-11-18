import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/change_password_repository.dart';
import '../datasources/change_password_datasource.dart';

class ChangePasswordRepositoryImpl implements ChangePasswordRepository {
  final ChangePasswordDatasource datasource;

  ChangePasswordRepositoryImpl({required this.datasource});

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return datasource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}

final changePasswordRepositoryProvider =
    Provider<ChangePasswordRepository>((ref) {
  final datasource = ref.watch(changePasswordDatasourceProvider);
  return ChangePasswordRepositoryImpl(datasource: datasource);
});
