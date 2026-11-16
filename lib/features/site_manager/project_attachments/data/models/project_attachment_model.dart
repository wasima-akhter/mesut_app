import '../../domain/entities/project_attachment_entity.dart';

class ProjectAttachmentModel extends ProjectAttachmentEntity {
  const ProjectAttachmentModel({
    required super.id,
    required super.url,
    required super.fileType,
    required super.fileName,
    required super.fileSize,
    super.isCover = false,
    super.category = 'PHOTO',
    required super.projectId,
    super.inspectionId,
    super.createdAt,
  });

  factory ProjectAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ProjectAttachmentModel(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      fileType: json['fileType']?.toString() ?? 'image/jpeg',
      fileName: json['fileName']?.toString() ?? 'attachment',
      fileSize: _asInt(json['fileSize']),
      isCover: _asBool(json['isCover']),
      category: json['category']?.toString() ?? 'PHOTO',
      projectId: json['projectId']?.toString() ?? '',
      inspectionId: json['inspectionId']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'fileType': fileType,
        'fileName': fileName,
        'fileSize': fileSize,
        'isCover': isCover,
        'category': category,
        'projectId': projectId,
        'inspectionId': inspectionId,
        'createdAt': createdAt?.toIso8601String(),
      };

  Map<String, dynamic> toRegisterPayload() => {
        'url': url,
        'fileType': fileType,
        'category': category,
        'fileName': fileName,
        'fileSize': fileSize,
        'isCover': isCover,
      };

  static int _asInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  static bool _asBool(dynamic val) {
    if (val is bool) return val;
    if (val is String) return val.toLowerCase() == 'true';
    if (val is num) return val != 0;
    return false;
  }
}

class ProjectAttachmentMetaModel extends ProjectAttachmentMetaEntity {
  const ProjectAttachmentMetaModel({
    super.total,
    super.totalPages,
    super.currentPage,
  });

  factory ProjectAttachmentMetaModel.fromJson(
    Map<String, dynamic>? json, {
    int requestedPage = 1,
  }) {
    if (json == null) {
      return ProjectAttachmentMetaModel(currentPage: requestedPage);
    }
    return ProjectAttachmentMetaModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      currentPage: requestedPage,
    );
  }
}

class ProjectAttachmentResponseModel extends ProjectAttachmentResponseEntity {
  const ProjectAttachmentResponseModel({super.items, super.meta});

  factory ProjectAttachmentResponseModel.fromJson(
    Map<String, dynamic> json, {
    int requestedPage = 1,
  }) {
    final data = json['data'];
    List<ProjectAttachmentModel> items = [];

    if (data is List<dynamic>) {
      items = data
          .whereType<Map<String, dynamic>>()
          .map(ProjectAttachmentModel.fromJson)
          .toList();
    } else if (data is Map<String, dynamic> && data['items'] is List) {
      final list = data['items'] as List;
      items = list
          .whereType<Map<String, dynamic>>()
          .map(ProjectAttachmentModel.fromJson)
          .toList();
    }

    final meta = ProjectAttachmentMetaModel.fromJson(
      json['meta'] as Map<String, dynamic>?,
      requestedPage: requestedPage,
    );

    return ProjectAttachmentResponseModel(items: items, meta: meta);
  }
}
