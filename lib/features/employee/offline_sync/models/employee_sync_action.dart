import 'dart:convert';

enum EmployeeSyncActionType {
  startTimer,
  stopTimer,
  manualTimeLog,
  uploadAssignmentPhoto,
  toggleAssignmentTask,
}

class EmployeeSyncAction {
  const EmployeeSyncAction({
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
  final EmployeeSyncActionType actionType;
  final String endpoint;
  final String httpMethod;
  final Map<String, dynamic>? payload;
  final String? projectId;
  final String? filePath;
  final String displayTitle;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  EmployeeSyncAction copyWith({
    int? attempts,
    String? lastError,
  }) {
    return EmployeeSyncAction(
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

  factory EmployeeSyncAction.fromJson(Map<String, dynamic> json) {
    return EmployeeSyncAction(
      id: json['id'] as String? ?? '',
      actionType: EmployeeSyncActionType.values.firstWhere(
        (e) => e.name == json['actionType'],
        orElse: () => EmployeeSyncActionType.manualTimeLog,
      ),
      endpoint: json['endpoint'] as String? ?? '',
      httpMethod: json['httpMethod'] as String? ?? 'POST',
      payload: json['payload'] is Map
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : null,
      projectId: json['projectId'] as String?,
      filePath: json['filePath'] as String?,
      displayTitle: json['displayTitle'] as String? ?? 'Pending Action',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      lastError: json['lastError'] as String?,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
