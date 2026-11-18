import 'package:construction_app/core/localization/localization_meta.dart';

class MobilePhaseProjectEntity {
  const MobilePhaseProjectEntity({
    required this.id,
    required this.name,
    required this.address,
  });

  final String id;
  final String name;
  final String address;
}

class MobilePhaseEntity {
  const MobilePhaseEntity({
    required this.id,
    required this.type,
    required this.status,
    required this.priority,
    this.startDate,
    this.endDate,
    required this.project,
    this.localization,
  });

  final String id;
  final String type;
  final String status;
  final String priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final MobilePhaseProjectEntity project;
  final LocalizationMeta? localization;

  MobilePhaseEntity copyWith({
    String? id,
    String? type,
    String? status,
    String? priority,
    DateTime? startDate,
    DateTime? endDate,
    MobilePhaseProjectEntity? project,
    LocalizationMeta? localization,
  }) {
    return MobilePhaseEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      project: project ?? this.project,
      localization: localization ?? this.localization,
    );
  }
}
