import 'package:construction_app/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

enum AppSnackBarType { success, error, info, warning }

class AppSnackBar {
  AppSnackBar._();

  static BuildContext? get _context =>
      appNavigatorKey.currentState?.overlay?.context;

  static void show({
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    final context = _context;

    if (context == null) return;

    final messenger = ScaffoldMessenger.maybeOf(context);

    if (messenger == null) return;

    final backgroundColor = switch (type) {
      AppSnackBarType.success => AppColors.successDark,
      AppSnackBarType.error => AppColors.errorDark,
      AppSnackBarType.info => AppColors.infoDark,
      AppSnackBarType.warning => AppColors.warningDark,
    };

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            message,
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.white),
          ),
        ),
      );
  }

  static void success(String message) {
    show(message: message, type: AppSnackBarType.success);
  }

  static void error(String message) {
    show(message: message, type: AppSnackBarType.error);
  }

  static void info(String message) {
    show(message: message, type: AppSnackBarType.info);
  }

  static void warning(String message) {
    show(message: message, type: AppSnackBarType.warning);
  }
}
