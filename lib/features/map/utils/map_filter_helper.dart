import '../domain/entities/map_location_entity.dart';

/// Helper for filtering and searching locations by category or query string.
class MapFilterHelper {
  const MapFilterHelper._();

  /// Filters [list] by [filter] category and text [query].
  static List<MapLocationEntity> applyFilterAndSearch(
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
}
