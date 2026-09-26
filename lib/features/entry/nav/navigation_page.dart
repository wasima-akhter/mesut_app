import 'package:construction_app/features/employee/home/employee_home_page.dart';
import 'package:construction_app/features/employee/plan/employee_plan_page.dart';
import 'package:construction_app/features/employee/timer/employee_time_page.dart';
import 'package:construction_app/features/site_manager/home/site_manager_home_page.dart';
import 'package:construction_app/features/site_manager/map/site_manager_map_page.dart';
import 'package:construction_app/features/site_manager/more/site_manager_more_page.dart';
import 'package:construction_app/features/site_manager/projects/site_manager_projects_page.dart';
import 'package:construction_app/features/site_manager/time_tracking/site_manager_time_tracking_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/enums/app_enum.dart';
import '../../../core/providers/common_provider.dart';
import '../../employee/profile/profile/employee_profile_page.dart';
import 'navigation_provider.dart';

class NavigationPage extends ConsumerStatefulWidget {
  const NavigationPage({super.key, this.index = 0});

  final int index;

  @override
  ConsumerState<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends ConsumerState<NavigationPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationProvider.notifier).changeTab(widget.index);
    });
  }

  // ------------------------------------------------------------
  // PAGES
  // ------------------------------------------------------------

  List<Widget> _getPages(UserRole role) {
    switch (role) {
      case UserRole.siteManager:
        return const [
          SiteManagerHomePage(),
          SiteManagerProjectsPage(),
          SiteManagerMapPage(),
          SiteManagerTimeTrackingPage(),
          SiteManagerMorePage(),
        ];

      case UserRole.employee:
        return const [
          EmployeeHomePage(),
          EmployeeTimePage(),
          EmployeePlanPage(),
          EmployeeProfilePage(),
        ];
    }
  }

  // ------------------------------------------------------------
  // ICONS
  // ------------------------------------------------------------

  List<IconData> _getIcons(UserRole role) {
    switch (role) {
      case UserRole.siteManager:
        return [
          Iconsax.home_2,
          Iconsax.folder_2,
          Iconsax.map_1,
          Iconsax.timer_1,
          Iconsax.more,
        ];

      case UserRole.employee:
        return [
          Iconsax.home_2,
          Iconsax.clock,
          Iconsax.task_square,
          Iconsax.profile_circle,
        ];
    }
  }

  // ------------------------------------------------------------
  // LABELS
  // ------------------------------------------------------------

  List<String> _getLabels(UserRole role) {
    switch (role) {
      case UserRole.siteManager:
        return ['Home', 'Projects', 'Map', 'Timer', 'More'];

      case UserRole.employee:
        return ['Home', 'Time', 'My Plan', 'Profile'];
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(userRoleProvider);

    if (role == null) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }

    final selectedIndex = ref.watch(navigationProvider);

    final pages = _getPages(role);
    final icons = _getIcons(role);
    final labels = _getLabels(role);

    final safeIndex = selectedIndex >= pages.length ? 0 : selectedIndex;

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: pages),
      bottomNavigationBar: _buildBottomNavBar(
        icons: icons,
        labels: labels,
        selectedIndex: safeIndex,
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM NAVIGATION
  // ------------------------------------------------------------

  Widget _buildBottomNavBar({
    required List<IconData> icons,
    required List<String> labels,
    required int selectedIndex,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.only(left: 15, right: 10, bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              icons.length,
              (index) => _buildNavItem(
                index: index,
                icon: icons[index],
                label: labels[index],
                selectedIndex: selectedIndex,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // NAV ITEM
  // ------------------------------------------------------------

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required int selectedIndex,
  }) {
    final isSelected = selectedIndex == index;

    final color = isSelected ? AppColors.primary : AppColors.neutral400;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ref.read(navigationProvider.notifier).changeTab(index);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
