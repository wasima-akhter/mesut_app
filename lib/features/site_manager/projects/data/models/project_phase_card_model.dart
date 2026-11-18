import '../../../../../core/localization/localization_meta.dart';
import '../../domain/entities/project_phase_card_entity.dart';

class ProjectPhaseCardModel extends ProjectPhaseCardEntity {
  const ProjectPhaseCardModel({
    required super.phaseId,
    required super.type,
    required super.status,
    required super.priority,
    super.startDate,
    super.endDate,
    required super.durationDays,
    required super.projectId,
    required super.projectName,
    required super.coordinates,
    required super.customer,
    required super.assigneeName,
    required super.budgetedHours,
    required super.totalLoggedHours,
    required super.isProfitable,
    super.localization,
  });

  factory ProjectPhaseCardModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return null;
      }
    }

    final coordsJson = json['coordinates'] as Map<String, dynamic>? ?? {};
    final coords = ProjectPhaseCoordinates(
      lat: (coordsJson['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (coordsJson['lng'] as num?)?.toDouble() ?? 0.0,
    );

    final custJson = json['customer'] as Map<String, dynamic>? ?? {};
    final customer = ProjectPhaseCustomer(
      id: custJson['id']?.toString() ?? '',
      name: custJson['name']?.toString() ?? '',
      category: custJson['category']?.toString() ?? '',
    );

    return ProjectPhaseCardModel(
      phaseId: json['phaseId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'ERECTION',
      status: json['status']?.toString() ?? 'ENQUIRY',
      priority: json['priority']?.toString() ?? 'MEDIUM',
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
      projectId: json['projectId']?.toString() ?? '',
      projectName: json['projectName']?.toString() ?? '',
      coordinates: coords,
      customer: customer,
      assigneeName: json['assigneeName']?.toString() ?? '',
      budgetedHours: (json['budgetedHours'] as num?)?.toDouble() ?? 0.0,
      totalLoggedHours: (json['totalLoggedHours'] as num?)?.toDouble() ?? 0.0,
      isProfitable: json['isProfitable'] as bool? ?? true,
      localization: LocalizationMeta.tryParse(json),
    );
  }
}
