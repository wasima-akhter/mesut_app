import 'package:construction_app/core/enums/app_enum.dart';
import 'package:construction_app/features/map/data/datasources/mock_map_datasource.dart';
import 'package:construction_app/features/map/data/repositories/map_repository_impl.dart';
import 'package:construction_app/features/map/domain/entities/map_coordinate_entity.dart';
import 'package:construction_app/features/map/domain/entities/map_location_entity.dart';
import 'package:construction_app/features/map/domain/entities/map_request_entity.dart';
import 'package:construction_app/features/map/domain/entities/map_route_entity.dart';
import 'package:construction_app/features/map/services/map_marker_service.dart';
import 'package:construction_app/features/map/services/route_service.dart';
import 'package:construction_app/features/map/utils/map_coordinate_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MapCoordinate Entity Tests', () {
    test('validates valid latitude and longitude within range', () {
      const validCoord = MapCoordinate(
        latitude: 50.9375,
        longitude: 6.9603,
        name: 'Köln',
      );
      expect(validCoord.isValid, isTrue);
    });

    test('detects invalid out-of-range coordinates', () {
      const invalidLat = MapCoordinate(latitude: 95.0, longitude: 6.9603);
      const invalidLon = MapCoordinate(latitude: 50.0, longitude: 195.0);
      const nanCoord = MapCoordinate(latitude: double.nan, longitude: 6.0);

      expect(invalidLat.isValid, isFalse);
      expect(invalidLon.isValid, isFalse);
      expect(nanCoord.isValid, isFalse);
    });

    test('calculates correct Haversine distance between two coordinates', () {
      const cologneCenter = MapCoordinate(latitude: 50.9375, longitude: 6.9603);
      const bayenthal = MapCoordinate(latitude: 50.9082, longitude: 6.9723);

      final distanceKm = cologneCenter.distanceTo(bayenthal);
      expect(distanceKm, greaterThan(3.0));
      expect(distanceKm, lessThan(4.5));
    });
  });

  group('MapRouteEntity Tests', () {
    test('formats distance and duration correctly', () {
      const route = MapRouteEntity(
        id: 'test_route',
        title: 'Test Route',
        start: MapCoordinate(latitude: 50.93, longitude: 6.95),
        destination: MapCoordinate(latitude: 50.90, longitude: 6.97),
        waypoints: [
          MapCoordinate(latitude: 50.93, longitude: 6.95),
          MapCoordinate(latitude: 50.90, longitude: 6.97),
        ],
        distanceKm: 4.8,
        durationMinutes: 14,
        isMockData: true,
      );

      expect(route.formattedDistance, equals('4.8 km'));
      expect(route.formattedDuration, equals('14 min'));
      expect(route.isMockData, isTrue);
      expect(route.hasValidWaypoints, isTrue);
    });
  });

  group('MapRequestEntity Factory Tests', () {
    test('siteManagerOverview factory creates correct multiLocation request', () {
      final req = MapRequestEntity.siteManagerOverview(initialFilter: 'Erection');
      expect(req.role, equals(UserRole.siteManager));
      expect(req.purpose, equals(MapPurpose.multiLocation));
      expect(req.filterCategory, equals('Erection'));
      expect(req.initialCameraTarget?.latitude, closeTo(50.9375, 0.01));
    });

    test('routeNavigation factory creates correct route request', () {
      const dest = MapLocationEntity(
        id: '1',
        title: 'Site A',
        address: 'Goltsteinstraße 12, Köln',
        coordinate: MapCoordinate(latitude: 50.9082, longitude: 6.9723),
      );

      final req = MapRequestEntity.routeNavigation(
        role: UserRole.employee,
        destination: dest,
      );

      expect(req.role, equals(UserRole.employee));
      expect(req.purpose, equals(MapPurpose.route));
      expect(req.showRoute, isTrue);
      expect(req.destination?.id, equals('1'));
    });
  });

  group('MapRepository & MockMapDataSource Tests', () {
    late MapRepositoryImpl repository;

    setUp(() {
      repository = const MapRepositoryImpl();
    });

    test('fetches sample Cologne locations', () async {
      final locations = await repository.getLocations();
      expect(locations, isNotEmpty);
      expect(locations.length, greaterThanOrEqualTo(5));
      expect(locations.first.address, contains('Köln'));
    });

    test('filters locations by category', () async {
      final erections = await repository.getLocations(category: 'Erection');
      expect(erections, isNotEmpty);
      expect(erections.every((loc) => loc.type == 'Erection'), isTrue);
    });

    test('computes realistic route with waypoints', () async {
      const origin = MapCoordinate(latitude: 50.9355, longitude: 6.9531);
      const destination = MapCoordinate(latitude: 50.9082, longitude: 6.9723);

      final route = await repository.getRoute(
        origin: origin,
        destination: destination,
      );

      expect(route.waypoints, isNotEmpty);
      expect(route.waypoints.length, greaterThanOrEqualTo(10));
      expect(route.distanceKm, greaterThan(0.0));
      expect(route.durationMinutes, greaterThan(0));
      expect(route.isMockData, isTrue);
    });
  });

  group('MapCoordinateResolver Tests', () {
    test('resolves known Cologne addresses to realistic coordinates', () {
      final goltstein = MapCoordinateResolver.resolve('Goltsteinstraße 12, 50968 Köln');
      expect(goltstein.latitude, closeTo(50.9082, 0.001));
      expect(goltstein.longitude, closeTo(6.9723, 0.001));

      final severin = MapCoordinateResolver.resolve('Severinstraße 44, 50678 Köln');
      expect(severin.latitude, closeTo(50.9288, 0.001));
      expect(severin.longitude, closeTo(6.9587, 0.001));
    });

    test('falls back gracefully to Cologne center on empty or unknown address', () {
      final fallback = MapCoordinateResolver.resolve('');
      expect(fallback.latitude, closeTo(50.9375, 0.001));
      expect(fallback.longitude, closeTo(6.9603, 0.001));
    });
  });

  group('RouteService Tests', () {
    test('calculates safe bounding box for single coordinate', () {
      const service = RouteService();
      const coord = MapCoordinate(latitude: 50.9082, longitude: 6.9723);

      final bounds = service.calculateBounds([coord]);
      expect(bounds.southwest.latitude, lessThan(coord.latitude));
      expect(bounds.northeast.latitude, greaterThan(coord.latitude));
    });

    test('calculates safe bounding box for empty list without throwing', () {
      const service = RouteService();
      final bounds = service.calculateBounds([]);
      expect(bounds.southwest.latitude, isNotNull);
      expect(bounds.northeast.latitude, isNotNull);
    });
  });

  group('MapMarkerService Tests', () {
    test('creates markers and skips invalid coordinates', () {
      const service = MapMarkerService();
      final locations = [
        const MapLocationEntity(
          id: 'valid_1',
          title: 'Valid Site',
          address: 'Köln',
          coordinate: MapCoordinate(latitude: 50.91, longitude: 6.95),
          type: 'Erection',
        ),
        const MapLocationEntity(
          id: 'invalid_1',
          title: 'Invalid Site',
          address: 'Bad',
          coordinate: MapCoordinate(latitude: 100.0, longitude: 200.0), // Invalid
        ),
      ];

      final markers = service.createMarkers(locations: locations);
      expect(markers.length, equals(1));
      expect(markers.first.markerId.value, equals('valid_1'));
    });
  });
}
