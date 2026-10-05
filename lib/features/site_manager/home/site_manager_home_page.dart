import 'package:construction_app/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SiteManagerHomePage extends StatefulWidget {
  const SiteManagerHomePage({super.key});

  @override
  State<SiteManagerHomePage> createState() => _SiteManagerHomePageState();
}

class _SiteManagerHomePageState extends State<SiteManagerHomePage> {
  bool notificationsEnabled = false;
  bool showAllOperations = false;

  int activeSites = 3;
  int scaffolds = 30;
  int inspectionsDue = 30;

  final List<Map<String, dynamic>> operations = [
    {
      'type': 'Erection',
      'typeColor': Color(0xFF00A651),
      'project': 'Prj-0842 . Goltsteins.Complex',
      'address': 'Goltsteinstrabe 12, 50968 Köln',
      'client': 'Mesut Rahaman',
      'planned': 14,
      'running': 5,
    },
    {
      'type': 'Dismantling',
      'typeColor': Color(0xFFFF9800),
      'project': 'Prj-0845 . Riverside Tower',
      'address': 'Rheinstrasse 28, 50667 Köln',
      'client': 'David Miller',
      'planned': 8,
      'running': 3,
    },
    {
      'type': 'Erection',
      'typeColor': Color(0xFF00A651),
      'project': 'Prj-0850 . Central Plaza',
      'address': 'Hohenzollernring 44, 50672 Köln',
      'client': 'Thomas Weber',
      'planned': 15,
      'running': 7,
    },
  ];

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(fontSize: 19.sp)),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _toggleNotifications() {
    setState(() {
      notificationsEnabled = !notificationsEnabled;
    });

    _showMessage(
      notificationsEnabled ? 'Notifications enabled' : 'Notifications disabled',
    );
  }

  void _openProject(Map<String, dynamic> project) {
    _showMessage('Opening ${project['project']}');
  }

  void _openRoute(Map<String, dynamic> project) {
    _showMessage('Opening route to ${project['address']}');
  }

  @override
  Widget build(BuildContext context) {
    final visibleOperations = showAllOperations
        ? operations
        : operations.take(1).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              sliver: SliverToBoxAdapter(child: _buildHeader()),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverToBoxAdapter(child: _buildMapCard()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverToBoxAdapter(child: _buildMainStats()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverToBoxAdapter(child: _buildSecondaryStats()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverToBoxAdapter(child: _buildOperationsHeader()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final operation = visibleOperations[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildOperationCard(operation),
                  );
                }, childCount: visibleOperations.length),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning',
                style: TextStyle(
                  fontSize: 19.sp,
                  color: Color(0xFF777777),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mesut Yilmaz',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF171717),
                ),
              ),
            ],
          ),
        ),

        // Network profile image
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const CircleAvatar(
            backgroundImage: NetworkImage(
              'https://randomuser.me/api/portraits/men/32.jpg',
            ),
          ),
        ),

        const SizedBox(width: 9),

        GestureDetector(
          onTap: _toggleNotifications,
          child: Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE4E4E4)),
            ),
            child: Icon(
              notificationsEnabled
                  ? Icons.notifications
                  : Icons.notifications_none_outlined,
              size: 21,
              color: notificationsEnabled
                  ? const Color(0xFF00652F)
                  : const Color(0xFF777777),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapCard() {
    return Container(
      height: 148,
      decoration: BoxDecoration(
        color: const Color(0xFFDDE6D8),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Map placeholder
          Positioned.fill(child: CustomPaint(painter: MapPlaceholderPainter())),

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
                '$activeSites Sites Active Today',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
            ),
          ),

          // Fake map pins
          const Positioned(
            left: 112,
            top: 70,
            child: _MapPin(color: Color(0xFF2196F3)),
          ),

          const Positioned(
            left: 174,
            top: 48,
            child: _MapPin(color: Color(0xFFFF9800)),
          ),

          const Positioned(
            right: 104,
            top: 84,
            child: _MapPin(color: Color(0xFFE53935)),
          ),

          Positioned(
            right: 9,
            bottom: 8,
            child: GestureDetector(
              onTap: () => _showMessage('Map view opened'),
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
                    Text(
                      'View Full Map',
                      style: TextStyle(
                        color: const Color(0xFFE22B3B),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildMainStats() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF004D26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Standing Scaffolds',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '$scaffolds',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 33.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Currently up across all sites',
                    maxLines: 2,
                    style: TextStyle(color: Colors.white70, fontSize: 17.sp),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  inspectionsDue += 1;
                });

                _showMessage('Inspection count updated');
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD9DC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE53948)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$inspectionsDue',
                      style: TextStyle(
                        color: const Color(0xFFE32638),
                        fontSize: 33.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Text(
                      'Inspection due',
                      style: TextStyle(
                        color: const Color(0xFFE32638),
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500,
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

  Widget _buildSecondaryStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Erection',
            color: const Color(0xFF00A651),
            planned: 14,
            running: 5,
            onTap: () => _showMessage('Erection operations selected'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            title: 'Dismantling',
            color: const Color(0xFFFF9800),
            planned: 14,
            running: 5,
            onTap: () => _showMessage('Dismantling operations selected'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required Color color,
    required int planned,
    required int running,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130.h,
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$planned',
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF171717),
                  ),
                ),
                Text(
                  '$running',
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF171717),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Planned',
                  style: TextStyle(
                    color: const Color(0xFF858585),
                    fontSize: 17.sp,
                  ),
                ),
                Text(
                  'Running',
                  style: TextStyle(
                    color: const Color(0xFF858585),
                    fontSize: 17.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationsHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Today's operations (3)",
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF171717),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              showAllOperations = !showAllOperations;
            });
          },
          child: Row(
            children: [
              Text(
                showAllOperations ? 'Show less' : 'View all',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF888888),
                ),
              ),
              const SizedBox(width: 3),
              Icon(
                showAllOperations
                    ? Icons.keyboard_arrow_up
                    : Icons.arrow_forward_ios,
                size: 13,
                color: const Color(0xFF888888),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOperationCard(Map<String, dynamic> operation) {
    final Color typeColor = operation['typeColor'];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Operation type
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              operation['type'],
              style: TextStyle(
                color: typeColor,
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 9),

          Text(
            operation['project'],
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF171717),
            ),
          ),

          const SizedBox(height: 7),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: Color(0xFF999999),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  operation['address'],
                  style: TextStyle(
                    fontSize: 17.sp,
                    color: const Color(0xFF8A8A8A),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            'Client: ${operation['client']}',
            style: TextStyle(fontSize: 17.sp, color: const Color(0xFF888888)),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openRoute(operation),
                  icon: const Icon(Icons.location_on_outlined, size: 18),
                  label: Text(
                    'Route',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF777777),
                    side: const BorderSide(color: Color(0xFFD9D9D9)),
                    minimumSize: Size(double.infinity, 42.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                flex: 2,
                child: AppButton(
                  onPressed: () => _openProject(operation),
                  height: 42.h,
                  text: 'Open Project',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final Color color;

  const _MapPin({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.location_on, size: 26, color: color);
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
