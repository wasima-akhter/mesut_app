import '../entities/project_attachment_entity.dart';

abstract class ProjectAttachmentsRepository {
  Future<ProjectAttachmentResponseEntity> getAttachments(
    String projectId, {
    String? category,
    int page = 1,
    int limit = 10,
  });

  Future<ProjectAttachmentEntity> registerAttachment(
    String projectId, {
    required String url,
    required String fileType,
    required String category,
    required String fileName,
    required int fileSize,
    bool isCover = false,
  });

  Future<ProjectAttachmentEntity> setCoverPhoto(
    String projectId,
    String attachmentId,
  );

  Future<bool> deleteAttachment(
    String projectId,
    String attachmentId,
  );
}
