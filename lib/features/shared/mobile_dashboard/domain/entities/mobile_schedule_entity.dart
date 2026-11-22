import 'package:construction_app/core/localization/localization_meta.dart';
import 'mobile_dashboard_entity.dart';

class MobileSchedulePhaseEntity {
  const MobileSchedulePhaseEntity({
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
  final DashboardProjectSummaryEntity project;
  final LocalizationMeta? localization;
}

class MobileScheduleInspectionEntity {
  const MobileScheduleInspectionEntity({
    required this.id,
    required this.siteTitle,
    required this.address,
    this.postalCode = '',
    this.city = '',
    this.appointmentDate,
    this.scaffoldArea = 0,
    this.scaffoldHeight = 0,
    this.scaffoldType = '',
    this.siteAccessInstructions = '',
    this.specialRequirements = '',
    this.status = 'PENDING',
    this.projectId = '',
    this.customerName = '',
    this.customerCategory = '',
    this.convertedProjectId,
    this.convertedProjectName,
    this.localization,
  });

  final String id;
  final String siteTitle;
  final String address;
  final String postalCode;
  final String city;
  final DateTime? appointmentDate;
  final double scaffoldArea;
  final double scaffoldHeight;
  final String scaffoldType;
  final String siteAccessInstructions;
  final String specialRequirements;
  final String status;
  final String projectId;
  final String customerName;
  final String customerCategory;
  final String? convertedProjectId;
  final String? convertedProjectName;
  final LocalizationMeta? localization;
}

class MobileScheduleDayEntity {
  const MobileScheduleDayEntity({
    required this.date,
    this.phases = const [],
    this.inspections = const [],
  });

  final String date;
  final List<MobileSchedulePhaseEntity> phases;
  final List<MobileScheduleInspectionEntity> inspections;

  int get totalEvents => phases.length + inspections.length;
}
