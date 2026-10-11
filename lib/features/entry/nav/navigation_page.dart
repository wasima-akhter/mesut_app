import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/enums/app_enum.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/providers/common_provider.dart';
import '../../employee/home/employee_home_page.dart';
import '../../employee/plan/employee_plan_page.dart';
import '../../employee/profile/profile/employee_profile_page.dart';
import '../../employee/timer/employee_time_tracking_page.dart';
import '../../site_manager/home/site_manager_home_page.dart';
import '../../site_manager/map/site_manager_map_page.dart';
import '../../site_manager/more/site_manager_more_page.dart';
import '../../site_manager/projects/site_manager_projects_page.dart';
import '../../site_manager/time_tracking/site_manager_time_tracking_page.dart';
import 'bottom_nav_tabs.dart';
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
      if (widget.index != 0) {
        ref.read(navigationProvider.notifier).changeTab(widget.index);
      }
    });
  }

  // ------------------------------------------------------------
  // PAGES BY ROLE
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
          EmployeeTimeTrackingPage(),
          EmployeePlanPage(),
          EmployeeProfilePage(),
        ];
    }
  }

  List<AppBottomTab> _getTabs(UserRole role) {
    switch (role) {
      case UserRole.siteManager:
        return SiteManagerBottomTabs.tabs;
      case UserRole.employee:
        return EmployeeBottomTabs.tabs;
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider);
    final loc = ref.watch(appStringsProvider);
    final role = ref.watch(userRoleProvider);

    if (role == null) {
      return Scaffold(body: Center(child: Text(loc.error)));
    }

    final selectedIndex = ref.watch(navigationProvider);
    final pages = _getPages(role);
    final tabs = _getTabs(role);

    final safeIndex = selectedIndex >= pages.length ? 0 : selectedIndex;

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: pages),
      bottomNavigationBar: _buildBottomNavBar(
        tabs: tabs,
        selectedIndex: safeIndex,
        loc: loc,
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM NAVIGATION
  // ------------------------------------------------------------

  Widget _buildBottomNavBar({
    required List<AppBottomTab> tabs,
    required int selectedIndex,
    required AppStrings loc,
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
              tabs.length,
              (index) => _buildNavItem(
                index: index,
                tab: tabs[index],
                label: tabs[index].getLabel(loc),
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
    required AppBottomTab tab,
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
            Icon(
              isSelected ? (tab.activeIcon ?? tab.icon) : tab.icon,
              color: color,
              size: 24,
            ),
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
