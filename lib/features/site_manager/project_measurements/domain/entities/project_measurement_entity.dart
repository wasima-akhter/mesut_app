import '../../../../../core/localization/localization_meta.dart';

/// Domain entity representing a scaffold measurement item.
class ProjectMeasurementEntity {
  final String id;
  final String projectId;
  final String position;
  final double length;
  final double height;
  final int quantity;
  final String unit;
  final String remark;
  final double area;
  final String scaffoldType;
  final DateTime? createdAt;

  const ProjectMeasurementEntity({
    required this.id,
    required this.projectId,
    this.position = '',
    this.length = 0.0,
    this.height = 0.0,
    this.quantity = 1,
    this.unit = 'M²',
    this.remark = '',
    this.area = 0.0,
    this.scaffoldType = 'Front Scaffold',
    this.createdAt,
    this.localization,
  });

  final LocalizationMeta? localization;

  /// Computed area as length * height * quantity.
  /// Falls back to API calculated area if available.
  double get calculatedArea {
    if (area > 0) return area;
    return length * height * quantity;
  }

  /// Human-readable dimensions text (e.g., L: 30.00 m × H: 10.00 m × Qty: 1)
  String get dimensionsText {
    final lenStr = length.toStringAsFixed(2);
    final hgtStr = height.toStringAsFixed(2);
    return 'L: $lenStr m × H: $hgtStr m × Qty: $quantity';
  }

  ProjectMeasurementEntity copyWith({
    String? id,
    String? projectId,
    String? position,
    double? length,
    double? height,
    int? quantity,
    String? unit,
    String? remark,
    double? area,
    String? scaffoldType,
    DateTime? createdAt,
  }) {
    return ProjectMeasurementEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      position: position ?? this.position,
      length: length ?? this.length,
      height: height ?? this.height,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      remark: remark ?? this.remark,
      area: area ?? this.area,
      scaffoldType: scaffoldType ?? this.scaffoldType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Metadata for measurement list pagination.
class ProjectMeasurementMetaEntity {
  final int total;
  final int totalPages;
  final int currentPage;

  const ProjectMeasurementMetaEntity({
    this.total = 0,
    this.totalPages = 1,
    this.currentPage = 1,
  });
}

/// Aggregated response entity containing measurements and project total area.
class ProjectMeasurementResponseEntity {
  final List<ProjectMeasurementEntity> items;
  final double totalArea;
  final ProjectMeasurementMetaEntity meta;

  const ProjectMeasurementResponseEntity({
    this.items = const [],
    this.totalArea = 0.0,
    this.meta = const ProjectMeasurementMetaEntity(),
  });
}
