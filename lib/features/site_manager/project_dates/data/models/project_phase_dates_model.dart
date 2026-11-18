import '../../../../../core/localization/localization_meta.dart';
import '../../domain/entities/project_phase_dates_entity.dart';

class ProjectPhaseDateItemModel extends ProjectPhaseDateItemEntity {
  const ProjectPhaseDateItemModel({
    required super.id,
    required super.projectId,
    required super.type,
    super.status = 'ENQUIRY',
    super.priority = 'MEDIUM',
    super.startDate,
    super.endDate,
    super.durationDays = 1,
    super.safetyInspectionComplete = false,
    super.localization,
  });

  factory ProjectPhaseDateItemModel.fromJson(
    Map<String, dynamic> json, {
    String fallbackProjectId = '',
  }) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return null;
      }
    }

    final durationVal = json['durationDays'];
    int parsedDuration = 1;
    if (durationVal is num) {
      parsedDuration = durationVal.toInt();
    } else if (durationVal is String) {
      parsedDuration = int.tryParse(durationVal) ?? 1;
    }

    final id = json['id']?.toString() ?? '';
    final projectId = json['projectId']?.toString() ?? fallbackProjectId;
    final type = json['type']?.toString() ?? 'ERECTION';
    final status = json['status']?.toString() ?? 'ENQUIRY';
    final priority = json['priority']?.toString() ?? 'MEDIUM';
    final safetyInspectionComplete =
        json['safetyInspectionComplete'] as bool? ?? false;

    return ProjectPhaseDateItemModel(
      id: id,
      projectId: projectId,
      type: type,
      status: status,
      priority: priority,
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      durationDays: parsedDuration > 0 ? parsedDuration : 1,
      safetyInspectionComplete: safetyInspectionComplete,
      localization: LocalizationMeta.tryParse(json),
    );
  }

  Map<String, dynamic> toUpdatePayload() => {
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'durationDays': durationDays,
        'safetyInspectionComplete': safetyInspectionComplete,
      };
}
