import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project_note_entity.dart';
import '../../domain/repositories/project_notes_repository.dart';
import '../datasources/project_notes_datasource.dart';
import '../models/project_note_model.dart';

class ProjectNotesRepositoryImpl implements ProjectNotesRepository {
  final ProjectNotesDatasource _datasource;

  ProjectNotesRepositoryImpl(this._datasource);

  @override
  Future<ProjectNoteResponseEntity> getProjectNotes({
    required String projectId,
    int page = 1,
    int limit = 10,
  }) async {
    final json = await _datasource.fetchProjectNotes(
      projectId: projectId,
      page: page,
      limit: limit,
    );
    return ProjectNoteResponseModel.fromJson(
      json,
      requestedPage: page,
    );
  }

  @override
  Future<ProjectNoteEntity> createNote({
    required String projectId,
    required String category,
    required String content,
  }) async {
    final body = {
      'category': category,
      'content': content,
    };

    final json = await _datasource.createProjectNote(
      projectId: projectId,
      body: body,
    );

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return ProjectNoteModel.fromJson(data);
    }
    return ProjectNoteModel(
      id: '',
      projectId: projectId,
      category: ProjectNoteModel.parseCategory(category),
      content: content,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<ProjectNoteEntity> updateNote({
    required String projectId,
    required String noteId,
    required String category,
    required String content,
  }) async {
    final body = {
      'category': category,
      'content': content,
    };

    final json = await _datasource.updateProjectNote(
      projectId: projectId,
      noteId: noteId,
      body: body,
    );

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return ProjectNoteModel.fromJson(data);
    }
    return ProjectNoteModel(
      id: noteId,
      projectId: projectId,
      category: ProjectNoteModel.parseCategory(category),
      content: content,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<bool> deleteNote({
    required String projectId,
    required String noteId,
  }) async {
    final json = await _datasource.deleteProjectNote(
      projectId: projectId,
      noteId: noteId,
    );
    return json['success'] == true;
  }
}

final projectNotesRepositoryProvider = Provider<ProjectNotesRepository>((ref) {
  final datasource = ref.watch(projectNotesDatasourceProvider);
  return ProjectNotesRepositoryImpl(datasource);
});
