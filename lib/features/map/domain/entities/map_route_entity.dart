import 'map_coordinate_entity.dart';

/// Strongly-typed route entity with waypoints, metrics, and sample data labeling.
class MapRouteEntity {
  final String id;
  final String title;
  final MapCoordinate start;
  final MapCoordinate destination;
  final List<MapCoordinate> waypoints;
  final double distanceKm;
  final int durationMinutes;
  final bool isMockData;
  final String? encodedPolyline;

  const MapRouteEntity({
    required this.id,
    required this.title,
    required this.start,
    required this.destination,
    required this.waypoints,
    required this.distanceKm,
    required this.durationMinutes,
    this.isMockData = false,
    this.encodedPolyline,
  });

  bool get isEmpty => waypoints.isEmpty;
  bool get hasValidWaypoints => waypoints.every((p) => p.isValid);

  String get formattedDistance {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes min';
    }
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    return mins == 0 ? '$hours h' : '${hours}h ${mins}m';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'start': start.toJson(),
        'destination': destination.toJson(),
        'waypoints': waypoints.map((w) => w.toJson()).toList(),
        'distanceKm': distanceKm,
        'durationMinutes': durationMinutes,
        'isMockData': isMockData,
        if (encodedPolyline != null) 'encodedPolyline': encodedPolyline,
      };

  factory MapRouteEntity.fromJson(Map<String, dynamic> json) {
    return MapRouteEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      start: MapCoordinate.fromJson(json['start'] as Map<String, dynamic>),
      destination:
          MapCoordinate.fromJson(json['destination'] as Map<String, dynamic>),
      waypoints: (json['waypoints'] as List<dynamic>)
          .map((w) => MapCoordinate.fromJson(w as Map<String, dynamic>))
          .toList(),
      distanceKm: (json['distanceKm'] as num).toDouble(),
      durationMinutes: json['durationMinutes'] as int,
      isMockData: json['isMockData'] as bool? ?? false,
      encodedPolyline: json['encodedPolyline'] as String?,
    );
  }
}
