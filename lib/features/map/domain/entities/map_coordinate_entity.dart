import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Strongly-typed geographic coordinate with validation and distance calculation.
class MapCoordinate {
  final double latitude;
  final double longitude;
  final String? name;

  const MapCoordinate({
    required this.latitude,
    required this.longitude,
    this.name,
  });

  /// Validates whether this coordinate falls within valid Earth latitude/longitude ranges.
  bool get isValid {
    if (latitude.isNaN || longitude.isNaN) return false;
    if (latitude.isInfinite || longitude.isInfinite) return false;
    return latitude >= -90.0 &&
        latitude <= 90.0 &&
        longitude >= -180.0 &&
        longitude <= 180.0;
  }

  /// Converts to standard google_maps_flutter LatLng.
  LatLng toLatLng() => LatLng(latitude, longitude);

  /// Computes distance in kilometers to another coordinate using the Haversine formula.
  double distanceTo(MapCoordinate other) {
    if (!isValid || !other.isValid) return 0.0;
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(other.latitude - latitude);
    final dLon = _toRadians(other.longitude - longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitude)) *
            math.cos(_toRadians(other.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degree) => degree * math.pi / 180.0;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (name != null) 'name': name,
      };

  factory MapCoordinate.fromJson(Map<String, dynamic> json) {
    return MapCoordinate(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      name: json['name'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapCoordinate &&
          runtimeType == other.runtimeType &&
          (latitude - other.latitude).abs() < 0.000001 &&
          (longitude - other.longitude).abs() < 0.000001;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'MapCoordinate($latitude, $longitude, name: $name)';
}

