import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String plusJakartaSans = 'Plus Jakarta Sans';
  static const String raleway = 'Raleway';
  static const String inter = 'Inter';

  // ---------------------------------------------------------------------------
  // Display / Marketing
  // ---------------------------------------------------------------------------

  static TextStyle get displayLarge => TextStyle(
    fontFamily: raleway,
    fontSize: 34.sp,
    height: 1.18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => TextStyle(
    fontFamily: raleway,
    fontSize: 30.sp,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static TextStyle get displaySmall => TextStyle(
    fontFamily: raleway,
    fontSize: 20.sp,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Headings
  // ---------------------------------------------------------------------------

  static TextStyle get headlineLarge => TextStyle(
    fontFamily: plusJakartaSans,
    fontSize: 26.sp,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontFamily: plusJakartaSans,
    fontSize: 22.sp,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineSmall => TextStyle(
    fontFamily: plusJakartaSans,
    fontSize: 20.sp,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Titles
  // ---------------------------------------------------------------------------

  static TextStyle get titleLarge => TextStyle(
    fontFamily: plusJakartaSans,
    fontSize: 18.sp,
    height: 1.35,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => TextStyle(
    fontFamily: plusJakartaSans,
    fontSize: 16.sp,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleSmall => TextStyle(
    fontFamily: plusJakartaSans,
    fontSize: 14.sp,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  static TextStyle get bodyLarge => TextStyle(
    fontFamily: plusJakartaSans,
    fontSize: 16.sp,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: plusJakartaSans,
    fontSize: 14.sp,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: plusJakartaSans,
    fontSize: 12.sp,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  // ---------------------------------------------------------------------------
  // Labels
  // ---------------------------------------------------------------------------

  static TextStyle get labelLarge => TextStyle(
    fontFamily: inter,
    fontSize: 14.sp,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => TextStyle(
    fontFamily: inter,
    fontSize: 12.sp,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelSmall => TextStyle(
    fontFamily: inter,
    fontSize: 11.sp,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
  );

  // ---------------------------------------------------------------------------
  // Special
  // ---------------------------------------------------------------------------

  static TextStyle get button => TextStyle(
    fontFamily: plusJakartaSans,
    fontSize: 15.sp,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: inter,
    fontSize: 11.sp,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );
}
