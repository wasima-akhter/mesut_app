import 'package:flutter/material.dart';

class ResponsiveHelper {
  ResponsiveHelper._();

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= 600;
  }

  static bool isPhone(BuildContext context) {
    return !isTablet(context);
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  static EdgeInsets safePadding(BuildContext context) {
    return MediaQuery.paddingOf(context);
  }

  static EdgeInsets viewInsets(BuildContext context) {
    return MediaQuery.viewInsetsOf(context);
  }
}
