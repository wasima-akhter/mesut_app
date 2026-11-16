import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/constants/route_constants.dart';
import '../../../../../core/enums/app_enum.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/services/address_resolver_service.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../../map/domain/entities/map_coordinate_entity.dart';
import '../../../../map/domain/entities/map_location_entity.dart';
import '../../../../map/domain/entities/map_request_entity.dart';
import '../../domain/entities/project_details_entity.dart';

class ProjectDetailsMapCard extends StatelessWidget {
  final ProjectCoordinates coordinates;
  final String title;

  const ProjectDetailsMapCard({
    super.key,
    required this.coordinates,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AddressResolverService.changeNotifier,
      builder: (context, _, _) {
        final resolvedAddress = AddressResolverService.resolveSync(
          coordinates.lat,
          coordinates.lng,
        );

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9.r),
            border: Border.all(color: const Color(0xFFE9E9E9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 145.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6EBE6),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(9.r),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _MapPlaceholderPainter()),
                    ),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .12),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: const Color(0xFFC8102E),
                          size: 28.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18.sp,
                          color: const Color(0xFF777777),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            resolvedAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFF555555),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    AppButton.dark(
                      text: context.loc.navigation,
                      leadingIcon: Icons.navigation_outlined,
                      onPressed: () {
                        final destination = MapLocationEntity(
                          id: 'proj_${resolvedAddress.hashCode}',
                          title: title.isNotEmpty ? title : context.loc.project,
                          address: resolvedAddress,
                          coordinate: MapCoordinate(
                            latitude: coordinates.lat != 0
                                ? coordinates.lat
                                : 50.9082,
                            longitude: coordinates.lng != 0
                                ? coordinates.lng
                                : 6.9723,
                          ),
                          type: 'Erection',
                        );

                        context.push(
                          RouteConstants.map,
                          extra: MapRequestEntity.routeNavigation(
                            role: UserRole.siteManager,
                            destination: destination,
                          ),
                        );
                      },
                      borderRadius: 7.r,
                      verticalPadding: 10.h,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final thinRoadPaint = Paint()
      ..color = const Color(0xFFD1D8D0)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final greenPaint = Paint()
      ..color = const Color(0xFFD8E5D4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .03,
        size.height * .08,
        size.width * .25,
        size.height * .25,
      ),
      greenPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .70,
        size.height * .55,
        size.width * .25,
        size.height * .35,
      ),
      greenPaint,
    );

    final road1 = Path()
      ..moveTo(0, size.height * .70)
      ..quadraticBezierTo(
        size.width * .40,
        size.height * .20,
        size.width,
        size.height * .40,
      );

    final road2 = Path()
      ..moveTo(size.width * .55, 0)
      ..quadraticBezierTo(
        size.width * .35,
        size.height * .45,
        size.width * .20,
        size.height,
      );

    canvas.drawPath(road1, roadPaint);
    canvas.drawPath(road2, roadPaint);
    canvas.drawPath(road1, thinRoadPaint);
    canvas.drawPath(road2, thinRoadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
