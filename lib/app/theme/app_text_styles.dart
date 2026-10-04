import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static late TextTheme _textTheme;

  static void initialize(TextTheme textTheme) {
    _textTheme = textTheme;
  }

  static TextStyle get displayLarge => _textTheme.displayLarge!;

  static TextStyle get displayMedium => _textTheme.displayMedium!;

  static TextStyle get displaySmall => _textTheme.displaySmall!;

  static TextStyle get headlineLarge => _textTheme.headlineLarge!;

  static TextStyle get headlineMedium => _textTheme.headlineMedium!;

  static TextStyle get headlineSmall => _textTheme.headlineSmall!;

  static TextStyle get titleLarge => _textTheme.titleLarge!;

  static TextStyle get titleMedium => _textTheme.titleMedium!;

  static TextStyle get titleSmall => _textTheme.titleSmall!;

  static TextStyle get bodyLarge => _textTheme.bodyLarge!;

  static TextStyle get bodyMedium => _textTheme.bodyMedium!;

  static TextStyle get bodySmall => _textTheme.bodySmall!;

  static TextStyle get labelLarge => _textTheme.labelLarge!;

  static TextStyle get labelMedium => _textTheme.labelMedium!;

  static TextStyle get labelSmall => _textTheme.labelSmall!;

  static TextStyle get button =>
      _textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w700);

  static TextStyle get caption =>
      _textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w400);
}
