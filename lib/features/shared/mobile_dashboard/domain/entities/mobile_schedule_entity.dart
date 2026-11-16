import 'mobile_dashboard_entity.dart';

class MobileSchedulePhaseEntity {
  const MobileSchedulePhaseEntity({
    required this.id,
    required this.type,
    required this.status,
    required this.priority,
    this.startDate,
    this.endDate,
    required this.project,
  });

  final String id;
  final String type;
  final String status;
  final String priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final DashboardProjectSummaryEntity project;
}

class MobileScheduleDayEntity {
  const MobileScheduleDayEntity({
    required this.date,
    this.phases = const [],
  });

  final String date;
  final List<MobileSchedulePhaseEntity> phases;
}
