import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/utils/logger.dart';
import '../domain/entities/map_coordinate_entity.dart';

/// Service for robust location permission handling and GPS coordinate retrieval.
class LocationService {
  const LocationService();

  /// Default fallback location in Cologne when device location is unavailable.
  static const MapCoordinate defaultCologneCoordinate = MapCoordinate(
    latitude: 50.9375,
    longitude: 6.9603,
    name: 'Köln Center (Default)',
  );

  /// Requests location permission with comprehensive status checking.
  Future<bool> requestLocationPermission() async {
    try {
      AppLogger.info('Requesting location permission...', name: 'MAP_LOCATION');
      final granted = await AppPermissions.requestLocation();
      AppLogger.info(
        'Location permission result: ${granted ? "GRANTED" : "DENIED"}',
        name: 'MAP_LOCATION',
      );
      return granted;
    } catch (e, st) {
      AppLogger.error(
        'Failed to request location permission',
        error: e,
        stackTrace: st,
        name: 'MAP_LOCATION',
      );
      return false;
    }
  }

  /// Checks if location permission is currently granted.
  Future<bool> hasLocationPermission() async {
    try {
      return await AppPermissions.hasLocationPermission();
    } catch (_) {
      return false;
    }
  }

  /// Checks if GPS / location service is enabled on the device.
  Future<bool> isLocationServiceEnabled() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        AppLogger.warning(
          '[MAP_LOCATION] Device GPS service is DISABLED in device system settings',
          name: 'MAP_LOCATION',
        );
      }
      return enabled;
    } catch (e) {
      AppLogger.warning('Location service check failed: $e', name: 'MAP_LOCATION');
      return false;
    }
  }

  /// Retrieves the current device location with timeout and fallback.
  /// Never throws an unhandled exception.
  Future<MapCoordinate?> getCurrentLocation({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final isServiceEnabled = await isLocationServiceEnabled();
      if (!isServiceEnabled) {
        AppLogger.warning(
          '[MAP_LOCATION] Location unavailable: Device location service (GPS) is turned OFF.',
          name: 'MAP_LOCATION',
        );
        return null;
      }

      final isGranted = await hasLocationPermission();
      if (!isGranted) {
        AppLogger.warning(
          '[MAP_LOCATION] Location unavailable: Location permission is NOT GRANTED.',
          name: 'MAP_LOCATION',
        );
        return null;
      }

      AppLogger.info('[MAP_LOCATION] Requesting GPS coordinates from hardware sensor...', name: 'MAP_LOCATION');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 6),
        ),
      );

      final coordinate = MapCoordinate(
        latitude: position.latitude,
        longitude: position.longitude,
        name: 'Current Location',
      );

      AppLogger.info(
        '[MAP_LOCATION] Location ACQUIRED: lat=${coordinate.latitude}, lng=${coordinate.longitude}',
        name: 'MAP_LOCATION',
      );
      return coordinate;
    } on TimeoutException {
      AppLogger.warning(
        '[MAP_LOCATION] Location unavailable: GPS sensor lookup TIMED OUT after ${timeout.inSeconds}s.',
        name: 'MAP_LOCATION',
      );
      return null;
    } catch (e, st) {
      AppLogger.error(
        '[MAP_LOCATION] Location unavailable: Unexpected error while acquiring position',
        error: e,
        stackTrace: st,
        name: 'MAP_LOCATION',
      );
      return null;
    }
  }

  /// Opens application system settings when permanently denied.
  Future<void> openSettings() async {
    await AppPermissions.openSettings();
  }

  /// Opens device location / GPS system settings when GPS is disabled.
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (_) {
      await AppPermissions.openSettings();
    }
  }
}
