import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/constants/route_constants.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/enums/app_enum.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../../map/domain/entities/map_coordinate_entity.dart';
import '../../../../map/domain/entities/map_location_entity.dart';
import '../../../../map/domain/entities/map_request_entity.dart';
import '../../../../map/utils/map_coordinate_resolver.dart';
import '../../../shared/helper/employee_models.dart';
import '../../domain/entities/employee_project_details_entity.dart';

class AssignmentDetailMapCard extends StatelessWidget {
  final EmployeeProjectDetailsEntity? project;
  final EmployeeAssignmentModel? fallback;

  const AssignmentDetailMapCard({
    super.key,
    this.project,
    this.fallback,
  });

  void _navigateToMap(BuildContext context) {
    final title = project?.name ?? fallback?.project ?? 'Project';
    final address = project?.fullAddress ?? fallback?.address ?? '';
    final MapCoordinate coord;
    if (project?.hasLocation == true) {
      coord = MapCoordinate(
        latitude: project!.latitude!,
        longitude: project!.longitude!,
      );
    } else {
      coord = MapCoordinateResolver.resolve(address);
    }

    final destination = MapLocationEntity(
      id: 'assignment_${project?.id ?? title.hashCode}',
      title: title,
      address: address,
      coordinate: coord,
      type: project?.phase?.type ?? 'ERECTION',
    );

    context.push(
      RouteConstants.map,
      extra: MapRequestEntity.routeNavigation(
        role: UserRole.employee,
        destination: destination,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final address = project?.fullAddress.isNotEmpty == true
        ? project!.fullAddress
        : (fallback?.address ?? 'Site Address');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 145.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9.r),
              color: const Color(0xFFDDE6D8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _MapCardPainter())),
                const Center(
                  child: Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 34,
                  ),
                ),
                Positioned(
                  left: 12.w,
                  bottom: 10.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(7.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Text(
                            address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () => _navigateToMap(context),
              height: 48.h,
              text: context.loc.navigation,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.2,
        size.width,
        size.height * 0.6,
      );
    canvas.drawPath(path1, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.3, 0)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.5,
        size.width * 0.8,
        size.height,
      );
    canvas.drawPath(path2, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
