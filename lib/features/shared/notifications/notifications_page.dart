import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import 'domain/entities/notification_entity.dart';
import 'presentation/providers/notifications_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  int _selectedFilterIndex = 0; // 0 = All, 1 = Unread

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).refresh();
    });
  }

  List<AppNotification> _filterNotifications(List<AppNotification> list) {
    if (_selectedFilterIndex == 1) {
      return list.where((n) => !n.isRead).toList();
    }
    return list;
  }

  void _markAllAsRead() {
    ref.read(notificationsProvider.notifier).markAllAsRead();
    _showSnackBar(context.loc.markedAsRead);
  }

  void _clearAll() {
    ref.read(notificationsProvider.notifier).clearAll();
    _showSnackBar(context.loc.allCleared);
  }

  void _markAsRead(AppNotification item) {
    if (!item.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(item.id);
    }
  }

  void _deleteNotification(AppNotification item) {
    ref.read(notificationsProvider.notifier).deleteNotification(item.id);
  }

  void _showSnackBar(String message) {
    AppSnackBar.showInfo(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$err', textAlign: TextAlign.center),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(notificationsProvider.notifier).refresh(),
                    child: Text(context.loc.retry),
                  ),
                ],
              ),
            ),
          ),
          data: (feed) {
            final allNotifications = feed.items;
            final filtered = _filterNotifications(allNotifications);

            return Column(
              children: [
                _buildHeader(allNotifications.isNotEmpty),
                _buildFilterTabs(allNotifications.length, feed.unreadCount),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () =>
                        ref.read(notificationsProvider.notifier).refresh(),
                    child: filtered.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 80.h),
                              _buildEmptyState(),
                            ],
                          )
                        : _buildNotificationList(filtered, feed),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool hasNotifications) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              onSelected: (value) {
                if (value == 'markRead') {
                  _markAllAsRead();
                } else if (value == 'clear') {
                  _clearAll();
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

  Widget _buildFilterTabs(int totalCount, int unreadCount) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          _filterChip(
            index: 0,
            label: context.loc.notificationsAll,
            count: totalCount,
          ),
          SizedBox(width: 10.w),
          _filterChip(
            index: 1,
            label: context.loc.notificationsUnread,
            count: unreadCount,
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required int index,
    required String label,
    required int count,
  }) {
    final isSelected = _selectedFilterIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.black : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16.5.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.neutral200,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 36,
                color: AppColors.textTertiary,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              context.loc.noNotifications,
              style: TextStyle(
                fontSize: 20.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              context.loc.noNotificationsSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.5.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    List<AppNotification> items,
    NotificationsFeedState feed,
  ) {
    final todayItems = items.where((i) => i.dateGroup == 'today').toList();
    final yesterdayItems = items
        .where((i) => i.dateGroup == 'yesterday')
        .toList();
    final earlierItems = items.where((i) => i.dateGroup == 'earlier').toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 24.h),
      children: [
        if (todayItems.isNotEmpty) ...[
          _buildGroupHeader(context.loc.notifToday),
          ...todayItems.map(_buildNotificationCard),
          SizedBox(height: 12.h),
        ],
        if (yesterdayItems.isNotEmpty) ...[
          _buildGroupHeader(context.loc.notifYesterday),
          ...yesterdayItems.map(_buildNotificationCard),
          SizedBox(height: 12.h),
        ],
        if (earlierItems.isNotEmpty) ...[
          _buildGroupHeader(context.loc.notifEarlier),
          ...earlierItems.map(_buildNotificationCard),
        ],
        if (feed.hasMore)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Center(
              child: feed.isLoadingMore
                  ? const CircularProgressIndicator()
                  : OutlinedButton(
                      onPressed: () =>
                          ref.read(notificationsProvider.notifier).loadMore(),
                      child: Text(context.loc.viewAll),
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h, top: 4.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 14.5.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification item) {
    final iconData = _getIconForType(item.type);
    final iconColor = _getColorForType(item.type);
    final iconBg = _getBgColorForType(item.type);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(item),
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
        onTap: () => _markAsRead(item),
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
                    Row(
                      children: [
                        if (item.projectTag != null) ...[
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
                          SizedBox(width: 8.w),
                        ],
                        Text(
                          item.displayTime,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}
