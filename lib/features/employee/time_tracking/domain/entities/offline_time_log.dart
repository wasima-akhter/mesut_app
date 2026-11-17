import 'package:uuid/uuid.dart';

import '../../../../core/enums/backend_enums.dart';

/// Immutable locally queued time log segment synced via `POST /mobile/sync`.
class OfflineTimeLog {
  const OfflineTimeLog({
    required this.clientSyncId,
    required this.phaseId,
    required this.activityType,
    required this.startTime,
    required this.endTime,
    this.breakMinutes = 0,
    this.projectName,
  });

  /// Stable UUID v4 generated ONCE at creation time; NEVER regenerated on retry.
  final String clientSyncId;
  final String phaseId;
  final BackendActivityType activityType;
  final DateTime startTime;
  final DateTime endTime;
  final int breakMinutes;
  final String? projectName;

  static const _uuid = Uuid();

  /// Creates a new offline segment with an immutable v4 `clientSyncId`.
  factory OfflineTimeLog.create({
    String? clientSyncId,
    required String phaseId,
    required BackendActivityType activityType,
    required DateTime startTime,
    required DateTime endTime,
    int breakMinutes = 0,
    String? projectName,
  }) {
    final trimmedId = clientSyncId?.trim() ?? '';
    return OfflineTimeLog(
      clientSyncId: trimmedId.isNotEmpty ? trimmedId : _uuid.v4(),
      phaseId: phaseId,
      activityType: activityType,
      startTime: startTime.toUtc(),
      endTime: endTime.toUtc(),
      breakMinutes: breakMinutes < 0 ? 0 : breakMinutes,
      projectName: projectName,
    );
  }

  /// Payload expected by `POST /api/v1/mobile/sync`.
  Map<String, dynamic> toApiPayload() => {
    'clientSyncId': clientSyncId,
    'phaseId': phaseId,
    'activityType': activityType.serializedName,
    'startTime': startTime.toUtc().toIso8601String(),
    'endTime': endTime.toUtc().toIso8601String(),
    'breakMinutes': breakMinutes,
  };

  /// Local persistence representation (preserves `clientSyncId` verbatim).
  Map<String, dynamic> toStorageJson() => {
    ...toApiPayload(),
    if (projectName != null) 'projectName': projectName,
  };

  factory OfflineTimeLog.fromStorageJson(Map<String, dynamic> json) {
    final rawSyncId = json['clientSyncId']?.toString().trim() ?? '';
    if (rawSyncId.isEmpty) {
      throw const FormatException('OfflineTimeLog requires clientSyncId');
    }
    return OfflineTimeLog(
      clientSyncId: rawSyncId,
      phaseId: (json['phaseId'] ?? '').toString(),
      activityType: BackendActivityType.fromString(
        json['activityType']?.toString(),
      ),
      startTime:
          DateTime.tryParse(json['startTime']?.toString() ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      endTime:
          DateTime.tryParse(json['endTime']?.toString() ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      breakMinutes: _parseInt(json['breakMinutes']),
      projectName: json['projectName']?.toString(),
    );
  }

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val == null) return 0;
    return int.tryParse(val.toString()) ?? 0;
  }
}

class MobileSyncResult {
  const MobileSyncResult({
    required this.created,
    required this.skipped,
    this.logs = const [],
  });

  final int created;
  final int skipped;
  final List<Map<String, dynamic>> logs;

  int get acknowledgedCount => created + skipped;

  factory MobileSyncResult.fromJson(Map<String, dynamic> json) {
    final rawLogs = json['logs'];
    final parsedLogs = rawLogs is List
        ? rawLogs
              .whereType<Map>()
              .map((m) => Map<String, dynamic>.from(m))
              .toList()
        : const <Map<String, dynamic>>[];

    return MobileSyncResult(
      created: _parseInt(json['created']),
      skipped: _parseInt(json['skipped']),
      logs: parsedLogs,
    );
  }

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val == null) return 0;
    return int.tryParse(val.toString()) ?? 0;
  }
}
