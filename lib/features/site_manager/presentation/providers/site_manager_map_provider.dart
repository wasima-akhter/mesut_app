import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helper/site_manager_models.dart';

class SiteManagerMapState {
  final String selectedFilter;
  final MapLocation? selectedLocation;
  final String searchQuery;
  final List<MapLocation> locations;

  const SiteManagerMapState({
    this.selectedFilter = 'All',
    this.selectedLocation,
    this.searchQuery = '',
    this.locations = const [
      MapLocation(
        id: '1',
        type: 'Erection',
        priority: 'High',
        title: 'Prj-0842 . Goisteins.Complex',
        company: 'Hochtief AG • Commercial',
        address: 'Goisteinstraße 12, 50968 Köln',
        date: 'Sept 18 - Sept 20 (2.5 days)',
        image: 'assets/images/project_preview.jpg',
        x: 0.60,
        y: 0.24,
      ),
      MapLocation(
        id: '2',
        type: 'Erection',
        priority: 'Medium',
        title: 'Project Erection Site',
        company: 'Construction Project',
        address: 'Leipzig, Germany',
        date: 'Sept 20 - Sept 22',
        image: 'assets/images/project_preview.jpg',
        x: 0.51,
        y: 0.34,
      ),
      MapLocation(
        id: '3',
        type: 'Dismantling',
        priority: 'High',
        title: 'Dismantling Project',
        company: 'Construction Company',
        address: 'Chemnitz, Germany',
        date: 'Sept 22 - Sept 24',
        image: 'assets/images/project_preview.jpg',
        x: 0.64,
        y: 0.43,
      ),
      MapLocation(
        id: '4',
        type: 'Standing',
        priority: 'Low',
        title: 'Standing Project',
        company: 'Construction Company',
        address: 'Bamberg, Germany',
        date: 'Sept 25 - Sept 28',
        image: 'assets/images/project_preview.jpg',
        x: 0.24,
        y: 0.54,
      ),
    ],
  });

  List<MapLocation> get filteredLocations {
    return locations.where((location) {
      final matchesFilter =
          selectedFilter == 'All' || location.type == selectedFilter;

      final query = searchQuery.trim().toLowerCase();
      if (query.isEmpty) return matchesFilter;

      final matchesSearch =
          location.title.toLowerCase().contains(query) ||
          location.company.toLowerCase().contains(query) ||
          location.address.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  SiteManagerMapState copyWith({
    String? selectedFilter,
    MapLocation? selectedLocation,
    bool clearSelectedLocation = false,
    String? searchQuery,
    List<MapLocation>? locations,
  }) {
    return SiteManagerMapState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedLocation: clearSelectedLocation
          ? null
          : (selectedLocation ?? this.selectedLocation),
      searchQuery: searchQuery ?? this.searchQuery,
      locations: locations ?? this.locations,
    );
  }
}

class SiteManagerMapNotifier extends Notifier<SiteManagerMapState> {
  @override
  SiteManagerMapState build() {
    return const SiteManagerMapState();
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void selectLocation(MapLocation? location) {
    if (location == null) {
      state = state.copyWith(clearSelectedLocation: true);
    } else {
      state = state.copyWith(selectedLocation: location);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final siteManagerMapProvider =
    NotifierProvider<SiteManagerMapNotifier, SiteManagerMapState>(
  SiteManagerMapNotifier.new,
);
