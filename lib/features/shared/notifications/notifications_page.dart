import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localization/context_extensions.dart';
import '../../../core/localization/pending_refetch_controller.dart';
import '../../../core/widgets/snack/app_snackbar.dart';
import '../../../core/widgets/states/app_error_widget.dart';
import 'domain/entities/notification_entity.dart';
import 'presentation/providers/notifications_provider.dart';
import 'presentation/widgets/notification_empty_state.dart';
import 'presentation/widgets/notification_header.dart';
import 'presentation/widgets/notification_list_view.dart';

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
    AppSnackBar.showInfo(context, context.loc.markedAsRead);
  }

  void _clearAll() {
    ref.read(notificationsProvider.notifier).clearAll();
    AppSnackBar.showInfo(context, context.loc.allCleared);
  }

  void _markAsRead(AppNotification item) {
    if (!item.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(item.id);
    }
  }

  void _deleteNotification(AppNotification item) {
    ref.read(notificationsProvider.notifier).deleteNotification(item.id);
  }

  void _onBack() {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final hasNotifications =
        notificationsAsync.asData?.value.items.isNotEmpty ?? false;
    final hasPendingTranslations = anyLocalizationPending(
      (notificationsAsync.asData?.value.items ?? const [])
          .map((n) => n.localization),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: PendingPollEffect(
          hasPending: hasPendingTranslations,
          onPoll: () => ref.read(notificationsProvider.notifier).refresh(),
          child: Column(
            children: [
              NotificationHeader(
                hasNotifications: hasNotifications,
                onBack: _onBack,
                onMarkAllAsRead: _markAllAsRead,
                onClearAll: _clearAll,
              ),
              Expanded(
                child: notificationsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => AppErrorWidget(
                    error: err,
                    showBackButton: true,
                    onBack: _onBack,
                    onRetry: () =>
                        ref.read(notificationsProvider.notifier).refresh(),
                  ),
                  data: (feed) {
                    final allNotifications = feed.items;
                    final filtered = _filterNotifications(allNotifications);

                    return Column(
                      children: [
                        _buildFilterTabs(
                          allNotifications.length,
                          feed.unreadCount,
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () => ref
                                .read(notificationsProvider.notifier)
                                .refresh(),
                            child: filtered.isEmpty
                                ? ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      SizedBox(height: 80.h),
                                      const NotificationEmptyState(),
                                    ],
                                  )
                                : NotificationListView(
                                    items: filtered,
                                    feed: feed,
                                    onMarkAsRead: _markAsRead,
                                    onDelete: _deleteNotification,
                                    onLoadMore: () => ref
                                        .read(notificationsProvider.notifier)
                                        .loadMore(),
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
}
