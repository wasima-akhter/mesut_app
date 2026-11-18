import '../../../../../core/localization/localization_meta.dart';
import '../../domain/entities/project_measurement_entity.dart';

class ProjectMeasurementModel extends ProjectMeasurementEntity {
  const ProjectMeasurementModel({
    required super.id,
    required super.projectId,
    super.position,
    super.length,
    super.height,
    super.quantity,
    super.unit,
    super.remark,
    super.area,
    super.scaffoldType,
    super.createdAt,
    super.localization,
  });

  factory ProjectMeasurementModel.fromJson(Map<String, dynamic> json) {
    return ProjectMeasurementModel(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      position: json['position'] as String? ?? '',
      length: _asDouble(json['length']),
      height: _asDouble(json['height']),
      quantity: _asInt(json['quantity']),
      unit: json['unit'] as String? ?? 'M²',
      remark: json['remark'] as String? ?? '',
      area: _asDouble(json['area']),
      scaffoldType: json['scaffoldType'] as String? ?? 'Front Scaffold',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      localization: LocalizationMeta.tryParse(json),
    );
  }

  static double _asDouble(dynamic val) {
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  static int _asInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 1;
    return 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'length': length,
      'height': height,
      'quantity': quantity,
      'unit': unit,
      if (remark.isNotEmpty) 'remark': remark,
    };
  }
}

class ProjectMeasurementMetaModel extends ProjectMeasurementMetaEntity {
  const ProjectMeasurementMetaModel({
    super.total,
    super.totalPages,
    super.currentPage,
  });

  factory ProjectMeasurementMetaModel.fromJson(
    Map<String, dynamic>? json, {
    int requestedPage = 1,
  }) {
    if (json == null) {
      return ProjectMeasurementMetaModel(currentPage: requestedPage);
    }
    return ProjectMeasurementMetaModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      currentPage: requestedPage,
    );
  }
}

class ProjectMeasurementResponseModel extends ProjectMeasurementResponseEntity {
  const ProjectMeasurementResponseModel({
    super.items,
    super.totalArea,
    super.meta,
  });

  factory ProjectMeasurementResponseModel.fromJson(
    Map<String, dynamic> json, {
    int requestedPage = 1,
  }) {
    final data = json['data'];
    List<ProjectMeasurementModel> items = [];
    double totalArea = 0.0;

    if (data is Map<String, dynamic>) {
      final itemsList = data['items'] as List<dynamic>? ?? [];
      items = itemsList
          .whereType<Map<String, dynamic>>()
          .map(ProjectMeasurementModel.fromJson)
          .toList();
      totalArea = (data['totalArea'] as num?)?.toDouble() ?? 0.0;
    } else if (data is List<dynamic>) {
      items = data
          .whereType<Map<String, dynamic>>()
          .map(ProjectMeasurementModel.fromJson)
          .toList();
      totalArea = items.fold(0.0, (sum, item) => sum + item.calculatedArea);
    }

    final meta = ProjectMeasurementMetaModel.fromJson(
      json['meta'] as Map<String, dynamic>?,
      requestedPage: requestedPage,
    );

    return ProjectMeasurementResponseModel(
      items: items,
      totalArea: totalArea,
      meta: meta,
    );
  }
}
