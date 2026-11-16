import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project_phase_dates_entity.dart';
import '../../domain/repositories/project_dates_repository.dart';
import '../datasources/project_dates_datasource.dart';
import '../models/project_phase_dates_model.dart';

class ProjectDatesRepositoryImpl implements ProjectDatesRepository {
  final ProjectDatesDatasource _datasource;

  ProjectDatesRepositoryImpl(this._datasource);

  @override
  Future<List<ProjectPhaseDateItemEntity>> getProjectPhases(
    String projectId,
  ) async {
    final res = await _datasource.fetchProjectPhases(projectId);
    final data = res['data'];

    if (data is Map<String, dynamic>) {
      final phasesRaw = data['phases'] as List? ?? [];
      if (phasesRaw.isNotEmpty) {
        return phasesRaw
            .whereType<Map<String, dynamic>>()
            .map((p) => ProjectPhaseDateItemModel.fromJson(
                  p,
                  fallbackProjectId: projectId,
                ))
            .toList();
      }

      // Fallback to scheduleData if phases list is empty
      final schedRaw = data['scheduleData'] as List? ?? [];
      if (schedRaw.isNotEmpty) {
        return schedRaw
            .whereType<Map<String, dynamic>>()
            .map((s) => ProjectPhaseDateItemModel.fromJson(
                  s,
                  fallbackProjectId: projectId,
                ))
            .toList();
      }
    }

    return [];
  }

  @override
  Future<ProjectPhaseDateItemEntity> updatePhaseDates({
    required String projectId,
    required String phaseId,
    required DateTime startDate,
    required DateTime endDate,
    required int durationDays,
    bool? safetyInspectionComplete,
  }) async {
    final payload = <String, dynamic>{
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'durationDays': durationDays,
    };
    if (safetyInspectionComplete != null) {
      payload['safetyInspectionComplete'] = safetyInspectionComplete;
    }

    final res = await _datasource.updatePhaseDates(
      projectId: projectId,
      phaseId: phaseId,
      body: payload,
    );

    final rawData = res['data'];
    if (rawData is Map<String, dynamic>) {
      return ProjectPhaseDateItemModel.fromJson(
        rawData,
        fallbackProjectId: projectId,
      );
    }

    throw Exception(res['message']?.toString() ?? 'Failed to update phase dates');
  }
}

final projectDatesRepositoryProvider = Provider<ProjectDatesRepository>((ref) {
  final ds = ref.watch(projectDatesDatasourceProvider);
  return ProjectDatesRepositoryImpl(ds);
});
