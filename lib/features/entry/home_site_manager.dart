// ============================================================
// HOME PAGE
// ============================================================

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HomeSiteManager extends StatefulWidget {
  const HomeSiteManager({super.key});

  @override
  State<HomeSiteManager> createState() => _HomeSiteManagerState();
}

class _HomeSiteManagerState extends State<HomeSiteManager> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ------------------------------------------------
            // FIXED-AT-TOP CONTENT
            // ------------------------------------------------
            const SliverToBoxAdapter(child: HeaderSection()),

            const SliverToBoxAdapter(child: MapSection()),

            const SliverToBoxAdapter(child: DashboardStats()),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ------------------------------------------------
            // SCROLLABLE CONTENT
            // ------------------------------------------------
            const SliverToBoxAdapter(child: OperationsHeader()),

            const OperationsSliverList(),

            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),

      // ------------------------------------------------------
      // FIXED BOTTOM NAVIGATION
      // ------------------------------------------------------
      bottomNavigationBar: BottomNavigation(
        selectedIndex: selectedTab,
        onChanged: (index) {
          setState(() {
            selectedTab = index;
          });
        },
      ),
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 17, 24, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Mesut Yilmaz',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,

                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          // Profile image
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage('https://i.pravatar.cc/150?img=12'),
              ),
            ),
          ),

          const SizedBox(width: 9),

          // Notification
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE3E3E3)),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 19,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MAP
// ============================================================

class MapSection extends StatelessWidget {
  const MapSection({super.key});

