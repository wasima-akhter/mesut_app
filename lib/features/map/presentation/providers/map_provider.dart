import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/map_repository_impl.dart';
import '../../domain/entities/map_coordinate_entity.dart';
import '../../domain/entities/map_location_entity.dart';
import '../../domain/entities/map_request_entity.dart';
import '../../domain/entities/map_route_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../../services/location_service.dart';
import '../../services/map_marker_service.dart';
import '../../services/route_service.dart';
import 'map_state.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return const MapRepositoryImpl();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

final mapMarkerServiceProvider = Provider<MapMarkerService>((ref) {
  return const MapMarkerService();
});

final routeServiceProvider = Provider<RouteService>((ref) {
  return const RouteService();
});

final mapProvider = NotifierProvider<MapNotifier, MapState>(
  MapNotifier.new,
);

class MapNotifier extends Notifier<MapState> {
  GoogleMapController? _controller;
  bool _isDisposed = false;

  @override
  MapState build() {
    ref.onDispose(() {
      _isDisposed = true;
      _controller = null;
    });
    return MapState.initial();
  }

  void attachMapController(GoogleMapController controller) {
    _controller = controller;
    AppLogger.info('GoogleMapController attached', name: 'MAP');
    _fitCameraToContent();
  }

  /// Primary initialization entry point with configurable [MapRequestEntity].
  Future<void> initialize(MapRequestEntity request) async {
    if (_isDisposed) return;

    AppLogger.info(
      'Initializing Map: role=${request.role}, purpose=${request.purpose}, title="${request.title}"',
      name: 'MAP',
    );

    state = state.copyWith(
      status: MapStatus.loading,
      request: request,
      errorMessage: null,
      selectedFilter: request.filterCategory ?? 'All',
      initialCameraPosition: CameraPosition(
        target: request.initialCameraTarget?.toLatLng() ??
            request.destination?.coordinate.toLatLng() ??
            const LatLng(50.9375, 6.9603),
        zoom: request.initialZoom,
      ),
    );

    try {
      final locationService = ref.read(locationServiceProvider);
      final repository = ref.read(mapRepositoryProvider);

      // Check location permission safely
      final hasPerm = await locationService.hasLocationPermission();
      MapCoordinate? userCoord;

      if (hasPerm || request.enableUserTracking) {
        userCoord = await locationService.getCurrentLocation();
      }

      // Fetch or use provided locations
      List<MapLocationEntity> locations;
      if (request.locations.isNotEmpty) {
        locations = request.locations;
      } else if (request.destination != null) {
        locations = [request.destination!];
      } else {
        locations = await repository.getLocations(
          role: request.role,
          category: request.filterCategory,
        );
      }

      // Compute or assign route if requested
      MapRouteEntity? route = request.route;
      if (route == null &&
          request.showRoute &&
          request.destination != null) {
        final originCoord = request.origin?.coordinate ??
            userCoord ??
            const MapCoordinate(
              latitude: 50.9355,
              longitude: 6.9531,
              name: 'Köln Startpunkt',
            );

        route = await repository.getRoute(
          origin: originCoord,
          destination: request.destination!.coordinate,
          title: 'Route to ${request.destination!.title}',
        );
      }

      final filtered = _applyFilterAndSearch(
        locations,
        state.selectedFilter,
        state.searchQuery,
      );

      final markers = _generateMarkers(
        locations: filtered,
        request: request,
        route: route,
        userCoord: userCoord,
      );

      final polylines = _generatePolylines(route);

      if (!_isDisposed) {
        state = state.copyWith(
          status: MapStatus.ready,
          userLocation: userCoord,
          hasLocationPermission: hasPerm,
          allLocations: locations,
          filteredLocations: filtered,
          selectedLocation: request.destination ??
              (locations.length == 1 ? locations.first : null),
          activeRoute: route,
          markers: markers,
          polylines: polylines,
        );

        _fitCameraToContent();
      }
    } catch (e, st) {
      AppLogger.error(
        'Failed to initialize map',
        error: e,
        stackTrace: st,
        name: 'MAP',
      );
      if (!_isDisposed) {
        state = state.copyWith(
          status: MapStatus.error,
          errorMessage: e.toString(),
        );
      }
    }
  }

