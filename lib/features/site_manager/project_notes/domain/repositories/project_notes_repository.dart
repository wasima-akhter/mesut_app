import '../entities/project_note_entity.dart';

abstract class ProjectNotesRepository {
  Future<ProjectNoteResponseEntity> getProjectNotes({
    required String projectId,
    int page = 1,
    int limit = 10,
  });

  Future<ProjectNoteEntity> createNote({
    required String projectId,
    required String category,
    required String content,
  });

  Future<ProjectNoteEntity> updateNote({
    required String projectId,
    required String noteId,
    required String category,
    required String content,
  });

  Future<bool> deleteNote({
    required String projectId,
    required String noteId,
  });
}
