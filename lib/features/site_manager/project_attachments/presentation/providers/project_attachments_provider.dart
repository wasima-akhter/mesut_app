import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/services/image_service.dart';
import '../../../../media/domain/repositories/media_repository.dart';
import '../../../../media/presentation/providers/media_providers.dart';
import '../../../offline_sync/models/site_manager_sync_action.dart';
import '../../../offline_sync/providers/site_manager_sync_provider.dart';
import '../../data/repositories/project_attachments_repository_impl.dart';
import '../../domain/entities/project_attachment_entity.dart';
import '../../domain/repositories/project_attachments_repository.dart';
import 'project_attachments_state.dart';

class ProjectAttachmentsNotifier extends Notifier<ProjectAttachmentsState> {
  static const int _pageSize = 10;

  @override
  ProjectAttachmentsState build() {
    return const ProjectAttachmentsState();
  }

  ProjectAttachmentsRepository get _repository =>
      ref.read(projectAttachmentsRepositoryProvider);

  MediaRepository get _mediaRepository => ref.read(mediaRepositoryProvider);

  void setActiveFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  /// Initial load or pull-to-refresh of attachments for [projectId].
  Future<void> loadInitial(String projectId, {bool isRefresh = false}) async {
    final isDifferentProject = state.projectId != projectId;

    state = state.copyWith(
      isLoading: isDifferentProject || !isRefresh,
      clearError: true,
      projectId: projectId,
      items: isDifferentProject ? const [] : state.items,
      page: 1,
    );

    try {
      final response = await _repository.getAttachments(
        projectId,
        page: 1,
        limit: _pageSize,
      );

      final hasMore =
          response.meta.totalPages > 1 && response.items.length >= _pageSize;

      state = state.copyWith(
        isLoading: false,
        items: response.items,
        page: 1,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Pagination loader: fetches the next page and appends to current list.
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true);

    try {
      final response = await _repository.getAttachments(
        state.projectId,
        page: nextPage,
        limit: _pageSize,
      );

      final hasMore = response.meta.totalPages > nextPage &&
          response.items.length >= _pageSize;

      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...response.items],
        page: nextPage,
        hasMore: hasMore,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<bool> uploadPhotoFromSource({
    required ImageSource source,
    bool isCover = false,
  }) async {
    final file = await AppImageService.pickCompressedImage(source: source);
    if (file == null) return false;

    return _uploadSingleFile(
      file: file,
      category: 'PHOTO',
      fileType: 'image/jpeg',
      isCover: isCover,
    );
  }

  Future<bool> uploadMultiplePhotos() async {
    final files = await AppImageService.pickMultipleCompressedImages(limit: 10);
    if (files.isEmpty) return false;

    state = state.copyWith(isMutating: true, clearError: true);
    var anySuccess = false;

    for (final file in files) {
      final success = await _uploadSingleFile(
        file: file,
        category: 'PHOTO',
        fileType: 'image/jpeg',
        isCover: false,
        skipLocalLoadingState: true,
      );
      if (success) anySuccess = true;
    }

    state = state.copyWith(isMutating: false);
    return anySuccess;
  }

  Future<bool> uploadPlanFile({
    required File file,
    required String fileName,
  }) async {
    return _uploadSingleFile(
      file: file,
      category: 'PDF_PLAN',
      fileType: 'application/pdf',
      overrideFileName: fileName,
      isCover: false,
    );
  }

  Future<bool> _uploadSingleFile({
    required File file,
    required String category,
    required String fileType,
    String? overrideFileName,
    bool isCover = false,
    bool skipLocalLoadingState = false,
  }) async {
    if (!skipLocalLoadingState) {
      state = state.copyWith(isMutating: true, clearError: true);
    }

    final fileName =
        overrideFileName ?? file.path.split(Platform.pathSeparator).last;
    final fileSize = await file.length();

    try {
      String remoteUrl;
      try {
        final uploadedUrls = await _mediaRepository.uploadMedia(files: [file]);
        remoteUrl = uploadedUrls.isNotEmpty ? uploadedUrls.first : file.path;
      } catch (_) {
        remoteUrl = file.path;
      }

      final newAttachment = await _repository.registerAttachment(
        state.projectId,
        url: remoteUrl,
        fileType: fileType,
        category: category,
        fileName: fileName,
        fileSize: fileSize,
        isCover: isCover,
      );

      final updatedList = isCover
          ? state.items.map((a) => a.copyWith(isCover: false)).toList()
          : List.of(state.items);
      updatedList.insert(0, newAttachment);

      state = state.copyWith(
        items: updatedList,
        isMutating: skipLocalLoadingState ? state.isMutating : false,
      );
      return true;
    } catch (_) {
      final localId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
      final offlineAttachment = ProjectAttachmentEntity(
        id: localId,
        projectId: state.projectId,
        url: file.path,
        fileType: fileType,
        category: category,
        fileName: fileName,
        fileSize: fileSize,
        isCover: isCover,
        createdAt: DateTime.now(),
      );

      final action = SiteManagerSyncAction(
        id: localId,
        actionType: SiteManagerSyncActionType.uploadAttachment,
        endpoint: ApiConstants.mobileProjectAttachments(state.projectId),
        httpMethod: 'POST',
        projectId: state.projectId,
        filePath: file.path,
        displayTitle: 'Attachment: $fileName',
        createdAt: DateTime.now(),
        payload: {
          'fileType': fileType,
          'category': category,
          'fileName': fileName,
          'fileSize': fileSize,
          'isCover': isCover,
        },
      );
      await ref.read(siteManagerSyncProvider.notifier).enqueue(action);

      final updatedList = isCover
          ? state.items.map((a) => a.copyWith(isCover: false)).toList()
          : List.of(state.items);
      updatedList.insert(0, offlineAttachment);

      state = state.copyWith(
        items: updatedList,
        isMutating: skipLocalLoadingState ? state.isMutating : false,
      );
      return true;
    }
  }

  Future<bool> setCoverPhoto(String attachmentId) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      final updated = await _repository.setCoverPhoto(state.projectId, attachmentId);
      final updatedList = state.items.map((a) => a.id == updated.id ? updated : a.copyWith(isCover: false)).toList();
      state = state.copyWith(items: updatedList, isMutating: false);
      return true;
    } catch (_) {
      final action = SiteManagerSyncAction(
        id: 'cover_${DateTime.now().millisecondsSinceEpoch}',
        actionType: SiteManagerSyncActionType.setCoverAttachment,
        endpoint: ApiConstants.mobileProjectAttachmentCover(state.projectId, attachmentId),
        httpMethod: 'PATCH',
        projectId: state.projectId,
        displayTitle: 'Set Cover Photo',
        createdAt: DateTime.now(),
      );
      await ref.read(siteManagerSyncProvider.notifier).enqueue(action);

      final updatedList = state.items.map((a) => a.id == attachmentId ? a.copyWith(isCover: true) : a.copyWith(isCover: false)).toList();
      state = state.copyWith(items: updatedList, isMutating: false);
      return true;
    }
  }

  Future<bool> deleteAttachment(String attachmentId) async {
    final updatedList = state.items.where((a) => a.id != attachmentId).toList();
    state = state.copyWith(items: updatedList, isMutating: false);

    try {
      await _repository.deleteAttachment(state.projectId, attachmentId);
      return true;
    } catch (_) {
      final action = SiteManagerSyncAction(
        id: 'del_att_${DateTime.now().millisecondsSinceEpoch}',
        actionType: SiteManagerSyncActionType.deleteAttachment,
        endpoint: ApiConstants.mobileProjectAttachmentById(state.projectId, attachmentId),
        httpMethod: 'DELETE',
        projectId: state.projectId,
        displayTitle: 'Delete Attachment',
        createdAt: DateTime.now(),
      );
      await ref.read(siteManagerSyncProvider.notifier).enqueue(action);
      return true;
    }
  }
}

final projectAttachmentsProvider =
    NotifierProvider<ProjectAttachmentsNotifier, ProjectAttachmentsState>(
  ProjectAttachmentsNotifier.new,
);
