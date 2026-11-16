import '../entities/project_phase_dates_entity.dart';

abstract class ProjectDatesRepository {
  Future<List<ProjectPhaseDateItemEntity>> getProjectPhases(String projectId);

  Future<ProjectPhaseDateItemEntity> updatePhaseDates({
    required String projectId,
    required String phaseId,
    required DateTime startDate,
    required DateTime endDate,
    required int durationDays,
    bool? safetyInspectionComplete,
  });
}
