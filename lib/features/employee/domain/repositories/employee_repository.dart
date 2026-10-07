import '../entities/employee_entities.dart';

abstract class EmployeeRepository {
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
