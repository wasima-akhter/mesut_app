class EmployeeScheduleProjectEntity {
  const EmployeeScheduleProjectEntity({
    required this.id,
    required this.name,
    this.address = '',
  });

  final String id;
  final String name;
  final String address;
}

class EmployeeScheduleSiteManagerEntity {
  const EmployeeScheduleSiteManagerEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  final String id;
  final String firstName;
  final String lastName;

  String get fullName {
    final full = '$firstName $lastName'.trim();
    return full.isNotEmpty ? full : '-';
  }
}

class EmployeeSchedulePhaseEntity {
  const EmployeeSchedulePhaseEntity({
    required this.id,
    required this.type,
    required this.status,
    required this.priority,
    this.startDate,
    this.endDate,
    required this.project,
    this.siteManagers = const [],
    this.assignedHours = 0,
  });

  final String id;
  final String type;
  final String status;
  final String priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final EmployeeScheduleProjectEntity project;
  final List<EmployeeScheduleSiteManagerEntity> siteManagers;
  final double assignedHours;

  String get siteManagerNames {
    if (siteManagers.isEmpty) return '-';
    return siteManagers.map((sm) => sm.fullName).join(', ');
  }
}

class EmployeeScheduleDayEntity {
  const EmployeeScheduleDayEntity({
    required this.date,
    this.phases = const [],
  });

  final String date;
  final List<EmployeeSchedulePhaseEntity> phases;

  bool get hasAssignments => phases.isNotEmpty;
}

