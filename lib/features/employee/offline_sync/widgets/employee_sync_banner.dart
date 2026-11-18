import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/context_extensions.dart';
import '../providers/employee_sync_provider.dart';
import 'employee_sync_details_sheet.dart';

class EmployeeSyncBanner extends ConsumerWidget {
  const EmployeeSyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(employeeSyncProvider);

    // If fully online, not syncing, and no pending items, show nothing
    if (syncState.isOnline && !syncState.isSyncing && !syncState.hasPending) {
      return const SizedBox.shrink();
    }

    if (syncState.isSyncing) {
      return InkWell(
        onTap: () => EmployeeSyncDetailsSheet.show(context),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            border: Border(bottom: BorderSide(color: Color(0xFFBFDBFE))),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 14.w,
                height: 14.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF2563EB),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  context.loc.syncingInProgress,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E40AF),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!syncState.isOnline) {
      return InkWell(
        onTap: () => EmployeeSyncDetailsSheet.show(context),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          decoration: const BoxDecoration(
            color: Color(0xFFFEF3C7),
            border: Border(bottom: BorderSide(color: Color(0xFFFCD34D))),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 16,
                color: Color(0xFFB45309),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  syncState.hasPending
                      ? '${context.loc.get('common.offline', 'Offline')} • ${context.loc.pendingSyncCount('${syncState.totalPendingCount}')}'
                      : '${context.loc.get('common.offline', 'Offline')} • ${context.loc.get('common.workingOffline', 'Working offline')}',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Online but has pending items
    return InkWell(
      onTap: () => EmployeeSyncDetailsSheet.show(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: const BoxDecoration(
          color: Color(0xFFF0FDF4),
          border: Border(bottom: BorderSide(color: Color(0xFFBBF7D0))),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              size: 16,
              color: Color(0xFF15803D),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                context.loc.pendingSyncCount('${syncState.totalPendingCount}'),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF166534),
                ),
              ),
            ),
            Text(
              context.loc.tapToSync,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF15803D),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
