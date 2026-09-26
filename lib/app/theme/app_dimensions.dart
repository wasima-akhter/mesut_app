import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDimensions {
  AppDimensions._();

  // Buttons
  static double get buttonHeight => 52.h;
  static double get buttonHeightSmall => 44.h;
  static double get buttonHeightLarge => 56.h;

  // Fields
  static double get fieldHeight => 52.h;
  static double get fieldHeightLarge => 56.h;

  // Icons
  static double get iconXs => 14.r;
  static double get iconSm => 18.r;
  static double get iconMd => 22.r;
  static double get iconLg => 24.r;
  static double get iconXl => 28.r;
  static double get iconXxl => 32.r;

  // Avatars
  static double get avatarSmall => 32.r;
  static double get avatarMedium => 44.r;
  static double get avatarLarge => 56.r;
  static double get avatarXLarge => 80.r;

  // Navigation
  static double get bottomNavigationHeight => 72.h;

  // Images
  static double get thumbnailSmall => 56.r;
  static double get thumbnailMedium => 80.r;
  static double get thumbnailLarge => 120.r;

  // Border radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusRound = 999;

  // Dialog
  static double get dialogMaxWidth => 420.w;

  // Bottom sheet
  static double get bottomSheetRadius => 24.r;

  static double get spacing16 => 16.w;
  static double get radius12 => 12.r;
  static double get appBarHeight => 50.h;

  static double get iconContainerMedium => 20.h;

  //
  // Dividers
  static const double dividerThickness = 1;

  // Loading indicators
  static const double loaderSize = 24;
  static const double loaderStrokeWidth = 2;

  // Spacing
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingLg = 16;

  static const double errorIconSize = 48.0;
  static const double emptyIconSize = 48.0;
}
