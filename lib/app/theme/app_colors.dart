import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand / Primary
  // ---------------------------------------------------------------------------

  static const Color primary50 = Color(0xFFFDE8EB);
  static const Color primary100 = Color(0xFFFCDDE1);
  static const Color primary200 = Color(0xFFF8B9C1);
  static const Color primary400 = Color(0xFFE91C37);
  static const Color primary500 = Color(0xFFD21932);
  static const Color primary600 = Color(0xFFBA162C);
  static const Color primary700 = Color(0xFFAF1529);
  static const Color primary800 = Color(0xFF8C1121);
  static const Color primary900 = Color(0xFF690D19);
  static const Color primary950 = Color(0xFF520A13);

  static const Color primary = primary600;

  // ---------------------------------------------------------------------------
  // Neutral
  // ---------------------------------------------------------------------------

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color neutral25 = Color(0xFFFCFCFD);
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color neutral100 = Color(0xFFF2F4F7);
  static const Color neutral200 = Color(0xFFE4E7EC);
  static const Color neutral300 = Color(0xFFD0D5DD);
  static const Color neutral400 = Color(0xFF98A2B3);
  static const Color neutral500 = Color(0xFF667085);
  static const Color neutral600 = Color(0xFF475467);
  static const Color neutral700 = Color(0xFF344054);
  static const Color neutral800 = Color(0xFF1D2939);
  static const Color neutral900 = Color(0xFF101828);

  // ---------------------------------------------------------------------------
  // Semantic
  // ---------------------------------------------------------------------------

  static const Color success = Color(0xFF12B76A);
  static const Color successLight = Color(0xFFECFDF3);
  static const Color successDark = Color(0xFF027A48);

  static const Color warning = Color(0xFFF79009);
  static const Color warningLight = Color(0xFFFFFAEB);
  static const Color warningDark = Color(0xFFB54708);

  static const Color error = Color(0xFFD92D20);
  static const Color errorLight = Color(0xFFFEF3F2);
  static const Color errorDark = Color(0xFFB42318);

  static const Color info = Color(0xFF2E90FA);
  static const Color infoLight = Color(0xFFEFF8FF);
  static const Color infoDark = Color(0xFF175CD3);

  // ---------------------------------------------------------------------------
  // Background
  // ---------------------------------------------------------------------------

  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = white;
  static const Color surfaceSecondary = neutral50;
  static const Color surfaceTertiary = neutral100;

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  static const Color textPrimary = neutral900;
  static const Color textSecondary = neutral600;
  static const Color textTertiary = neutral500;
  static const Color textDisabled = neutral400;
  static const Color textOnPrimary = white;

  // ---------------------------------------------------------------------------
  // Border
  // ---------------------------------------------------------------------------

  static const Color border = neutral200;
  static const Color borderLight = neutral100;
  static const Color borderDark = neutral300;

  // ---------------------------------------------------------------------------
  // Overlay
  // ---------------------------------------------------------------------------

  static const Color overlay = Color(0x66000000);
  static const Color scrim = Color(0x52000000);
}
