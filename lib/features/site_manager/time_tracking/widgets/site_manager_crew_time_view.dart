import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../shared/mobile_dashboard/domain/entities/mobile_project_entity.dart';
import '../../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../../shared/mobile_time_tracking/domain/entities/mobile_time_log_entity.dart';
import '../../../shared/mobile_time_tracking/presentation/providers/mobile_time_tracking_provider.dart';
import '../../presentation/providers/site_manager_time_provider.dart';
import 'site_manager_crew_card.dart';

/// Slivers rendering the "Site Crew Time" section of Site Manager Time Tracking with real API data.
class SiteManagerCrewTimeView {
  const SiteManagerCrewTimeView._();

  static List<Widget> buildSlivers(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(mobileProjectsProvider);
    final projects =
        projectsAsync.asData?.value ?? const <MobileProjectEntity>[];
    final seen = <String>{};
    final validProjects = projects
        .where((p) => p.id.isNotEmpty && seen.add(p.id))
        .toList();
    final hasMore = ref.watch(mobileProjectsProvider.notifier).hasMore;
    final timeState = ref.watch(siteManagerTimeProvider);
    final notifier = ref.read(siteManagerTimeProvider.notifier);

    final selectedProjectId =
        validProjects.any((p) => p.id == timeState.selectedProject)
        ? timeState.selectedProject
        : (validProjects.isNotEmpty ? validProjects.first.id : '');

    if (selectedProjectId.isNotEmpty &&
        ref.read(mobileCrewTimeProvider.notifier).projectId !=
            selectedProjectId) {
      Future.microtask(() {
        if (timeState.selectedProject != selectedProjectId) {
          notifier.setSelectedProject(selectedProjectId);
        }
        ref
            .read(mobileCrewTimeProvider.notifier)
            .load(projectId: selectedProjectId);
      });
    }

    final crewTimeAsync = ref.watch(mobileCrewTimeProvider);
    final crewData = crewTimeAsync.asData?.value;
    final crewMembers =
        crewData?.crewBreakdown ?? const <MobileCrewMemberSummaryEntity>[];

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
        sliver: SliverToBoxAdapter(
          child: _buildProjectDropdown(
            context,
            ref,
            validProjects,
            selectedProjectId,
            hasMore,
            notifier,
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
        sliver: SliverToBoxAdapter(child: _buildCrewSummary(context, crewData)),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 0),
        sliver: SliverToBoxAdapter(
          child: Text(
            context.loc.crewBreakdown,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      _buildCrewListSliver(context, crewTimeAsync, crewMembers),
    ];
  }

  static Widget _buildProjectDropdown(
    BuildContext context,
    WidgetRef ref,
    List<MobileProjectEntity> projects,
    String selectedProjectId,
    bool hasMore,
    SiteManagerTimeNotifier notifier,
  ) {
    final seen = <String>{};
    final validProjects = projects
        .where((p) => p.id.isNotEmpty && seen.add(p.id))
        .toList();

    if (validProjects.isEmpty) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: context.loc.project,
          hintText: context.loc.noProjectsFound,
        ),
        child: Text(context.loc.noProjectsFound),
      );
    }

    final effectiveValue = validProjects.any((p) => p.id == selectedProjectId)
        ? selectedProjectId
        : validProjects.first.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.project,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: effectiveValue,
          decoration: InputDecoration(hintText: context.loc.selectProject),
          items: [
            ...validProjects.map((project) {
              return DropdownMenuItem<String>(
                value: project.id,
                child: Flexible(
                  child: Text(
                    project.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              );
            }),
            if (hasMore)
              DropdownMenuItem<String>(
                value: '__load_more__',
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline, size: 16),
                    SizedBox(width: 6.w),
                    Text(context.loc.loadMore),
                  ],
                ),
              ),
          ],
          onChanged: (id) {
            if (id == null) return;
            if (id == '__load_more__') {
              ref.read(mobileProjectsProvider.notifier).loadMore();
              return;
            }
            notifier.setSelectedProject(id);
            ref.read(mobileCrewTimeProvider.notifier).load(projectId: id);
          },
        ),
      ],
    );
  }

  static Widget _buildCrewListSliver(
    BuildContext context,
    AsyncValue<MobileCrewTimeEntity?> crewTimeAsync,
    List<MobileCrewMemberSummaryEntity> crewMembers,
  ) {
    return crewTimeAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              e.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ),
      data: (_) {
        if (crewMembers.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 36.h),
                child: Text(
                  context.loc.noRecentLogs,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          );
        }
        return SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 30.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: SiteManagerCrewCard(member: crewMembers[index]),
              ),
              childCount: crewMembers.length,
            ),
          ),
        );
      },
    );
  }

  static Widget _buildCrewSummary(
    BuildContext context,
    MobileCrewTimeEntity? data,
  ) {
    final totalHours = data?.totalProjectHours ?? 0.0;
    final totalDuration = Duration(minutes: (totalHours * 60).round());
    final activities =
        data?.hoursByActivity ?? const <MobileCrewActivityHoursEntity>[];

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.timeDarkSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.totalProjectHours,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.neutral400),
          ),
          SizedBox(height: 3.h),
          Text(
            totalDuration.formatCompactLocalized(),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.white),
          ),
          SizedBox(height: 14.h),
          ...activities.map((act) {
            final ratio = totalHours > 0
                ? (act.hours / totalHours).clamp(0.0, 1.0)
                : 0.0;
            return SiteManagerCrewCard.crewProgress(
              context,
              activity: act.activityType,
              hours: '${act.hours.toStringAsFixed(1)}h',
              progress: ratio,
            );
          }),
        ],
      ),
    );
  }
}
