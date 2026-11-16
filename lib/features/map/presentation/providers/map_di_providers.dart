import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/repositories/map_repository_impl.dart';
import '../../domain/repositories/map_repository.dart';
import '../../services/location_service.dart';
import '../../services/map_camera_service.dart';
import '../../services/map_marker_service.dart';
import '../../services/route_service.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return MapRepositoryImpl(client);
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

final mapCameraServiceProvider = Provider<MapCameraService>((ref) {
  return const MapCameraService();
});
