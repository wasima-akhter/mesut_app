import '../../helper/employee_enums.dart';
import '../../domain/entities/employee_entities.dart';

abstract class EmployeeDataSource {
  Future<List<EmployeeAssignment>> getAssignments();
  Future<List<EmployeeCalendarEvent>> getScheduleEvents();
  Future<List<EmployeeTimeLog>> getTimeLogs();
  Future<void> saveTimeEntry({
    required String projectId,
    required String startTime,
    required String endTime,
    required String breakTime,
  });
  Future<List<EmployeeProject>> getAvailableProjects();
}

class EmployeeMockDataSourceImpl implements EmployeeDataSource {
  final List<EmployeeAssignment> _assignments = const [
    EmployeeAssignment(
      project: 'Prj-0842 · Goltsteins.Complex',
      address: 'Goltsteinstraße 12, 50968 Köln',
      activity: EmployeeActivityType.erection,
      schedule: 'Start: 07:30 am',
      scaffoldArea: '50m²',
      siteManager: 'Mesut Rahaman',
    ),
    EmployeeAssignment(
      project: 'Prj-0843 · Rheinauhafen Office',
      address: 'Agrippinawerft 22, 50678 Köln',
      activity: EmployeeActivityType.dismantling,
      schedule: 'Start: 09:00 am',
      scaffoldArea: '120m²',
      siteManager: 'Tim Müller',
    ),
    EmployeeAssignment(
      project: 'Prj-0844 · Severin Residenz',
      address: 'Severinstraße 44, 50678 Köln',
      activity: EmployeeActivityType.others,
      schedule: 'Start: 01:00 pm',
      scaffoldArea: '85m²',
      siteManager: 'Klaus Wagner',
    ),
  ];

  final List<EmployeeProject> _projects = const [
    EmployeeProject(
      id: 'Prj-0842',
      name: 'Goltsteins.Complex',
      address: 'Goltsteinstraße 12, 50968 Köln',
      activity: EmployeeActivityType.erection,
      startTime: '07:30 am',
      endTime: '04:30 pm',
      siteManager: 'Mesut Rahaman',
    ),
    EmployeeProject(
      id: 'Prj-0843',
      name: 'Rheinauhafen Office',
      address: 'Agrippinawerft 22, 50678 Köln',
      activity: EmployeeActivityType.dismantling,
      startTime: '09:00 am',
      endTime: '05:00 pm',
      siteManager: 'Tim Müller',
    ),
  ];

  late final List<EmployeeCalendarEvent> _calendarEvents;
  late final List<EmployeeTimeLog> _timeLogs;

  EmployeeMockDataSourceImpl() {
    _calendarEvents = [
      EmployeeCalendarEvent(
        date: DateTime.now(),
        project: _projects[0],
      ),
      EmployeeCalendarEvent(
        date: DateTime.now().add(const Duration(days: 1)),
        project: _projects[0],
      ),
      EmployeeCalendarEvent(
        date: DateTime.now().add(const Duration(days: 2)),
        project: _projects[1],
      ),
    ];

    _timeLogs = [
      EmployeeTimeLog(
        id: 'log-1',
        date: 'Today',
        project: _projects[0],
        duration: '7h 30m',
        breakTime: '45m',
        synced: true,
      ),
      EmployeeTimeLog(
        id: 'log-2',
        date: 'Yesterday',
        project: _projects[1],
        duration: '8h 00m',
        breakTime: '30m',
        synced: true,
      ),
    ];
  }

  @override
  Future<List<EmployeeAssignment>> getAssignments() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _assignments;
  }

  @override
  Future<List<EmployeeCalendarEvent>> getScheduleEvents() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _calendarEvents;
  }

  @override
  Future<List<EmployeeTimeLog>> getTimeLogs() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _timeLogs;
  }

  @override
  Future<void> saveTimeEntry({
    required String projectId,
    required String startTime,
    required String endTime,
    required String breakTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final project = _projects.firstWhere(
      (p) => p.id == projectId,
      orElse: () => _projects.first,
    );
    _timeLogs.insert(
      0,
      EmployeeTimeLog(
        id: 'log-${DateTime.now().millisecondsSinceEpoch}',
        date: 'Today',
        project: project,
        duration: '8h 00m',
        breakTime: breakTime,
        synced: false,
      ),
    );
  }

  @override
  Future<List<EmployeeProject>> getAvailableProjects() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _projects;
  }
}
