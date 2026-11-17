import '../../../projects/enums.dart';

class ProjectTaskEmployeeEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? role;

  const ProjectTaskEmployeeEntity({
    required this.id,
    this.firstName = '',
    this.lastName = '',
    this.avatarUrl,
    this.role,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : 'Unknown';
  }
}

class ProjectTaskEntity {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final ProjectPriority priority;
  final bool isCompleted;
  final DateTime? dueDate;
  final ProjectTaskEmployeeEntity? employee;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProjectTaskEntity({
    required this.id,
    required this.projectId,
    this.title = '',
    this.description = '',
    this.priority = ProjectPriority.medium,
    this.isCompleted = false,
    this.dueDate,
    this.employee,
    this.createdAt,
    this.updatedAt,
  });

  String get displayTitle {
    if (description.isNotEmpty) return description;
    if (title.isNotEmpty) return title;
    return 'Untitled Task';
  }

  ProjectTaskEntity copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    ProjectPriority? priority,
    bool? isCompleted,
    DateTime? dueDate,
    ProjectTaskEmployeeEntity? employee,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectTaskEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      employee: employee ?? this.employee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProjectTasksPaginationMeta {
  final int total;
  final int totalPages;
  final int currentPage;
  final String? nextPage;
  final String? previousPage;

  const ProjectTasksPaginationMeta({
    this.total = 0,
    this.totalPages = 1,
    this.currentPage = 1,
    this.nextPage,
    this.previousPage,
  });

  bool get hasMore => currentPage < totalPages || nextPage != null;
}

class ProjectTasksGroupResult {
  final List<ProjectTaskEntity> open;
  final List<ProjectTaskEntity> completed;
  final ProjectTasksPaginationMeta meta;

  const ProjectTasksGroupResult({
    this.open = const [],
    this.completed = const [],
    this.meta = const ProjectTasksPaginationMeta(),
  });
}
