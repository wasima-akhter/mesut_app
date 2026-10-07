import 'employee_enums.dart';

class EmployeeAssignmentModel {
  final String project;
  final String address;
  final EmployeeActivityType activity;
  final String schedule;
  final String scaffoldArea;
  final String siteManager;

  const EmployeeAssignmentModel({
    required this.project,
    required this.address,
    required this.activity,
    required this.schedule,
    required this.scaffoldArea,
    required this.siteManager,
  });
}
//

class EmployeeProjectModel {
  final String id;
  final String name;
  final String address;
  final EmployeeActivityType activity;
  final String startTime;
  final String endTime;
  final String siteManager;

  const EmployeeProjectModel({
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

class EmployeeTimeLogModel {
  final String date;
  final EmployeeProjectModel project;
  final String duration;
  final String breakTime;
  final bool synced;

  const EmployeeTimeLogModel({
    required this.date,
    required this.project,
    required this.duration,
    required this.breakTime,
    required this.synced,
  });
}

class EmployeeCalendarEventModel {
  final DateTime date;
  final EmployeeProjectModel project;

  const EmployeeCalendarEventModel({required this.date, required this.project});
}

final List<EmployeeAssignmentModel> fakeAssignments = [
  EmployeeAssignmentModel(
    project: 'Skyline Tower',
    address: 'Gulshan Avenue, Dhaka',
    activity: EmployeeActivityType.dismantling,
    schedule: '08:00 AM - 05:00 PM',
    scaffoldArea: 'North Wing - Level 8',
    siteManager: 'Rahim Ahmed',
  ),
  EmployeeAssignmentModel(
    project: 'Green Valley Complex',
    address: 'Banani, Dhaka',
    activity: EmployeeActivityType.erection,
    schedule: '09:00 AM - 04:00 PM',
    scaffoldArea: 'Building B - Level 5',
    siteManager: 'Tanvir Hasan',
  ),
  EmployeeAssignmentModel(
    project: 'Riverside Plaza',
    address: 'Uttara, Dhaka',
    activity: EmployeeActivityType.others,
    schedule: '07:30 AM - 03:30 PM',
    scaffoldArea: 'East Block - Level 3',
    siteManager: 'Karim Hossain',
  ),
  EmployeeAssignmentModel(
    project: 'City Center Mall',
    address: 'Dhanmondi, Dhaka',
    activity: EmployeeActivityType.dismantling,
    schedule: '10:00 AM - 06:00 PM',
    scaffoldArea: 'Main Entrance - Level 2',
    siteManager: 'Sabbir Rahman',
  ),
  EmployeeAssignmentModel(
    project: 'Lakeview Residences',
    address: 'Mirpur, Dhaka',
    activity: EmployeeActivityType.erection,
    schedule: '08:30 AM - 05:30 PM',
    scaffoldArea: 'Tower A - Level 12',
    siteManager: 'Nayeem Islam',
  ),
];
