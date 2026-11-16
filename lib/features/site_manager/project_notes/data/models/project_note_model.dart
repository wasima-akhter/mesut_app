import '../../../projects/enums.dart';
import '../../domain/entities/project_note_entity.dart';

class ProjectNoteAuthorModel extends ProjectNoteAuthorEntity {
  const ProjectNoteAuthorModel({
    required super.id,
    super.firstName,
    super.lastName,
  });

  factory ProjectNoteAuthorModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProjectNoteAuthorModel(id: '');
    return ProjectNoteAuthorModel(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
    );
  }
}

class ProjectNoteModel extends ProjectNoteEntity {
  const ProjectNoteModel({
    required super.id,
    required super.projectId,
    super.category,
    super.content,
    super.author,
    super.createdAt,
  });

  factory ProjectNoteModel.fromJson(Map<String, dynamic> json) {
    return ProjectNoteModel(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      category: parseCategory(json['category'] as String?),
      content: json['content'] as String? ?? json['details'] as String? ?? '',
      author: json['author'] is Map<String, dynamic>
          ? ProjectNoteAuthorModel.fromJson(
              json['author'] as Map<String, dynamic>,
            )
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'category': categoryToApi(category), 'content': content};
  }

  static ProjectNoteCategory parseCategory(String? raw) {
    final str = raw?.trim().toUpperCase().replaceAll(' ', '_') ?? '';
    switch (str) {
      case 'SITE_ACCESS':
        return ProjectNoteCategory.siteAccess;
      case 'CUSTOMER_REQUEST':
        return ProjectNoteCategory.customerRequest;
      case 'OPEN_POINTS':
        return ProjectNoteCategory.openPoints;
      case 'AGREEMENTS':
        return ProjectNoteCategory.agreements;
      case 'SPECIAL_REQUIREMENTS':
        return ProjectNoteCategory.specialRequirements;
      case 'LOCAL_CONTACT':
        return ProjectNoteCategory.localContact;
      case 'GENERAL':
      default:
        return ProjectNoteCategory.general;
    }
  }

  static String categoryToApi(ProjectNoteCategory category) {
    switch (category) {
      case ProjectNoteCategory.siteAccess:
        return 'SITE_ACCESS';
      case ProjectNoteCategory.customerRequest:
        return 'CUSTOMER_REQUEST';
      case ProjectNoteCategory.openPoints:
        return 'OPEN_POINTS';
      case ProjectNoteCategory.agreements:
        return 'AGREEMENTS';
      case ProjectNoteCategory.specialRequirements:
        return 'SPECIAL_REQUIREMENTS';
      case ProjectNoteCategory.localContact:
        return 'LOCAL_CONTACT';
      case ProjectNoteCategory.general:
        return 'GENERAL';
    }
  }
}

class ProjectNoteMetaModel extends ProjectNoteMetaEntity {
  const ProjectNoteMetaModel({
    super.total,
    super.totalPages,
    super.currentPage,
  });

  factory ProjectNoteMetaModel.fromJson(
    Map<String, dynamic>? json, {
    int requestedPage = 1,
  }) {
    if (json == null) return ProjectNoteMetaModel(currentPage: requestedPage);
    return ProjectNoteMetaModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      currentPage: requestedPage,
    );
  }
}

class ProjectNoteResponseModel extends ProjectNoteResponseEntity {
  const ProjectNoteResponseModel({super.items, super.meta});

  factory ProjectNoteResponseModel.fromJson(
    Map<String, dynamic> json, {
    int requestedPage = 1,
  }) {
    final data = json['data'];
    List<ProjectNoteModel> items = [];

    if (data is List<dynamic>) {
      items = data
          .whereType<Map<String, dynamic>>()
          .map(ProjectNoteModel.fromJson)
          .toList();
    } else if (data is Map<String, dynamic> && data['items'] is List) {
      final list = data['items'] as List;
      items = list
          .whereType<Map<String, dynamic>>()
          .map(ProjectNoteModel.fromJson)
          .toList();
    }

    final meta = ProjectNoteMetaModel.fromJson(
      json['meta'] as Map<String, dynamic>?,
      requestedPage: requestedPage,
    );

    return ProjectNoteResponseModel(items: items, meta: meta);
  }
}
