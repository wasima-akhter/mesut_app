import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/services/address_resolver_service.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../../../core/widgets/snack/app_snackbar.dart';
import '../../../../map/services/location_service.dart';

class LocationMapPickerSheet extends StatefulWidget {
  final double initialLat;
  final double initialLng;

  const LocationMapPickerSheet({
    super.key,
    required this.initialLat,
    required this.initialLng,
  });

  static Future<({double lat, double lng, String address})?> show(
    BuildContext context, {
    required double initialLat,
    required double initialLng,
  }) {
    return showModalBottomSheet<({double lat, double lng, String address})>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationMapPickerSheet(
        initialLat: initialLat,
        initialLng: initialLng,
      ),
    );
  }

  @override
  State<LocationMapPickerSheet> createState() => _LocationMapPickerSheetState();
}

class _LocationMapPickerSheetState extends State<LocationMapPickerSheet> {
  late double _selectedLat;
  late double _selectedLng;
  late String _resolvedAddress;
  GoogleMapController? _mapController;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _selectedLat = widget.initialLat != 0 ? widget.initialLat : 50.9375;
    _selectedLng = widget.initialLng != 0 ? widget.initialLng : 6.9603;
    _resolvedAddress = AddressResolverService.resolveSync(
      _selectedLat,
      _selectedLng,
    );
    AddressResolverService.resolve(_selectedLat, _selectedLng).then((addr) {
      if (mounted) setState(() => _resolvedAddress = addr);
    });
  }

  void _updatePosition(double lat, double lng) {
    setState(() {
      _selectedLat = lat;
      _selectedLng = lng;
      _resolvedAddress = AddressResolverService.resolveSync(lat, lng);
    });
    AddressResolverService.resolve(lat, lng).then((addr) {
      if (mounted && _selectedLat == lat && _selectedLng == lng) {
        setState(() => _resolvedAddress = addr);
      }
    });
  }

  Future<void> _moveToCurrentLocation() async {
    setState(() => _isLocating = true);
    final locationService = const LocationService();

    var hasPermission = await locationService.hasLocationPermission();
    if (!hasPermission) {
      hasPermission = await locationService.requestLocationPermission();
    }

    if (!hasPermission) {
      if (mounted) {
        setState(() => _isLocating = false);
        AppSnackBar.showError(context, context.loc.locationPermissionRequired);
      }
      return;
    }

    final coordinate = await locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() => _isLocating = false);

    if (coordinate != null) {
      _updatePosition(coordinate.latitude, coordinate.longitude);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(coordinate.latitude, coordinate.longitude),
          16,
        ),
      );
    } else {
      AppSnackBar.showError(context, context.loc.unableToGetGpsLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.88;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_selectedLat, _selectedLng),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  onTap: (latLng) =>
                      _updatePosition(latLng.latitude, latLng.longitude),
                  markers: {
                    Marker(
                      markerId: const MarkerId('picked_site_pin'),
                      position: LatLng(_selectedLat, _selectedLng),
                      draggable: true,
                      onDragEnd: (pos) =>
                          _updatePosition(pos.latitude, pos.longitude),
                    ),
                  },
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                ),
                _buildMapActionControls(),
              ],
            ),
          ),
          _buildBottomConfirmationCard(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.loc.selectSiteLocation,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  context.loc.tapMapToPositionPin,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapActionControls() {
    return Positioned(
      top: 12.h,
      right: 12.w,
      child: Column(
        children: [
          FloatingActionButton.small(
            heroTag: 'map_picker_my_location',
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2563EB),
            onPressed: _isLocating ? null : _moveToCurrentLocation,
            child: _isLocating
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
          ),
          SizedBox(height: 8.h),
          FloatingActionButton.small(
            heroTag: 'map_picker_zoom_in',
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF333333),
            onPressed: () =>
                _mapController?.animateCamera(CameraUpdate.zoomIn()),
            child: const Icon(Icons.add),
          ),
          SizedBox(height: 6.h),
          FloatingActionButton.small(
            heroTag: 'map_picker_zoom_out',
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF333333),
            onPressed: () =>
                _mapController?.animateCamera(CameraUpdate.zoomOut()),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomConfirmationCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFC8102E),
                  size: 20,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    _resolvedAddress,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF222222),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              'Lat: ${_selectedLat.toStringAsFixed(5)}, Lng: ${_selectedLng.toStringAsFixed(5)}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF777777),
              ),
            ),
            SizedBox(height: 12.h),
            AppButton(
              text: context.loc.confirmLocation,
              borderRadius: 8.r,
              onPressed: () => Navigator.of(context).pop((
                lat: _selectedLat,
                lng: _selectedLng,
                address: _resolvedAddress,
              )),
            ),
          ],
        ),
      ),
    );
  }
}
