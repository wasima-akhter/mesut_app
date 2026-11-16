import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/entities/map_location_entity.dart';
import '../../domain/entities/map_request_entity.dart';
import '../../domain/entities/map_route_entity.dart';
import '../../services/map_camera_service.dart';
import '../../utils/map_filter_helper.dart';
import 'map_di_providers.dart';
import 'map_state.dart';

export 'map_di_providers.dart';

final mapProvider = NotifierProvider<MapNotifier, MapState>(MapNotifier.new);

class MapNotifier extends Notifier<MapState> {
  GoogleMapController? _controller;
  Timer? _searchDebounce;
  bool _isDisposed = false;

  @override
  MapState build() {
    ref.onDispose(() {
      _isDisposed = true;
      _searchDebounce?.cancel();
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
    AppLogger.info('Init Map: role=${request.role}, purpose=${request.purpose}', name: 'MAP');

    final target = request.initialCameraTarget?.toLatLng() ??
        request.destination?.coordinate.toLatLng() ??
        MapCameraService.cologneCityCenter;

    state = state.copyWith(
      status: MapStatus.loading,
      request: request,
      errorMessage: null,
      selectedFilter: request.filterCategory ?? 'All',
      clearActiveRoute: request.route == null,
      clearSelectedLocation: request.destination == null,
      initialCameraPosition: CameraPosition(target: target, zoom: request.initialZoom),
    );

    try {
      final locationService = ref.read(locationServiceProvider);
      final repository = ref.read(mapRepositoryProvider);

      final hasPerm = await locationService.hasLocationPermission() ||
          await locationService.requestLocationPermission();
      final userCoord = (hasPerm || request.enableUserTracking) ? await locationService.getCurrentLocation() : null;

      final locations = request.locations.isNotEmpty
          ? request.locations
          : (request.destination != null
              ? [request.destination!]
              : await repository.getLocations(role: request.role, category: request.filterCategory, search: state.searchQuery));

      MapRouteEntity? route = request.route;
      final originCoord = request.origin?.coordinate ?? (userCoord != null && userCoord.isValid ? userCoord : null);
      if (route == null && request.showRoute && request.destination != null && originCoord != null) {
        route = await repository.getRoute(
          origin: originCoord,
          destination: request.destination!.coordinate,
          title: 'Route to ${request.destination!.title}',
        );
      }

      final filtered = MapFilterHelper.applyFilterAndSearch(
        locations,
        state.selectedFilter,
        state.searchQuery,
      );

      final markers = ref.read(mapMarkerServiceProvider).buildMapMarkers(
            locations: filtered,
            request: request,
            route: route,
            userCoord: userCoord,
            selectedLocationId: state.selectedLocation?.id,
            onLocationTap: selectLocation,
          );

      if (!_isDisposed) {
        state = state.copyWith(
          status: MapStatus.ready,
          userLocation: userCoord,
          hasLocationPermission: hasPerm,
          allLocations: locations,
          filteredLocations: filtered,
          selectedLocation: request.destination ?? (locations.length == 1 ? locations.first : null),
          activeRoute: route,
          markers: markers,
          polylines: _generatePolylines(route),
        );
        _fitCameraToContent();
      }
    } catch (e, st) {
      AppLogger.error('Failed to init map', error: e, stackTrace: st, name: 'MAP');
      if (!_isDisposed) {
        state = state.copyWith(status: MapStatus.error, errorMessage: e.toString());
      }
    }
  }

  /// Selects a location on the map. Passing null resets back to all sites.
  void selectLocation(MapLocationEntity? location) {
    if (_isDisposed) return;
    AppLogger.info('Selected location: ${location?.title}', name: 'MAP');
    state = state.copyWith(
      selectedLocation: location,
      clearSelectedLocation: location == null,
      clearActiveRoute: location == null,
      polylines: location == null ? const {} : state.polylines,
    );
    _updateMarkers();

    if (location != null && location.hasValidCoordinates && _controller != null) {
      _controller?.animateCamera(CameraUpdate.newLatLngZoom(location.coordinate.toLatLng(), 15.0));
    } else if (location == null) {
      _fitCameraToContent();
    }
  }

  /// Clears active route and selected location, resetting view back to all projects.
  void clearRouteOrSelection() {
    if (_isDisposed) return;
    AppLogger.info('Reset map: clear route and selection', name: 'MAP');
    state = state.copyWith(clearActiveRoute: true, clearSelectedLocation: true, polylines: const {});
    _updateMarkers();
    _fitCameraToContent();
  }

  /// Sets category filter chip and fetches matching projects from API.
  Future<void> setFilter(String filter) async {
    if (_isDisposed) return;
    AppLogger.info('Filter changed to: $filter', name: 'MAP');
    state = state.copyWith(selectedFilter: filter, clearSelectedLocation: true);
    await _reloadLocations();
  }

  /// Updates search query and fetches matching projects from API with debounce.
  void setSearchQuery(String query) {
    if (_isDisposed) return;
    state = state.copyWith(searchQuery: query);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      if (_isDisposed) return;
      await _reloadLocations();
    });
  }

