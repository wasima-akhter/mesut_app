import 'package:construction_app/core/localization/localization_meta.dart';
import '../../domain/entities/employee_project_details_entity.dart';

class EmployeeProjectPhotoModel {
  static EmployeeProjectPhotoEntity fromJson(Map<String, dynamic> json) {
    return EmployeeProjectPhotoEntity(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      fileType: json['fileType']?.toString(),
      fileName: json['fileName']?.toString(),
      fileSize: (json['fileSize'] as num?)?.toInt(),
      isCover: json['isCover'] == true,
      category: json['category']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      localization: LocalizationMeta.tryParse(json),
    );
  }

  static List<EmployeeProjectPhotoEntity> fromJsonList(dynamic jsonList) {
    if (jsonList is! List) return const [];
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
  }
}
