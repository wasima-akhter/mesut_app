import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/localization/context_extensions.dart';
import '../../../../core/widgets/snack/app_snackbar.dart';
import '../../../../core/widgets/states/app_error_widget.dart';
import '../../../shared/mobile_time_tracking/domain/entities/mobile_time_log_entity.dart';
import '../../../shared/mobile_time_tracking/presentation/providers/mobile_time_tracking_provider.dart';
import 'site_manager_my_time_entry_card.dart';
import 'site_manager_start_timer_sheet.dart';

/// Slivers rendering the "My Time" section of Site Manager Time Tracking with real API logs.
class SiteManagerMyTimeView {
  const SiteManagerMyTimeView._();

  static List<Widget> buildSlivers(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(mobileTimeLogsProvider);
    final notifier = ref.read(mobileTimeLogsProvider.notifier);
    final isRunning = notifier.activeTimeLogId != null;
    final logs = logsAsync.asData?.value ?? const <MobileTimeLogEntity>[];

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
        sliver: SliverToBoxAdapter(child: _buildSummary(context, logs)),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
        sliver: SliverToBoxAdapter(
          child: _buildTimerButton(context, ref, isRunning),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 0),
        sliver: SliverToBoxAdapter(
          child: Text(context.loc.recentLogs, style: Theme.of(context).textTheme.titleLarge),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
        sliver: SliverToBoxAdapter(
          child: _buildFilterChips(context, notifier.period, notifier),
        ),
      ),
      _buildLogsSliver(context, logsAsync, notifier.refresh),
    ];
  }

  static Widget _buildLogsSliver(
    BuildContext context,
    AsyncValue<List<MobileTimeLogEntity>> logsAsync,
    VoidCallback onRetry,
  ) {
    return logsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: AppErrorWidget(
            error: e,
            onRetry: onRetry,
          ),
        ),
      ),
      data: (logs) {
        if (logs.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 36.h),
                child: Text(context.loc.noRecentLogs, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          );
        }
        return SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 30.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: SiteManagerMyTimeEntryCard(entry: logs[index]),
              ),
              childCount: logs.length,
            ),
          ),
        );
      },
    );
  }

  static Widget _buildSummary(BuildContext context, List<MobileTimeLogEntity> logs) {
    final totalHours = logs.fold<double>(0.0, (acc, item) => acc + item.netHours);
    final totalDuration = Duration(minutes: (totalHours * 60).round());

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.timeDarkSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _summaryValue(
                  context,
                  title: context.loc.loggedTime,
                  value: totalDuration.formatCompactLocalized(),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _summaryValue(
                    context,
                    title: context.loc.status,
                    value: '${logs.length} ${context.loc.timeLogsLabel}',
                    alignRight: true,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: LinearProgressIndicator(
              value: (totalHours / 40.0).clamp(0.0, 1.0),
              minHeight: 5.h,
              backgroundColor: AppColors.neutral600,
              valueColor: const AlwaysStoppedAnimation(AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _summaryValue(
    BuildContext context, {
    required String title,
    required String value,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.neutral400),
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.white),
        ),
      ],
    );
  }

  static Widget _buildTimerButton(BuildContext context, WidgetRef ref, bool isRunning) {
    return Material(
      color: isRunning ? AppColors.error : AppColors.primary,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: () async {
          if (isRunning) {
            try {
              await ref.read(mobileTimeLogsProvider.notifier).stopActiveTimer();
              if (context.mounted) {
                AppSnackBar.showSuccess(context, context.loc.timerStopped);
              }
            } catch (e) {
              if (context.mounted) AppSnackBar.showError(context, e.toString());
            }
          } else {
            SiteManagerStartTimerSheet.show(context);
          }
        },
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
          child: Center(
            child: Text(
              isRunning ? context.loc.stopTimer : context.loc.startNewTimer,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildFilterChips(
    BuildContext context,
    String activePeriod,
    MobileTimeLogsNotifier notifier,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _filterChip(context, context.loc.today, activePeriod == 'TODAY', () => notifier.setPeriod('TODAY')),
          SizedBox(width: 7.w),
          _filterChip(context, context.loc.thisWeek, activePeriod == 'WEEK', () => notifier.setPeriod('WEEK')),
          SizedBox(width: 7.w),
          _filterChip(context, context.loc.thisMonth, activePeriod == 'MONTH', () => notifier.setPeriod('MONTH')),
        ],
      ),
    );
  }

  static Widget _filterChip(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surfaceTertiary,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? AppColors.white : AppColors.textSecondary,
                ),
          ),
        ),
      ),
    );
  }
}
