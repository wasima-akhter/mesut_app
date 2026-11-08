import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../domain/entities/map_coordinate_entity.dart';
import '../domain/entities/map_location_entity.dart';

/// Service responsible for generating Google Maps [Marker]s with role and status color-coding.
class MapMarkerService {
  const MapMarkerService();

  /// Converts a list of [MapLocationEntity] into a set of Google Maps [Marker]s.
  Set<Marker> createMarkers({
    required List<MapLocationEntity> locations,
    String? selectedLocationId,
    ValueChanged<MapLocationEntity>? onLocationTap,
  }) {
    final markers = <Marker>{};

    for (final loc in locations) {
      if (!loc.hasValidCoordinates) {
        AppLogger.warning(
          'Skipping marker creation for location "${loc.title}" (invalid coordinates: ${loc.latitude}, ${loc.longitude})',
          name: 'MAP',
        );
        continue;
      }

      final isSelected = loc.id == selectedLocationId;
      final hue = _getHueForType(loc.type);

      markers.add(
        Marker(
          markerId: MarkerId(loc.id),
          position: loc.coordinate.toLatLng(),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: loc.title,
            snippet: loc.address,
            onTap: onLocationTap != null ? () => onLocationTap(loc) : null,
          ),
          zIndexInt: isSelected ? 2 : 1,
          onTap: onLocationTap != null ? () => onLocationTap(loc) : null,
        ),
      );
    }

    AppLogger.info('Created ${markers.length} location markers', name: 'MAP');
    return markers;
  }

  /// Creates a distinctive marker for the user's current GPS position or route origin.
  Marker createOriginMarker({
    required MapCoordinate coordinate,
    String title = 'Start Location',
    VoidCallback? onTap,
  }) {
    return Marker(
      markerId: const MarkerId('marker_origin'),
      position: coordinate.toLatLng(),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: title),
      zIndexInt: 3,
      onTap: onTap,
    );
  }

  /// Creates a distinctive marker for the destination site.
  Marker createDestinationMarker({
    required MapLocationEntity destination,
    VoidCallback? onTap,
  }) {
    return Marker(
      markerId: MarkerId('marker_dest_${destination.id}'),
      position: destination.coordinate.toLatLng(),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
        title: destination.title,
        snippet: destination.address,
      ),
      zIndexInt: 4,
      onTap: onTap,
    );
  }

  /// Creates a marker for another participant (e.g., employee or delivery team).
  Marker createParticipantMarker({
    required MapLocationEntity participant,
    VoidCallback? onTap,
  }) {
    return Marker(
      markerId: MarkerId('marker_part_${participant.id}'),
      position: participant.coordinate.toLatLng(),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(
        title: participant.title,
        snippet: participant.subtitle ?? 'Field Team',
      ),
      zIndexInt: 5,
      onTap: onTap,
    );
  }

  static double _getHueForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'erection':
        return BitmapDescriptor.hueAzure;
      case 'dismantling':
        return BitmapDescriptor.hueOrange;
      case 'standing':
        return BitmapDescriptor.hueCyan;
      case 'inspection':
        return BitmapDescriptor.hueViolet;
      default:
        return BitmapDescriptor.hueBlue;
    }
  }
}
