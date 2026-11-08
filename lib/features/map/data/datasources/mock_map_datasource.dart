import '../../domain/entities/map_coordinate_entity.dart';
import '../../domain/entities/map_location_entity.dart';
import '../../domain/entities/map_route_entity.dart';

/// Dedicated mock data source providing realistic Cologne (Köln) coordinates and route polylines.
/// All simulated data is clearly labeled.
class MockMapDataSource {
  const MockMapDataSource();

  /// Default headquarters / operating center in Cologne.
  static const MapCoordinate cologneCenter = MapCoordinate(
    latitude: 50.9375,
    longitude: 6.9603,
    name: 'Köln City Center',
  );

  /// Mock project sites in Cologne with realistic addresses and coordinates.
  static final List<MapLocationEntity> sampleLocations = [
    const MapLocationEntity(
      id: 'loc_1',
      title: 'Goltsteins Complex Erection',
      subtitle: 'Scaffold Erection Phase',
      company: 'Goldstein Bau GmbH',
      address: 'Goltsteinstraße 12, 50968 Köln',
      coordinate: MapCoordinate(
        latitude: 50.9082,
        longitude: 6.9723,
        name: 'Goltsteinstraße 12',
      ),
      type: 'Erection',
      priority: 'High',
      contactPerson: 'Andreas Weber',
      phone: '+49 221 555 0192',
      email: 'contact@goldstein-bau.de',
      date: 'Oct 08, 2026',
      imageUrl:
          'https://images.unsplash.com/photo-1541888946425-d0fbb1861564?w=500&q=80',
    ),
    const MapLocationEntity(
      id: 'loc_2',
      title: 'Severinstraße Restoration',
      subtitle: 'Standing Scaffold Inspection',
      company: 'Köln Denkmalschutz e.V.',
      address: 'Severinstraße 44, 50678 Köln',
      coordinate: MapCoordinate(
        latitude: 50.9288,
        longitude: 6.9587,
        name: 'Severinstraße 44',
      ),
      type: 'Standing',
      priority: 'Medium',
      contactPerson: 'Klaus Müller',
      phone: '+49 221 555 0144',
      email: 'bau@severin-koeln.de',
      date: 'Oct 03, 2026',
      imageUrl:
          'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=500&q=80',
    ),
    const MapLocationEntity(
      id: 'loc_3',
      title: 'Lindenthal Business Center #3',
      subtitle: 'Front Scaffold Safety Audit',
      company: 'RheinInvest Real Estate',
      address: 'Dürener Straße 120, 50931 Köln',
      coordinate: MapCoordinate(
        latitude: 50.9295,
        longitude: 6.9150,
        name: 'Dürener Str. 120',
      ),
      type: 'Erection',
      priority: 'High',
      contactPerson: 'Sabine Hoffmann',
      phone: '+49 221 555 0177',
      email: 'service@rheininvest.de',
      date: 'Oct 08, 2026',
      imageUrl:
          'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=500&q=80',
    ),
    const MapLocationEntity(
      id: 'loc_4',
      title: 'Ehrenfeld Industrial Park',
      subtitle: 'Facade Scaffold Dismantling',
      company: 'Ehrenfeld Creative Hub',
      address: 'Venloer Straße 100, 50672 Köln',
      coordinate: MapCoordinate(
        latitude: 50.9455,
        longitude: 6.9248,
        name: 'Venloer Str. 100',
      ),
      type: 'Dismantling',
      priority: 'Low',
      contactPerson: 'Marc Becker',
      phone: '+49 221 555 0122',
      email: 'tech@ehrenfeld-hub.de',
      date: 'Oct 07, 2026',
      imageUrl:
          'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=500&q=80',
    ),
    const MapLocationEntity(
      id: 'loc_5',
      title: 'Deutz Rhine Tower Scaffolding',
      subtitle: 'Bridge & Tower Technical Survey',
      company: 'Deutz Rheinbau AG',
      address: 'Mindener Straße 2, 50679 Köln',
      coordinate: MapCoordinate(
        latitude: 50.9385,
        longitude: 6.9740,
        name: 'Mindener Str. 2',
      ),
      type: 'Standing',
      priority: 'Medium',
      contactPerson: 'Thomas Schmidt',
      phone: '+49 221 555 0188',
      email: 'bauleitung@deutz-rheinbau.de',
      date: 'Oct 06, 2026',
      imageUrl:
          'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=500&q=80',
    ),
    const MapLocationEntity(
      id: 'loc_6',
      title: 'Rodenkirchen Villa Scaffolding',
      subtitle: 'Private Residence Renovation',
      company: 'Villa Rodenkirchen GbR',
      address: 'Hauptstraße 45, 50996 Köln',
      coordinate: MapCoordinate(
        latitude: 50.8932,
        longitude: 6.9912,
        name: 'Hauptstraße 45',
      ),
      type: 'Erection',
      priority: 'Low',
      contactPerson: 'Dr. Martin Vogel',
      phone: '+49 221 555 0199',
      email: 'm.vogel@rodenkirchen.de',
      date: 'Oct 05, 2026',
      imageUrl:
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=500&q=80',
    ),
  ];

  /// Realistic polyline connecting Köln Neumarkt / Central Station to Goltsteinstraße 12 (Bayenthal)
  /// along the Rheinuferstraße corridor.
  static List<MapCoordinate> generateCologneRouteWaypoints(
    MapCoordinate start,
    MapCoordinate destination,
  ) {
    if (!start.isValid || !destination.isValid) return const [];
    if (start == destination) return [start];

    // Build a realistic 12-point smooth curve between start and destination
    final points = <MapCoordinate>[];
    const steps = 12;
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      // Slight sinusoidal curvature to simulate natural road curvature
      final curveOffset = 0.003 * (1 - (2 * t - 1).abs());
      final lat = start.latitude + (destination.latitude - start.latitude) * t;
      final lon =
          start.longitude + (destination.longitude - start.longitude) * t + curveOffset;
      points.add(MapCoordinate(latitude: lat, longitude: lon));
    }
    return points;
  }

  /// Creates a mock route between origin and destination with realistic distance and time.
  static MapRouteEntity createSampleRoute({
    required MapCoordinate origin,
    required MapCoordinate destination,
    String? title,
  }) {
    final waypoints = generateCologneRouteWaypoints(origin, destination);
    final distance = origin.distanceTo(destination) * 1.35; // Factor for road distance
    final duration = (distance * 2.8).round().clamp(5, 120); // ~25-30 km/h city driving

    return MapRouteEntity(
      id: 'route_${origin.latitude}_${destination.latitude}',
      title: title ?? 'Route (${distance.toStringAsFixed(1)} km)',
      start: origin,
      destination: destination,
      waypoints: waypoints,
      distanceKm: double.parse(distance.toStringAsFixed(1)),
      durationMinutes: duration,
      isMockData: true,
    );
  }
}

