import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/services/launcher_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/app_outlined_button.dart';
import '../../domain/entities/map_location_entity.dart';

/// Card displayed at the bottom of the map when a location marker is selected.
class MapLocationCard extends StatelessWidget {
  final MapLocationEntity location;
  final VoidCallback onRoute;
  final VoidCallback? onOpenDetails;
  final VoidCallback onClose;

  const MapLocationCard({
    super.key,
    required this.location,
    required this.onRoute,
    this.onOpenDetails,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Type badge, Priority and Close
          Row(
            children: [
              if (location.type != null) ...[
                _badge(
                  text: _localizeType(context, location.type),
                  color: _getTypeColor(location.type),
                ),
                SizedBox(width: 8.w),
              ],
              if (location.priority != null) ...[
                _badge(
                  text: location.priority!,
                  color: _getPriorityColor(location.priority),
                  outlined: true,
                ),
              ],
              const Spacer(),
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
                    size: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Title & Company
          Text(
            location.title,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (location.company != null) ...[
            SizedBox(height: 2.h),
            Text(
              location.company!,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: 6.h),

          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  location.address,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Action Buttons: Route, Details, Call, External Nav
          Row(
            children: [
              Expanded(
                child: AppButton(
                  onPressed: onRoute,
                  leadingIcon: Icons.route_outlined,
                  text: context.loc.mapShowRoute,
                  height: 40.h,
                ),
              ),
              if (onOpenDetails != null) ...[
                SizedBox(width: 8.w),
                Expanded(
                  child: AppOutlinedButton(
                    onPressed: onOpenDetails,
                    leadingIcon: Icons.open_in_new,
                    text: context.loc.mapOpenProject,
                    height: 40.h,
                    borderColor: AppColors.border,
                  ),
                ),
              ],
              SizedBox(width: 8.w),
              // External navigation icon
              _iconAction(
                icon: Icons.navigation_outlined,
                tooltip: context.loc.mapTurnByTurn,
                onTap: () {
                  AppLauncherService.openMapNavigation(
                    latitude: location.latitude,
                    longitude: location.longitude,
                    address: location.address,
                    label: location.title,
                  );
                },
              ),
              if (location.phone != null) ...[
                SizedBox(width: 6.w),
                _iconAction(
                  icon: Icons.phone_outlined,
                  tooltip: context.loc.mapCall,
                  onTap: () =>
                      AppLauncherService.makePhoneCall(location.phone!),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.neutral100,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 40.w,
            height: 40.h,
            alignment: Alignment.center,
            child: Icon(icon, size: 18.sp, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _badge({
    required String text,
    required Color color,
    bool outlined = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color, width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'erection':
        return AppColors.info;
      case 'dismantling':
        return AppColors.warning;
      case 'standing':
        return AppColors.success;
      case 'inspection':
        return const Color(0xFF673AB7);
      default:
        return AppColors.primary;
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _localizeType(BuildContext context, String? type) {
    if (type == null) return '';
    switch (type.toLowerCase()) {
      case 'erection':
        return context.loc.mapFilterErection;
      case 'dismantling':
        return context.loc.mapFilterDismantling;
      case 'standing':
        return context.loc.mapFilterStanding;
      case 'inspection':
        return context.loc.mapFilterInspection;
      default:
        return type;
    }
  }
}
