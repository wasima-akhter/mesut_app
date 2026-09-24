import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../enums/user_role.dart';

final selectedRoleProvider = NotifierProvider<SelectedRoleNotifier, UserRole?>(
  SelectedRoleNotifier.new,
);

class SelectedRoleNotifier extends Notifier<UserRole?> {
  @override
  UserRole? build() {
    return null;
  }

  void setRole(UserRole role) {
    state = role;
  }

  void clear() {
    state = null;
  }
}
