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
import '../../../../core/widgets/buttons/app_back_button.dart';
import '../../domain/entities/map_location_entity.dart';
import '../../domain/entities/map_request_entity.dart';
import '../providers/map_provider.dart';
import '../providers/map_state.dart';
import '../widgets/map_controls.dart';
import '../widgets/map_error_view.dart';
import '../widgets/map_info_panel.dart';
import '../widgets/map_loading_view.dart';
import '../widgets/map_location_card.dart';

/// Centralized, production-oriented Google Maps screen supporting all roles and map modes.
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

  static const List<String> _filterCategories = [
    'All',
    'Erection',
    'Dismantling',
    'Standing',
    'Inspection',
  ];

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
      final request =
          widget.initialRequest ??
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

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    final notifier = ref.read(mapProvider.notifier);
    final isMulti = mapState.request.purpose == MapPurpose.multiLocation;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ------------------------------------------------------------------
          // 1. Google Map View
          // ------------------------------------------------------------------
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
              _localMapController = controller;
              notifier.attachMapController(controller);
            },
            onTap: (_) {
              if (mapState.activeRoute == null) {
                notifier.selectLocation(null);
              }
            },
          ),

          // ------------------------------------------------------------------
          // 2. Top Header & Search / Filters
          // ------------------------------------------------------------------
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(mapState),
                  if (isMulti) ...[
                    SizedBox(height: 10.h),
                    _buildSearchBar(notifier),
                    SizedBox(height: 8.h),
                    _buildFilterChips(mapState, notifier),
                  ],
                ],
              ),
            ),
          ),

          // ------------------------------------------------------------------
          // 3. Map Floating Controls (Recenter, Zoom, Map Type, Traffic)
          // ------------------------------------------------------------------
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

          // ------------------------------------------------------------------
          // 4. Informative Location Permission Banner (Non-blocking)
          // ------------------------------------------------------------------
          if (!mapState.hasLocationPermission && !mapState.isLoading)
            Positioned(
              left: 16.w,
              right: 16.w,
              top: isMulti ? 195.h : 95.h,
              child: _buildPermissionNotice(notifier),
            ),

          // ------------------------------------------------------------------
          // 5. Bottom Overlay: Route Info Panel OR Selected Location Card
          // ------------------------------------------------------------------
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
                      destination:
                          mapState.selectedLocation ??
                          mapState.request.destination,
                      onClose: () {
                        notifier.initialize(
                          mapState.request.copyWith(showRoute: false),
                        );
                      },
                    )
                  : (mapState.selectedLocation != null
                        ? MapLocationCard(
                            key: ValueKey(
                              'card_${mapState.selectedLocation!.id}',
                            ),
                            location: mapState.selectedLocation!,
                            onRoute: () => notifier.loadRouteTo(
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

          // ------------------------------------------------------------------
          // 6. Loading Indicator
          // ------------------------------------------------------------------
          if (mapState.isLoading)
            Positioned.fill(
              child: MapLoadingView(message: context.loc.mapLoadingData),
            ),

          // ------------------------------------------------------------------
          // 7. Error State
          // ------------------------------------------------------------------
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

  Widget _buildTopBar(MapState state) {
    final canPop = Navigator.of(context).canPop();
    final title =
        state.request.title ??
        (state.request.role == UserRole.siteManager
            ? context.loc.mapSiteManagerMap
            : context.loc.mapAssignmentNavigation);

    return Row(
      children: [
        if (canPop) ...[
          AppBackButton(onPressed: () => context.pop()),
          SizedBox(width: 10.w),
        ],
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_city,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _roleBadge(state.request.role),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(MapNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: notifier.setSearchQuery,
        decoration: InputDecoration(
          hintText: context.loc.mapSearchHint,
          hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    notifier.setSearchQuery('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildFilterChips(MapState state, MapNotifier notifier) {
    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filterCategories.length,
        separatorBuilder: (_, _) => SizedBox(width: 6.w),
        itemBuilder: (context, index) {
          final cat = _filterCategories[index];
          final isSelected = state.selectedFilter == cat;

          return GestureDetector(
            onTap: () => notifier.setFilter(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Text(
                _localizeFilter(context, cat),
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPermissionNotice(MapNotifier notifier) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFFD54F)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Color(0xFFF57F17)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              context.loc.mapPermissionNotice,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFE65100),
              ),
            ),
          ),
          TextButton(
            onPressed: notifier.recenterOnUser,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 24),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              context.loc.mapEnable,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleBadge(UserRole role) {
    final isSM = role == UserRole.siteManager;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isSM
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        isSM ? context.loc.mapRoleSiteManager : context.loc.mapRoleEmployee,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: isSM ? AppColors.primary : AppColors.info,
        ),
      ),
    );
  }

  String _localizeFilter(BuildContext context, String cat) {
    switch (cat) {
      case 'All':
        return context.loc.mapFilterAll;
      case 'Erection':
        return context.loc.mapFilterErection;
      case 'Dismantling':
        return context.loc.mapFilterDismantling;
      case 'Standing':
        return context.loc.mapFilterStanding;
      case 'Inspection':
        return context.loc.mapFilterInspection;
      default:
        return cat;
    }
  }
}
