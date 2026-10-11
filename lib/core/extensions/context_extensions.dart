import 'package:flutter/material.dart';

import '../widgets/snack/app_snackbar.dart';

extension ContextExtensions on BuildContext {
  // ---------------------------------------------------------------------------
  // Screen
  // ---------------------------------------------------------------------------

  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  bool get isKeyboardOpen => MediaQuery.viewInsetsOf(this).bottom > 0;

  // ---------------------------------------------------------------------------
  // Text Styles
  // ---------------------------------------------------------------------------

  TextStyle get displayLarge => Theme.of(this).textTheme.displayLarge!;

  TextStyle get displayMedium => Theme.of(this).textTheme.displayMedium!;

  TextStyle get displaySmall => Theme.of(this).textTheme.displaySmall!;

  TextStyle get headlineLarge => Theme.of(this).textTheme.headlineLarge!;

  TextStyle get headlineMedium => Theme.of(this).textTheme.headlineMedium!;

  TextStyle get headlineSmall => Theme.of(this).textTheme.headlineSmall!;

  TextStyle get titleLarge => Theme.of(this).textTheme.titleLarge!;

  TextStyle get titleMedium => Theme.of(this).textTheme.titleMedium!;

  TextStyle get titleSmall => Theme.of(this).textTheme.titleSmall!;

  TextStyle get bodyLarge => Theme.of(this).textTheme.bodyLarge!;

  TextStyle get bodyMedium => Theme.of(this).textTheme.bodyMedium!;

  TextStyle get bodySmall => Theme.of(this).textTheme.bodySmall!;

  TextStyle get labelLarge => Theme.of(this).textTheme.labelLarge!;

  TextStyle get labelMedium => Theme.of(this).textTheme.labelMedium!;

  TextStyle get labelSmall => Theme.of(this).textTheme.labelSmall!;

  // ---------------------------------------------------------------------------
  // SnackBar
  // ---------------------------------------------------------------------------

  void showSuccessSnackBar(
    String message, {
    String? title,
    IconData? icon,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    AppSnackBar.showSuccess(
      this,
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

  void showErrorSnackBar(
    String message, {
    String? title,
    IconData? icon,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    AppSnackBar.showError(
      this,
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

  void showWarningSnackBar(
    String message, {
    String? title,
    IconData? icon,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    AppSnackBar.showWarning(
      this,
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

  void showInfoSnackBar(
    String message, {
    String? title,
    IconData? icon,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    AppSnackBar.showInfo(
      this,
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

  void showAppSnackBar(
    String message, {
    bool isError = false,
    AppSnackBarType? type,
    String? title,
    IconData? icon,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final resolvedType = type ??
        (isError ? AppSnackBarType.error : AppSnackBarType.info);
    AppSnackBar.show(
      context: this,
      message: message,
      type: resolvedType,
      title: title,
      icon: icon,
      showIcon: showIcon,
      duration: duration,
      action: action,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
