import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project_measurement_entity.dart';
import '../../domain/repositories/project_measurements_repository.dart';
import '../datasources/project_measurements_datasource.dart';
import '../models/project_measurement_model.dart';

class ProjectMeasurementsRepositoryImpl implements ProjectMeasurementsRepository {
  final ProjectMeasurementsDatasource _datasource;

  ProjectMeasurementsRepositoryImpl(this._datasource);

  @override
  Future<ProjectMeasurementResponseEntity> getProjectMeasurements({
    required String projectId,
    int page = 1,
    int limit = 10,
  }) async {
    final json = await _datasource.fetchProjectMeasurements(
      projectId: projectId,
      page: page,
      limit: limit,
    );
    return ProjectMeasurementResponseModel.fromJson(
      json,
      requestedPage: page,
    );
  }

  @override
  Future<ProjectMeasurementEntity> createMeasurement({
    required String projectId,
    required String position,
    required double length,
    required double height,
    required int quantity,
    required String unit,
    String? remark,
  }) async {
    final body = {
      'position': position,
      'length': length,
      'height': height,
      'quantity': quantity,
      'unit': unit,
      if (remark != null && remark.trim().isNotEmpty) 'remark': remark.trim(),
    };

    final json = await _datasource.createProjectMeasurement(
      projectId: projectId,
      body: body,
    );

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return ProjectMeasurementModel.fromJson(data);
    }
    return ProjectMeasurementModel(
      id: '',
      projectId: projectId,
      position: position,
      length: length,
      height: height,
      quantity: quantity,
      unit: unit,
      remark: remark ?? '',
      area: length * height * quantity,
    );
  }

  @override
  Future<ProjectMeasurementEntity> updateMeasurement({
    required String projectId,
    required String measurementId,
    required String position,
    required double length,
    required double height,
    required int quantity,
    required String unit,
    String? remark,
  }) async {
    final body = {
      'position': position,
      'length': length,
      'height': height,
      'quantity': quantity,
      'unit': unit,
      if (remark != null && remark.trim().isNotEmpty) 'remark': remark.trim(),
    };

    final json = await _datasource.updateProjectMeasurement(
      projectId: projectId,
      measurementId: measurementId,
      body: body,
    );

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return ProjectMeasurementModel.fromJson(data);
    }
    return ProjectMeasurementModel(
      id: measurementId,
      projectId: projectId,
      position: position,
      length: length,
      height: height,
      quantity: quantity,
      unit: unit,
      remark: remark ?? '',
      area: length * height * quantity,
    );
  }

  @override
  Future<bool> deleteMeasurement({
    required String projectId,
    required String measurementId,
  }) async {
    final json = await _datasource.deleteProjectMeasurement(
      projectId: projectId,
      measurementId: measurementId,
    );
    return json['success'] == true;
  }
}

final projectMeasurementsRepositoryProvider =
    Provider<ProjectMeasurementsRepository>((ref) {
  final datasource = ref.watch(projectMeasurementsDatasourceProvider);
  return ProjectMeasurementsRepositoryImpl(datasource);
});
