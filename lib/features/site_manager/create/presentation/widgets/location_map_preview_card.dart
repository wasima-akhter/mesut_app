import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/localization/context_extensions.dart';

class LocationMapPreviewCard extends StatelessWidget {
  final double lat;
  final double lng;
  final VoidCallback onTapChange;
  final void Function(GoogleMapController controller)? onMapCreated;

  const LocationMapPreviewCard({
    super.key,
    required this.lat,
    required this.lng,
    required this.onTapChange,
    this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLat = lat != 0 ? lat : 50.9375;
    final effectiveLng = lng != 0 ? lng : 6.9603;

    return Container(
      height: 150.h,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(effectiveLat, effectiveLng),
              zoom: 14,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('preview_marker'),
                position: LatLng(effectiveLat, effectiveLng),
              ),
            },
            onMapCreated: onMapCreated,
            onTap: (_) => onTapChange(),
            gestureRecognizers: {
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            left: 8.w,
            bottom: 8.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(4.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                'Lat: ${effectiveLat.toStringAsFixed(4)}, Lng: ${effectiveLng.toStringAsFixed(4)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
            ),
          ),
          Positioned(
            right: 8.w,
            top: 8.h,
            child: GestureDetector(
              onTap: onTapChange,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fullscreen, color: Colors.white, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      context.loc.tapToChange,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
