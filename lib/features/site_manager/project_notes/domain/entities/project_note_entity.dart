import '../../../../../core/localization/localization_meta.dart';
import '../../../projects/enums.dart';

/// Author entity associated with a note.
class ProjectNoteAuthorEntity {
  final String id;
  final String firstName;
  final String lastName;

  const ProjectNoteAuthorEntity({
    required this.id,
    this.firstName = '',
    this.lastName = '',
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : 'Unknown';
  }
}

/// Domain entity representing a project note.
class ProjectNoteEntity {
  final String id;
  final String projectId;
  final ProjectNoteCategory category;
  final String content;
  final ProjectNoteAuthorEntity? author;
  final DateTime? createdAt;

  const ProjectNoteEntity({
    required this.id,
    required this.projectId,
    this.category = ProjectNoteCategory.general,
    this.content = '',
    this.author,
    this.createdAt,
    this.localization,
  });

  final LocalizationMeta? localization;

  String get authorName => author?.fullName ?? 'Site Manager';

  ProjectNoteEntity copyWith({
    String? id,
    String? projectId,
    ProjectNoteCategory? category,
    String? content,
    ProjectNoteAuthorEntity? author,
    DateTime? createdAt,
  }) {
    return ProjectNoteEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      category: category ?? this.category,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Metadata for project notes pagination.
class ProjectNoteMetaEntity {
  final int total;
  final int totalPages;
  final int currentPage;

  const ProjectNoteMetaEntity({
    this.total = 0,
    this.totalPages = 1,
    this.currentPage = 1,
  });
}

/// Response entity containing list of project notes and pagination metadata.
class ProjectNoteResponseEntity {
  final List<ProjectNoteEntity> items;
  final ProjectNoteMetaEntity meta;

  const ProjectNoteResponseEntity({
    this.items = const [],
    this.meta = const ProjectNoteMetaEntity(),
  });
}
