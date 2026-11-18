import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_radii.dart';

class AppTheme {
  AppTheme._();

  static ThemeData? _cachedLight;

  static ThemeData get light => _cachedLight ??= _buildLight();

  static void invalidateCache() {
    _cachedLight = null;
  }

  static ThemeData _buildLight() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.primary500,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.white,
      ),

      fontFamily: 'PlusJakartaSans',

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Raleway',
          fontSize: 37.5.sp,
          height: 1.18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Raleway',
          fontSize: 33.5.sp,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Raleway',
          fontSize: 23.5.sp,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),

        headlineLarge: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 29.5.sp,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 25.5.sp,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 23.5.sp,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),

        titleLarge: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 21.5.sp,
          height: 1.35,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 19.5.sp,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 17.5.sp,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),

        bodyLarge: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 19.5.sp,
          height: 1.5,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 17.5.sp,
          height: 1.5,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 15.5.sp,
          height: 1.45,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiary,
        ),

        labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17.5.sp,
          height: 1.35,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15.5.sp,
          height: 1.35,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14.5.sp,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 21.5.sp,
          height: 1.35,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.large),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 17.5.sp,
          height: 1.5,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: AppDimensions.bottomNavigationHeight,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary100,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.5.sp,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
          ),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.neutral900,
        contentTextStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 17.5.sp,
          height: 1.5,
          fontWeight: FontWeight.w400,
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.medium),
      ),
    );
  }
}
