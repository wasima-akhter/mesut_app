import '../../../../../core/localization/localization_meta.dart';
import '../../domain/entities/employee_project_details_entity.dart';

class EmployeeProjectTaskModel {
  static EmployeeProjectTaskEntity fromJson(Map<String, dynamic> json) {
    String? employeeName;
    String? employeeAvatar;

    final empObj = json['employee'];
    if (empObj is Map<String, dynamic>) {
      final f = empObj['firstName']?.toString() ?? '';
      final l = empObj['lastName']?.toString() ?? '';
      employeeName = '$f $l'.trim();
      employeeAvatar = empObj['avatarUrl']?.toString();
    }

    return EmployeeProjectTaskEntity(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      priority: json['priority']?.toString().toUpperCase() ?? 'MEDIUM',
      isCompleted: json['isCompleted'] == true,
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,
      employeeName: employeeName,
      employeeAvatar: employeeAvatar,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      localization: LocalizationMeta.tryParse(json),
    );
  }

  static List<EmployeeProjectTaskEntity> fromJsonList(dynamic jsonList) {
    if (jsonList is! List) return const [];
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
  }
}
