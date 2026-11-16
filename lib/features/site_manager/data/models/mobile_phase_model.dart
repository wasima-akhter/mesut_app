import '../../domain/entities/mobile_phase_entity.dart';

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

class MobilePhaseModel {
  static MobilePhaseEntity fromJson(Map<String, dynamic> json) {
    final proj = _asMap(json['project']);
    return MobilePhaseEntity(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      priority: (json['priority'] ?? '').toString(),
      startDate: _asDateTime(json['startDate']),
      endDate: _asDateTime(json['endDate']),
      project: MobilePhaseProjectEntity(
        id: (proj['id'] ?? '').toString(),
        name: (proj['name'] ?? '').toString(),
        address: (proj['address'] ?? '').toString(),
      ),
    );
  }

  static List<MobilePhaseEntity> fromList(dynamic rawList) {
    if (rawList is! List) return const [];
    final result = <MobilePhaseEntity>[];
    for (final item in rawList) {
      final map = _asMap(item);
      if (map.isNotEmpty) {
        result.add(fromJson(map));
      }
    }
    return result;
  }
}
