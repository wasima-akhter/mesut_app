import '../../../../../core/localization/localization_meta.dart';
import '../../domain/entities/project_details_entity.dart';

class ProjectDetailsModel extends ProjectDetailsEntity {
  const ProjectDetailsModel({
    required super.id,
    required super.name,
    required super.coordinates,
    required super.siteAccessCode,
    required super.siteAccessNotes,
    required super.scaffoldSpecification,
    required super.scheduleData,
    required super.nextSafetyInspection,
    required super.budgetedHours,
    required super.totalLoggedHours,
    required super.isProfitable,
    required super.phases,
    required super.customer,
    required super.hoursByActivity,
    required super.crewBreakdown,
    required super.attachmentCounts,
    super.localization,
  });

  factory ProjectDetailsModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return null;
      }
    }

    final coordsJson = json['coordinates'] as Map<String, dynamic>? ?? {};
    final coords = ProjectCoordinates(
      lat: (coordsJson['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (coordsJson['lng'] as num?)?.toDouble() ?? 0.0,
    );

    final specJson = json['scaffoldSpecification'] as Map<String, dynamic>? ?? {};
    final scaffoldSpec = ProjectScaffoldSpec(
      area: (specJson['area'] as num?)?.toDouble() ?? 0.0,
      height: (specJson['height'] as num?)?.toDouble() ?? 0.0,
      type: specJson['type']?.toString() ?? '',
    );

    final schedRaw = json['scheduleData'] as List? ?? [];
    final scheduleData = schedRaw
        .whereType<Map<String, dynamic>>()
        .map((s) => ProjectScheduleData(
              id: s['id']?.toString() ?? '',
              type: s['type']?.toString() ?? 'erection',
              startDate: parseDate(s['startDate']),
              endDate: parseDate(s['endDate']),
              durationDays: (s['durationDays'] as num?)?.toInt() ?? 0,
            ))
        .toList();

    final inspJson = json['nextSafetyInspection'] as Map<String, dynamic>? ?? {};
    final nextSafetyInspection = NextSafetyInspection(
      id: inspJson['id']?.toString() ?? '',
      appointmentDate: parseDate(inspJson['appointmentDate']),
      siteTitle: inspJson['siteTitle']?.toString() ?? '',
      address: inspJson['address']?.toString() ?? '',
      city: inspJson['city']?.toString() ?? '',
    );

    final phasesRaw = json['phases'] as List? ?? [];
    final phases = phasesRaw
        .whereType<Map<String, dynamic>>()
        .map((p) => ProjectPhaseItem(
              id: p['id']?.toString() ?? '',
              projectId: p['projectId']?.toString() ?? '',
              type: p['type']?.toString() ?? 'ERECTION',
              status: p['status']?.toString() ?? 'ENQUIRY',
              priority: p['priority']?.toString() ?? 'MEDIUM',
              startDate: parseDate(p['startDate']),
              endDate: parseDate(p['endDate']),
              durationDays: (p['durationDays'] as num?)?.toInt() ?? 0,
              safetyInspectionComplete:
                  p['safetyInspectionComplete'] as bool? ?? false,
            ))
        .toList();

    final custJson = json['customer'] as Map<String, dynamic>? ?? {};
    final primaryRaw = custJson['primaryContact'] as Map<String, dynamic>? ?? {};
    final customer = ProjectCustomerDetail(
      id: custJson['id']?.toString() ?? '',
      name: custJson['name']?.toString() ?? '',
      category: custJson['category']?.toString() ?? '',
      primaryContact: CustomerPrimaryContact(
        name: primaryRaw['name']?.toString() ?? '',
        phone: primaryRaw['phone']?.toString() ?? '',
        email: primaryRaw['email']?.toString() ?? '',
      ),
    );

    final hoursRaw = json['hoursByActivity'] as List? ?? [];
    final hoursByActivity = hoursRaw
        .whereType<Map<String, dynamic>>()
        .map((h) => LaborHoursByActivity(
              activityType: h['activityType']?.toString() ?? '',
              hours: (h['hours'] as num?)?.toDouble() ?? 0.0,
            ))
        .toList();

    final crewRaw = json['crewBreakdown'] as List? ?? [];
    final crewBreakdown = crewRaw
        .whereType<Map<String, dynamic>>()
        .map((c) {
          final uJson = c['user'] as Map<String, dynamic>? ?? {};
          return CrewBreakdownItem(
            user: CrewUser(
              id: uJson['id']?.toString() ?? '',
              firstName: uJson['firstName']?.toString() ?? '',
              lastName: uJson['lastName']?.toString() ?? '',
            ),
            totalHours: (c['totalHours'] as num?)?.toDouble() ?? 0.0,
            synced: c['synced'] as bool? ?? true,
          );
        })
        .toList();

    final attachJson = json['attachmentCounts'] as Map<String, dynamic>? ?? {};
    final attachmentCounts = AttachmentCounts(
      photos: (attachJson['photos'] as num?)?.toInt() ?? 0,
      pdfPlans: (attachJson['pdfPlans'] as num?)?.toInt() ?? 0,
    );

    return ProjectDetailsModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      coordinates: coords,
      siteAccessCode: json['siteAccessCode']?.toString() ?? '',
      siteAccessNotes: json['siteAccessNotes']?.toString() ?? '',
      scaffoldSpecification: scaffoldSpec,
      scheduleData: scheduleData,
      nextSafetyInspection: nextSafetyInspection,
      budgetedHours: (json['budgetedHours'] as num?)?.toDouble() ?? 0.0,
      totalLoggedHours: (json['totalLoggedHours'] as num?)?.toDouble() ?? 0.0,
      isProfitable: json['isProfitable'] as bool? ?? true,
      phases: phases,
      customer: customer,
      hoursByActivity: hoursByActivity,
      crewBreakdown: crewBreakdown,
      attachmentCounts: attachmentCounts,
      localization: LocalizationMeta.tryParse(json),
    );
  }
}
