import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/route_constants.dart';
import '../../../core/enums/app_enum.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/localization_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../entry/nav/navigation_provider.dart';
import '../../map/domain/entities/map_coordinate_entity.dart';
import '../../map/domain/entities/map_location_entity.dart';
import '../../map/domain/entities/map_request_entity.dart';
import '../../map/utils/map_coordinate_resolver.dart';
import '../../shared/mobile_dashboard/domain/entities/mobile_dashboard_entity.dart';
import '../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../shared/notifications/presentation/providers/notifications_provider.dart';
import '../presentation/providers/site_manager_home_provider.dart';
import 'widgets/site_manager_home_header.dart';
import 'widgets/site_manager_home_map_card.dart';
import 'widgets/site_manager_home_operation_card.dart';
import 'widgets/site_manager_home_stats.dart';

class SiteManagerHomePage extends ConsumerWidget {
  const SiteManagerHomePage({super.key});

  void _openRoute(
    BuildContext context,
    UpcomingTaskEntity task,
    List<MobileMapPinEntity> pins,
  ) {
    final pin = pins.where((p) => p.id == task.project.id).firstOrNull;
    final coordinate = pin != null
        ? MapCoordinate(latitude: pin.latitude, longitude: pin.longitude)
        : MapCoordinateResolver.resolve(task.project.address);

    final destination = MapLocationEntity(
      id: task.project.id.isNotEmpty ? task.project.id : task.phaseId,
      title: task.project.name,
      address: task.project.address,
      coordinate: coordinate,
      type: task.type,
    );

    context.push(
      RouteConstants.map,
      extra: MapRequestEntity.routeNavigation(
        role: UserRole.siteManager,
        destination: destination,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLanguageProvider);
    final homeState = ref.watch(siteManagerHomeProvider);
    final dashboardAsync = ref.watch(mobileDashboardProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final currentUser = ref.watch(currentUserProvider);
    final profile = ref.watch(mobileProfileProvider).asData?.value;

    final userName = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : (currentUser?.fullName.isNotEmpty == true
              ? currentUser!.fullName
              : context.loc.siteManager);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(mobileDashboardProvider.notifier).refresh(),
              ref.read(notificationsProvider.notifier).refresh(),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                sliver: SliverToBoxAdapter(
                  child: SiteManagerHomeHeader(
                    userName: userName,
                    unreadCount: unreadCount,
                    avatarUrl: profile?.avatarUrl,
                  ),
                ),
              ),
              ...dashboardAsync.when(
                loading: () => [
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
                error: (_, _) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(context.loc.somethingWentWrong),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => ref
                                .read(mobileDashboardProvider.notifier)
                                .refresh(),
                            child: Text(context.loc.mapRetry),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                data: (dashboard) {
                  final tasks = homeState.showAllOperations
                      ? dashboard.upcomingTasks
                      : dashboard.upcomingTasks.take(3).toList();
                  return [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      sliver: SliverToBoxAdapter(
                        child: SiteManagerHomeMapCard(
                          activeSitesCount: dashboard.mapPins.length,
                          onTap: () => ref
                              .read(navigationProvider.notifier)
                              .changeTab(2),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      sliver: SliverToBoxAdapter(
                        child: SiteManagerHomeStats(
                          stats: dashboard.stats,
                          onTapProjects: () => ref
                              .read(navigationProvider.notifier)
                              .changeTab(1),
                          onTapInspections: () => context.push(
                            RouteConstants.siteManagerSiteInspection,
                          ),
                          onTapSchedule: () =>
                              context.push(RouteConstants.siteManagerSchedule),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.loc.upcomingTasks,
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ),
                            if (dashboard.upcomingTasks.length > 3)
                              TextButton(
                                onPressed: () => ref
                                    .read(siteManagerHomeProvider.notifier)
                                    .toggleShowAllOperations(),
                                child: Text(
                                  homeState.showAllOperations
                                      ? context.loc.showLess
                                      : context.loc.viewAll,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (tasks.isEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 20,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                            child: Text(
                              context.loc.noUpcomingTasks,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                        sliver: SliverList.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return SiteManagerHomeOperationCard(
                              task: task,
                              onOpenProject: () => context.push(
                                RouteConstants.siteManagerProjectDetail,
                                extra: task.project.id,
                              ),
                              onOpenRoute: () =>
                                  _openRoute(context, task, dashboard.mapPins),
                            );
                          },
                        ),
                      ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
