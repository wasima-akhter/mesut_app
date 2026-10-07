// ============================================================
// PROJECT MODEL
// ============================================================

import 'enums.dart';

class Project {
  final String id;
  final String title;
  final String company;
  final String address;
  final String owner;
  final String duration;
  final ProjectPhase phase;
  final ProjectPriority priority;
  final ProjectStatus status;

  const Project({
    required this.id,
    required this.title,
    required this.company,
    required this.address,
    required this.owner,
    required this.duration,
    required this.phase,
    required this.priority,
    required this.status,
  });
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
  ProjectPhoto({required this.id, required this.url, this.isCover = false});

  final String id;
  final String url;
  bool isCover;
}

class ProjectPlanFile {
  ProjectPlanFile({required this.name});

  final String name;
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
    this.author = 'Mesut Yilmaz',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ProjectNoteCategory category;
  String details;
  String author;
  DateTime createdAt;
}
