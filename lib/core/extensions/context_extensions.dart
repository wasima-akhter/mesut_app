import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

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

  void showAppSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isError ? AppColors.error : AppColors.neutral900,
          content: Text(
            message,
            style: bodyMedium.copyWith(color: AppColors.white),
          ),
        ),
      );
  }
}
