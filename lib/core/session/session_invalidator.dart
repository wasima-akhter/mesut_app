import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/employee/home/presentation/providers/employee_dashboard_provider.dart';
import '../../features/employee/profile/presentation/providers/employee_profile_provider.dart';
import '../../features/employee/time_tracking/presentation/providers/employee_timer_provider.dart';
import '../../features/entry/nav/navigation_provider.dart';
import '../../features/shared/config/presentation/providers/mobile_config_provider.dart';
import '../../features/shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../features/shared/mobile_time_tracking/presentation/providers/mobile_time_tracking_provider.dart';
import '../../features/shared/notifications/presentation/providers/notifications_provider.dart';
import '../../features/site_manager/presentation/providers/mobile_inspection_provider.dart';
import '../../features/site_manager/presentation/providers/mobile_phase_provider.dart';
import '../../features/site_manager/presentation/providers/site_manager_home_provider.dart';
import '../../features/site_manager/presentation/providers/site_manager_profile_provider.dart';
import '../../features/site_manager/projects/presentation/providers/site_manager_projects_provider.dart';
import '../../features/site_manager/presentation/providers/site_manager_time_provider.dart';

/// Centralized session state cleanup releasing memory & user state on logout/expiry.
void clearUserSessionState(Ref ref) {
  debugPrint(
    'clearUserSessionState: Resetting navigation and user-scoped providers...',
  );

  void safeInvalidate(void Function() fn, String label) {
    try {
      fn();
    } catch (e) {
      debugPrint('Error invalidating $label: $e');
    }
  }

  safeInvalidate(() => ref.invalidate(navigationProvider), 'navigationProvider');
  safeInvalidate(
    () => ref.invalidate(employeeDashboardProvider),
    'employeeDashboardProvider',
  );
  safeInvalidate(
    () => ref.invalidate(employeeProfileProvider),
    'employeeProfileProvider',
  );
  safeInvalidate(
    () => ref.invalidate(employeeTimerProvider),
    'employeeTimerProvider',
  );
  safeInvalidate(
    () => ref.invalidate(siteManagerProfileProvider),
    'siteManagerProfileProvider',
  );
  safeInvalidate(
    () => ref.invalidate(siteManagerHomeProvider),
    'siteManagerHomeProvider',
  );
  safeInvalidate(
    () => ref.invalidate(siteManagerProjectsProvider),
    'siteManagerProjectsProvider',
  );
  safeInvalidate(
    () => ref.invalidate(siteManagerTimeProvider),
    'siteManagerTimeProvider',
  );
  safeInvalidate(
    () => ref.invalidate(notificationsProvider),
    'notificationsProvider',
  );
  safeInvalidate(
    () => ref.invalidate(mobileConfigProvider),
    'mobileConfigProvider',
  );
  safeInvalidate(
    () => ref.invalidate(mobileDashboardProvider),
    'mobileDashboardProvider',
  );
  safeInvalidate(
    () => ref.invalidate(mobileProjectsProvider),
    'mobileProjectsProvider',
  );
  safeInvalidate(
    () => ref.invalidate(mobileProfileProvider),
    'mobileProfileProvider',
  );
  safeInvalidate(
    () => ref.invalidate(mobileScheduleProvider),
    'mobileScheduleProvider',
  );
  safeInvalidate(
    () => ref.invalidate(mobileMapPinsProvider),
    'mobileMapPinsProvider',
  );
  safeInvalidate(
    () => ref.invalidate(mobileTimeLogsProvider),
    'mobileTimeLogsProvider',
  );
  safeInvalidate(
    () => ref.invalidate(mobileCrewTimeProvider),
    'mobileCrewTimeProvider',
  );
  safeInvalidate(
    () => ref.invalidate(mobileInspectionsProvider),
    'mobileInspectionsProvider',
  );
  safeInvalidate(
    () => ref.invalidate(mobilePhasesProvider),
    'mobilePhasesProvider',
  );
}
