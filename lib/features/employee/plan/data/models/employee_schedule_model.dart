import 'package:construction_app/core/localization/localization_meta.dart';
import '../../domain/entities/employee_schedule_entity.dart';

class EmployeeScheduleModel {
  static List<EmployeeScheduleDayEntity> fromList(dynamic rawList) {
    if (rawList is! List) return const [];
    final days = <EmployeeScheduleDayEntity>[];

    for (final dayItem in rawList) {
      final dayMap = _asMap(dayItem);
      if (dayMap.isEmpty) continue;

      final rawPhases = dayMap['phases'];
      final phases = <EmployeeSchedulePhaseEntity>[];

      if (rawPhases is List) {
        for (final pItem in rawPhases) {
          final p = _asMap(pItem);
          if (p.isEmpty) continue;

          final proj = _asMap(p['project']);
          final rawSms = p['siteManagers'];
          final siteManagers = <EmployeeScheduleSiteManagerEntity>[];

          if (rawSms is List) {
            for (final smItem in rawSms) {
              final sm = _asMap(smItem);
              if (sm.isEmpty) continue;
              siteManagers.add(
                EmployeeScheduleSiteManagerEntity(
                  id: (sm['id'] ?? '').toString(),
                  firstName: (sm['firstName'] ?? '').toString(),
                  lastName: (sm['lastName'] ?? '').toString(),
                ),
              );
            }
          }

          phases.add(
            EmployeeSchedulePhaseEntity(
              id: (p['id'] ?? '').toString(),
              type: (p['type'] ?? '').toString(),
              status: (p['status'] ?? '').toString(),
              priority: (p['priority'] ?? '').toString(),
              startDate: _asDateTime(p['startDate']),
              endDate: _asDateTime(p['endDate']),
              assignedHours: (p['assignedHours'] as num?)?.toDouble() ?? 0,
              project: EmployeeScheduleProjectEntity(
                id: (proj['id'] ?? '').toString(),
                name: (proj['name'] ?? '').toString(),
                address: (proj['address'] ?? '').toString(),
              ),
              siteManagers: siteManagers,
              localization: LocalizationMeta.tryParse(p),
            ),
          );
        }
      }

      days.add(
        EmployeeScheduleDayEntity(
          date: (dayMap['date'] ?? '').toString(),
          phases: phases,
        ),
      );
    }

    return days;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

