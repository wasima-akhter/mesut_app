import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/context_extensions.dart';
import '../models/employee_sync_action.dart';
import '../providers/employee_sync_provider.dart';
import '../services/employee_sync_service.dart';

class EmployeeSyncDetailsSheet extends ConsumerWidget {
  const EmployeeSyncDetailsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const EmployeeSyncDetailsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(employeeSyncProvider);

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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        syncState.isOnline
                            ? context.loc.pendingSyncCount(
                                '${syncState.totalPendingCount}',
                              )
                            : '${context.loc.get('common.offline', 'Offline')} • ${context.loc.pendingSyncCount('${syncState.totalPendingCount}')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (syncState.hasPending)
                  ElevatedButton(
                    onPressed: syncState.isSyncing
                        ? null
                        : () =>
                            ref.read(employeeSyncProvider.notifier).syncAll(),
                    child: Text(
                      syncState.isSyncing
                          ? context.loc.syncingInProgress
                          : context.loc.syncNow,
                    ),
                  ),
              ],
            ),
            Divider(height: 24.h),
            if (syncState.pendingActions.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48.sp,
                        color: AppColors.success,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        context.loc.noPendingSyncItems,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: syncState.pendingActions.length,
                  separatorBuilder: (_, _) => Divider(height: 12.h),
                  itemBuilder: (context, index) {
                    final action = syncState.pendingActions[index];
                    final friendlyError = action.lastError != null
                        ? _cleanDisplayError(context, action.lastError!)
                        : null;
                    final payloadSummary = _formatPayloadSummary(action);

                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 16.r,
                        backgroundColor: friendlyError != null
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFEFF6FF),
                        child: Icon(
                          friendlyError != null
                              ? Icons.sync_problem_rounded
                              : Icons.sync_rounded,
                          size: 16.sp,
                          color: friendlyError != null
                              ? const Color(0xFFB45309)
                              : AppColors.primary,
                        ),
                      ),
                      title: Text(
                        action.displayTitle,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$payloadSummary • ${_formatDate(action.createdAt)}',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          if (friendlyError != null) ...[
                            SizedBox(height: 3.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 12.5.sp,
                                  color: const Color(0xFFD97706),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    friendlyError,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xFFB45309),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      trailing: action.attempts > 0
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                '${action.attempts}x',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatPayloadSummary(EmployeeSyncAction action) {
    final p = EmployeeSyncService.sanitizePayload(action);
    return switch (action.actionType) {
      EmployeeSyncActionType.startTimer =>
        'Timer • ${p['activityType']?.toString().toUpperCase() ?? 'ERECTION'}',
      EmployeeSyncActionType.stopTimer => 'Timer Stop',
      EmployeeSyncActionType.manualTimeLog =>
        'Manual • ${p['activityType'] ?? 'ERECTION'} (${p['breakMinutes'] ?? 0}m break)',
      EmployeeSyncActionType.uploadAssignmentPhoto => 'Photo Upload',
      EmployeeSyncActionType.toggleAssignmentTask => 'Task Status',
    };
  }

  String _cleanDisplayError(BuildContext context, String rawError) {
    final l = rawError.toLowerCase();
    if (l.contains('unrecognized key') ||
        l.contains('validation') ||
        l.contains('422')) {
      return context.loc
          .get('sync.formatUpdated', 'Format updated • Ready to sync');
    }
    if (l.contains('conflict') || l.contains('409')) {
      return context.loc
          .get('sync.conflictResolved', 'Updated on server • Ready to sync');
    }
    if (l.contains('connection') ||
        l.contains('network') ||
        l.contains('timeout') ||
        l.contains('offline')) {
      return context.loc.get('sync.errorConnectionFailed',
          'Connection issue • Will retry automatically');
    }
    if (l.contains('server') ||
        l.contains('500') ||
        l.contains('502') ||
        l.contains('503')) {
      return context.loc.get('sync.errorServerUnavailable',
          'Server temporarily unavailable • Will retry');
    }
    if (l.contains('not found') || l.contains('404')) {
      return context.loc.get('sync.errorNotFound', 'Item not found on server');
    }
    if (l.contains('session') ||
        l.contains('unauthorized') ||
        l.contains('401') ||
        l.contains('403')) {
      return context.loc
          .get('sync.errorSessionExpired', 'Session expired • Please sign in again');
    }
    if (l.contains('dioexception') ||
        l.contains('cannot') ||
        l.contains('bad response') ||
        l.contains('exception:')) {
      return context.loc.get(
          'sync.errorSyncFailed', 'Could not sync changes • Will retry automatically');
    }
    return rawError;
  }

  String _formatDate(DateTime dt) {
    final l = dt.toLocal();
    final m = '${l.month}'.padLeft(2, '0');
    final d = '${l.day}'.padLeft(2, '0');
    final hh = '${l.hour}'.padLeft(2, '0');
    final mm = '${l.minute}'.padLeft(2, '0');
    return '${l.year}-$m-$d $hh:$mm';
  }
}
