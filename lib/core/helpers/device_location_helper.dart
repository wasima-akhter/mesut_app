import 'package:geolocator/geolocator.dart';

class DeviceCoordinates {
  const DeviceCoordinates({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

/// Safely attempts to retrieve device coordinates for auth telemetry without blocking or prompting.
abstract final class DeviceLocationHelper {
  static Future<DeviceCoordinates?> tryGetCoordinates() async {
    try {
      return await _readCoordinates().timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<DeviceCoordinates?> _readCoordinates() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      return null;
    }

    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      return DeviceCoordinates(
        lat: lastKnown.latitude,
        lng: lastKnown.longitude,
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 2),
      ),
    );
    return DeviceCoordinates(
      lat: position.latitude,
      lng: position.longitude,
    );
  }
}
