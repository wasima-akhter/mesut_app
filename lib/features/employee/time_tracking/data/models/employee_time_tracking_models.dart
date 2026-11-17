import '../../domain/entities/employee_time_tracking_entities.dart';

abstract final class EmployeeTimeTrackingModels {
  static EmployeeActiveTimerEntity? parseActiveTimer(dynamic json) {
    if (json == null || json is! Map) return null;
    final map = Map<String, dynamic>.from(json);
    final id = map['id']?.toString() ?? '';
    if (id.isEmpty) return null;

    final projectMap = map['project'] is Map
        ? Map<String, dynamic>.from(map['project'] as Map)
        : const <String, dynamic>{};

    return EmployeeActiveTimerEntity(
      id: id,
      phaseId: map['phaseId']?.toString() ?? '',
      activityType: map['activityType']?.toString() ?? 'ERECTION',
      startTime: DateTime.tryParse(map['startTime']?.toString() ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(map['endTime']?.toString() ?? ''),
      isManual: map['isManual'] == true,
      status: map['status']?.toString() ?? 'IN_PROGRESS',
      breakMinutes: _parseInt(map['breakMinutes']),
      netHours: _parseDouble(map['netHours']),
      projectId: projectMap['id']?.toString() ?? '',
      projectName: projectMap['name']?.toString() ?? '',
      synced: map['synced'] == true,
    );
  }

  static EmployeeTimeSummaryEntity summaryFromJson(Map<String, dynamic> json) {
    return EmployeeTimeSummaryEntity(
      todayHours: _parseDouble(json['todayHours']),
      weekHours: _parseDouble(json['weekHours']),
      weeklyHoursTarget: _parseDouble(json['weeklyHoursTarget'], fallback: 40.0),
      weekNumber: _parseInt(json['weekNumber'], fallback: 1),
      weekStartDate: DateTime.tryParse(json['weekStartDate']?.toString() ?? ''),
      weekEndDate: DateTime.tryParse(json['weekEndDate']?.toString() ?? ''),
      activeTimer: parseActiveTimer(json['activeTimer']),
    );
  }

  static List<EmployeeAssignedProjectEntity> projectListFromJson(dynamic json) {
    final list = json is List
        ? json
        : (json is Map ? (json['data'] is List ? json['data'] : null) : null);
    if (list == null || list is! List) return const [];
    return list
        .whereType<Map>()
        .map((m) {
          final map = Map<String, dynamic>.from(m);
          return EmployeeAssignedProjectEntity(
            id: map['id']?.toString() ?? '',
            name: map['name']?.toString() ?? '',
            phaseId: map['phaseId']?.toString() ?? '',
            phaseType: map['phaseType']?.toString() ?? 'ERECTION',
          );
        })
        .where((p) => p.id.isNotEmpty)
        .toList();
  }

  static List<EmployeeRecentLogEntity> logListFromJson(dynamic json) {
    final list = json is List
        ? json
        : (json is Map ? (json['data'] is List ? json['data'] : null) : null);
    if (list == null || list is! List) return const [];
    return list
        .whereType<Map>()
        .map((m) {
          final map = Map<String, dynamic>.from(m);
          final projectMap = map['project'] is Map
              ? Map<String, dynamic>.from(map['project'] as Map)
              : const <String, dynamic>{};

          return EmployeeRecentLogEntity(
            id: map['id']?.toString() ?? '',
            phaseId: map['phaseId']?.toString() ?? '',
            activityType: map['activityType']?.toString() ?? 'ERECTION',
            startTime: DateTime.tryParse(map['startTime']?.toString() ?? '') ?? DateTime.now(),
            endTime: DateTime.tryParse(map['endTime']?.toString() ?? ''),
            isManual: map['isManual'] == true,
            status: map['status']?.toString() ?? 'PENDING_APPROVAL',
            breakMinutes: _parseInt(map['breakMinutes']),
            netHours: _parseDouble(map['netHours']),
            projectId: projectMap['id']?.toString() ?? '',
            projectName: projectMap['name']?.toString() ?? '',
            synced: map['synced'] == true,
          );
        })
        .where((l) => l.id.isNotEmpty)
        .toList();
  }

  static double _parseDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }
}