  Future<void> _reloadLocations() async {
    try {
      final repository = ref.read(mapRepositoryProvider);
      final locations = state.request.locations.isNotEmpty
          ? MapFilterHelper.applyFilterAndSearch(state.request.locations, state.selectedFilter, state.searchQuery)
          : await repository.getLocations(
              role: state.request.role,
              category: state.selectedFilter,
              search: state.searchQuery,
            );

      if (_isDisposed) return;
      final markers = ref.read(mapMarkerServiceProvider).buildMapMarkers(
            locations: locations,
            request: state.request,
            route: state.activeRoute,
            userCoord: state.userLocation,
            selectedLocationId: state.selectedLocation?.id,
            onLocationTap: selectLocation,
          );

      state = state.copyWith(
        allLocations: locations,
        filteredLocations: locations,
        markers: markers,
      );

      if (state.selectedLocation == null) {
        _fitCameraToContent();
      }
    } catch (e, st) {
      AppLogger.error('Failed to reload map', error: e, stackTrace: st, name: 'MAP');
    }
  }

  /// Requests current GPS position and recenters camera.
  Future<void> recenterOnUser() async {
    if (_isDisposed) return;
    var coord = state.userLocation;
    if (coord == null || !coord.isValid) {
      final locService = ref.read(locationServiceProvider);
      final granted = await locService.requestLocationPermission();
      state = state.copyWith(hasLocationPermission: granted);
      if (granted && !_isDisposed) {
        coord = await locService.getCurrentLocation();
        if (coord != null) {
          state = state.copyWith(userLocation: coord);
          _updateMarkers();
        }
      }
    }

    await ref.read(mapCameraServiceProvider).recenterOnUserOrFallback(
          controller: _controller,
          userLocation: coord,
          fallbackLocations: state.filteredLocations,
        );
  }

  /// Loads turn-by-turn route to a specific destination.
  /// Requests location permission and queries GPS sensor if not yet acquired.
  Future<bool> loadRouteTo(MapLocationEntity destination) async {
    if (_isDisposed) return false;
    try {
      var userCoord = state.userLocation;
      if (userCoord == null || !userCoord.isValid) {
        final locService = ref.read(locationServiceProvider);
        final hasPerm = await locService.hasLocationPermission() ||
            await locService.requestLocationPermission();
        state = state.copyWith(hasLocationPermission: hasPerm);
        if (hasPerm) {
          userCoord = await locService.getCurrentLocation();
          if (userCoord != null && userCoord.isValid && !_isDisposed) {
            state = state.copyWith(userLocation: userCoord);
            _updateMarkers();
          }
        }
      }

      if (userCoord == null || !userCoord.isValid) return false;

      final route = await ref.read(mapRepositoryProvider).getRoute(
            origin: userCoord,
            destination: destination.coordinate,
            title: 'Route to ${destination.title}',
          );
      state = state.copyWith(activeRoute: route, selectedLocation: destination, polylines: _generatePolylines(route));

      _updateMarkers();
      _fitCameraToContent();
      return true;
    } catch (e, st) {
      AppLogger.error('Failed to load route', error: e, stackTrace: st, name: 'MAP_ROUTE');
      return false;
    }
  }

  void retry() => initialize(state.request);

  void toggleMapType() => state = state.copyWith(
        mapType: state.mapType == MapType.normal ? MapType.hybrid : MapType.normal,
      );

  void toggleTraffic() => state = state.copyWith(isTrafficEnabled: !state.isTrafficEnabled);

  void _updateMarkers() => state = state.copyWith(
        markers: ref.read(mapMarkerServiceProvider).buildMapMarkers(
              locations: state.filteredLocations,
              request: state.request,
              route: state.activeRoute,
              userCoord: state.userLocation,
              selectedLocationId: state.selectedLocation?.id,
              onLocationTap: selectLocation,
            ),
      );

  Set<Polyline> _generatePolylines(MapRouteEntity? route) =>
      route == null || route.isEmpty ? const {} : {ref.read(routeServiceProvider).createPolyline(route: route)};

  void _fitCameraToContent() {
    if (_controller == null || _isDisposed) return;
    ref.read(mapCameraServiceProvider).fitToContent(
          controller: _controller,
          routeService: ref.read(routeServiceProvider),
          locations: state.filteredLocations,
          userLocation: state.userLocation,
          activeRoute: state.activeRoute,
          selectedLocation: state.selectedLocation,
        );
  }
}
