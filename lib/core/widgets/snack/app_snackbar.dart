import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

enum AppSnackBarType { success, error, warning, info }

class AppSnackBar {
  AppSnackBar._();

  static BuildContext? get _defaultContext =>
      appNavigatorKey.currentState?.overlay?.context ??
      appNavigatorKey.currentContext;

  static SnackBar create({
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    String? title,
    IconData? icon,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    String? actionLabel,
    VoidCallback? onAction,
    Color? backgroundColor,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    EdgeInsetsGeometry? margin,
  }) {
    final resolvedBg = backgroundColor ??
        switch (type) {
          AppSnackBarType.success => AppColors.successDark,
          AppSnackBarType.error => AppColors.errorDark,
          AppSnackBarType.warning => AppColors.warningDark,
          AppSnackBarType.info => AppColors.infoDark,
        };

    final resolvedIcon = icon ??
        (showIcon
            ? switch (type) {
                AppSnackBarType.success => Icons.check_circle_outline_rounded,
                AppSnackBarType.error => Icons.error_outline_rounded,
                AppSnackBarType.warning => Icons.warning_amber_rounded,
                AppSnackBarType.info => Icons.info_outline_rounded,
              }
            : null);

    final resolvedAction = action ??
        (actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: AppColors.white,
                onPressed: onAction,
              )
            : null);

    return SnackBar(
      behavior: behavior,
      backgroundColor: resolvedBg,
      duration: duration,
      margin: margin ?? EdgeInsets.all(16.r),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      action: resolvedAction,
      content: Row(
        children: [
          if (resolvedIcon != null) ...[
            Icon(
              resolvedIcon,
              color: AppColors.white,
              size: 22.sp,
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title.trim().isNotEmpty) ...[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? show({
    BuildContext? context,
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    String? title,
    IconData? icon,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    String? actionLabel,
    VoidCallback? onAction,
    Color? backgroundColor,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    EdgeInsetsGeometry? margin,
  }) {
    final targetContext = (context != null && context.mounted)
        ? context
        : _defaultContext;

    if (targetContext == null) return null;

    final messenger = ScaffoldMessenger.maybeOf(targetContext);
    if (messenger == null) return null;

    final snackBar = create(
      message: message,
      type: type,
      title: title,
      icon: icon,
      showIcon: showIcon,
      duration: duration,
      action: action,
      actionLabel: actionLabel,
      onAction: onAction,
      backgroundColor: backgroundColor,
      behavior: behavior,
      margin: margin,
    );

    messenger.hideCurrentSnackBar();
    return messenger.showSnackBar(snackBar);
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSuccess(
    BuildContext? context,
    String message, {
    String? title,
    IconData? icon,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return show(
      context: context,
      message: message,
      type: AppSnackBarType.success,
      title: title,
      icon: icon,
      showIcon: showIcon,
      duration: duration,
      action: action,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showError(
    BuildContext? context,
    String message, {
    String? title,
    IconData? icon,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return show(
      context: context,
      message: message,
      type: AppSnackBarType.error,
      title: title,
      icon: icon,
      showIcon: showIcon,
      duration: duration,
      action: action,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showWarning(
    BuildContext? context,
    String message, {
    String? title,
    IconData? icon,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return show(
      context: context,
      message: message,
      type: AppSnackBarType.warning,
      title: title,
      icon: icon,
      showIcon: showIcon,
      duration: duration,
      action: action,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showInfo(
    BuildContext? context,
    String message, {
    String? title,
    IconData? icon,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return show(
      context: context,
      message: message,
      type: AppSnackBarType.info,
      title: title,
      icon: icon,
      showIcon: showIcon,
      duration: duration,
      action: action,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  // ---------------------------------------------------------------------------
  // Context-optional convenience helpers
  // ---------------------------------------------------------------------------

  static void success(
    String message, {
    BuildContext? context,
    String? title,
    IconData? icon,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showSuccess(
      context,
      message,
      title: title,
      icon: icon,
      showIcon: showIcon,
      duration: duration,
      action: action,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void error(
    String message, {
    BuildContext? context,
    String? title,
    IconData? icon,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showError(
      context,
      message,
      title: title,
      icon: icon,
      showIcon: showIcon,
      duration: duration,
      action: action,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void warning(
    String message, {
    BuildContext? context,
    String? title,
    IconData? icon,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showWarning(
      context,
      message,
      title: title,
      icon: icon,
      showIcon: showIcon,
      duration: duration,
      action: action,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void info(
    String message, {
    BuildContext? context,
    String? title,
    IconData? icon,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showInfo(
      context,
      message,
      title: title,
      icon: icon,
      showIcon: showIcon,
      duration: duration,
      action: action,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void hide({BuildContext? context}) {
    final targetContext = (context != null && context.mounted)
        ? context
        : _defaultContext;
    if (targetContext != null) {
      ScaffoldMessenger.maybeOf(targetContext)?.hideCurrentSnackBar();
    }
  }

  static void clear({BuildContext? context}) {
    final targetContext = (context != null && context.mounted)
        ? context
        : _defaultContext;
    if (targetContext != null) {
      ScaffoldMessenger.maybeOf(targetContext)?.clearSnackBars();
    }
  }
}
