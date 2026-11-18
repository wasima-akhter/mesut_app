import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_providers.dart';

abstract class ChangePasswordDatasource {
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class ChangePasswordDatasourceImpl implements ChangePasswordDatasource {
  final ApiClient apiClient;

  ChangePasswordDatasourceImpl({required this.apiClient});

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await apiClient.post<Map<String, dynamic>>(
      ApiConstants.settingsPassword,
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }
}

final changePasswordDatasourceProvider = Provider<ChangePasswordDatasource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return ChangePasswordDatasourceImpl(apiClient: apiClient);
});
