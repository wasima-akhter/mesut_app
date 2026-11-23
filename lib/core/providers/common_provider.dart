import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/storage_keys.dart';
import '../enums/app_enum.dart';
import '../storage/storage_provider.dart';

/// Holds the currently authenticated user's role.
///
/// null = not authenticated / no role assigned.
final userRoleProvider = NotifierProvider<UserRoleNotifier, UserRole?>(
  UserRoleNotifier.new,
);

class UserRoleNotifier extends Notifier<UserRole?> {
  @override
  UserRole? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedRoleStr = prefs.getString(StorageKeys.userRole);
    return UserRoleExtension.fromString(savedRoleStr);
  }

  /// Assign a role.
  void setRole(UserRole role) {
    state = role;
    try {
      ref
          .read(sharedPreferencesProvider)
          .setString(StorageKeys.userRole, role.name);
    } catch (_) {}
  }

  /// Clear the current role.
  void clearRole() {
    state = null;
    try {
      ref.read(sharedPreferencesProvider).remove(StorageKeys.userRole);
    } catch (_) {}
  }

  /// Convenience method for debug login.
  void loginAsSiteManager() {
    state = UserRole.siteManager;
  }

  /// Convenience method for debug login.
  void loginAsEmployee() {
    state = UserRole.employee;
  }

  /// Convenience method for logout.
  void logout() {
    state = null;
  }
}
