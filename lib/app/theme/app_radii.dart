import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppRadii {
  AppRadii._();

  static double get xs => 4.r;
  static double get sm => 8.r;
  static double get md => 12.r;
  static double get lg => 16.r;
  static double get xl => 20.r;
  static double get xxl => 24.r;

  static double get pill => 999.r;

  static BorderRadius get small => BorderRadius.circular(sm);

  static BorderRadius get medium => BorderRadius.circular(md);

  static BorderRadius get large => BorderRadius.circular(lg);

  static BorderRadius get extraLarge => BorderRadius.circular(xl);

  static BorderRadius get pillRadius => BorderRadius.circular(pill);
}
