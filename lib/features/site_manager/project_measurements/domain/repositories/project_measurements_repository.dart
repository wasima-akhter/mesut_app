import '../entities/project_measurement_entity.dart';

abstract class ProjectMeasurementsRepository {
  Future<ProjectMeasurementResponseEntity> getProjectMeasurements({
    required String projectId,
    int page = 1,
    int limit = 10,
  });

  Future<ProjectMeasurementEntity> createMeasurement({
    required String projectId,
    required String position,
    required double length,
    required double height,
    required int quantity,
    required String unit,
    String? remark,
  });

  Future<ProjectMeasurementEntity> updateMeasurement({
    required String projectId,
    required String measurementId,
    required String position,
    required double length,
    required double height,
    required int quantity,
    required String unit,
    String? remark,
  });

  Future<bool> deleteMeasurement({
    required String projectId,
    required String measurementId,
  });
}
