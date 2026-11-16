import '../../domain/entities/mobile_dashboard_entity.dart';
import '../../domain/entities/mobile_profile_entity.dart';
import '../../domain/entities/mobile_project_entity.dart';
import '../../domain/entities/mobile_schedule_entity.dart';

int _asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _asDouble(dynamic value, [double fallback = 0]) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) return null;
  final raw = value.toString().trim();
  if (raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

class MobileDashboardModel {
  static MobileDashboardEntity fromJson(Map<String, dynamic> json) {
    final statsJson = _asMap(json['stats']);
    final stats = DashboardStatsEntity(
      pendingInspections: _asInt(statsJson['pendingInspections']),
      assignedProjects: _asInt(statsJson['assignedProjects']),
    );

    final rawTasks = json['upcomingTasks'];
    final upcomingTasks = <UpcomingTaskEntity>[];
    if (rawTasks is List) {
      for (final item in rawTasks) {
        final map = _asMap(item);
        if (map.isEmpty) continue;
        final projectMap = _asMap(map['project']);
        upcomingTasks.add(
          UpcomingTaskEntity(
            phaseId: (map['phaseId'] ?? '').toString(),
            type: (map['type'] ?? '').toString(),
            status: (map['status'] ?? '').toString(),
            priority: (map['priority'] ?? '').toString(),
            startDate: _asDateTime(map['startDate']),
            endDate: _asDateTime(map['endDate']),
            project: DashboardProjectSummaryEntity(
              id: (projectMap['id'] ?? '').toString(),
              name: (projectMap['name'] ?? '').toString(),
              address: (projectMap['address'] ?? '').toString(),
            ),
          ),
        );
      }
    }

    final mapPins = MobileMapPinModel.fromList(json['mapPins']);

    return MobileDashboardEntity(
      stats: stats,
      upcomingTasks: upcomingTasks,
      mapPins: mapPins,
    );
  }
}

class MobileMapPinModel {
  static MobileMapPinEntity fromJson(Map<String, dynamic> json) {
    return MobileMapPinEntity(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      activePhaseType: (json['activePhaseType'] ?? '').toString(),
    );
  }

  static List<MobileMapPinEntity> fromList(dynamic rawList) {
    if (rawList is! List) return const [];
    final pins = <MobileMapPinEntity>[];
    for (final item in rawList) {
      final map = _asMap(item);
      if (map.isNotEmpty) {
        pins.add(fromJson(map));
      }
    }
    return pins;
  }
}

class MobileProjectModel {
  static MobileProjectEntity fromJson(Map<String, dynamic> json) {
    final customerMap = _asMap(json['customer']);
    final rawPhases = json['phases'];
    final phases = <MobileProjectPhaseEntity>[];
    if (rawPhases is List) {
      for (final item in rawPhases) {
        final p = _asMap(item);
        if (p.isEmpty) continue;
        phases.add(
          MobileProjectPhaseEntity(
            id: (p['id'] ?? '').toString(),
            type: (p['type'] ?? '').toString(),
            status: (p['status'] ?? '').toString(),
            priority: (p['priority'] ?? '').toString(),
            startDate: _asDateTime(p['startDate']),
            endDate: _asDateTime(p['endDate']),
          ),
        );
      }
    }

    return MobileProjectEntity(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      customer: MobileProjectCustomerEntity(
        id: (customerMap['id'] ?? '').toString(),
        name: (customerMap['name'] ?? '').toString(),
      ),
      phases: phases,
      budgetedHours: _asDouble(json['budgetedHours']),
      totalLoggedHours: _asDouble(json['totalLoggedHours']),
      isProfitable: json['isProfitable'] is bool
          ? json['isProfitable'] as bool
          : true,
    );
  }

  static List<MobileProjectEntity> fromList(dynamic rawList) {
    if (rawList is! List) return const [];
    final result = <MobileProjectEntity>[];
    for (final item in rawList) {
      final map = _asMap(item);
      if (map.isNotEmpty) {
        result.add(fromJson(map));
      }
    }
    return result;
  }
}

class MobileProfileModel {
  static MobileProfileEntity fromJson(Map<String, dynamic> json) {
    final avatar = json['avatarUrl']?.toString().trim();
    return MobileProfileEntity(
      id: (json['id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      avatarUrl: (avatar == null || avatar.isEmpty) ? null : avatar,
      weeklyHoursTarget: _asDouble(json['weeklyHoursTarget']),
      hoursThisWeek: _asDouble(json['hoursThisWeek']),
      assignedProjectsCount: _asInt(json['assignedProjectsCount']),
      completedProjectsCount: _asInt(json['completedProjectsCount']),
    );
  }
}

class MobileScheduleModel {
  static List<MobileScheduleDayEntity> fromList(dynamic rawList) {
    if (rawList is! List) return const [];
    final days = <MobileScheduleDayEntity>[];
    for (final dayItem in rawList) {
      final dayMap = _asMap(dayItem);
      if (dayMap.isEmpty) continue;
      final rawPhases = dayMap['phases'];
      final phases = <MobileSchedulePhaseEntity>[];
      if (rawPhases is List) {
        for (final pItem in rawPhases) {
          final p = _asMap(pItem);
          if (p.isEmpty) continue;
          final proj = _asMap(p['project']);
          phases.add(
            MobileSchedulePhaseEntity(
              id: (p['id'] ?? '').toString(),
              type: (p['type'] ?? '').toString(),
              status: (p['status'] ?? '').toString(),
              priority: (p['priority'] ?? '').toString(),
              startDate: _asDateTime(p['startDate']),
              endDate: _asDateTime(p['endDate']),
              project: DashboardProjectSummaryEntity(
                id: (proj['id'] ?? '').toString(),
                name: (proj['name'] ?? '').toString(),
                address: (proj['address'] ?? '').toString(),
              ),
            ),
          );
        }
      }
      days.add(
        MobileScheduleDayEntity(
          date: (dayMap['date'] ?? '').toString(),
          phases: phases,
        ),
      );
    }
    return days;
  }
}
