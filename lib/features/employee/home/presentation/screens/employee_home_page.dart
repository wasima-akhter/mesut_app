import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/constants/route_constants.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/enums/app_enum.dart';
import '../../../../../core/localization/pending_refetch_controller.dart';
import '../../../../../core/pagination/app_pagination_footer.dart';
import '../../../../map/domain/entities/map_coordinate_entity.dart';
import '../../../../map/domain/entities/map_location_entity.dart';
import '../../../../map/domain/entities/map_request_entity.dart';
import '../../../../map/utils/map_coordinate_resolver.dart';
import '../../../assignments/presentation/providers/employee_assignment_details_provider.dart';
import '../../../shared/helper/employee_enums.dart';
import '../../../shared/helper/employee_models.dart';
import '../../../time_tracking/presentation/providers/employee_time_tracking_provider.dart';
import '../../../time_tracking/presentation/providers/employee_timer_provider.dart';
import '../../domain/entities/employee_dashboard_entity.dart';
import '../providers/employee_dashboard_provider.dart';
import '../widgets/employee_assignment_card.dart';
import '../widgets/employee_home_header.dart';
import '../widgets/employee_home_placeholders.dart';

class EmployeeHomePage extends ConsumerStatefulWidget {
  const EmployeeHomePage({super.key});

  @override
  ConsumerState<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends ConsumerState<EmployeeHomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      ref.read(employeeDashboardProvider.notifier).loadMore();
    }
  }

  EmployeeAssignmentModel _toAssignment(EmployeeDashboardTaskEntity task) {
    final activity = task.isDismantling
        ? EmployeeActivityType.dismantling
        : EmployeeActivityType.erection;

    return EmployeeAssignmentModel(
      projectId: task.project.id,
      phaseId: task.phaseId,
      project: task.project.name.isNotEmpty
          ? task.project.name
          : 'Project Phase',
      address: task.project.address,
      activity: activity,
      schedule: task.workingHours.isNotEmpty
          ? 'Start: ${task.workingHours.split('-').first.trim()}'
          : 'Start: 07:30 am',
      scaffoldArea: '50m²',
      siteManager: task.siteManager.name.isNotEmpty
          ? task.siteManager.name
          : 'Site Manager',
      latitude: task.project.latitude,
      longitude: task.project.longitude,
      localization: task.localization,
    );
  }

  void _openAssignment(EmployeeAssignmentModel assignment) {
    ref.read(assignmentDetailsProvider.notifier).setAssignment(assignment);
    context.push(RouteConstants.employeeAssignmentDetails);
  }

  void _startNewTimer(EmployeeAssignmentModel assignment) {
    ref.read(assignmentDetailsProvider.notifier).setAssignment(assignment);
    final projectId = assignment.projectId?.isNotEmpty == true
        ? assignment.projectId!
        : (assignment.phaseId?.isNotEmpty == true
              ? assignment.phaseId!
              : assignment.project);
    ref
        .read(employeeTimeTrackingProvider.notifier)
        .startTimer(
          projectId: projectId,
          activityType: assignment.activity.name.toUpperCase(),
        );
    ref
        .read(employeeTimerProvider.notifier)
        .startTimer(
          project: EmployeeProjectModel(
            id: projectId,
            name: assignment.project,
            address: assignment.address,
            activity: assignment.activity,
            startTime: '07:30 am',
            endTime: '04:15 pm',
            siteManager: assignment.siteManager,
          ),
          activity: assignment.activity,
        );
    context.push(RouteConstants.employeeActiveTimerPage);
  }

  void _showNavigationMessage(EmployeeAssignmentModel assignment) {
    final coordinate =
        (assignment.latitude != null &&
            assignment.longitude != null &&
            assignment.latitude != 0 &&
            assignment.longitude != 0)
        ? MapCoordinate(
            latitude: assignment.latitude!,
            longitude: assignment.longitude!,
          )
        : MapCoordinateResolver.resolve(assignment.address);

    final destination = MapLocationEntity(
      id: 'assignment_${assignment.address.hashCode}',
      title: assignment.project,
      address: assignment.address,
      coordinate: coordinate,
      type: assignment.activity.label,
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
    final dashboardState = ref.watch(employeeDashboardProvider);
    final dashboard = dashboardState.dashboard;
    final user = dashboard.user;
    final tasks = dashboard.upcomingTasks;
    final taskCount = dashboard.totalUpcomingTasks > 0
        ? dashboard.totalUpcomingTasks
        : tasks.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: PendingPollEffect(
          hasPending: anyLocalizationPending(tasks.map((t) => t.localization)),
          onPoll: () => ref.read(employeeDashboardProvider.notifier).refresh(),
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(employeeDashboardProvider.notifier).refresh(),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 10.h),
                sliver: SliverToBoxAdapter(
                  child: EmployeeHomeHeader(user: user),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                sliver: SliverToBoxAdapter(
                  child: EmployeeHomeDateHeader(dashboard: dashboard),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 18.h)),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                sliver: SliverToBoxAdapter(
                  child: EmployeeHomeTasksSectionHeader(taskCount: taskCount),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 12.h)),
              if (dashboardState.isLoading && tasks.isEmpty)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 30.h),
                  sliver: const SliverToBoxAdapter(
                    child: EmployeeHomeLoadingPlaceholder(),
                  ),
                )
              else if (dashboardState.errorMessage != null && tasks.isEmpty)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 30.h),
                  sliver: SliverToBoxAdapter(
                    child: EmployeeHomeErrorPlaceholder(
                      message: dashboardState.errorMessage,
                      onRetry: () => ref
                          .read(employeeDashboardProvider.notifier)
                          .loadInitial(),
                    ),
                  ),
                )
              else if (tasks.isEmpty)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 30.h),
                  sliver: const SliverToBoxAdapter(
                    child: EmployeeHomeEmptyPlaceholder(),
                  ),
                )
              else ...[
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 16.h),
                  sliver: SliverList.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (_, _) => SizedBox(height: 14.h),
                    itemBuilder: (context, index) {
                      final assignment = _toAssignment(tasks[index]);
                      return EmployeeAssignmentCard(
                        assignment: assignment,
                        onTap: () => _openAssignment(assignment),
                        onNavigate: () => _showNavigationMessage(assignment),
                        onStartTimer: () => _startNewTimer(assignment),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: AppPaginationFooter(
                    hasMore: dashboardState.hasMore,
                    isLoadingMore: dashboardState.isLoadingMore,
                    itemCount: tasks.length,
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 24.h)),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
}
