import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/context_extensions.dart';

/// Floating map control buttons: Recenter, Zoom In/Out, Map Type, Traffic.
class MapControls extends StatelessWidget {
  final VoidCallback onRecenter;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onToggleMapType;
  final VoidCallback onToggleTraffic;
  final bool isTrafficEnabled;
  final bool isHybrid;

  const MapControls({
    super.key,
    required this.onRecenter,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onToggleMapType,
    required this.onToggleTraffic,
    this.isTrafficEnabled = false,
    this.isHybrid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Map Type Toggle
        _controlButton(
          icon: isHybrid ? Icons.map : Icons.satellite_alt_outlined,
          tooltip: context.loc.mapStyle,
          onTap: onToggleMapType,
        ),
        SizedBox(height: 8.h),

        // Traffic Toggle
        _controlButton(
          icon: Icons.traffic,
          tooltip: context.loc.mapTraffic,
          active: isTrafficEnabled,
          onTap: onToggleTraffic,
        ),
        SizedBox(height: 8.h),

        // Zoom In
        _controlButton(
          icon: Icons.add,
          tooltip: context.loc.mapZoomIn,
          onTap: onZoomIn,
        ),
        SizedBox(height: 4.h),

        // Zoom Out
        _controlButton(
          icon: Icons.remove,
          tooltip: context.loc.mapZoomOut,
          onTap: onZoomOut,
        ),
        SizedBox(height: 8.h),

        // Recenter / GPS
        _controlButton(
          icon: Icons.my_location,
          tooltip: context.loc.mapMyLocation,
          onTap: onRecenter,
          highlightColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool active = false,
    Color? highlightColor,
  }) {
    return Material(
      color: active ? AppColors.primary : Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(
          color: active ? AppColors.primary : AppColors.border,
          width: 0.8,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 42.w,
            height: 42.w,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20.sp,
              color: active
                  ? Colors.white
                  : (highlightColor ?? AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
