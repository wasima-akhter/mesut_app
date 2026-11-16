import '../../domain/entities/project_attachment_entity.dart';

class ProjectAttachmentsState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool isMutating;
  final String? errorMessage;
  final List<ProjectAttachmentEntity> items;
  final String activeFilter; // 'all', 'photos', 'plans'
  final int page;
  final bool hasMore;
  final String projectId;

  const ProjectAttachmentsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isMutating = false,
    this.errorMessage,
    this.items = const [],
    this.activeFilter = 'all',
    this.page = 1,
    this.hasMore = true,
    this.projectId = '',
  });

  bool get isEmpty => !isLoading && items.isEmpty;

  ProjectAttachmentEntity? get coverPhoto {
    final photoList = photos;
    final markedCover = photoList.where((p) => p.isCover).firstOrNull;
    if (markedCover != null) return markedCover;
    return photoList.firstOrNull;
  }

  List<ProjectAttachmentEntity> get photos =>
      items.where((a) => a.isPhoto).toList();

  List<ProjectAttachmentEntity> get otherPhotos {
    final cover = coverPhoto;
    if (cover == null) return [];
    return photos.where((p) => p.id != cover.id).toList();
  }

  List<ProjectAttachmentEntity> get pdfPlans =>
      items.where((a) => a.isPdfPlan).toList();

  int get photoCount => photos.length;
  int get planCount => pdfPlans.length;

  bool get showPhotosSection =>
      activeFilter == 'all' || activeFilter == 'photos';

  bool get showPlansSection =>
      activeFilter == 'all' || activeFilter == 'plans';

  ProjectAttachmentsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isMutating,
    String? errorMessage,
    bool clearError = false,
    List<ProjectAttachmentEntity>? items,
    String? activeFilter,
    int? page,
    bool? hasMore,
    String? projectId,
  }) {
    return ProjectAttachmentsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      items: items ?? this.items,
      activeFilter: activeFilter ?? this.activeFilter,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      projectId: projectId ?? this.projectId,
    );
  }
}
