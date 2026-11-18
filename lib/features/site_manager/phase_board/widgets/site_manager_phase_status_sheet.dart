import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/context_extensions.dart';
import '../domain/entities/mobile_phase_entity.dart';
import '../models/backend_phase_status.dart';

class SiteManagerPhaseStatusSheet extends StatelessWidget {
  const SiteManagerPhaseStatusSheet({super.key, required this.phase});

  final MobilePhaseEntity phase;

  static Future<String?> show(BuildContext context, MobilePhaseEntity phase) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SiteManagerPhaseStatusSheet(phase: phase),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = BackendPhaseStatus.fromString(phase.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Text(
              phase.project.name.isNotEmpty ? phase.project.name : phase.id,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              context.loc.updateStatus,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 19.sp,
              ),
            ),
            SizedBox(height: 12.h),
            ...BackendPhaseStatus.values.map((status) {
              final isSelected = status == currentStatus;
              return Column(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(status.value),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.h,
                        horizontal: 4.w,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: BoxDecoration(
                              color: status.color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              status.icon,
                              size: 19.sp,
                              color: status.color,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Text(
                              status.localizedName(context),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 16.sp,
                                    color: isSelected
                                        ? status.color
                                        : AppColors.textPrimary,
                                  ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              size: 20.sp,
                              color: status.color,
                            ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ],
              );
            }),
            SizedBox(height: 12.h),
            Center(
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 8.h,
                  ),
                  child: Text(
                    context.loc.cancel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
