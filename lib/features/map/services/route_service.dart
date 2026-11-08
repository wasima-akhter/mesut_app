import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../domain/entities/map_coordinate_entity.dart';
import '../domain/entities/map_route_entity.dart';

/// Service responsible for polyline rendering and camera bounds calculation.
class RouteService {
  const RouteService();

  /// Converts a [MapRouteEntity] into a styled Google Maps [Polyline].
  Polyline createPolyline({
    required MapRouteEntity route,
    Color color = const Color(0xFFE22B3B), // App Primary Red
    int width = 5,
  }) {
    final validPoints = route.waypoints
        .where((w) => w.isValid)
        .map((w) => w.toLatLng())
        .toList();

    AppLogger.info(
      'Creating polyline with ${validPoints.length} valid coordinates',
      name: 'MAP_ROUTE',
    );

    return Polyline(
      polylineId: PolylineId(route.id),
      points: validPoints,
      color: color,
      width: width,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
    );
  }

  /// Calculates a safe [LatLngBounds] encompassing all coordinates with boundary padding.
  /// Handles single coordinate, empty lists, and identical points safely.
  LatLngBounds calculateBounds(List<MapCoordinate> coordinates) {
    final validCoords = coordinates.where((c) => c.isValid).toList();

    if (validCoords.isEmpty) {
      AppLogger.warning('No valid coordinates for bounds, using Cologne default', name: 'MAP');
      return LatLngBounds(
        southwest: const LatLng(50.9000, 6.9000),
        northeast: const LatLng(50.9700, 7.0100),
      );
    }

    if (validCoords.length == 1) {
      final p = validCoords.first;
      return LatLngBounds(
        southwest: LatLng(p.latitude - 0.008, p.longitude - 0.008),
        northeast: LatLng(p.latitude + 0.008, p.longitude + 0.008),
      );
    }

    double minLat = validCoords.first.latitude;
    double maxLat = validCoords.first.latitude;
    double minLng = validCoords.first.longitude;
    double maxLng = validCoords.first.longitude;

    for (final c in validCoords) {
      minLat = math.min(minLat, c.latitude);
      maxLat = math.max(maxLat, c.latitude);
      minLng = math.min(minLng, c.longitude);
      maxLng = math.max(maxLng, c.longitude);
    }

    // Guard against identical start and end coordinates
    if ((maxLat - minLat).abs() < 0.0001 && (maxLng - minLng).abs() < 0.0001) {
      return LatLngBounds(
        southwest: LatLng(minLat - 0.005, minLng - 0.005),
        northeast: LatLng(maxLat + 0.005, maxLng + 0.005),
      );
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
