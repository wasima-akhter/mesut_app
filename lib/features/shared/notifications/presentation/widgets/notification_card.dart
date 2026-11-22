import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/widgets/translation/translation_status_badge.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  IconData _getIconForType(NotificationCategory type) {
    switch (type) {
      case NotificationCategory.schedule:
        return Icons.calendar_month_outlined;
      case NotificationCategory.safety:
        return Icons.warning_amber_rounded;
      case NotificationCategory.timeTracking:
        return Icons.access_time_rounded;
      case NotificationCategory.task:
        return Icons.layers_outlined;
      case NotificationCategory.inspection:
        return Icons.assignment_turned_in_outlined;
      case NotificationCategory.system:
        return Icons.info_outline_rounded;
    }
  }

  Color _getColorForType(NotificationCategory type) {
    switch (type) {
      case NotificationCategory.schedule:
        return AppColors.info;
      case NotificationCategory.safety:
        return AppColors.error;
      case NotificationCategory.timeTracking:
        return AppColors.success;
      case NotificationCategory.task:
        return AppColors.warning;
      case NotificationCategory.inspection:
        return const Color(0xFF673AB7);
      case NotificationCategory.system:
        return AppColors.primary;
    }
  }

  Color _getBgColorForType(NotificationCategory type) {
    switch (type) {
      case NotificationCategory.schedule:
        return AppColors.infoLight;
      case NotificationCategory.safety:
        return AppColors.errorLight;
      case NotificationCategory.timeTracking:
        return AppColors.successLight;
      case NotificationCategory.task:
        return AppColors.warningLight;
      case NotificationCategory.inspection:
        return const Color(0xFFEDE7F6);
      case NotificationCategory.system:
        return AppColors.primary.withValues(alpha: 0.12);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconForType(item.type);
    final iconColor = _getColorForType(item.type);
    final iconBg = _getBgColorForType(item.type);

    return RepaintBoundary(
      child: Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: item.isRead ? AppColors.white : const Color(0xFFFFF9F9),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: item.isRead
                  ? AppColors.border
                  : AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(iconData, size: 22, color: iconColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 17.5.sp,
                              fontWeight: item.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!item.isRead) ...[
                          SizedBox(width: 6.w),
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.message,
                      style: TextStyle(
                        fontSize: 15.5.sp,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (item.projectTag != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              item.projectTag!,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        Text(
                          item.displayTime,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        if (item.localization != null)
                          TranslationStatusBadge.fromMeta(item.localization),
                      ],
                    ),
                  ],
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
