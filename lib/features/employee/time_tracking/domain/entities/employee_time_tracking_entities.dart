class EmployeeActiveTimerEntity {
  const EmployeeActiveTimerEntity({
    required this.id,
    required this.phaseId,
    required this.activityType,
    required this.startTime,
    this.endTime,
    this.isManual = false,
    this.status = 'IN_PROGRESS',
    this.breakMinutes = 0,
    this.netHours = 0,
    required this.projectId,
    required this.projectName,
    this.synced = true,
  });

  final String id;
  final String phaseId;
  final String activityType;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isManual;
  final String status;
  final int breakMinutes;
  final double netHours;
  final String projectId;
  final String projectName;
  final bool synced;
}

class EmployeeTimeSummaryEntity {
  const EmployeeTimeSummaryEntity({
    this.todayHours = 0.0,
    this.weekHours = 0.0,
    this.weeklyHoursTarget = 40.0,
    this.weekNumber = 1,
    this.weekStartDate,
    this.weekEndDate,
    this.activeTimer,
  });

  final double todayHours;
  final double weekHours;
  final double weeklyHoursTarget;
  final int weekNumber;
  final DateTime? weekStartDate;
  final DateTime? weekEndDate;
  final EmployeeActiveTimerEntity? activeTimer;

  bool get hasActiveTimer => activeTimer != null;
  double get progressRatio =>
      weeklyHoursTarget > 0 ? (weekHours / weeklyHoursTarget).clamp(0.0, 1.0) : 0.0;
}

class EmployeeAssignedProjectEntity {
  const EmployeeAssignedProjectEntity({
    required this.id,
    required this.name,
    required this.phaseId,
    required this.phaseType,
  });

  final String id;
  final String name;
  final String phaseId;
  final String phaseType;

  String get displayName => '$name ($phaseType)';
}

class EmployeeRecentLogEntity {
  const EmployeeRecentLogEntity({
    required this.id,
    required this.phaseId,
    required this.activityType,
    required this.startTime,
    this.endTime,
    this.isManual = false,
    this.status = 'PENDING_APPROVAL',
    this.breakMinutes = 0,
    this.netHours = 0,
    required this.projectId,
    required this.projectName,
    this.synced = true,
  });

  final String id;
  final String phaseId;
  final String activityType;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isManual;
  final String status;
  final int breakMinutes;
  final double netHours;
  final String projectId;
  final String projectName;
  final bool synced;

  Duration get duration => endTime != null
      ? endTime!.difference(startTime)
      : Duration(minutes: (netHours * 60).round());
}
