import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../app/constants/route_constants.dart';
import '../../../core/localization/app_strings.dart';

/// Reusable configuration model for a bottom navigation tab.
class AppBottomTab {
  final String route;
  final String Function(AppStrings loc) labelBuilder;
  final IconData icon;
  final IconData? activeIcon;

  const AppBottomTab({
    required this.route,
    required this.labelBuilder,
    required this.icon,
    this.activeIcon,
  });

  String getLabel(AppStrings loc) => labelBuilder(loc);
}

/// Centralized tabs configuration for Site Manager role.
abstract final class SiteManagerBottomTabs {
  static final List<AppBottomTab> tabs = [
    AppBottomTab(
      route: RouteConstants.siteManagerDashboard,
      labelBuilder: (loc) => loc.navHome,
      icon: Iconsax.home_2,
    ),
    AppBottomTab(
      route: RouteConstants.siteManagerProjects,
      labelBuilder: (loc) => loc.navProjects,
      icon: Iconsax.folder_2,
    ),
    AppBottomTab(
      route: RouteConstants.siteManagerMap,
      labelBuilder: (loc) => loc.navMap,
      icon: Iconsax.map_1,
    ),
    AppBottomTab(
      route: RouteConstants.siteManagerTime,
      labelBuilder: (loc) => loc.navTime,
      icon: Iconsax.timer_1,
    ),
    AppBottomTab(
      route: RouteConstants.siteManagerMore,
      labelBuilder: (loc) => loc.navMore,
      icon: Iconsax.more,
    ),
  ];
}

/// Centralized tabs configuration for Employee role.
abstract final class EmployeeBottomTabs {
  static final List<AppBottomTab> tabs = [
    AppBottomTab(
      route: RouteConstants.employeeHome,
      labelBuilder: (loc) => loc.navHome,
      icon: Iconsax.home_2,
    ),
    AppBottomTab(
      route: RouteConstants.employeeTime,
      labelBuilder: (loc) => loc.navTime,
      icon: Iconsax.clock,
    ),
    AppBottomTab(
      route: RouteConstants.employeePlan,
      labelBuilder: (loc) => loc.navMyPlan,
      icon: Iconsax.task_square,
    ),
    AppBottomTab(
      route: RouteConstants.employeeProfile,
      labelBuilder: (loc) => loc.navProfile,
      icon: Iconsax.profile_circle,
    ),
  ];
}
