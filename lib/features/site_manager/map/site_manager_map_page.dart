import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_provider.dart';
import '../../map/domain/entities/map_request_entity.dart';
import '../../map/presentation/screens/central_map_screen.dart';

/// Site Manager Map Page.
///
/// Displays real project locations fetched from `GET /api/v1/mobile/projects`.
/// Supports:
/// - Real-time filtering by phase types (omits filter param when 'All' is selected).
/// - Case-insensitive search across project name, address, and city.
/// - Detailed project information card (name, customer, phase, address, hours, dates).
/// - Seamless return/back navigation to the initial all-sites view after inspecting a marker.
class SiteManagerMapPage extends ConsumerWidget {
  const SiteManagerMapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLanguageProvider);

    return CentralMapScreen(
      key: const ValueKey('site-manager-central-map'),
      initialRequest: MapRequestEntity.siteManagerOverview(),
    );
  }
}
