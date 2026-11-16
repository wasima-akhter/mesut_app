import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/localization_provider.dart';
import '../../map/domain/entities/map_coordinate_entity.dart';
import '../../map/domain/entities/map_location_entity.dart';
import '../../map/domain/entities/map_request_entity.dart';
import '../../map/presentation/screens/central_map_screen.dart';
import '../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';

/// Site Manager Map Tab page powered by `GET /api/v1/mobile/map`.
class SiteManagerMapPage extends ConsumerWidget {
  const SiteManagerMapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLanguageProvider);
    final pinsAsync = ref.watch(mobileMapPinsProvider);
    final notifier = ref.read(mobileMapPinsProvider.notifier);
    final selectedType = notifier.selectedType;

    final pins = pinsAsync.asData?.value ?? const [];
    final locations = pins
        .map(
          (pin) => MapLocationEntity(
            id: pin.id,
            title: pin.name,
            address: pin.name,
            coordinate: MapCoordinate(
              latitude: pin.latitude,
              longitude: pin.longitude,
              name: pin.name,
            ),
            type: pin.activePhaseType,
          ),
        )
        .toList();

    final signature =
        '${selectedType ?? "ALL"}_${pins.map((e) => e.id).join("_")}';

    final filters = <(String?, String)>[
      (null, context.loc.mapFilterAll),
      ('ERECTION', context.loc.erectionPhase),
      ('DISMANTLING', context.loc.dismantlingPhase),
      ('STANDING', context.loc.standing),
      ('MAINTENANCE', context.loc.maintenancePhase),
    ];

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final (typeValue, label) = filters[index];
                return ChoiceChip(
                  label: Text(label),
                  selected: selectedType == typeValue,
                  onSelected: (_) => notifier.filterByType(typeValue),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              CentralMapScreen(
                key: ValueKey('sm-map-$signature'),
                initialRequest: MapRequestEntity.siteManagerOverview(
                  locations: locations,
                  initialFilter: selectedType,
                ),
              ),
              if (pinsAsync.hasValue && pins.isEmpty)
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_off_outlined, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(context.loc.noProjectsFound)),
                          TextButton(
                            onPressed: () =>
                                ref.invalidate(mobileMapPinsProvider),
                            child: Text(context.loc.mapRetry),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
