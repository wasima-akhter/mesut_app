import 'package:flutter/material.dart';

import '../../domain/entities/employee_time_tracking_entities.dart';
import '../../../shared/helper/employee_enums.dart';
import '../../../shared/helper/employee_models.dart';

class EmployeeTimeTrackingMappers {
  const EmployeeTimeTrackingMappers._();

  static EmployeeTimeLogModel toLogModel(EmployeeRecentLogEntity entity) {
    final activity = entity.activityType.toUpperCase() == 'DISMANTLING'
        ? EmployeeActivityType.dismantling
        : EmployeeActivityType.erection;
    final start = entity.startTime.toLocal();
    final end = entity.endTime?.toLocal();

    return EmployeeTimeLogModel(
      timestamp: start,
      project: EmployeeProjectModel(
        id: entity.projectId.isNotEmpty ? entity.projectId : entity.phaseId,
        name: entity.projectName,
        address: '',
        activity: activity,
        startTimeOfDay: TimeOfDay(hour: start.hour, minute: start.minute),
        endTimeOfDay: end != null
            ? TimeOfDay(hour: end.hour, minute: end.minute)
            : null,
        siteManager: '',
      ),
      duration: entity.netHours > 0
          ? entity.netHours.toStringAsFixed(1)
          : '0.0',
      durationHours: entity.netHours,
      breakTime: '${entity.breakMinutes}m',
      breakDuration: Duration(minutes: entity.breakMinutes),
      synced: entity.synced,
    );
  }

  static List<EmployeeProjectModel> toProjectModels(
    List<EmployeeAssignedProjectEntity> entities,
  ) {
    return entities
        .map(
          (e) => EmployeeProjectModel(
            id: e.id,
            name: e.displayName,
            address: '',
            activity: e.phaseType.toUpperCase() == 'DISMANTLING'
                ? EmployeeActivityType.dismantling
                : EmployeeActivityType.erection,
            siteManager: '',
          ),
        )
        .toList();
  }
}
