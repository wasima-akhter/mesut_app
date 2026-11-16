import '../../../../core/enums/app_enum.dart';
import '../entities/map_coordinate_entity.dart';
import '../entities/map_location_entity.dart';
import '../entities/map_route_entity.dart';

/// Abstract repository defining the contract for map locations and route data.
/// Switching to [RemoteMapRepository] later requires ZERO UI changes.
abstract class MapRepository {
  /// Fetches all active locations for the specified role, optional category filter, and search query.
  Future<List<MapLocationEntity>> getLocations({
    UserRole? role,
    String? category,
    String? search,
  });

  /// Fetches a specific location by its unique ID.
  Future<MapLocationEntity?> getLocationById(String id);

  /// Computes or retrieves route between two coordinates with waypoints.
  Future<MapRouteEntity> getRoute({
    required MapCoordinate origin,
    required MapCoordinate destination,
    String? title,
  });

  /// Fetches sites within a given radius in kilometers.
  Future<List<MapLocationEntity>> getNearbySites({
    required MapCoordinate center,
    double radiusKm = 15.0,
  });
}
