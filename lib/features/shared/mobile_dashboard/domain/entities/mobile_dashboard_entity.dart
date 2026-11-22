import 'package:construction_app/core/localization/localization_meta.dart';

class DashboardPhaseStatsEntity {
  const DashboardPhaseStatsEntity({
    this.planned = 0,
    this.running = 0,
  });

  final int planned;
  final int running;
}

class DashboardStatsEntity {
  const DashboardStatsEntity({
    this.pendingInspections = 0,
    this.assignedProjects = 0,
    this.standingActiveSites = 0,
    this.erection = const DashboardPhaseStatsEntity(),
    this.dismantling = const DashboardPhaseStatsEntity(),
  });

  final int pendingInspections;
  final int assignedProjects;
  final int standingActiveSites;
  final DashboardPhaseStatsEntity erection;
  final DashboardPhaseStatsEntity dismantling;
}

class DashboardProjectSummaryEntity {
  const DashboardProjectSummaryEntity({
    required this.id,
    required this.name,
    required this.address,
  });

  final String id;
  final String name;
  final String address;
}

class UpcomingTaskEntity {
  const UpcomingTaskEntity({
    required this.phaseId,
    required this.type,
    required this.status,
    required this.priority,
    this.startDate,
    this.endDate,
    required this.project,
    this.localization,
  });

  final String phaseId;
  final String type;
  final String status;
  final String priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final DashboardProjectSummaryEntity project;
  final LocalizationMeta? localization;
}

class MobileMapPinEntity {
  const MobileMapPinEntity({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.activePhaseType,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String activePhaseType;
}

class MobileDashboardEntity {
  const MobileDashboardEntity({
    this.stats = const DashboardStatsEntity(),
    this.upcomingTasks = const [],
    this.mapPins = const [],
    this.localization,
  });

  final DashboardStatsEntity stats;
  final List<UpcomingTaskEntity> upcomingTasks;
  final List<MobileMapPinEntity> mapPins;
  final LocalizationMeta? localization;
}
