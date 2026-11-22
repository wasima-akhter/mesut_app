import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/context_extensions.dart';
import '../../../shared/mobile_dashboard/domain/entities/mobile_dashboard_entity.dart';

class SiteManagerHomeMapCard extends StatelessWidget {
  const SiteManagerHomeMapCard({
    super.key,
    required this.activeSitesCount,
    required this.pins,
    required this.onTap,
  });

  final int activeSitesCount;
  final List<MobileMapPinEntity> pins;
  final VoidCallback onTap;

  Color _getPinColor(String type) {
    switch (type.toUpperCase()) {
      case 'ERECTION':
        return const Color(0xFF2196F3);
      case 'DISMANTLING':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFFE53935);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: 148,
      decoration: BoxDecoration(
        color: const Color(0xFFDDE6D8),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: MapPlaceholderPainter()),
          ),
          Positioned(
            left: 10,
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .08),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(
                '$activeSitesCount ${context.loc.activeSites}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
            ),
          ),
          if (pins.isNotEmpty)
            ...pins.take(5).toList().asMap().entries.map((entry) {
              const leftPositions = [112.0, 174.0, 240.0, 75.0, 140.0];
              const topPositions = [70.0, 48.0, 84.0, 85.0, 30.0];
              final idx = entry.key;
              final pin = entry.value;
              return Positioned(
                left: leftPositions[idx % leftPositions.length],
                top: topPositions[idx % topPositions.length],
                child: Icon(
                  Icons.location_on,
                  size: 26,
                  color: _getPinColor(pin.activePhaseType),
                ),
              );
            })
          else ...[
            const Positioned(
              left: 112,
              top: 70,
              child: Icon(Icons.location_on, size: 26, color: Color(0xFF2196F3)),
            ),
            const Positioned(
              left: 174,
              top: 48,
              child: Icon(Icons.location_on, size: 26, color: Color(0xFFFF9800)),
            ),
            const Positioned(
              right: 104,
              top: 84,
              child: Icon(Icons.location_on, size: 26, color: Color(0xFFE53935)),
            ),
          ],
          Positioned(
            right: 9,
            bottom: 8,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        context.loc.navMap,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFFE22B3B),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 17,
                      color: Color(0xFFE22B3B),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: .9)
      ..strokeWidth = 13
      ..style = PaintingStyle.stroke;

    final smallRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: .8)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final greenPaint = Paint()
      ..color = const Color(0xFFBFDDAA)
      ..style = PaintingStyle.fill;

    // Green map areas
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .02,
        size.height * .68,
        size.width * .25,
        size.height * .28,
      ),
      greenPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(size.width * .75, 0, size.width * .25, size.height * .22),
      greenPaint,
    );

    // Main roads
    final path1 = Path()
      ..moveTo(-20, size.height * .2)
      ..lineTo(size.width * .45, size.height * .75)
      ..lineTo(size.width + 30, size.height * .48);

    canvas.drawPath(path1, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * .35, -20)
      ..lineTo(size.width * .50, size.height * .45)
      ..lineTo(size.width * .62, size.height + 20);

    canvas.drawPath(path2, roadPaint);

    final path3 = Path()
      ..moveTo(-20, size.height * .65)
      ..lineTo(size.width * .35, size.height * .55)
      ..lineTo(size.width + 20, size.height * .82);

    canvas.drawPath(path3, smallRoadPaint);

    final path4 = Path()
      ..moveTo(size.width * .80, -10)
      ..lineTo(size.width * .66, size.height * .40)
      ..lineTo(size.width * .93, size.height + 20);

    canvas.drawPath(path4, smallRoadPaint);

    // Simple building blocks
    final buildingPaint = Paint()
      ..color = const Color(0xFFD0D0CC)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final x = (i % 4) * size.width * .25 + 8;
      final y = (i ~/ 4) * size.height * .30 + 8;

      canvas.drawRect(
        Rect.fromLTWH(x, y, size.width * .13, size.height * .14),
        buildingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
