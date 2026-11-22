import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/constants/route_constants.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/localization/pending_refetch_controller.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../shared/helper/employee_enums.dart';
import '../../../shared/helper/employee_models.dart';
import '../../../time_tracking/presentation/providers/employee_timer_provider.dart';
import '../providers/employee_assignment_details_provider.dart';
import '../widgets/assignment_detail_header.dart';
import '../widgets/assignment_detail_instructions_card.dart';
import '../widgets/assignment_detail_manager_card.dart';
import '../widgets/assignment_detail_map_card.dart';
import '../widgets/assignment_detail_photos_card.dart';
import '../widgets/assignment_detail_project_card.dart';
import '../widgets/assignment_detail_tasks_card.dart';

class AssignmentDetailsPage extends ConsumerStatefulWidget {
  final String? projectId;

  const AssignmentDetailsPage({super.key, this.projectId});

  @override
  ConsumerState<AssignmentDetailsPage> createState() =>
      _AssignmentDetailsPageState();
}

class _AssignmentDetailsPageState extends ConsumerState<AssignmentDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pid = widget.projectId;
      if (pid != null && pid.isNotEmpty) {
        ref.read(assignmentDetailsProvider.notifier).loadProject(pid);
      }
    });
  }

  void _startTimer(BuildContext context, WidgetRef ref) {
    final state = ref.read(assignmentDetailsProvider);
    final project = state.project;
    final fallback = state.fallbackAssignment;

    final id = project?.id ?? fallback?.projectId ?? 'project';
    final phaseId = project?.phase?.id ?? fallback?.phaseId;
    final name = project?.name ?? fallback?.project ?? 'Project';
    final address = project?.fullAddress ?? fallback?.address ?? '';
    final activity = fallback?.activity ?? EmployeeActivityType.erection;

    ref.read(employeeTimerProvider.notifier).startTimer(
          project: EmployeeProjectModel(
            id: id,
            phaseId: phaseId,
            name: name,
            address: address,
            activity: activity,
            startTime: '07:30 am',
            endTime: '04:15 pm',
            startTimeOfDay:
                fallback?.startTimeOfDay ?? const TimeOfDay(hour: 7, minute: 30),
            endTimeOfDay:
                fallback?.endTimeOfDay ?? const TimeOfDay(hour: 16, minute: 15),
            siteManager: project?.siteManager?.fullName ??
                fallback?.siteManager ??
                'Site Manager',
          ),
          activity: activity,
        );
    context.push(RouteConstants.employeeActiveTimerPage);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assignmentDetailsProvider);
    final project = state.project;
    final fallback = state.fallbackAssignment;

    if (state.isLoading && !state.hasData) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final projectId = project?.id ?? fallback?.projectId ?? widget.projectId ?? '';
    final projectTitle = project?.name ?? fallback?.project ?? 'Project';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: PendingPollEffect(
          hasPending: state.hasPendingTranslation,
          onPoll: () => ref.read(assignmentDetailsProvider.notifier).refresh(),
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(assignmentDetailsProvider.notifier).refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 10.h),
                  sliver: const SliverToBoxAdapter(
                    child: AssignmentDetailHeader(),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  sliver: SliverToBoxAdapter(
                    child: AssignmentDetailProjectCard(
                      project: project,
                      fallback: fallback,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  sliver: SliverToBoxAdapter(
                    child: AssignmentDetailMapCard(
                      project: project,
                      fallback: fallback,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  sliver: SliverToBoxAdapter(
                    child: AssignmentDetailManagerCard(
                      manager: project?.siteManager,
                      fallback: fallback,
                    ),
                  ),
                ),
                if (project?.siteAccessCode != null ||
                    project?.siteAccessNotes != null) ...[
                  SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    sliver: SliverToBoxAdapter(
                      child: AssignmentDetailInstructionsCard(
                        accessCode: project?.siteAccessCode,
                        accessNotes: project?.siteAccessNotes,
                      ),
                    ),
                  ),
                ],
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  sliver: SliverToBoxAdapter(
                    child: AssignmentDetailPhotosCard(
                      projectId: projectId,
                      projectTitle: projectTitle,
                      photoCount: project?.photoCount ?? 0,
                      photos: project?.photos ?? const [],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  sliver: SliverToBoxAdapter(
                    child: AssignmentDetailTasksCard(
                      tasks: state.tasks,
                      onToggleTask: (taskId) {
                        ref
                            .read(assignmentDetailsProvider.notifier)
                            .toggleTask(taskId);
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 25.h),
                  sliver: SliverToBoxAdapter(
                    child: AppButton(
                      onPressed: () => _startTimer(context, ref),
                      height: 52.h,
                      text: context.loc.startNewTimer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
