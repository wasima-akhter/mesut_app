class EmployeeDashboardUserEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String role;
  final String? avatarUrl;

  const EmployeeDashboardUserEntity({
    this.id = '',
    this.firstName = '',
    this.lastName = '',
    this.role = 'EMPLOYEE',
    this.avatarUrl,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : 'Employee';
  }
}

class EmployeeDashboardProjectEntity {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const EmployeeDashboardProjectEntity({
    this.id = '',
    this.name = '',
    this.address = '',
    this.latitude = 0,
    this.longitude = 0,
  });
}

class EmployeeDashboardSiteManagerEntity {
  final String id;
  final String name;
  final String? phone;
  final String? email;

  const EmployeeDashboardSiteManagerEntity({
    this.id = '',
    this.name = '',
    this.phone,
    this.email,
  });
}

class EmployeeDashboardTaskEntity {
  final String phaseId;
  final String type;
  final String status;
  final String priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final EmployeeDashboardProjectEntity project;
  final EmployeeDashboardSiteManagerEntity siteManager;
  final String workingHours;

  const EmployeeDashboardTaskEntity({
    this.phaseId = '',
    this.type = 'ERECTION',
    this.status = '',
    this.priority = 'HIGH',
    this.startDate,
    this.endDate,
    this.project = const EmployeeDashboardProjectEntity(),
    this.siteManager = const EmployeeDashboardSiteManagerEntity(),
    this.workingHours = '',
  });

  bool get isDismantling => type.toUpperCase() == 'DISMANTLING';
}

class EmployeeDashboardEntity {
  final EmployeeDashboardUserEntity user;
  final DateTime? date;
  final String formattedDate;
  final int totalUpcomingTasks;
  final List<EmployeeDashboardTaskEntity> upcomingTasks;

  const EmployeeDashboardEntity({
    this.user = const EmployeeDashboardUserEntity(),
    this.date,
    this.formattedDate = '',
    this.totalUpcomingTasks = 0,
    this.upcomingTasks = const [],
  });
}
