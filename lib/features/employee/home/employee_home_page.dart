import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/enums/app_enum.dart';
import '../../../core/extensions/date_time_extensions.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/localization_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../map/domain/entities/map_coordinate_entity.dart';
import '../../map/domain/entities/map_location_entity.dart';
import '../../map/domain/entities/map_request_entity.dart';
import '../../map/utils/map_coordinate_resolver.dart';
import '../../shared/mobile_dashboard/domain/entities/mobile_dashboard_entity.dart';
import '../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../shared/notifications/presentation/providers/notifications_provider.dart';
import '../helper/employee_enums.dart';
import '../helper/employee_models.dart';
import '../presentation/providers/employee_assignment_details_provider.dart';
import '../presentation/providers/employee_timer_provider.dart';
import 'widgets/employee_home_header.dart';
import 'widgets/employee_home_stats_row.dart';
import 'widgets/employee_upcoming_task_card.dart';

class EmployeeHomePage extends ConsumerWidget {
  const EmployeeHomePage({super.key});

  EmployeeAssignmentModel _toAssignmentModel(UpcomingTaskEntity task) {
    final activity = task.type.trim().toUpperCase() == 'DISMANTLING'
        ? EmployeeActivityType.dismantling
        : EmployeeActivityType.erection;
    final start = task.startDate?.toLocal();
    final end = task.endDate?.toLocal();
    return EmployeeAssignmentModel(
      project: task.project.name,
      address: task.project.address,
      activity: activity,
      schedule: start != null
          ? '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}'
          : '--',
      startTimeOfDay: start != null
          ? TimeOfDay(hour: start.hour, minute: start.minute)
          : const TimeOfDay(hour: 7, minute: 30),
      endTimeOfDay: end != null
          ? TimeOfDay(hour: end.hour, minute: end.minute)
          : const TimeOfDay(hour: 16, minute: 15),
      scaffoldArea: '--',
      siteManager: '--',
    );
  }

  void _openTask(BuildContext context, WidgetRef ref, UpcomingTaskEntity task) {
    ref
        .read(assignmentDetailsProvider.notifier)
        .setAssignment(_toAssignmentModel(task));
    context.push(RouteConstants.employeeAssignmentDetails);
  }

  void _startTimerForTask(
    BuildContext context,
    WidgetRef ref,
    UpcomingTaskEntity task,
  ) {
    final assignment = _toAssignmentModel(task);
    ref.read(assignmentDetailsProvider.notifier).setAssignment(assignment);
    ref
        .read(employeeTimerProvider.notifier)
        .startTimer(
          project: EmployeeProjectModel(
            id: task.project.id.isNotEmpty ? task.project.id : task.phaseId,
            name: task.project.name,
            address: task.project.address,
            activity: assignment.activity,
            startTime: assignment.schedule,
            endTime: '16:15',
            startTimeOfDay:
                assignment.startTimeOfDay ??
                const TimeOfDay(hour: 7, minute: 30),
            endTimeOfDay:
                assignment.endTimeOfDay ??
                const TimeOfDay(hour: 16, minute: 15),
            siteManager: assignment.siteManager,
          ),
          activity: assignment.activity,
        );
    context.push(RouteConstants.employeeActiveTimerPage);
  }

  void _openNavigation(
    BuildContext context,
    UpcomingTaskEntity task,
    List<MobileMapPinEntity> pins,
  ) {
    final matchedPin = pins.where((p) => p.id == task.project.id).firstOrNull;
    final coordinate = matchedPin != null
        ? MapCoordinate(
            latitude: matchedPin.latitude,
            longitude: matchedPin.longitude,
          )
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
        role: UserRole.employee,
        destination: destination,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLanguageProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final dashboardAsync = ref.watch(mobileDashboardProvider);
    final currentUser = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(mobileProfileProvider);
    final profile = profileAsync.asData?.value;

    final userName = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : (currentUser?.fullName.isNotEmpty == true
              ? currentUser!.fullName
              : context.loc.employee);

    return Scaffold(
      backgroundColor: AppColors.background,
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
                padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 8.h),
                sliver: SliverToBoxAdapter(
                  child: EmployeeHomeHeader(
                    userName: userName,
                    unreadCount: unreadCount,
                    avatarUrl: profile?.avatarUrl,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.h, bottom: 16.h),
                    child: Text(
                      DateTime.now().formatLocalized(style: 'weekday_full'),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                error: (err, _) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(context.loc.somethingWentWrong),
                          SizedBox(height: 12.h),
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
                data: (dashboard) => [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    sliver: SliverToBoxAdapter(
                      child: EmployeeHomeStatsRow(stats: dashboard.stats),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 12.h),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.loc.upcomingTasks,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              '${dashboard.upcomingTasks.length} ${context.loc.smTasks}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (dashboard.upcomingTasks.isEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 24.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            context.loc.noUpcomingTasks,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 30.h),
                      sliver: SliverList.separated(
                        itemCount: dashboard.upcomingTasks.length,
                        separatorBuilder: (_, _) => SizedBox(height: 14.h),
                        itemBuilder: (context, index) {
                          final task = dashboard.upcomingTasks[index];
                          return EmployeeUpcomingTaskCard(
                            task: task,
                            onTap: () => _openTask(context, ref, task),
                            onNavigate: () => _openNavigation(
                              context,
                              task,
                              dashboard.mapPins,
                            ),
                            onStartTimer: () =>
                                _startTimerForTask(context, ref, task),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
