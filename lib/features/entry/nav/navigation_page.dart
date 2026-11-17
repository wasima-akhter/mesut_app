import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/enums/app_enum.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/providers/common_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/notification_socket_service.dart';
import '../../../core/storage/storage_provider.dart';
import '../../employee/home/presentation/screens/employee_home_page.dart';
import '../../employee/plan/presentation/screens/employee_plan_page.dart';
import '../../employee/time_tracking/presentation/providers/offline_sync_provider.dart';
import '../../employee/profile/presentation/screens/employee_profile_page.dart';
import '../../employee/time_tracking/presentation/screens/employee_time_tracking_page.dart';
import '../../shared/config/presentation/providers/mobile_config_provider.dart';
import '../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../shared/notifications/presentation/providers/notifications_provider.dart';
import '../../site_manager/home/site_manager_home_page.dart';
import '../../site_manager/map/site_manager_map_page.dart';
import '../../site_manager/more/site_manager_more_page.dart';
import '../../site_manager/offline_sync/providers/site_manager_sync_provider.dart';
import '../../site_manager/offline_sync/widgets/site_manager_sync_banner.dart';
import '../../site_manager/projects/presentation/screens/site_manager_projects_page.dart';
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
  final Set<int> _visitedTabs = {0};
  UserRole? _lastRole;

  @override
  void initState() {
    super.initState();

    if (widget.index != 0) {
      _visitedTabs.add(widget.index);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.index != 0) {
        ref.read(navigationProvider.notifier).changeTab(widget.index);
      }
      unawaited(_bootstrapAuthenticatedSession());
    });
  }

  Future<void> _bootstrapAuthenticatedSession() async {
    if (!mounted) return;
    final storage = ref.read(storageServiceProvider);
    final token = await storage.getAccessToken();
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      ref.read(notificationSocketServiceProvider).connect(token);
    }
    unawaited(ref.read(mobileConfigProvider.notifier).refresh());
    unawaited(ref.read(mobileProfileProvider.notifier).refresh());
    unawaited(ref.read(notificationsProvider.notifier).refresh());
    unawaited(ref.read(offlineSyncProvider.notifier).syncPendingLogs());
    unawaited(ref.read(siteManagerSyncProvider.notifier).syncAll());
    ref.read(pushNotificationServiceProvider).consumePendingInitialNavigation();
  }

  Widget _buildTabPage(UserRole role, int index) {
    switch (role) {
      case UserRole.siteManager:
        switch (index) {
          case 0:
            return const SiteManagerHomePage();
          case 1:
            return const SiteManagerProjectsPage();
          case 2:
            return const SiteManagerMapPage();
          case 3:
            return const SiteManagerTimeTrackingPage();
          case 4:
            return const SiteManagerMorePage();
          default:
            return const SizedBox.shrink();
        }
      case UserRole.employee:
        switch (index) {
          case 0:
            return const EmployeeHomePage();
          case 1:
            return const EmployeeTimeTrackingPage();
          case 2:
            return const EmployeePlanPage();
          case 3:
            return const EmployeeProfilePage();
          default:
            return const SizedBox.shrink();
        }
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

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider.select((lang) => lang.code));
    final loc = ref.watch(appStringsProvider);
    final role = ref.watch(userRoleProvider);

    if (role == null) {
      return Scaffold(body: Center(child: Text(loc.error)));
    }

    if (_lastRole != role) {
      _lastRole = role;
      _visitedTabs
        ..clear()
        ..add(0);
    }

    final selectedIndex = ref.watch(navigationProvider);
    final tabs = _getTabs(role);
    final safeIndex = selectedIndex >= tabs.length ? 0 : selectedIndex;
    _visitedTabs.add(safeIndex);

    // Lazy-mount tabs only after first visit to reduce startup memory, GPU, and map/GPS battery drain.
    final pages = List<Widget>.generate(
      tabs.length,
      (index) => _visitedTabs.contains(index)
          ? _buildTabPage(role, index)
          : const SizedBox.shrink(),
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (role == UserRole.siteManager) const SiteManagerSyncBanner(),
            Expanded(
              child: IndexedStack(index: safeIndex, children: pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(
        tabs: tabs,
        selectedIndex: safeIndex,
        loc: loc,
      ),
    );
  }

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
