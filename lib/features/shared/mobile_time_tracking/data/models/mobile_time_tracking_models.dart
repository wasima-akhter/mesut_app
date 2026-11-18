import '../../../../../core/enums/backend_enums.dart';
import '../../../../../core/localization/localization_meta.dart';
import '../../../../shared/mobile_dashboard/data/models/mobile_dashboard_models.dart';
import '../../domain/entities/mobile_time_log_entity.dart';

int _asInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? fallback;
}

double _asDouble(dynamic v, [double fallback = 0]) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? fallback;
}

DateTime? _asDateTime(dynamic v) {
  if (v == null) return null;
  final raw = v.toString().trim();
  return raw.isEmpty ? null : DateTime.tryParse(raw);
}

Map<String, dynamic> _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return const <String, dynamic>{};
}

class MobileTimeLogUserModel {
  static MobileTimeLogUserEntity fromJson(Map<String, dynamic> json) {
    return MobileTimeLogUserEntity(
      id: (json['id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
    );
  }
}

class MobileTimeLogModel {
  static MobileTimeLogEntity fromJson(Map<String, dynamic> json) {
    final userMap = _asMap(json['user']);
    final clientSync = json['clientSyncId']?.toString().trim();
    return MobileTimeLogEntity(
      id: (json['id'] ?? '').toString(),
      phaseId: (json['phaseId'] ?? '').toString(),
      activityType: BackendActivityType.fromString(
        json['activityType']?.toString(),
      ),
      startTime: _asDateTime(json['startTime']),
      endTime: _asDateTime(json['endTime']),
      isManual: json['isManual'] == true,
      status: (json['status'] ?? 'PENDING_APPROVAL').toString(),
      clientSyncId: (clientSync == null || clientSync.isEmpty)
          ? null
          : clientSync,
      breakMinutes: _asInt(json['breakMinutes']),
      netHours: _asDouble(json['netHours']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
      user: userMap.isEmpty ? null : MobileTimeLogUserModel.fromJson(userMap),
      localization: LocalizationMeta.tryParse(json),
    );
  }

  static List<MobileTimeLogEntity> fromList(dynamic rawList) {
    if (rawList is! List) return const [];
    final result = <MobileTimeLogEntity>[];
    for (final item in rawList) {
      final map = _asMap(item);
      if (map.isNotEmpty) {
        result.add(fromJson(map));
      }
    }
    return result;
  }
}

class MobileTimerStartResultModel {
  static MobileTimerStartResultEntity fromJson(Map<String, dynamic> json) {
    final logMap = _asMap(json['timeLog']);
    final projectMap = _asMap(json['project']);
    return MobileTimerStartResultEntity(
      timeLog: MobileTimeLogModel.fromJson(logMap.isEmpty ? json : logMap),
      project: projectMap.isEmpty
          ? null
          : MobileProjectModel.fromJson(projectMap),
    );
  }
}

class MobileCrewTimeModel {
  static MobileCrewTimeEntity fromJson(Map<String, dynamic> json) {
    final hoursByActivity = <MobileCrewActivityHoursEntity>[];
    if (json['hoursByActivity'] is List) {
      for (final item in json['hoursByActivity'] as List) {
        final m = _asMap(item);
        if (m.isEmpty) continue;
        hoursByActivity.add(
          MobileCrewActivityHoursEntity(
            activityType: BackendActivityType.fromString(
              m['activityType']?.toString(),
            ),
            hours: _asDouble(m['hours']),
          ),
        );
      }
    }

    final crewBreakdown = <MobileCrewMemberSummaryEntity>[];
    if (json['crewBreakdown'] is List) {
      for (final item in json['crewBreakdown'] as List) {
        final m = _asMap(item);
        if (m.isEmpty) continue;
        crewBreakdown.add(
          MobileCrewMemberSummaryEntity(
            user: MobileTimeLogUserModel.fromJson(_asMap(m['user'])),
            totalHours: _asDouble(m['totalHours']),
            synced: m['synced'] != false,
          ),
        );
      }
    }

    return MobileCrewTimeEntity(
      totalProjectHours: _asDouble(json['totalProjectHours']),
      hoursByActivity: hoursByActivity,
      crewBreakdown: crewBreakdown,
      logs: MobileTimeLogModel.fromList(json['logs']),
    );
  }
}
