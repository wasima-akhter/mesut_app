import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/app_enum.dart';
import '../../core/providers/common_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../constants/route_constants.dart';

final routeGuardProvider = Provider<RouteGuard>((ref) => RouteGuard(ref));

class RouteGuard {
  RouteGuard(this._ref);

  final Ref _ref;

  static const Set<String> _siteManagerRoutes = {
    RouteConstants.siteManager,
    RouteConstants.siteManagerDashboard,
    RouteConstants.siteManagerProjects,
    RouteConstants.siteManagerMap,
    RouteConstants.siteManagerTeam,
    RouteConstants.siteManagerTime,
    RouteConstants.siteManagerMore,
    RouteConstants.siteManagerProjectDetail,
    RouteConstants.siteManagerCreateproject,
    RouteConstants.siteManagerPhaseBoard,
    RouteConstants.siteManagerSiteInspection,
    RouteConstants.siteManagerInspectionSurveyPage,
    RouteConstants.siteManagerInspectionPhotos,
    RouteConstants.siteManagerInspectionCalendarPage,
    RouteConstants.siteManagerProfile,
    RouteConstants.siteManagerProfileEdit,
    RouteConstants.siteManagerSchedule,
  };

  bool isAuthenticated() {
    return _ref.read(authProvider).isAuthenticated;
  }

  UserRole? currentRole() {
    return _ref.read(userRoleProvider);
  }

  bool canAccessEmployee() {
    final role = currentRole();
    return role == null || role == UserRole.employee;
  }

  bool canAccessSiteManager() {
    final role = currentRole();
    return role == null || role == UserRole.siteManager;
  }

  bool isSiteManagerOnlyPath(String path) {
    return path.startsWith('/site-manager') ||
        _siteManagerRoutes.contains(path);
  }
}
