import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/constants/route_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/app_enum.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/map_location_entity.dart';
import '../../domain/entities/map_request_entity.dart';
import '../providers/map_provider.dart';
import '../widgets/map_controls.dart';
import '../widgets/map_error_view.dart';
import '../widgets/map_header_bar.dart';
import '../widgets/map_info_panel.dart';
import '../widgets/map_loading_view.dart';
import '../widgets/map_location_card.dart';
import '../widgets/map_permission_banner.dart';

/// Centralized, production-ready Google Maps screen supporting all roles and map modes.
class CentralMapScreen extends ConsumerStatefulWidget {
  final MapRequestEntity? initialRequest;

  const CentralMapScreen({super.key, this.initialRequest});

  @override
  ConsumerState<CentralMapScreen> createState() => _CentralMapScreenState();
}

class _CentralMapScreenState extends ConsumerState<CentralMapScreen> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _localMapController;
  bool _isMapInitialized = false;
  Timer? _diagnosticTimer;

  @override
  void initState() {
    super.initState();
    _diagnosticTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && !_isMapInitialized) {
        AppLogger.warning(
          'Google Maps view has not attached after 8s. Check API key enablement and device network.',
          name: 'MAP',
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = widget.initialRequest ??
          MapRequestEntity(
            role: UserRole.siteManager,
            purpose: MapPurpose.multiLocation,
          );
      ref.read(mapProvider.notifier).initialize(request);
    });
  }

  @override
  void dispose() {
    _diagnosticTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onOpenProjectDetails(MapLocationEntity location) {
    context.push(RouteConstants.siteManagerProjectDetail, extra: location.id);
  }

  Future<void> _handleShowRoute(MapLocationEntity location) async {
    final success = await ref.read(mapProvider.notifier).loadRouteTo(location);
    if (!success && mounted) {
      _showEnableLocationDialog();
    }
  }

  void _showEnableLocationDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        icon: Icon(Icons.location_off_outlined, size: 36.sp, color: AppColors.primary),
        title: Text(
          context.loc.locationPermissionRequired,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.loc.locationPermissionMessage,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5.sp, color: AppColors.textSecondary),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(context.loc.cancel, style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final locationService = ref.read(locationServiceProvider);
              final isGpsOn = await locationService.isLocationServiceEnabled();
              if (!isGpsOn) {
                await locationService.openLocationSettings();
              } else {
                await locationService.openSettings();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text(context.loc.settings, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    final notifier = ref.read(mapProvider.notifier);
    final isMulti = mapState.request.purpose == MapPurpose.multiLocation;
    final canPop = Navigator.of(context).canPop();
    final hasSelection =
        mapState.selectedLocation != null || mapState.activeRoute != null;
    final onBack = hasSelection
        ? () => notifier.clearRouteOrSelection()
        : (canPop ? () => context.pop() : null);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Google Map View
          GoogleMap(
            initialCameraPosition: mapState.initialCameraPosition,
            markers: mapState.markers,
            polylines: mapState.polylines,
            mapType: mapState.mapType,
            trafficEnabled: mapState.isTrafficEnabled,
            myLocationEnabled: mapState.hasLocationPermission,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            padding: EdgeInsets.only(
              top: isMulti ? 140.h : 80.h,
              bottom: mapState.activeRoute != null
                  ? 210.h
                  : (mapState.selectedLocation != null ? 180.h : 30.h),
            ),
            onMapCreated: (controller) {
              _isMapInitialized = true;
              _localMapController = controller;
              notifier.attachMapController(controller);
            },
            onTap: (_) {
              if (hasSelection) {
                notifier.clearRouteOrSelection();
              }
            },
          ),

          // 2. Top Header & Search / Filters
          MapHeaderBar(
            state: mapState,
            searchController: _searchController,
            onSearchChanged: notifier.setSearchQuery,
            onSearchClear: () {
              _searchController.clear();
              notifier.setSearchQuery('');
            },
            onFilterChanged: notifier.setFilter,
            onBack: onBack,
          ),

          // 3. Map Floating Controls (Recenter, Zoom, Map Type, Traffic)
          Positioned(
            right: 16.w,
            top: isMulti ? 200.h : 130.h,
            child: MapControls(
              onRecenter: notifier.recenterOnUser,
              onZoomIn: () =>
                  _localMapController?.animateCamera(CameraUpdate.zoomIn()),
              onZoomOut: () =>
                  _localMapController?.animateCamera(CameraUpdate.zoomOut()),
              onToggleMapType: notifier.toggleMapType,
              onToggleTraffic: notifier.toggleTraffic,
              isTrafficEnabled: mapState.isTrafficEnabled,
              isHybrid: mapState.mapType == MapType.hybrid,
            ),
          ),

          // 4. Location Permission Banner (Non-blocking, visible when GPS is off or denied)
          if (!mapState.hasLocationPermission && !mapState.isLoading)
            Positioned(
              left: 16.w,
              right: 16.w,
              top: isMulti ? 195.h : 95.h,
              child: MapPermissionBanner(onEnable: notifier.recenterOnUser),
            ),

          // 5. Bottom Overlay: Route Info Panel OR Selected Location Card
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 20.h,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: mapState.activeRoute != null
                  ? MapInfoPanel(
                      key: const ValueKey('route_panel'),
                      route: mapState.activeRoute!,
                      destination: mapState.selectedLocation ??
                          mapState.request.destination,
                      onClose: () => notifier.clearRouteOrSelection(),
                    )
                  : (mapState.selectedLocation != null
                      ? MapLocationCard(
                          key: ValueKey('card_${mapState.selectedLocation!.id}'),
                          location: mapState.selectedLocation!,
                          userLocation: mapState.userLocation,
                          onRoute: () => _handleShowRoute(
                            mapState.selectedLocation!,
                          ),
                          onOpenDetails: () => _onOpenProjectDetails(
                            mapState.selectedLocation!,
                          ),
                          onClose: () => notifier.selectLocation(null),
                        )
                      : const SizedBox.shrink()),
            ),
          ),

          // 6. Loading Indicator
          if (mapState.isLoading)
            Positioned.fill(
              child: MapLoadingView(message: context.loc.mapLoadingData),
            ),

          // 7. Error State
          if (mapState.hasError)
            Positioned.fill(
              child: MapErrorView(
                message: mapState.errorMessage,
                onRetry: notifier.retry,
              ),
            ),
        ],
      ),
    );
  }
}
