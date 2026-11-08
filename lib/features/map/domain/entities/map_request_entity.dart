import '../../../../core/enums/app_enum.dart';
import 'map_coordinate_entity.dart';
import 'map_location_entity.dart';
import 'map_route_entity.dart';

/// Purpose/mode of the map screen.
enum MapPurpose {
  /// Displays a single site or inspection location with details.
  singleLocation,

  /// Displays multiple sites with filtering, search, and marker clustering/selection.
  multiLocation,

  /// Previews a route from origin/current location to a destination with metrics.
  route,

  /// Prepared for future live participant / worker tracking.
  liveTracking,
}

/// Strongly-typed request model passed when navigating to the map screen.
class MapRequestEntity {
  final UserRole role;
  final MapPurpose purpose;
  final String? title;
  final MapLocationEntity? destination;
  final MapLocationEntity? origin;
  final MapLocationEntity? participantLocation;
  final List<MapLocationEntity> locations;
  final MapRouteEntity? route;
  final bool showRoute;
  final bool enableUserTracking;
  final String? filterCategory;
  final MapCoordinate? initialCameraTarget;
  final double initialZoom;

  const MapRequestEntity({
    required this.role,
    this.purpose = MapPurpose.multiLocation,
    this.title,
    this.destination,
    this.origin,
    this.participantLocation,
    this.locations = const [],
    this.route,
    this.showRoute = false,
    this.enableUserTracking = false,
    this.filterCategory,
    this.initialCameraTarget,
    this.initialZoom = 13.5,
  });

  /// Factory for Site Manager overview of all active project sites.
  factory MapRequestEntity.siteManagerOverview({
    List<MapLocationEntity> locations = const [],
    String? initialFilter,
  }) {
    return MapRequestEntity(
      role: UserRole.siteManager,
      purpose: MapPurpose.multiLocation,
      title: 'Active Sites Map',
      locations: locations,
      filterCategory: initialFilter,
      initialCameraTarget: const MapCoordinate(
        latitude: 50.9375,
        longitude: 6.9603,
        name: 'Köln Center',
      ),
      initialZoom: 12.0,
    );
  }

  /// Factory for viewing a single project or site detail.
  factory MapRequestEntity.singleSite({
    required UserRole role,
    required MapLocationEntity site,
    String? customTitle,
  }) {
    return MapRequestEntity(
      role: role,
      purpose: MapPurpose.singleLocation,
      title: customTitle ?? site.title,
      destination: site,
      initialCameraTarget: site.coordinate,
      initialZoom: 15.5,
    );
  }

  /// Factory for navigating / previewing a route to a destination.
  factory MapRequestEntity.routeNavigation({
    required UserRole role,
    required MapLocationEntity destination,
    MapLocationEntity? origin,
    MapRouteEntity? route,
  }) {
    return MapRequestEntity(
      role: role,
      purpose: MapPurpose.route,
      title: 'Route to ${destination.title}',
      destination: destination,
      origin: origin,
      route: route,
      showRoute: true,
      enableUserTracking: true,
      initialCameraTarget: destination.coordinate,
      initialZoom: 13.0,
    );
  }

  /// Factory for live tracking readiness (worker / delivery participant).
  factory MapRequestEntity.liveTracking({
    required UserRole role,
    required MapLocationEntity destination,
    required MapLocationEntity participant,
  }) {
    return MapRequestEntity(
      role: role,
      purpose: MapPurpose.liveTracking,
      title: 'Live Tracking: ${participant.title}',
      destination: destination,
      participantLocation: participant,
      showRoute: true,
      enableUserTracking: true,
      initialCameraTarget: participant.coordinate,
      initialZoom: 14.0,
    );
  }

  MapRequestEntity copyWith({
    UserRole? role,
    MapPurpose? purpose,
    String? title,
    MapLocationEntity? destination,
    MapLocationEntity? origin,
    MapLocationEntity? participantLocation,
    List<MapLocationEntity>? locations,
    MapRouteEntity? route,
    bool? showRoute,
    bool? enableUserTracking,
    String? filterCategory,
    MapCoordinate? initialCameraTarget,
    double? initialZoom,
  }) {
    return MapRequestEntity(
      role: role ?? this.role,
      purpose: purpose ?? this.purpose,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      origin: origin ?? this.origin,
      participantLocation: participantLocation ?? this.participantLocation,
      locations: locations ?? this.locations,
      route: route ?? this.route,
      showRoute: showRoute ?? this.showRoute,
      enableUserTracking: enableUserTracking ?? this.enableUserTracking,
      filterCategory: filterCategory ?? this.filterCategory,
      initialCameraTarget: initialCameraTarget ?? this.initialCameraTarget,
      initialZoom: initialZoom ?? this.initialZoom,
    );
  }
}
