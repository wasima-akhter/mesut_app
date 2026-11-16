import '../../../../core/constants/api_constants.dart';
import '../../../../core/enums/app_enum.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/address_resolver_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/map_coordinate_entity.dart';
import '../../domain/entities/map_location_entity.dart';
import '../../domain/entities/map_route_entity.dart';
import '../../domain/repositories/map_repository.dart';

/// Concrete implementation of [MapRepository] backed by real mobile APIs.
class MapRepositoryImpl implements MapRepository {
  final ApiClient _client;

  const MapRepositoryImpl(this._client);

  @override
  Future<List<MapLocationEntity>> getLocations({
    UserRole? role,
    String? category,
  }) async {
    AppLogger.info(
      'Fetching real project locations: role=$role, category=$category',
      name: 'MAP',
    );

    final locations = <MapLocationEntity>[];

    try {
      final response = await _client.get(
        ApiConstants.mobileProjects,
        queryParameters: {
          'tab': 'ALL',
          'limit': 50,
        },
      );

      final rawData = response.data;
      if (rawData is Map<String, dynamic> && rawData['data'] is List) {
        final list = rawData['data'] as List;
        for (final item in list) {
          if (item is! Map<String, dynamic>) continue;

          final coords = item['coordinates'] as Map<String, dynamic>? ?? {};
          final lat = _asDouble(coords['lat']);
          final lng = _asDouble(coords['lng']);
          if (lat == 0 && lng == 0) continue;

          final id = item['projectId']?.toString() ??
              item['id']?.toString() ??
              '';
          final title = item['projectName']?.toString() ??
              item['name']?.toString() ??
              'Project';
          final customerObj = item['customer'] is Map
              ? item['customer'] as Map<String, dynamic>
              : null;
          final company = customerObj?['name']?.toString();
          final rawType = item['type']?.toString() ?? 'Erection';
          final normalizedType = _normalizeType(rawType);
          final priority = _normalizePriority(item['priority']?.toString());
          final address = AddressResolverService.resolveSync(
            lat,
            lng,
            fallbackCity: item['city']?.toString(),
          );

          locations.add(
            MapLocationEntity(
              id: id,
              title: title,
              subtitle: '$normalizedType • ${item['status'] ?? 'Active'}',
              company: company,
              address: address,
              coordinate: MapCoordinate(
                latitude: lat,
                longitude: lng,
                name: title,
              ),
              type: normalizedType,
              priority: priority,
              contactPerson: item['assigneeName']?.toString(),
            ),
          );
        }
      }

      // Fallback: Query /mobile/map pins if no coordinates found from projects
      if (locations.isEmpty) {
        final mapResponse = await _client.get(ApiConstants.mobileMap);
        final mapData = mapResponse.data;
        if (mapData is Map<String, dynamic> && mapData['data'] is List) {
          for (final pin in mapData['data']) {
            if (pin is! Map<String, dynamic>) continue;
            final lat = _asDouble(pin['latitude'] ?? pin['lat']);
            final lng = _asDouble(pin['longitude'] ?? pin['lng']);
            if (lat == 0 && lng == 0) continue;

            final id = pin['id']?.toString() ?? '';
            final title = pin['name']?.toString() ?? 'Project';
            final rawType = pin['activePhaseType']?.toString() ?? 'Erection';
            final normalizedType = _normalizeType(rawType);
            final address = AddressResolverService.resolveSync(lat, lng);

            locations.add(
              MapLocationEntity(
                id: id,
                title: title,
                subtitle: normalizedType,
                address: address,
                coordinate: MapCoordinate(
                  latitude: lat,
                  longitude: lng,
                  name: title,
                ),
                type: normalizedType,
                priority: 'High',
              ),
            );
          }
        }
      }

      if (category != null && category.isNotEmpty && category != 'All') {
        return locations.where((loc) => loc.type == category).toList();
      }

      return locations;
    } catch (e, st) {
      AppLogger.error(
        'Failed to fetch real map locations from API',
        error: e,
        stackTrace: st,
        name: 'MAP',
      );
      return [];
    }
  }

  @override
  Future<MapLocationEntity?> getLocationById(String id) async {
    AppLogger.info('Fetching real location by ID: $id', name: 'MAP');
    try {
      final response = await _client.get(ApiConstants.mobileProjectById(id));
      final rawData = response.data;
      if (rawData is Map<String, dynamic> &&
          rawData['data'] is Map<String, dynamic>) {
        final item = rawData['data'] as Map<String, dynamic>;
        final coords = item['coordinates'] as Map<String, dynamic>? ?? {};
        final lat = _asDouble(coords['lat']);
        final lng = _asDouble(coords['lng']);
        final title = item['name']?.toString() ?? 'Project';
        final address = AddressResolverService.resolveSync(lat, lng);

        return MapLocationEntity(
          id: id,
          title: title,
          subtitle: item['status']?.toString() ?? 'Active',
          address: address,
          coordinate: MapCoordinate(
            latitude: lat,
            longitude: lng,
            name: title,
          ),
          type: 'Erection',
          priority: item['priority']?.toString(),
        );
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<MapRouteEntity> getRoute({
    required MapCoordinate origin,
    required MapCoordinate destination,
    String? title,
  }) async {
    final distanceKm = origin.distanceTo(destination);
    final durationMinutes = (distanceKm / 40.0 * 60).round().clamp(1, 9999);

    final waypoints = [
      origin,
      MapCoordinate(
        latitude: (origin.latitude * 2 + destination.latitude) / 3,
        longitude: (origin.longitude * 2 + destination.longitude) / 3,
      ),
      MapCoordinate(
        latitude: (origin.latitude + destination.latitude * 2) / 3,
        longitude: (origin.longitude + destination.longitude * 2) / 3,
      ),
      destination,
    ];

    return MapRouteEntity(
      id: 'route_${origin.latitude}_${destination.latitude}',
      title: title ?? 'Route',
      origin: origin,
      destination: destination,
      waypoints: waypoints,
      distanceKm: double.parse(distanceKm.toStringAsFixed(1)),
      durationMinutes: durationMinutes,
      steps: [
        MapRouteStep(
          instruction: 'Navigate towards ${destination.name.isNotEmpty ? destination.name : 'Destination'}',
          distance: '${distanceKm.toStringAsFixed(1)} km',
          duration: '$durationMinutes min',
          coordinate: origin,
        ),
      ],
    );
  }

  @override
  Future<List<MapLocationEntity>> getNearbySites({
    required MapCoordinate center,
    double radiusKm = 15.0,
  }) async {
    final all = await getLocations();
    return all
        .where((loc) => center.distanceTo(loc.coordinate) <= radiusKm)
        .toList();
  }

  static double _asDouble(dynamic val) {
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  static String _normalizeType(String? raw) {
    final upper = raw?.toUpperCase() ?? '';
    if (upper.contains('DISMANTL')) return 'Dismantling';
    if (upper.contains('STAND')) return 'Standing';
    if (upper.contains('INSPECT')) return 'Inspection';
    return 'Erection';
  }

  static String _normalizePriority(String? raw) {
    final upper = raw?.toUpperCase() ?? '';
    if (upper == 'HIGH') return 'High';
    if (upper == 'LOW') return 'Low';
    return 'Medium';
  }
}
