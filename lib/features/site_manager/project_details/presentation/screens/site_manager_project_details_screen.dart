import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/localization/context_extensions.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../../../core/widgets/states/app_data_state.dart';
import '../../../../../core/widgets/states/app_empty_widget.dart';
import '../../../../../core/widgets/states/app_screen_state_view.dart';
import '../../../project_attachments/presentation/widgets/project_photos_tab_view.dart';
import '../../../project_measurements/presentation/widgets/project_measurement_tab_view.dart';
import '../../../project_notes/presentation/widgets/project_notes_tab_view.dart';
import '../../../project_tasks/presentation/widgets/project_tasks_tab_view.dart';
import '../../../project_dates/presentation/widgets/project_dates_tab_view.dart';
import '../../../projects/enums.dart';
import '../../../project_history/presentation/widgets/project_history_tab_view.dart';
import '../providers/project_details_provider.dart';
import '../widgets/project_details_header.dart';
import '../widgets/project_details_overview_tab.dart';
import '../widgets/project_details_skeleton_loader.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(projectDetailsProvider.notifier)
          .loadOverview(widget.projectId, forceRefresh: true);
    });
  }

  @override
  void didUpdateWidget(covariant ProjectDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId &&
        widget.projectId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(projectDetailsProvider.notifier)
            .loadOverview(widget.projectId, forceRefresh: true);
      });
    }
  }

  Widget _buildPlaceholderHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: Row(
        children: [
          AppIconButton.circle(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: () => context.pop(),
            size: 34.w,
            border: Border.all(color: const Color(0xFFE5E5E5)),
            iconColor: const Color(0xFF333333),
            iconSize: 17.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              context.loc.projectDetails,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111111),
              ),
            ),
          ),
          SizedBox(width: 34.w),
        ],
      ),
    );
  }

  Widget _buildFixedTabs(ProjectDetailsTab selectedTab) {
    return Container(
      height: 44.h,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: ProjectDetailsTab.values.map((tab) {
            final selected = tab == selectedTab;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ref.read(projectDetailsProvider.notifier).selectTab(tab);
              },
              child: Container(
                constraints: BoxConstraints(maxWidth: 110.w),
                margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 5.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFC8102E)
                      : const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? Colors.white : const Color(0xFF777777),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabBody(ProjectDetailsState state) {
    final hasValidDetails =
        state.details != null && state.details!.id == widget.projectId;

    switch (state.selectedTab) {
      case ProjectDetailsTab.overview:
        final effectiveStatus =
            (!hasValidDetails &&
                (state.overviewStatus == AppDataStatus.initial ||
                    state.overviewStatus == AppDataStatus.refreshing))
            ? AppDataStatus.loading
            : state.overviewStatus;

        return AppScreenStateView(
          status: effectiveStatus,
          errorMessage: state.errorMessage,
          errorObject: state.errorObject,
          loadingShimmer: const ProjectDetailsSkeletonLoader(),
          onRetry: () => ref
              .read(projectDetailsProvider.notifier)
              .loadOverview(widget.projectId, forceRefresh: true),
          child: hasValidDetails
              ? ProjectDetailsOverviewTab(
                  details: state.details!,
                  onRefresh: () => ref
                      .read(projectDetailsProvider.notifier)
                      .loadOverview(widget.projectId, forceRefresh: true),
                )
              : AppEmptyWidget(
                  message: context.loc.noData,
                  onRetry: () => ref
                      .read(projectDetailsProvider.notifier)
                      .loadOverview(widget.projectId, forceRefresh: true),
                ),
        );
      case ProjectDetailsTab.tasks:
        return ProjectTasksTabView(projectId: widget.projectId);
      case ProjectDetailsTab.photos:
        return ProjectPhotosTabView(
          projectId: widget.projectId,
          projectName: hasValidDetails ? state.details!.name : '',
        );
      case ProjectDetailsTab.measurement:
        return ProjectMeasurementTabView(projectId: widget.projectId);
      case ProjectDetailsTab.dates:
        return ProjectDatesTabView(projectId: widget.projectId);
      case ProjectDetailsTab.notes:
        return ProjectNotesTabView(projectId: widget.projectId);
      case ProjectDetailsTab.history:
        return ProjectHistoryTabView(projectId: widget.projectId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectDetailsProvider);
    final hasValidDetails =
        state.details != null && state.details!.id == widget.projectId;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            if (hasValidDetails)
              ProjectDetailsHeader(details: state.details!)
            else
              _buildPlaceholderHeader(context),
            _buildFixedTabs(state.selectedTab),
            Expanded(child: _buildTabBody(state)),
          ],
        ),
      ),
    );
  }
}
