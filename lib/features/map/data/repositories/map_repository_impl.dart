import '../../../../core/enums/app_enum.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/map_coordinate_entity.dart';
import '../../domain/entities/map_location_entity.dart';
import '../../domain/entities/map_route_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/mock_map_datasource.dart';

/// Concrete implementation of [MapRepository] backed by [MockMapDataSource].
/// Can be seamlessly swapped with [RemoteMapRepository] once backend APIs are ready.
class MapRepositoryImpl implements MapRepository {
  final MockMapDataSource _dataSource;

  const MapRepositoryImpl({MockMapDataSource? dataSource})
      : _dataSource = dataSource ?? const MockMapDataSource();

  @override
  Future<List<MapLocationEntity>> getLocations({
    UserRole? role,
    String? category,
  }) async {
    AppLogger.info(
      'Fetching locations: role=$role, category=$category',
      name: 'MAP',
    );
    // Simulate brief network latency
    await Future.delayed(const Duration(milliseconds: 150));

    var list = MockMapDataSource.sampleLocations;

    if (category != null && category.isNotEmpty && category != 'All') {
      list = list.where((loc) => loc.type == category).toList();
    }

    return list;
  }

  @override
  Future<MapLocationEntity?> getLocationById(String id) async {
    AppLogger.info('Fetching location by ID: $id', name: 'MAP');
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return MockMapDataSource.sampleLocations.firstWhere((loc) => loc.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<MapRouteEntity> getRoute({
    required MapCoordinate origin,
    required MapCoordinate destination,
    String? title,
  }) async {
    AppLogger.info(
      'Calculating route from ${origin.latitude},${origin.longitude} to ${destination.latitude},${destination.longitude}',
      name: 'MAP_ROUTE',
    );
    await Future.delayed(const Duration(milliseconds: 200));

    return MockMapDataSource.createSampleRoute(
      origin: origin,
      destination: destination,
      title: title,
    );
  }

  @override
  Future<List<MapLocationEntity>> getNearbySites({
    required MapCoordinate center,
    double radiusKm = 15.0,
  }) async {
    AppLogger.info(
      'Searching sites within ${radiusKm}km of ${center.latitude},${center.longitude}',
      name: 'MAP_LOCATION',
    );
    await Future.delayed(const Duration(milliseconds: 100));

    return MockMapDataSource.sampleLocations
        .where((loc) => center.distanceTo(loc.coordinate) <= radiusKm)
        .toList();
  }
}

