import '../../../../../core/localization/localization_meta.dart';
import '../../domain/entities/project_history_entity.dart';

class ProjectHistoryUserModel extends ProjectHistoryUserEntity {
  const ProjectHistoryUserModel({
    required super.id,
    super.firstName,
    super.lastName,
    super.role,
  });

  factory ProjectHistoryUserModel.fromJson(Map<String, dynamic> json) {
    return ProjectHistoryUserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
      };
}

class ProjectHistoryModel extends ProjectHistoryEntity {
  const ProjectHistoryModel({
    required super.id,
    required super.action,
    required super.details,
    super.createdAt,
    super.user,
    super.localization,
  });

  factory ProjectHistoryModel.fromJson(Map<String, dynamic> json) {
    ProjectHistoryUserModel? user;
    if (json['user'] is Map<String, dynamic>) {
      user = ProjectHistoryUserModel.fromJson(
        json['user'] as Map<String, dynamic>,
      );
    }

    return ProjectHistoryModel(
      id: json['id']?.toString() ?? '',
      action: json['action']?.toString() ?? 'Action',
      details: json['details']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      user: user,
      localization: LocalizationMeta.tryParse(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'details': details,
        'createdAt': createdAt?.toIso8601String(),
        'user': user != null
            ? {
                'id': user!.id,
                'firstName': user!.firstName,
                'lastName': user!.lastName,
                'role': user!.role,
              }
            : null,
      };
}

class ProjectHistoryMetaModel extends ProjectHistoryMetaEntity {
  const ProjectHistoryMetaModel({
    super.total,
    super.totalPages,
    super.currentPage,
  });

  factory ProjectHistoryMetaModel.fromJson(
    Map<String, dynamic>? json, {
    int requestedPage = 1,
  }) {
    if (json == null) {
      return ProjectHistoryMetaModel(currentPage: requestedPage);
    }
    return ProjectHistoryMetaModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      currentPage: requestedPage,
    );
  }
}

class ProjectHistoryResponseModel extends ProjectHistoryResponseEntity {
  const ProjectHistoryResponseModel({super.items, super.meta});

  factory ProjectHistoryResponseModel.fromJson(
    Map<String, dynamic> json, {
    int requestedPage = 1,
  }) {
    final data = json['data'];
    List<ProjectHistoryModel> items = [];

    if (data is List<dynamic>) {
      items = data
          .whereType<Map<String, dynamic>>()
          .map(ProjectHistoryModel.fromJson)
          .toList();
    } else if (data is Map<String, dynamic> && data['items'] is List) {
      final list = data['items'] as List;
      items = list
          .whereType<Map<String, dynamic>>()
          .map(ProjectHistoryModel.fromJson)
          .toList();
    }

    final meta = ProjectHistoryMetaModel.fromJson(
      json['meta'] as Map<String, dynamic>?,
      requestedPage: requestedPage,
    );

    return ProjectHistoryResponseModel(items: items, meta: meta);
  }
}
