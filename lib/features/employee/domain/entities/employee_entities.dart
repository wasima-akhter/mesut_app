import '../../helper/employee_enums.dart';

class EmployeeAssignment {
  final String project;
  final String address;
  final EmployeeActivityType activity;
  final String schedule;
  final String scaffoldArea;
  final String siteManager;

  const EmployeeAssignment({
    required this.project,
    required this.address,
    required this.activity,
    required this.schedule,
    required this.scaffoldArea,
    required this.siteManager,
  });
}

class EmployeeProject {
  final String id;
  final String name;
  final String address;
  final EmployeeActivityType activity;
  final String startTime;
  final String endTime;
  final String siteManager;

  const EmployeeProject({
    required this.id,
    required this.name,
    required this.address,
    required this.activity,
    required this.startTime,
    required this.endTime,
    required this.siteManager,
  });

  String get fullName => '$id · $name';
}

class EmployeeTimeLog {
  final String id;
  final String date;
  final EmployeeProject project;
  final String duration;
  final String breakTime;
  final bool synced;

  const EmployeeTimeLog({
    required this.id,
    required this.date,
    required this.project,
    required this.duration,
    required this.breakTime,
    required this.synced,
  });
}

class EmployeeCalendarEvent {
  final DateTime date;
  final EmployeeProject project;

  const EmployeeCalendarEvent({
    required this.date,
    required this.project,
  });
}
