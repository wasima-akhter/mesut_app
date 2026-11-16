import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/localization_provider.dart';
import '../../shared/config/presentation/providers/mobile_config_provider.dart';
import '../../shared/mobile_time_tracking/presentation/providers/mobile_time_tracking_provider.dart';
import '../../shared/mobile_time_tracking/presentation/widgets/mobile_manual_time_dialog.dart';
import '../../shared/mobile_time_tracking/presentation/widgets/mobile_time_logs_section.dart';
import '../presentation/providers/offline_sync_provider.dart';
import 'widgets/employee_timer_control_card.dart';

class EmployeeTimeTrackingPage extends ConsumerWidget {
  const EmployeeTimeTrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLanguageProvider);
    final allowManual = ref.watch(allowEmployeeManualTimeProvider);
    final syncState = ref.watch(offlineSyncProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(mobileTimeLogsProvider.notifier).refresh(),
              ref.read(offlineSyncProvider.notifier).syncPendingLogs(),
            ]);
          },
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.loc.timeTracking,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (allowManual)
                    OutlinedButton.icon(
                      onPressed: () {
                        showModalBottomSheet<bool>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const MobileManualTimeDialog(),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(context.loc.manualLabel),
                    ),
                ],
              ),
              if (syncState.hasPending) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sync_outlined,
                        color: Color(0xFFEA580C),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          context.loc.pendingSyncCount(
                            '${syncState.pendingCount}',
                          ),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: syncState.isSyncing
                            ? null
                            : () => ref
                                  .read(offlineSyncProvider.notifier)
                                  .syncPendingLogs(),
                        child: Text(
                          syncState.isSyncing
                              ? context.loc.syncingInProgress
                              : context.loc.syncNow,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 14.h),
              const EmployeeTimerControlCard(),
              SizedBox(height: 18.h),
              const MobileTimeLogsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
