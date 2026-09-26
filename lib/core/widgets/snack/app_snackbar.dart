import 'package:construction_app/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

enum AppSnackBarType { success, error, info, warning }

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    final isError = type == AppSnackBarType.error;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? AppColors.errorDark
              : AppColors.successDark,
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

  static void success(BuildContext context, String message) {
    show(context, message: message, type: AppSnackBarType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: AppSnackBarType.error);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: AppSnackBarType.info);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: AppSnackBarType.warning);
  }
}
