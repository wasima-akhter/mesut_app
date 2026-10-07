import '../../domain/entities/employee_entities.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_datasource.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeDataSource _dataSource;

  const EmployeeRepositoryImpl(this._dataSource);

  @override
  Future<List<EmployeeAssignment>> getAssignments() {
    return _dataSource.getAssignments();
  }

  @override
  Future<List<EmployeeCalendarEvent>> getScheduleEvents() {
    return _dataSource.getScheduleEvents();
  }

  @override
  Future<List<EmployeeTimeLog>> getTimeLogs() {
    return _dataSource.getTimeLogs();
  }

  @override
  Future<void> saveTimeEntry({
    required String projectId,
    required String startTime,
    required String endTime,
    required String breakTime,
  }) {
    return _dataSource.saveTimeEntry(
      projectId: projectId,
      startTime: startTime,
      endTime: endTime,
      breakTime: breakTime,
    );
  }

  @override
  Future<List<EmployeeProject>> getAvailableProjects() {
    return _dataSource.getAvailableProjects();
  }
}
