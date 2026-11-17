import 'dart:convert';

enum SiteManagerSyncActionType {
  createProject,
  createTask,
  toggleTask,
  deleteTask,
  saveMeasurements,
  updateMeasurement,
  deleteMeasurement,
  createNote,
  updateNote,
  deleteNote,
  updatePhaseDates,
  uploadAttachment,
  deleteAttachment,
  setCoverAttachment,
  updatePhaseStatus,
  completeInspection,
  manualTimeLog,
  startTimer,
  stopTimer,
}

class SiteManagerSyncAction {
  const SiteManagerSyncAction({
    required this.id,
    required this.actionType,
    required this.endpoint,
    required this.httpMethod,
    this.payload,
    this.projectId,
    this.filePath,
    required this.displayTitle,
    required this.createdAt,
    this.attempts = 0,
    this.lastError,
  });

  final String id;
  final SiteManagerSyncActionType actionType;
  final String endpoint;
  final String httpMethod;
  final Map<String, dynamic>? payload;
  final String? projectId;
  final String? filePath;
  final String displayTitle;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  SiteManagerSyncAction copyWith({
    int? attempts,
    String? lastError,
  }) {
    return SiteManagerSyncAction(
      id: id,
      actionType: actionType,
      endpoint: endpoint,
      httpMethod: httpMethod,
      payload: payload,
      projectId: projectId,
      filePath: filePath,
      displayTitle: displayTitle,
      createdAt: createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actionType': actionType.name,
      'endpoint': endpoint,
      'httpMethod': httpMethod,
      'payload': payload,
      'projectId': projectId,
      'filePath': filePath,
      'displayTitle': displayTitle,
      'createdAt': createdAt.toIso8601String(),
      'attempts': attempts,
      'lastError': lastError,
    };
  }

  factory SiteManagerSyncAction.fromJson(Map<String, dynamic> json) {
    return SiteManagerSyncAction(
      id: json['id'] as String? ?? '',
      actionType: SiteManagerSyncActionType.values.firstWhere(
        (e) => e.name == json['actionType'],
        orElse: () => SiteManagerSyncActionType.createNote,
      ),
      endpoint: json['endpoint'] as String? ?? '',
      httpMethod: json['httpMethod'] as String? ?? 'POST',
      payload: json['payload'] is Map
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : null,
      projectId: json['projectId'] as String?,
      filePath: json['filePath'] as String?,
      displayTitle: json['displayTitle'] as String? ?? 'Pending action',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      lastError: json['lastError'] as String?,
    );
  }

  String serialize() => jsonEncode(toJson());

  static SiteManagerSyncAction? deserialize(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return SiteManagerSyncAction.fromJson(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
