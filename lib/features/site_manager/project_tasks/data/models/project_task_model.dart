import '../../../../../core/localization/localization_meta.dart';
import '../../../projects/enums.dart';
import '../../domain/entities/project_task_entity.dart';

class ProjectTaskEmployeeModel extends ProjectTaskEmployeeEntity {
  const ProjectTaskEmployeeModel({
    required super.id,
    super.firstName,
    super.lastName,
    super.avatarUrl,
    super.role,
  });

  factory ProjectTaskEmployeeModel.fromJson(Map<String, dynamic> json) {
    return ProjectTaskEmployeeModel(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      role: json['role']?.toString(),
    );
  }
}

class ProjectTaskModel extends ProjectTaskEntity {
  const ProjectTaskModel({
    required super.id,
    required super.projectId,
    super.title,
    super.description,
    super.priority,
    super.isCompleted,
    super.dueDate,
    super.employee,
    super.createdAt,
    super.updatedAt,
    super.localization,
  });

  factory ProjectTaskModel.fromJson(Map<String, dynamic> json) {
    return ProjectTaskModel(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priority: _parsePriority(json['priority']),
      isCompleted: json['isCompleted'] == true,
      dueDate: _parseDate(json['dueDate']),
      employee: json['employee'] is Map<String, dynamic>
          ? ProjectTaskEmployeeModel.fromJson(
              json['employee'] as Map<String, dynamic>,
            )
          : null,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      localization: LocalizationMeta.tryParse(json),
    );
  }

  static ProjectPriority _parsePriority(dynamic value) {
    if (value == null) return ProjectPriority.medium;
    final s = value.toString().trim().toUpperCase();
    if (s == 'HIGH') return ProjectPriority.high;
    if (s == 'LOW') return ProjectPriority.low;
    return ProjectPriority.medium;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class ProjectTasksPaginationMetaModel extends ProjectTasksPaginationMeta {
  const ProjectTasksPaginationMetaModel({
    super.total,
    super.totalPages,
    super.currentPage,
    super.nextPage,
    super.previousPage,
  });

  factory ProjectTasksPaginationMetaModel.fromJson(
    Map<String, dynamic> json,
    int requestedPage,
  ) {
    final links = json['links'] as Map<String, dynamic>? ?? {};
    return ProjectTasksPaginationMetaModel(
      total: _asInt(json['total']),
      totalPages: _asInt(json['totalPages'], fallback: 1),
      currentPage: requestedPage,
      nextPage: links['nextPage']?.toString(),
      previousPage: links['previousPage']?.toString(),
    );
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
