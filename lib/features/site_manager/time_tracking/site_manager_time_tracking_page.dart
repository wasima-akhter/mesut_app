import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/pending_refetch_controller.dart';
import '../../../core/utils/app_date_time_formatter.dart';
import '../../shared/mobile_dashboard/presentation/providers/mobile_dashboard_provider.dart';
import '../../shared/mobile_time_tracking/presentation/providers/mobile_time_tracking_provider.dart';
import '../helper/site_manager_enums.dart';
import 'presentation/providers/site_manager_time_provider.dart';
import 'widgets/site_manager_add_time_sheet.dart';
import 'widgets/site_manager_crew_time_view.dart';
import 'widgets/site_manager_my_time_view.dart';

class SiteManagerTimeTrackingPage extends ConsumerWidget {
  const SiteManagerTimeTrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(siteManagerTimeProvider);
    final notifier = ref.read(siteManagerTimeProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            RepaintBoundary(child: _buildHeader(context)),
            RepaintBoundary(
              child: _buildMainTabs(context, state.selectedTab, notifier),
            ),
            Expanded(
              child: PendingPollEffect(
                hasPending: anyLocalizationPending([
                  ...(ref.watch(mobileTimeLogsProvider).asData?.value ??
                          const [])
                      .map((l) => l.localization),
                  ...(ref.watch(mobileProjectsProvider).asData?.value ??
                          const [])
                      .map((p) => p.localization),
                ]),
                onPoll: () async {
                  if (state.selectedTab == TimeTrackingTab.myTime) {
                    await ref.read(mobileTimeLogsProvider.notifier).refresh();
                  } else {
                    await Future.wait([
                      ref.read(mobileProjectsProvider.notifier).refresh(),
                      ref.read(mobileCrewTimeProvider.notifier).refresh(),
                    ]);
                  }
                },
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (state.selectedTab == TimeTrackingTab.myTime) {
                      await ref.read(mobileTimeLogsProvider.notifier).refresh();
                    } else {
                      await Future.wait([
                        ref.read(mobileProjectsProvider.notifier).refresh(),
                        ref.read(mobileCrewTimeProvider.notifier).refresh(),
                      ]);
                    }
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      if (state.selectedTab == TimeTrackingTab.myTime)
                        ...SiteManagerMyTimeView.buildSlivers(context, ref)
                      else
                        ...SiteManagerCrewTimeView.buildSlivers(context, ref),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.loc.timeTracking,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 4.h),
                Text(
                  AppDateTimeFormatter.formatDateRange(weekStart, weekEnd),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          _buildHeaderAction(
            context,
            icon: Icons.add,
            label: context.loc.addTime,
            onTap: () => SiteManagerAddTimeSheet.show(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17.sp, color: AppColors.textSecondary),
              SizedBox(width: 4.w),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainTabs(
    BuildContext context,
    TimeTrackingTab selectedTab,
    SiteManagerTimeNotifier notifier,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: _tabItem(
                context,
                label: context.loc.myTime,
                selected: selectedTab == TimeTrackingTab.myTime,
                onTap: () => notifier.setTab(TimeTrackingTab.myTime),
              ),
            ),
            Expanded(
              child: _tabItem(
                context,
                label: context.loc.siteCrewTime,
                selected: selectedTab == TimeTrackingTab.siteCrewTime,
                onTap: () => notifier.setTab(TimeTrackingTab.siteCrewTime),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? AppColors.black : Colors.transparent,
      borderRadius: BorderRadius.circular(7.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 12.w),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
