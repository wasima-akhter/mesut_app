import '../../../../../core/localization/localization_meta.dart';

/// Domain entity representing a project attachment (Photo or PDF Plan).
class ProjectAttachmentEntity {
  final String id;
  final String url;
  final String fileType;
  final String fileName;
  final int fileSize;
  final bool isCover;
  final String category;
  final String projectId;
  final String? inspectionId;
  final DateTime? createdAt;
  final LocalizationMeta? localization;

  const ProjectAttachmentEntity({
    required this.id,
    required this.url,
    required this.fileType,
    required this.fileName,
    required this.fileSize,
    this.isCover = false,
    this.category = 'PHOTO',
    required this.projectId,
    this.inspectionId,
    this.createdAt,
    this.localization,
  });

  bool get isPhoto => category.toUpperCase() == 'PHOTO';

  bool get isPdfPlan =>
      category.toUpperCase() == 'PDF_PLAN' ||
      fileName.toLowerCase().endsWith('.pdf') ||
      fileType.toLowerCase().contains('pdf');

  String get formattedSize {
    if (fileSize <= 0) return '';
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  ProjectAttachmentEntity copyWith({
    String? id,
    String? url,
    String? fileType,
    String? fileName,
    int? fileSize,
    bool? isCover,
    String? category,
    String? projectId,
    String? inspectionId,
    DateTime? createdAt,
  }) {
    return ProjectAttachmentEntity(
      id: id ?? this.id,
      url: url ?? this.url,
      fileType: fileType ?? this.fileType,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      isCover: isCover ?? this.isCover,
      category: category ?? this.category,
      projectId: projectId ?? this.projectId,
      inspectionId: inspectionId ?? this.inspectionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Metadata for project attachments pagination.
class ProjectAttachmentMetaEntity {
  final int total;
  final int totalPages;
  final int currentPage;

  const ProjectAttachmentMetaEntity({
    this.total = 0,
    this.totalPages = 1,
    this.currentPage = 1,
  });
}

/// Response entity containing list of project attachments and pagination metadata.
class ProjectAttachmentResponseEntity {
  final List<ProjectAttachmentEntity> items;
  final ProjectAttachmentMetaEntity meta;

  const ProjectAttachmentResponseEntity({
    this.items = const [],
    this.meta = const ProjectAttachmentMetaEntity(),
  });
}
