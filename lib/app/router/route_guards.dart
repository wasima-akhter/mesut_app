import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/app_enum.dart';

final routeGuardProvider = Provider<RouteGuard>((ref) => RouteGuard());

class RouteGuard {
  bool isAuthenticated() {
    return false;
  }

  UserRole? currentRole() {
    return null;
  }

  bool canAccessEmployee() {
    final role = currentRole();

    return role == null || role == UserRole.employee;
  }

  bool canAccessSiteManager() {
    final role = currentRole();

    return role == null || role == UserRole.siteManager;
  }
}
