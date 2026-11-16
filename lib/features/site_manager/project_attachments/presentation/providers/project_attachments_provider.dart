import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/services/image_service.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../media/domain/repositories/media_repository.dart';
import '../../../../media/presentation/providers/media_providers.dart';
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
    state = state.copyWith(
      isLoading: !isRefresh,
      clearError: true,
      projectId: projectId,
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
    } catch (e, st) {
      AppLogger.error(
        'Failed to load project attachments',
        error: e,
        stackTrace: st,
        name: 'ATTACHMENTS',
      );
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
    } catch (e, st) {
      AppLogger.error(
        'Failed to load more attachments',
        error: e,
        stackTrace: st,
        name: 'ATTACHMENTS',
      );
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

    try {
      final fileName = overrideFileName ??
          file.path.split(Platform.pathSeparator).last;
      final fileSize = await file.length();

      // Step 1: Upload media to S3 via Media repository
      String remoteUrl;
      try {
        final uploadedUrls = await _mediaRepository.uploadMedia(files: [file]);
        if (uploadedUrls.isNotEmpty) {
          remoteUrl = uploadedUrls.first;
        } else {
          remoteUrl = file.path;
        }
      } catch (_) {
        remoteUrl = file.path;
      }

      // Step 2: Register attachment row in database
      final newAttachment = await _repository.registerAttachment(
        state.projectId,
        url: remoteUrl,
        fileType: fileType,
        category: category,
        fileName: fileName,
        fileSize: fileSize,
        isCover: isCover,
      );

      // If registered as cover, unmark existing covers in state
      List<ProjectAttachmentEntity> updatedList;
      if (isCover) {
        updatedList =
            state.items.map((a) => a.copyWith(isCover: false)).toList();
      } else {
        updatedList = List.of(state.items);
      }
      updatedList.insert(0, newAttachment);

      state = state.copyWith(
        items: updatedList,
        isMutating: skipLocalLoadingState ? state.isMutating : false,
      );
      return true;
    } catch (e, st) {
      AppLogger.error(
        'Failed to upload attachment',
        error: e,
        stackTrace: st,
        name: 'ATTACHMENTS',
      );
      state = state.copyWith(
        isMutating: skipLocalLoadingState ? state.isMutating : false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> setCoverPhoto(String attachmentId) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      final updated =
          await _repository.setCoverPhoto(state.projectId, attachmentId);
      final updatedList = state.items.map((a) {
        if (a.id == updated.id) {
          return updated;
        }
        return a.copyWith(isCover: false);
      }).toList();

      state = state.copyWith(items: updatedList, isMutating: false);
      return true;
    } catch (e, st) {
      AppLogger.error(
        'Failed to set cover photo',
        error: e,
        stackTrace: st,
        name: 'ATTACHMENTS',
      );
      state = state.copyWith(isMutating: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteAttachment(String attachmentId) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      final ok =
          await _repository.deleteAttachment(state.projectId, attachmentId);
      if (ok) {
        final updatedList =
            state.items.where((a) => a.id != attachmentId).toList();
        state = state.copyWith(items: updatedList, isMutating: false);
        return true;
      }
      state = state.copyWith(isMutating: false);
      return false;
    } catch (e, st) {
      AppLogger.error(
        'Failed to delete attachment',
        error: e,
        stackTrace: st,
        name: 'ATTACHMENTS',
      );
      state = state.copyWith(isMutating: false, errorMessage: e.toString());
      return false;
    }
  }
}

final projectAttachmentsProvider =
    NotifierProvider<ProjectAttachmentsNotifier, ProjectAttachmentsState>(
  ProjectAttachmentsNotifier.new,
);
