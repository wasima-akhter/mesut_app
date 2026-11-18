import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';

class NotificationHeader extends StatelessWidget {
  final bool hasNotifications;
  final VoidCallback onBack;
  final VoidCallback onMarkAllAsRead;
  final VoidCallback onClearAll;

  const NotificationHeader({
    super.key,
    required this.hasNotifications,
    required this.onBack,
    required this.onMarkAllAsRead,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              context.loc.notificationsTitle,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (hasNotifications)
            PopupMenuButton<String>(
              icon: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              onSelected: (value) {
                if (value == 'markRead') {
                  onMarkAllAsRead();
                } else if (value == 'clear') {
                  onClearAll();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'markRead',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.done_all,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        context.loc.markAllAsRead,
                        style: TextStyle(fontSize: 16.5.sp),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        context.loc.clearAll,
                        style: TextStyle(
                          fontSize: 16.5.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
