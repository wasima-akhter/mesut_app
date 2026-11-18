import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:construction_app/app/theme/app_colors.dart';
import 'package:construction_app/core/localization/context_extensions.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notifications_provider.dart';
import 'notification_card.dart';

class NotificationListView extends StatelessWidget {
  final List<AppNotification> items;
  final NotificationsFeedState feed;
  final ValueChanged<AppNotification> onMarkAsRead;
  final ValueChanged<AppNotification> onDelete;
  final VoidCallback onLoadMore;

  const NotificationListView({
    super.key,
    required this.items,
    required this.feed,
    required this.onMarkAsRead,
    required this.onDelete,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final todayItems = items.where((i) => i.dateGroup == 'today').toList();
    final yesterdayItems =
        items.where((i) => i.dateGroup == 'yesterday').toList();
    final earlierItems = items.where((i) => i.dateGroup == 'earlier').toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 24.h),
      children: [
        if (todayItems.isNotEmpty) ...[
          _buildGroupHeader(context, context.loc.notifToday),
          ...todayItems.map(
            (item) => NotificationCard(
              item: item,
              onTap: () => onMarkAsRead(item),
              onDismiss: () => onDelete(item),
            ),
          ),
          SizedBox(height: 12.h),
        ],
        if (yesterdayItems.isNotEmpty) ...[
          _buildGroupHeader(context, context.loc.notifYesterday),
          ...yesterdayItems.map(
            (item) => NotificationCard(
              item: item,
              onTap: () => onMarkAsRead(item),
              onDismiss: () => onDelete(item),
            ),
          ),
          SizedBox(height: 12.h),
        ],
        if (earlierItems.isNotEmpty) ...[
          _buildGroupHeader(context, context.loc.notifEarlier),
          ...earlierItems.map(
            (item) => NotificationCard(
              item: item,
              onTap: () => onMarkAsRead(item),
              onDismiss: () => onDelete(item),
            ),
          ),
        ],
        if (feed.hasMore)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Center(
              child: feed.isLoadingMore
                  ? const CircularProgressIndicator()
                  : OutlinedButton(
                      onPressed: onLoadMore,
                      child: Text(context.loc.viewAll),
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildGroupHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h, top: 4.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 14.5.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
