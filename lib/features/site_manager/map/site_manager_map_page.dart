import 'package:flutter/material.dart';
import '../../map/domain/entities/map_request_entity.dart';
import '../../map/presentation/screens/central_map_screen.dart';

/// Site Manager Map Tab page embedding the centralized Google Maps screen.
class SiteManagerMapPage extends StatelessWidget {
  const SiteManagerMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CentralMapScreen(
      initialRequest: MapRequestEntity.siteManagerOverview(),
    );
  }
}