  // Public OpenStreetMap static map.
  //
  // This is intentionally an image rather than a map package,
  // as requested.
  static const String mapUrl =
      'https://staticmap.openstreetmap.de/staticmap.php'
      '?center=50.9385,6.9586'
      '&zoom=15'
      '&size=800x350'
      '&maptype=mapnik'
      '&markers=50.9385,6.9586,red-pushpin';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(
          height: 153,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                mapUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    color: const Color(0xFFDDE1DE),
                    alignment: Alignment.center,
                    child: const Text(
                      'Map unavailable',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Container(
                    color: const Color(0xFFE5E7E5),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.successDark,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // White top-left label
              Positioned(
                left: 7,
                top: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .94),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '3',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.successDark,
                        ),
                      ),
                      SizedBox(width: 3),
                      Text(
                        'Sites Active Today',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // View full map
              Positioned(
                right: 9,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 11,
                    right: 5,
                    top: 7,
                    bottom: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAFFD9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'View Full Map',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 7),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DASHBOARD STATS
// ============================================================

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 13, 34, 0),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(flex: 2, child: StandingScaffoldsCard()),
              SizedBox(width: 7),
              Expanded(child: InspectionCard()),
            ],
          ),
          const SizedBox(height: 13),
          const Row(
            children: [
              Expanded(
                child: OperationStatCard(
                  title: 'Erection',
                  planned: '12',
                  running: '5',
                  color: Color(0xFF0CBF58),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: OperationStatCard(
                  title: 'Dismantling',
                  planned: '12',
                  running: '5',
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StandingScaffoldsCard extends StatelessWidget {
  const StandingScaffoldsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.fromLTRB(8, 9, 10, 7),
      decoration: BoxDecoration(
        color: AppColors.successDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Standing Scaffolds',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          const Text(
            '30',
            style: TextStyle(
              fontSize: 21,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Currently up across all sites',
            style: TextStyle(
              fontSize: 9.5,
              color: Colors.white.withValues(alpha: .7),
            ),
          ),
        ],
      ),
    );
  }
}

class InspectionCard extends StatelessWidget {
  const InspectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.fromLTRB(10, 11, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error, width: .7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '30',
            style: TextStyle(
              fontSize: 21,
              color: AppColors.error,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Inspection due',
            style: TextStyle(
              fontSize: 9.5,
              color: AppColors.error,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class OperationStatCard extends StatelessWidget {
  final String title;
  final String planned;
  final String running;
  final Color color;

  const OperationStatCard({
    super.key,
    required this.title,
    required this.planned,
    required this.running,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 89,
      padding: const EdgeInsets.fromLTRB(10, 11, 9, 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE1E1E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: StatNumber(number: planned, label: 'Planned'),
              ),
              Expanded(
                child: StatNumber(number: running, label: 'Running'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatNumber extends StatelessWidget {
  final String number;
  final String label;

  const StatNumber({super.key, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 9.5, color: AppColors.neutral400),
        ),
      ],
    );
  }
}

// ============================================================
// OPERATIONS HEADER
// ============================================================

class OperationsHeader extends StatelessWidget {
  const OperationsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 0, 34, 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Text(
              "Today's operations (3)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -.25,
                color: AppColors.black,
              ),
            ),
          ),
          Row(
            children: const [
              Text(
                'View all',
                style: TextStyle(fontSize: 10, color: AppColors.neutral400),
              ),
              SizedBox(width: 3),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 9,
                color: AppColors.neutral400,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// OPERATIONS LIST
// ============================================================

class OperationsSliverList extends StatelessWidget {
  const OperationsSliverList({super.key});

  static const operations = [
    OperationData(
      type: 'Erection',
      project: 'Prj-0842 . Goltsteins.Complex',
      address: 'Goltsteinstraße 12, 50678 Köln',
      client: 'Mesut Rahaman',
      workers: '4 Worker assigned',
    ),
    OperationData(
      type: 'Dismantling',
      project: 'Prj-0839 . Rhein Office',
      address: 'Rheinweg 24, 50667 Köln',
      client: 'Klaus Meyer',
      workers: '3 Worker assigned',
    ),
    OperationData(
      type: 'Erection',
      project: 'Prj-0836 . City Center',
      address: 'Hohe Straße 18, 50667 Köln',
      client: 'Martin Weber',
      workers: '5 Worker assigned',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // IMPORTANT:
    // This is SliverList, NOT ListView/ListView.builder.
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 34),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final operation = operations[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == operations.length - 1 ? 0 : 9,
            ),
            child: OperationCard(operation: operation),
          );
        }, childCount: operations.length),
      ),
    );
  }
}

class OperationData {
  final String type;
  final String project;
  final String address;
  final String client;
  final String workers;

  const OperationData({
    required this.type,
    required this.project,
    required this.address,
    required this.client,
    required this.workers,
  });
}

// ============================================================
// OPERATION CARD
// ============================================================

class OperationCard extends StatelessWidget {
  final OperationData operation;

  const OperationCard({super.key, required this.operation});

  @override
  Widget build(BuildContext context) {
    final isErection = operation.type == 'Erection';

    return Container(
      padding: const EdgeInsets.fromLTRB(9, 9, 9, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top line
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isErection
                      ? const Color(0xFFE6FBEA)
                      : const Color(0xFFFFF1DA),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  operation.type,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: isErection
                        ? const Color(0xFF08B84D)
                        : const Color(0xFFE99400),
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.people_outline_rounded,
                size: 13,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                operation.workers,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          // Project name
          Text(
            operation.project,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              letterSpacing: -.15,
            ),
          ),

          const SizedBox(height: 5),

          // Address
          Text(
            operation.address,
            style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
          ),

          const SizedBox(height: 4),

          // Client
          Row(
            children: [
              const Text(
                'Client: ',
                style: TextStyle(fontSize: 10, color: AppColors.neutral400),
              ),
              Text(
                operation.client,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          // Buttons
          Row(
            children: [
              Expanded(
                flex: 4,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: Color(0xFFD4D4D4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: const Icon(
                    Icons.directions_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  label: const Text(
                    'Route',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 6,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Open Project',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BOTTOM NAVIGATION
// ============================================================

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E8E8), width: .7)),
      ),
      child: Row(
        children: [
          BottomNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          BottomNavItem(
            icon: Icons.folder_outlined,
            label: 'Projects',
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
          BottomNavItem(
            icon: Icons.map_outlined,
            label: 'Map',
            selected: selectedIndex == 2,
            onTap: () => onChanged(2),
          ),
          BottomNavItem(
            icon: Icons.access_time_rounded,
            label: 'Time',
            selected: selectedIndex == 3,
            onTap: () => onChanged(3),
          ),
          BottomNavItem(
            icon: Icons.more_horiz_rounded,
            label: 'More',
            selected: selectedIndex == 4,
            onTap: () => onChanged(4),
          ),
        ],
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFFF163A) : const Color(0xFF777777);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
