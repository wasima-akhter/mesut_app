import 'dart:async';

import 'package:construction_app/core/enums/backend_enums.dart';
import 'package:construction_app/core/helpers/device_location_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/helper/employee_enums.dart';
import '../../../shared/helper/employee_models.dart';
import '../../data/datasources/employee_time_tracking_datasource.dart';
import 'employee_time_tracking_provider.dart';
import 'offline_sync_provider.dart';

abstract final class EmployeeTimerHelpers {
  static const defaultProject = EmployeeProjectModel(
    id: '',
    name: '',
    address: '',
    activity: EmployeeActivityType.erection,
    startTime: '',
    endTime: '',
    siteManager: '',
  );

  static List<EmployeeTimeLogModel> get defaultLogs => const [];

  static bool isValidUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(str);
  }

  static Future<String> resolvePhaseId({
    required Ref ref,
    required String rawId,
    required EmployeeActivityType activity,
    String? directPhaseId,
  }) async {
    if (directPhaseId != null &&
        directPhaseId.isNotEmpty &&
        isValidUuid(directPhaseId)) {
      return directPhaseId;
    }
    if (isValidUuid(rawId)) return rawId;
    try {
      final projects = await ref
          .read(employeeTimeTrackingDatasourceProvider)
          .getProjects();
      if (projects.isNotEmpty) {
        final matching = projects
            .where((p) => p.id == rawId || p.phaseId == rawId)
            .toList();
        if (matching.isNotEmpty) {
          final actName = activity == EmployeeActivityType.dismantling
              ? 'DISMANTLING'
              : 'ERECTION';
          final byType = matching.firstWhere(
            (p) => p.phaseType.toUpperCase() == actName,
            orElse: () => matching.first,
          );
          if (byType.phaseId.isNotEmpty && isValidUuid(byType.phaseId)) {
            return byType.phaseId;
          }
        }
        final firstValid = projects.firstWhere(
          (p) => p.phaseId.isNotEmpty && isValidUuid(p.phaseId),
          orElse: () => projects.first,
        );
        if (firstValid.phaseId.isNotEmpty) return firstValid.phaseId;
      }
    } catch (_) {}
    return rawId;
  }

  static Future<String?> resolveActiveTimeLogId({
    required Ref ref,
    String? currentId,
  }) async {
    if (currentId != null && currentId.isNotEmpty && isValidUuid(currentId)) {
      return currentId;
    }
    final trackingId = ref
        .read(employeeTimeTrackingProvider)
        .summary
        .activeTimer
        ?.id;
    if (trackingId != null && trackingId.isNotEmpty) {
      return trackingId;
    }
    try {
      final summary = await ref
          .read(employeeTimeTrackingDatasourceProvider)
          .getSummary();
      final active = summary.activeTimer;
      if (active != null && active.id.isNotEmpty) {
        return active.id;
      }
    } catch (_) {}
    try {
      final remoteDs = ref.read(mobileTimerRemoteDataSourceProvider);
      final logs = await remoteDs.getTimeLogs(period: 'WEEK');
      for (final l in logs) {
        if (l['status'] == 'IN_PROGRESS' || l['endTime'] == null) {
          final id = l['id']?.toString();
          if (id != null && id.isNotEmpty) return id;
        }
      }
    } catch (_) {}
    return currentId;
  }

  static Future<String?> stopActiveTimer({
    required Ref ref,
    String? currentId,
    required String phaseId,
    required BackendActivityType activity,
    String? directPhaseId,
  }) async {
    String? activeId = await resolveActiveTimeLogId(
      ref: ref,
      currentId: currentId,
    );

    final remoteDs = ref.read(mobileTimerRemoteDataSourceProvider);
    final coords = await DeviceLocationHelper.tryGetCoordinates();

    if (activeId != null && activeId.isNotEmpty) {
      try {
        await remoteDs.stopTimer(
          timeLogId: activeId,
          lat: coords?.lat,
          lng: coords?.lng,
        );
      } catch (_) {}
    }

    return activeId;
  }

  static String? extractTimeLogId(Map<String, dynamic> response) {
    if (response['id'] != null) return response['id'].toString();
    final data = response['data'];
    if (data is Map && data['id'] != null) return data['id'].toString();
    final timeLog =
        response['timeLog'] ?? (data is Map ? data['timeLog'] : null);
    if (timeLog is Map && timeLog['id'] != null) {
      return timeLog['id'].toString();
    }
    return null;
  }

  static BackendActivityType mapActivity(EmployeeActivityType activity) {
    switch (activity) {
      case EmployeeActivityType.erection:
        return BackendActivityType.erection;
      case EmployeeActivityType.dismantling:
        return BackendActivityType.dismantling;
      case EmployeeActivityType.others:
        return BackendActivityType.other;
    }
  }

  static EmployeeActivityType mapBackendToEmployee(
    BackendActivityType activity,
  ) {
    switch (activity) {
      case BackendActivityType.erection:
        return EmployeeActivityType.erection;
      case BackendActivityType.dismantling:
        return EmployeeActivityType.dismantling;
      case BackendActivityType.other:
      case BackendActivityType.transport:
      case BackendActivityType.maintenance:
        return EmployeeActivityType.others;
    }
  }

  static void enqueueOfflineLog({
    required Ref ref,
    required String phaseId,
    required BackendActivityType activity,
    required DateTime startTime,
    required DateTime endTime,
    required int breakMinutes,
    required String projectName,
  }) {
    try {
      unawaited(
        ref
            .read(offlineSyncProvider.notifier)
            .enqueueCompletedSegment(
              phaseId: phaseId,
              activityType: activity,
              startTime: startTime,
              endTime: endTime,
              breakMinutes: breakMinutes,
              projectName: projectName,
            ),
      );
    } catch (_) {}
  }
}
