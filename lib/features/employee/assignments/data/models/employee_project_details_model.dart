import '../../../../../core/localization/localization_meta.dart';
import '../../domain/entities/employee_project_details_entity.dart';
import 'employee_project_photo_model.dart';
import 'employee_project_task_model.dart';

class EmployeeProjectDetailsModel {
  static EmployeeProjectDetailsEntity fromJson(Map<String, dynamic> json) {
    double? lat;
    double? lng;
    final coords = json['coordinates'];
    if (coords is Map<String, dynamic>) {
      lat = (coords['lat'] as num?)?.toDouble();
      lng = (coords['lng'] as num?)?.toDouble();
    }

    EmployeeProjectPhaseEntity? phase;
    final pObj = json['phase'];
    if (pObj is Map<String, dynamic>) {
      phase = EmployeeProjectPhaseEntity(
        id: pObj['id']?.toString() ?? '',
        type: pObj['type']?.toString().toUpperCase() ?? 'ERECTION',
        status: pObj['status']?.toString().toUpperCase() ?? 'ENQUIRY',
        startDate: pObj['startDate'] != null
            ? DateTime.tryParse(pObj['startDate'].toString())
            : null,
        endDate: pObj['endDate'] != null
            ? DateTime.tryParse(pObj['endDate'].toString())
            : null,
        assignedHoursToday:
            (pObj['assignedHoursToday'] as num?)?.toDouble() ?? 0,
      );
    }

    EmployeeProjectManagerEntity? manager;
    final smObj = json['siteManager'];
    if (smObj is Map<String, dynamic>) {
      manager = EmployeeProjectManagerEntity(
        id: smObj['id']?.toString() ?? '',
        firstName: smObj['firstName']?.toString() ?? '',
        lastName: smObj['lastName']?.toString() ?? '',
        phone: smObj['phone']?.toString(),
        avatarUrl: smObj['avatarUrl']?.toString(),
      );
    }

    return EmployeeProjectDetailsEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      latitude: lat,
      longitude: lng,
      siteAccessCode: json['siteAccessCode']?.toString(),
      siteAccessNotes: json['siteAccessNotes']?.toString(),
      scaffoldArea: (json['scaffoldArea'] as num?)?.toDouble() ?? 0,
      scaffoldLabel: json['scaffoldLabel']?.toString(),
      phase: phase,
      siteManager: manager,
      photoCount: (json['photoCount'] as num?)?.toInt() ?? 0,
      photos: EmployeeProjectPhotoModel.fromJsonList(json['photos']),
      taskCount: (json['taskCount'] as num?)?.toInt() ?? 0,
      tasks: EmployeeProjectTaskModel.fromJsonList(json['tasks']),
      localization: LocalizationMeta.tryParse(json),
    );
  }
}