  /// Selects a location on the map and recenters camera.
  void selectLocation(MapLocationEntity? location) {
    if (_isDisposed) return;
    AppLogger.info('Selected location: ${location?.title}', name: 'MAP');
    state = state.copyWith(
      selectedLocation: location,
      clearSelectedLocation: location == null,
    );

    _updateMarkers();

    if (location != null && location.hasValidCoordinates && _controller != null) {
      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(location.coordinate.toLatLng(), 15.0),
      );
    }
  }

  /// Sets category filter chip.
  void setFilter(String filter) {
    if (_isDisposed) return;
    AppLogger.info('Filter changed to: $filter', name: 'MAP');
    final filtered = _applyFilterAndSearch(
      state.allLocations,
      filter,
      state.searchQuery,
    );

    // If selected location doesn't match new filter, deselect it
    final keepSelection = state.selectedLocation != null &&
        (filter == 'All' || state.selectedLocation!.type == filter);

    state = state.copyWith(
      selectedFilter: filter,
      filteredLocations: filtered,
      clearSelectedLocation: !keepSelection,
    );

    _updateMarkers();
    _fitCameraToContent();
  }

  /// Updates search query filter.
  void setSearchQuery(String query) {
    if (_isDisposed) return;
    final filtered = _applyFilterAndSearch(
      state.allLocations,
      state.selectedFilter,
      query,
    );

    state = state.copyWith(
      searchQuery: query,
      filteredLocations: filtered,
    );

    _updateMarkers();
  }

  /// Requests current GPS position and recenters camera.
  Future<void> recenterOnUser() async {
    if (_isDisposed) return;
    AppLogger.info('Recentering on user GPS...', name: 'MAP_LOCATION');
    final locationService = ref.read(locationServiceProvider);

    var coord = state.userLocation;
    if (coord == null || !coord.isValid) {
      final granted = await locationService.requestLocationPermission();
      state = state.copyWith(hasLocationPermission: granted);
      if (granted) {
        coord = await locationService.getCurrentLocation();
        if (coord != null && !_isDisposed) {
          state = state.copyWith(userLocation: coord);
        }
      }
    }

    if (coord != null && coord.isValid && _controller != null) {
      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(coord.toLatLng(), 15.5),
      );
    } else if (_controller != null) {
      // Fallback to Cologne center
      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          const LatLng(50.9375, 6.9603),
          13.0,
        ),
      );
    }
  }

  /// Loads turn-by-turn route to a specific destination.
  Future<void> loadRouteTo(MapLocationEntity destination) async {
    if (_isDisposed) return;
    try {
      final repository = ref.read(mapRepositoryProvider);
      final origin = state.userLocation ??
          const MapCoordinate(
            latitude: 50.9355,
            longitude: 6.9531,
            name: 'Köln Startpunkt',
          );

      final route = await repository.getRoute(
        origin: origin,
        destination: destination.coordinate,
        title: 'Route to ${destination.title}',
      );

      final polylines = _generatePolylines(route);

      state = state.copyWith(
        activeRoute: route,
        selectedLocation: destination,
        polylines: polylines,
      );

      _updateMarkers();
      _fitCameraToContent();
    } catch (e, st) {
      AppLogger.error('Failed to load route', error: e, stackTrace: st, name: 'MAP_ROUTE');
    }
  }

  /// Retries map initialization.
  void retry() {
    initialize(state.request);
  }

  /// Toggles satellite / normal map type.
  void toggleMapType() {
    state = state.copyWith(
      mapType: state.mapType == MapType.normal
          ? MapType.hybrid
          : MapType.normal,
    );
  }

  /// Toggles real-time traffic layer.
  void toggleTraffic() {
    state = state.copyWith(isTrafficEnabled: !state.isTrafficEnabled);
  }

  // --- Private Helpers ---

  List<MapLocationEntity> _applyFilterAndSearch(
    List<MapLocationEntity> list,
    String filter,
    String query,
  ) {
    var result = list;
    if (filter != 'All') {
      result = result.where((loc) => loc.type == filter).toList();
    }
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result
          .where(
            (loc) =>
                loc.title.toLowerCase().contains(q) ||
                loc.address.toLowerCase().contains(q) ||
                (loc.company?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }
    return result;
  }

  void _updateMarkers() {
    final markers = _generateMarkers(
      locations: state.filteredLocations,
      request: state.request,
      route: state.activeRoute,
      userCoord: state.userLocation,
    );
    state = state.copyWith(markers: markers);
  }

  Set<Marker> _generateMarkers({
    required List<MapLocationEntity> locations,
    required MapRequestEntity request,
    MapRouteEntity? route,
    MapCoordinate? userCoord,
  }) {
    final markerService = ref.read(mapMarkerServiceProvider);
    final markers = markerService.createMarkers(
      locations: locations,
      selectedLocationId: state.selectedLocation?.id,
      onLocationTap: (loc) => selectLocation(loc),
    );

    // Add origin / user marker if route is active
    if (route != null && route.start.isValid) {
      markers.add(
        markerService.createOriginMarker(
          coordinate: route.start,
          title: userCoord != null ? 'Your Location' : 'Start Point',
        ),
      );
    }

    // Add participant marker for live tracking
    if (request.participantLocation != null &&
        request.participantLocation!.hasValidCoordinates) {
      markers.add(
        markerService.createParticipantMarker(
          participant: request.participantLocation!,
          onTap: () => selectLocation(request.participantLocation),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _generatePolylines(MapRouteEntity? route) {
    if (route == null || route.isEmpty) return const {};
    final routeService = ref.read(routeServiceProvider);
    return {routeService.createPolyline(route: route)};
  }

  void _fitCameraToContent() {
    if (_controller == null || _isDisposed) return;
    try {
      final routeService = ref.read(routeServiceProvider);
      final coords = <MapCoordinate>[];

      // If active route is present, fit to route waypoints
      if (state.activeRoute != null && state.activeRoute!.waypoints.isNotEmpty) {
        coords.addAll(state.activeRoute!.waypoints);
      } else if (state.filteredLocations.isNotEmpty) {
        coords.addAll(state.filteredLocations.map((l) => l.coordinate));
      } else if (state.selectedLocation != null) {
        coords.add(state.selectedLocation!.coordinate);
      }

      if (state.userLocation != null && state.userLocation!.isValid) {
        coords.add(state.userLocation!);
      }

      if (coords.isNotEmpty) {
        final bounds = routeService.calculateBounds(coords);
        _controller?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 65.0),
        );
      }
    } catch (e) {
      AppLogger.warning('Camera fit adjustment skipped: $e', name: 'MAP');
    }
  }
}
