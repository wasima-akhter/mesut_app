import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../enums/app_enum.dart';

/// Holds the currently authenticated user's role.
///
/// null = not authenticated / no role assigned.
final userRoleProvider = NotifierProvider<UserRoleNotifier, UserRole?>(
  UserRoleNotifier.new,
);

class UserRoleNotifier extends Notifier<UserRole?> {
  @override
  UserRole? build() {
    // Default state:
    // No authenticated role.
    return null;
  }

  /// Assign a role.
  void setRole(UserRole role) {
    state = role;
  }

  /// Clear the current role.
  void clearRole() {
    state = null;
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
