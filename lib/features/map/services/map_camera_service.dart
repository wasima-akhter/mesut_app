import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/utils/logger.dart';
import '../domain/entities/map_coordinate_entity.dart';
import '../domain/entities/map_location_entity.dart';
import '../domain/entities/map_route_entity.dart';
import 'route_service.dart';

/// Service responsible for camera positioning, auto-fitting, and fallback centering.
class MapCameraService {
  static const LatLng cologneCityCenter = LatLng(50.9375, 6.9603);

  const MapCameraService();

  /// Adjusts camera viewport to frame active content (locations, manager location, or route).
  Future<void> fitToContent({
    required GoogleMapController? controller,
    required RouteService routeService,
    required List<MapLocationEntity> locations,
    required MapCoordinate? userLocation,
    MapRouteEntity? activeRoute,
    MapLocationEntity? selectedLocation,
  }) async {
    if (controller == null) return;

    try {
      final coords = <MapCoordinate>[];

      if (activeRoute != null && activeRoute.waypoints.isNotEmpty) {
        coords.addAll(activeRoute.waypoints);
      } else if (locations.isNotEmpty) {
        coords.addAll(locations.map((l) => l.coordinate));
      } else if (selectedLocation != null) {
        coords.add(selectedLocation.coordinate);
      }

      final hasUser = userLocation != null && userLocation.isValid;

      // Include user GPS if within 100km of the project region
      if (hasUser) {
        final reference = selectedLocation?.coordinate ??
            activeRoute?.destination ??
            const MapCoordinate(latitude: 50.9375, longitude: 6.9603);
        if (userLocation.distanceTo(reference) < 100.0) {
          coords.add(userLocation);
        }
      }

      if (coords.length == 1) {
        final singleTarget = coords.first.toLatLng();
        AppLogger.info(
          '════════════════════════════════════════════════════════════════\n'
          '[MAP_CAMERA] Framing camera over 1 coordinate:\n'
          '  • Project Location: $singleTarget\n'
          '  • Manager Live Location: ${hasUser ? "INCLUDED" : "NOT AVAILABLE / EXCLUDED"}\n'
          '  • What does the map show?\n'
          '      1. Exact single project pin\n'
          '      2. Camera centered directly on project with zoom 15.0\n'
          '      3. ${hasUser ? "Rose pin for manager location" : "Permission banner at top (no manager pin)"}\n'
          '════════════════════════════════════════════════════════════════',
          name: 'MAP_CAMERA',
        );
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(singleTarget, 15.0),
        );
      } else if (coords.isNotEmpty) {
        final bounds = routeService.calculateBounds(coords);
        AppLogger.info(
          '════════════════════════════════════════════════════════════════\n'
          '[MAP_CAMERA] Framing camera over ${coords.length} coordinate(s):\n'
          '  • Manager Live Location: ${hasUser ? "INCLUDED (${userLocation.latitude}, ${userLocation.longitude})" : "NOT AVAILABLE / EXCLUDED"}\n'
          '  • Project Sites in view: ${locations.length}\n'
          '  • Bounds: SW(${bounds.southwest.latitude}, ${bounds.southwest.longitude}) to NE(${bounds.northeast.latitude}, ${bounds.northeast.longitude})\n'
          '  • What does the map show?\n'
          '      1. Real project markers\n'
          '      2. Camera fitted around all ${locations.length} project sites\n'
          '      3. ${hasUser ? "Rose pin for manager location" : "Permission banner at top (no manager pin)"}\n'
          '════════════════════════════════════════════════════════════════',
          name: 'MAP_CAMERA',
        );
        await controller.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 65.0),
        );
      } else if (hasUser) {
        AppLogger.info(
          '[MAP_CAMERA] No project coordinates found. Centering on Manager GPS: (${userLocation.latitude}, ${userLocation.longitude})',
          name: 'MAP_CAMERA',
        );
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(userLocation.toLatLng(), 15.0),
        );
      } else {
        AppLogger.warning(
          '════════════════════════════════════════════════════════════════\n'
          '[MAP_CAMERA] NEITHER MANAGER LOCATION NOR PROJECT SITES AVAILABLE:\n'
          '  • Manager Location: NOT AVAILABLE\n'
          '  • Project Sites: 0 available or matching filter\n'
          '  • What does the map show?\n'
          '      -> Centering map on Cologne City Center: LatLng(50.9375, 6.9603)\n'
          '      -> Zoom level: 12.0\n'
          '════════════════════════════════════════════════════════════════',
          name: 'MAP_CAMERA',
        );
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(cologneCityCenter, 12.0),
        );
      }
    } catch (e) {
      AppLogger.warning('Camera fit adjustment skipped: $e', name: 'MAP_CAMERA');
    }
  }

  /// Recenters the camera on manager GPS, or falls back to first project site or Cologne center.
  Future<void> recenterOnUserOrFallback({
    required GoogleMapController? controller,
    required MapCoordinate? userLocation,
    required List<MapLocationEntity> fallbackLocations,
  }) async {
    if (controller == null) return;

    if (userLocation != null && userLocation.isValid) {
      AppLogger.info(
        '[MAP_LOCATION] Recenter SUCCESS: Animating camera to manager GPS (${userLocation.latitude}, ${userLocation.longitude}) [zoom 15.5]',
        name: 'MAP_LOCATION',
      );
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(userLocation.toLatLng(), 15.5),
      );
    } else {
      final fallbackTarget = fallbackLocations.isNotEmpty
          ? fallbackLocations.first.coordinate.toLatLng()
          : cologneCityCenter;
      final fallbackDesc = fallbackLocations.isNotEmpty
          ? 'First project site: "${fallbackLocations.first.title}" at $fallbackTarget'
          : 'Cologne city center: $fallbackTarget';

      AppLogger.warning(
        '════════════════════════════════════════════════════════════════\n'
        '[MAP_LOCATION] Recenter FALLBACK: Manager location is unavailable!\n'
        '  • What does the map show?\n'
        '  • Moving camera to: $fallbackDesc (zoom 13.0)\n'
        '════════════════════════════════════════════════════════════════',
        name: 'MAP_LOCATION',
      );
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(fallbackTarget, 13.0),
      );
    }
  }
}
