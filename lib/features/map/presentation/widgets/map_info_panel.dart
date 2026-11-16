import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/services/launcher_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/app_outlined_button.dart';
import '../../domain/entities/map_location_entity.dart';
import '../../domain/entities/map_route_entity.dart';

/// Bottom panel displaying route metrics (distance, duration, endpoints)
/// and external turn-by-turn navigation launcher.
class MapInfoPanel extends StatelessWidget {
  final MapRouteEntity route;
  final MapLocationEntity? destination;
  final VoidCallback? onClose;

  const MapInfoPanel({
    super.key,
    required this.route,
    this.destination,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with navigation badge and close button
            Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.navigation_outlined,
                        size: 13.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        context.loc.navigation,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (onClose != null)
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),

            // Route metrics: Duration & Distance
            Row(
              children: [
                Icon(
                  Icons.directions_car,
                  size: 26.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  route.formattedDuration,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  '•  ${route.formattedDistance}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // Destination address
            if (destination != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 18.sp,
                    color: AppColors.success,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destination!.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          destination!.address,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      final destLat = destination?.latitude ?? route.destination.latitude;
                      final destLon = destination?.longitude ?? route.destination.longitude;
                      final originLat = route.start.isValid ? route.start.latitude : null;
                      final originLon = route.start.isValid ? route.start.longitude : null;
                      AppLauncherService.openMapNavigation(
                        latitude: destLat,
                        longitude: destLon,
                        originLatitude: originLat,
                        originLongitude: originLon,
                      );
                    },
                    text: context.loc.mapStartNavigation,
                    leadingIcon: Icons.navigation_outlined,
                    height: 44.h,
                  ),
                ),
                if (destination?.phone != null) ...[
                  SizedBox(width: 10.w),
                  AppOutlinedButton(
                    onPressed: () {
                      AppLauncherService.makePhoneCall(destination!.phone!);
                    },
                    leadingIcon: Icons.phone_outlined,
                    text: context.loc.mapCall,
                    height: 44.h,
                    borderColor: AppColors.border,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
