// ============================================================
// PROJECT MODEL
// ============================================================

import 'dart:typed_data';

import 'enums.dart';

class Project {
  final String id;
  final String title;
  final String company;
  final String address;
  final String owner;
  final String duration;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? durationDays;
  final ProjectPhase phase;
  final ProjectPriority priority;
  final ProjectStatus status;
  final double totalLoggedHours;
  final double budgetHours;

  const Project({
    required this.id,
    required this.title,
    required this.company,
    required this.address,
    required this.owner,
    required this.duration,
    this.startDate,
    this.endDate,
    this.durationDays,
    required this.phase,
    required this.priority,
    required this.status,
    this.totalLoggedHours = 0.0,
    this.budgetHours = 0.0,
  });

  bool get isProfitable =>
      budgetHours > 0 ? totalLoggedHours <= budgetHours : true;

  double get remainingHours => budgetHours - totalLoggedHours;

  double get budgetProgress =>
      budgetHours > 0 ? (totalLoggedHours / budgetHours).clamp(0.0, 1.5) : 0.0;

  String get formattedTotalHours =>
      '${totalLoggedHours.toStringAsFixed(totalLoggedHours.truncateToDouble() == totalLoggedHours ? 0 : 1)}h';

  String get formattedBudgetHours =>
      '${budgetHours.toStringAsFixed(budgetHours.truncateToDouble() == budgetHours ? 0 : 1)}h';
}

class EmployeeLaborSummary {
  final String employeeName;
  final String role;
  final double loggedHours;
  final String? avatar;
  final String recentActivity;

  const EmployeeLaborSummary({
    required this.employeeName,
    required this.role,
    required this.loggedHours,
    this.avatar,
    this.recentActivity = 'Erection',
  });

  String get formattedHours =>
      '${loggedHours.toStringAsFixed(loggedHours.truncateToDouble() == loggedHours ? 0 : 1)}h';
}


/// ===============================================================
/// MODELS
/// ===============================================================

class ProjectTask {
  ProjectTask({
    required this.description,
    required this.employee,
    required this.priority,
    this.dueDate,
    this.completed = false,
  });

  String description;
  String employee;
  ProjectPriority priority;
  DateTime? dueDate;
  bool completed;

  ProjectTask copyWith({
    String? description,
    String? employee,
    ProjectPriority? priority,
    DateTime? dueDate,
    bool? completed,
  }) {
    return ProjectTask(
      description: description ?? this.description,
      employee: employee ?? this.employee,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
    );
  }
}

class PhotoItem {
  final String title;
  final String meta;
  final String tag;
  final String? badge;
  final String imagePath;

  const PhotoItem({
    required this.title,
    required this.meta,
    required this.tag,
    this.badge,
    required this.imagePath,
  });
}

class ProjectPhoto {
  ProjectPhoto({
    required this.id,
    required this.url,
    this.isCover = false,
    this.title,
    this.caption,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String url;
  bool isCover;
  final String? title;
  final String? caption;
  final DateTime createdAt;

  ProjectPhoto copyWith({
    String? id,
    String? url,
    bool? isCover,
    String? title,
    String? caption,
    DateTime? createdAt,
  }) {
    return ProjectPhoto(
      id: id ?? this.id,
      url: url ?? this.url,
      isCover: isCover ?? this.isCover,
      title: title ?? this.title,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ProjectPlanFile {
  ProjectPlanFile({
    required this.name,
    this.path,
    this.fileBytes,
    this.size = '1.8 MB',
    DateTime? uploadDate,
  }) : uploadDate = uploadDate ?? DateTime.now();

  final String name;
  final String? path;
  final Uint8List? fileBytes;
  final String size;
  final DateTime uploadDate;

  ProjectPlanFile copyWith({
    String? name,
    String? path,
    Uint8List? fileBytes,
    String? size,
    DateTime? uploadDate,
  }) {
    return ProjectPlanFile(
      name: name ?? this.name,
      path: path ?? this.path,
      fileBytes: fileBytes ?? this.fileBytes,
      size: size ?? this.size,
      uploadDate: uploadDate ?? this.uploadDate,
    );
  }
}

class MeasurementItem {
  MeasurementItem({
    required this.position,
    required this.length,
    required this.height,
    required this.quantity,
    required this.unit,
    required this.remark,
  });

  String position;
  double length;
  double height;
  int quantity;
  String unit;
  String remark;

  double get calculatedArea {
    return length * height * quantity;
  }
}

class ProjectNote {
  ProjectNote({
    required this.category,
    required this.details,
    this.author = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ProjectNoteCategory category;
  String details;
  String author;
  DateTime createdAt;
}
