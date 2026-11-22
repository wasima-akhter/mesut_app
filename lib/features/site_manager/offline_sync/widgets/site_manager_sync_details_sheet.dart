import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/context_extensions.dart';
import '../providers/site_manager_sync_provider.dart';

class SiteManagerSyncDetailsSheet extends ConsumerWidget {
  const SiteManagerSyncDetailsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const SiteManagerSyncDetailsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(siteManagerSyncProvider);
    final visibleActions = syncState.visiblePendingActions;

    return Container(
      constraints: BoxConstraints(maxHeight: 0.75.sh),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 20.h),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(
                  syncState.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: syncState.isOnline
                      ? AppColors.primary
                      : const Color(0xFFB45309),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.loc.synced,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        syncState.isOnline
                            ? context.loc.pendingSyncCount(
                                '${visibleActions.length}',
                              )
                            : '${context.loc.get('common.offline', 'Offline')} • ${context.loc.pendingSyncCount('${visibleActions.length}')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (visibleActions.isNotEmpty)
                  ElevatedButton(
                    onPressed: syncState.isSyncing
                        ? null
                        : () => ref
                              .read(siteManagerSyncProvider.notifier)
                              .syncAll(),
                    child: Text(
                      syncState.isSyncing
                          ? context.loc.syncingInProgress
                          : context.loc.syncNow,
                    ),
                  ),
              ],
            ),
            Divider(height: 24.h),
            if (visibleActions.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: AppColors.success,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        context.loc.get(
                          'sync.allSynced',
                          'All changes are synchronized',
                        ),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    ...visibleActions.map((action) {
                      return ListTile(
                        leading: const Icon(Icons.pending_actions_rounded),
                        title: Text(action.displayTitle),
                        subtitle: Text(
                          '${action.httpMethod} ${action.endpoint}\n${action.createdAt.toLocal().toString().split('.').first}',
                        ),
                        isThreeLine: true,
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
