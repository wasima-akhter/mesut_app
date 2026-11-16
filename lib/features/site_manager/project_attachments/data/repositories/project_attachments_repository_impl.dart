import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project_attachment_entity.dart';
import '../../domain/repositories/project_attachments_repository.dart';
import '../datasources/project_attachments_datasource.dart';
import '../models/project_attachment_model.dart';

class ProjectAttachmentsRepositoryImpl implements ProjectAttachmentsRepository {
  final ProjectAttachmentsDatasource _datasource;

  ProjectAttachmentsRepositoryImpl(this._datasource);

  @override
  Future<ProjectAttachmentResponseEntity> getAttachments(
    String projectId, {
    String? category,
    int page = 1,
    int limit = 10,
  }) async {
    final res = await _datasource.fetchAttachments(
      projectId: projectId,
      category: category,
      page: page,
      limit: limit,
    );
    return ProjectAttachmentResponseModel.fromJson(
      res,
      requestedPage: page,
    );
  }

  @override
  Future<ProjectAttachmentEntity> registerAttachment(
    String projectId, {
    required String url,
    required String fileType,
    required String category,
    required String fileName,
    required int fileSize,
    bool isCover = false,
  }) async {
    final payload = {
      'url': url,
      'fileType': fileType,
      'category': category.toUpperCase(),
      'fileName': fileName,
      'fileSize': fileSize,
      'isCover': isCover,
    };

    final res = await _datasource.registerAttachment(
      projectId: projectId,
      body: payload,
    );

    final rawData = res['data'];
    if (rawData is Map<String, dynamic>) {
      return ProjectAttachmentModel.fromJson(rawData);
    }
    throw Exception(res['message']?.toString() ?? 'Failed to register attachment');
  }

  @override
  Future<ProjectAttachmentEntity> setCoverPhoto(
    String projectId,
    String attachmentId,
  ) async {
    final res = await _datasource.setCoverPhoto(
      projectId: projectId,
      attachmentId: attachmentId,
    );

    final rawData = res['data'];
    if (rawData is Map<String, dynamic>) {
      return ProjectAttachmentModel.fromJson(rawData);
    }
    throw Exception(res['message']?.toString() ?? 'Failed to update cover photo');
  }

  @override
  Future<bool> deleteAttachment(
    String projectId,
    String attachmentId,
  ) async {
    final res = await _datasource.deleteAttachment(
      projectId: projectId,
      attachmentId: attachmentId,
    );

    return res['success'] == true || res['data'] != null;
  }
}

final projectAttachmentsRepositoryProvider =
    Provider<ProjectAttachmentsRepository>((ref) {
  final ds = ref.watch(projectAttachmentsDatasourceProvider);
  return ProjectAttachmentsRepositoryImpl(ds);
});
