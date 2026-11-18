import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/employee/home/presentation/providers/employee_dashboard_provider.dart';
import '../../features/employee/plan/presentation/providers/employee_schedule_provider.dart';
import '../../features/employee/time_tracking/presentation/providers/employee_time_tracking_provider.dart';
import '../../features/employee/time_tracking/presentation/providers/employee_timer_projects_provider.dart';
import '../../features/shared/config/presentation/providers/mobile_config_provider.dart';
import '../../features/shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../features/shared/mobile_time_tracking/presentation/providers/mobile_time_tracking_provider.dart';
import '../../features/shared/notifications/presentation/providers/notifications_provider.dart';
import '../../features/site_manager/inspection_pages/presentation/providers/mobile_inspection_provider.dart';
import '../../features/site_manager/phase_board/presentation/providers/mobile_phase_provider.dart';
import '../../features/site_manager/project_attachments/presentation/providers/project_attachments_provider.dart';
import '../../features/site_manager/project_dates/presentation/providers/project_dates_provider.dart';
import '../../features/site_manager/project_history/presentation/providers/project_history_provider.dart';
import '../../features/site_manager/project_measurements/presentation/providers/project_measurements_provider.dart';
import '../../features/site_manager/project_notes/presentation/providers/project_notes_provider.dart';
import '../../features/site_manager/project_tasks/presentation/providers/project_tasks_provider.dart';
import '../../features/site_manager/projects/presentation/providers/site_manager_projects_provider.dart';
import '../services/address_resolver_service.dart';

/// Clears in-memory caches and invalidates active Riverpod providers so that
/// all screens refetch localized content immediately after a language switch.
Future<void> onAppLanguageChanged(Ref ref) async {
  AddressResolverService.clearCache();

  // Employee providers
  try {
    ref.read(employeeDashboardProvider.notifier).refresh();
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

  // Site Manager providers
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

  // Project details providers
  try {
    ref.invalidate(projectTasksProvider);
    ref.invalidate(projectMeasurementsProvider);
    ref.invalidate(projectNotesProvider);
    ref.invalidate(projectAttachmentsProvider);
    ref.invalidate(projectDatesProvider);
    ref.invalidate(projectHistoryProvider);
  } catch (_) {}

  // Shared providers
  try {
    ref.read(notificationsProvider.notifier).refresh();
  } catch (_) {}
  try {
    ref.invalidate(mobileConfigProvider);
  } catch (_) {}
}
