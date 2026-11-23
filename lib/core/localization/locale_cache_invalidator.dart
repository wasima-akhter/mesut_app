import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_di_providers.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/employee/assignments/presentation/providers/employee_assignment_details_provider.dart';
import '../../features/employee/home/presentation/providers/employee_dashboard_provider.dart';
import '../../features/employee/plan/presentation/providers/employee_schedule_provider.dart';
import '../../features/employee/time_tracking/presentation/providers/employee_time_tracking_provider.dart';
import '../../features/employee/time_tracking/presentation/providers/employee_timer_projects_provider.dart';
import '../../features/shared/config/presentation/providers/mobile_config_provider.dart';
import '../../features/shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../features/shared/mobile_time_tracking/presentation/providers/mobile_crew_time_provider.dart';
import '../../features/shared/mobile_time_tracking/presentation/providers/mobile_time_tracking_provider.dart';
import '../../features/shared/notifications/presentation/providers/notifications_provider.dart';
import '../../features/site_manager/inspection_pages/presentation/providers/mobile_inspection_provider.dart';
import '../../features/site_manager/phase_board/presentation/providers/mobile_phase_provider.dart';
import '../../features/site_manager/project_attachments/presentation/providers/project_attachments_provider.dart';
import '../../features/site_manager/project_dates/presentation/providers/project_dates_provider.dart';
import '../../features/site_manager/project_details/presentation/providers/project_details_provider.dart';
import '../../features/site_manager/project_history/presentation/providers/project_history_provider.dart';
import '../../features/site_manager/project_measurements/presentation/providers/project_measurements_provider.dart';
import '../../features/site_manager/project_notes/presentation/providers/project_notes_provider.dart';
import '../../features/site_manager/project_tasks/presentation/providers/project_tasks_provider.dart';
import '../../features/site_manager/projects/presentation/providers/site_manager_projects_provider.dart';
import '../constants/storage_keys.dart';
import '../enums/app_enum.dart';
import '../providers/common_provider.dart';
import '../services/address_resolver_service.dart';
import '../storage/storage_provider.dart';

/// Clears in-memory caches and invalidates active Riverpod providers so that
/// all screens refetch localized content immediately after a language switch.
/// Dedicated role APIs are strictly isolated: employee endpoints are only
/// called for employees, and site manager endpoints only for site managers.
Future<void> onAppLanguageChanged(Ref ref) async {
  AddressResolverService.clearCache();

  // If the user has not logged in yet, skip refreshing authenticated providers
  // to avoid triggering redundant network calls and UI thread jank.
  if (!ref.read(authProvider).isAuthenticated) {
    return;
  }

  final role = ref.read(userRoleProvider) ??
      ref.read(currentUserProvider)?.role ??
      UserRoleExtension.fromString(
        ref.read(sharedPreferencesProvider).getString(StorageKeys.userRole),
      );

  if (role == UserRole.employee) {
    // Dedicated Employee providers
    try {
      ref.read(employeeDashboardProvider.notifier).refresh();
    } catch (_) {}
    try {
      ref.read(assignmentDetailsProvider.notifier).refresh();
    } catch (_) {}
    try {
      ref.read(employeeScheduleProvider.notifier).refresh();
    } catch (_) {}
    try {
      ref.read(employeeTimeTrackingProvider.notifier).loadInitial();
    } catch (_) {}
    try {
      ref.read(employeeTimerProjectsProvider.notifier).loadInitial();
    } catch (_) {}
  } else if (role == UserRole.siteManager) {
    // Dedicated Site Manager providers
    try {
      ref.read(mobileDashboardProvider.notifier).refresh();
    } catch (_) {}
    try {
      ref.read(mobileProjectsProvider.notifier).refresh();
    } catch (_) {}
    try {
      ref.read(siteManagerProjectsProvider.notifier).loadInitial(isRefresh: true);
    } catch (_) {}
    try {
      ref.read(mobileInspectionsProvider.notifier).refresh();
    } catch (_) {}
    try {
      ref.read(mobilePhasesProvider.notifier).refresh();
    } catch (_) {}
    try {
      ref.read(mobileTimeLogsProvider.notifier).refresh();
    } catch (_) {}
    try {
      ref.invalidate(mobileCrewTimeProvider);
    } catch (_) {}
    try {
      ref.invalidate(mobileScheduleProvider);
    } catch (_) {}

    // Site Manager project details providers
    try {
      ref.invalidate(projectDetailsProvider);
      ref.invalidate(projectTasksProvider);
      ref.invalidate(projectMeasurementsProvider);
      ref.invalidate(projectNotesProvider);
      ref.invalidate(projectAttachmentsProvider);
      ref.invalidate(projectDatesProvider);
      ref.invalidate(projectHistoryProvider);
    } catch (_) {}
  }

  // Shared providers (both roles)
  try {
    ref.read(mobileProfileProvider.notifier).refresh();
  } catch (_) {}
  try {
    ref.read(notificationsProvider.notifier).refresh();
  } catch (_) {}
  try {
    await ref.read(mobileConfigProvider.notifier).refresh();
  } catch (_) {}
}
