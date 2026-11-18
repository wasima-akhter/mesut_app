import 'package:construction_app/core/localization/localization_meta.dart';
import '../../domain/entities/mobile_inspection_entity.dart';

double _asDouble(dynamic v, [double fallback = 0]) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? fallback;
}

DateTime? _asDateTime(dynamic v) {
  if (v == null) return null;
  final raw = v.toString().trim();
  return raw.isEmpty ? null : DateTime.tryParse(raw);
}

Map<String, dynamic> _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return const <String, dynamic>{};
}

class MobileInspectionModel {
  static MobileInspectionEntity fromJson(Map<String, dynamic> json) {
    final cust = _asMap(json['customer']);
    return MobileInspectionEntity(
      id: (json['id'] ?? '').toString(),
      siteTitle: (json['siteTitle'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      postalCode: (json['postalCode'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      appointmentDate: _asDateTime(json['appointmentDate']),
      scaffoldArea: _asDouble(json['scaffoldArea']),
      scaffoldHeight: _asDouble(json['scaffoldHeight']),
      scaffoldType: (json['scaffoldType'] ?? '').toString(),
      status: (json['status'] ?? 'PENDING').toString(),
      customer: MobileInspectionCustomerEntity(
        id: (cust['id'] ?? '').toString(),
        name: (cust['name'] ?? '').toString(),
      ),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
      localization: LocalizationMeta.tryParse(json),
    );
  }

  static List<MobileInspectionEntity> fromList(dynamic rawList) {
    if (rawList is! List) return const [];
    final result = <MobileInspectionEntity>[];
    for (final item in rawList) {
      final map = _asMap(item);
      if (map.isNotEmpty) {
        result.add(fromJson(map));
      }
    }
    return result;
  }
}
