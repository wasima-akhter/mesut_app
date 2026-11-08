import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/enums/app_enum.dart';
import '../../domain/entities/map_coordinate_entity.dart';
import '../../domain/entities/map_location_entity.dart';
import '../../domain/entities/map_request_entity.dart';
import '../../domain/entities/map_route_entity.dart';

enum MapStatus { initial, loading, ready, error }

class MapState {
  final MapStatus status;
  final String? errorMessage;
  final bool isOffline;
  final MapRequestEntity request;
  final MapCoordinate? userLocation;
  final bool hasLocationPermission;
  final List<MapLocationEntity> allLocations;
  final List<MapLocationEntity> filteredLocations;
  final MapLocationEntity? selectedLocation;
  final MapRouteEntity? activeRoute;
  final String selectedFilter;
  final String searchQuery;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final CameraPosition initialCameraPosition;
  final bool isFollowUserEnabled;
  final bool isTrafficEnabled;
  final MapType mapType;

  const MapState({
    this.status = MapStatus.initial,
    this.errorMessage,
    this.isOffline = false,
    required this.request,
    this.userLocation,
    this.hasLocationPermission = false,
    this.allLocations = const [],
    this.filteredLocations = const [],
    this.selectedLocation,
    this.activeRoute,
    this.selectedFilter = 'All',
    this.searchQuery = '',
    this.markers = const {},
    this.polylines = const {},
    this.initialCameraPosition = const CameraPosition(
      target: LatLng(50.9375, 6.9603), // Cologne
      zoom: 12.5,
    ),
    this.isFollowUserEnabled = false,
    this.isTrafficEnabled = false,
    this.mapType = MapType.normal,
  });

  bool get isLoading => status == MapStatus.loading;
  bool get hasError => status == MapStatus.error;
  bool get isReady => status == MapStatus.ready;

  MapState copyWith({
    MapStatus? status,
    String? errorMessage,
    bool? isOffline,
    MapRequestEntity? request,
    MapCoordinate? userLocation,
    bool? hasLocationPermission,
    List<MapLocationEntity>? allLocations,
    List<MapLocationEntity>? filteredLocations,
    MapLocationEntity? selectedLocation,
    bool clearSelectedLocation = false,
    MapRouteEntity? activeRoute,
    bool clearActiveRoute = false,
    String? selectedFilter,
    String? searchQuery,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    CameraPosition? initialCameraPosition,
    bool? isFollowUserEnabled,
    bool? isTrafficEnabled,
    MapType? mapType,
  }) {
    return MapState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      isOffline: isOffline ?? this.isOffline,
      request: request ?? this.request,
      userLocation: userLocation ?? this.userLocation,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      allLocations: allLocations ?? this.allLocations,
      filteredLocations: filteredLocations ?? this.filteredLocations,
      selectedLocation: clearSelectedLocation
          ? null
          : (selectedLocation ?? this.selectedLocation),
      activeRoute:
          clearActiveRoute ? null : (activeRoute ?? this.activeRoute),
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      initialCameraPosition:
          initialCameraPosition ?? this.initialCameraPosition,
      isFollowUserEnabled: isFollowUserEnabled ?? this.isFollowUserEnabled,
      isTrafficEnabled: isTrafficEnabled ?? this.isTrafficEnabled,
      mapType: mapType ?? this.mapType,
    );
  }

  factory MapState.initial({MapRequestEntity? request}) {
    final req = request ??
        MapRequestEntity(
          role: UserRole.siteManager,
          purpose: MapPurpose.multiLocation,
        );
    return MapState(
      status: MapStatus.initial,
      request: req,
      initialCameraPosition: CameraPosition(
        target: req.initialCameraTarget?.toLatLng() ??
            const LatLng(50.9375, 6.9603),
        zoom: req.initialZoom,
      ),
    );
  }
}
