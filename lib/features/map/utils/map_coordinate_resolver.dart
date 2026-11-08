import '../domain/entities/map_coordinate_entity.dart';

/// Helper utility to resolve addresses in the application to realistic Cologne coordinates.
class MapCoordinateResolver {
  const MapCoordinateResolver._();

  static MapCoordinate resolve(String? address) {
    if (address == null || address.trim().isEmpty) {
      return const MapCoordinate(
        latitude: 50.9375,
        longitude: 6.9603,
        name: 'Köln City Center',
      );
    }

    final lower = address.toLowerCase();
    if (lower.contains('goltstein') || lower.contains('goldstein')) {
      return const MapCoordinate(
        latitude: 50.9082,
        longitude: 6.9723,
        name: 'Goltsteinstraße 12, Köln',
      );
    } else if (lower.contains('severin')) {
      return const MapCoordinate(
        latitude: 50.9288,
        longitude: 6.9587,
        name: 'Severinstraße 44, Köln',
      );
    } else if (lower.contains('lindenthal') ||
        lower.contains('dürener') ||
        lower.contains('durener')) {
      return const MapCoordinate(
        latitude: 50.9295,
        longitude: 6.9150,
        name: 'Dürener Str. 120, Köln',
      );
    } else if (lower.contains('ehrenfeld') || lower.contains('venloer')) {
      return const MapCoordinate(
        latitude: 50.9455,
        longitude: 6.9248,
        name: 'Venloer Str. 100, Köln',
      );
    } else if (lower.contains('deutz') || lower.contains('mindener')) {
      return const MapCoordinate(
        latitude: 50.9385,
        longitude: 6.9740,
        name: 'Mindener Str. 2, Köln',
      );
    } else if (lower.contains('rodenkirchen') ||
        lower.contains('hauptstraße') ||
        lower.contains('hauptstrasse')) {
      return const MapCoordinate(
        latitude: 50.8932,
        longitude: 6.9912,
        name: 'Hauptstraße 45, Köln',
      );
    }

    // Default to Cologne city center
    return const MapCoordinate(
      latitude: 50.9375,
      longitude: 6.9603,
      name: 'Köln Center',
    );
  }
}
