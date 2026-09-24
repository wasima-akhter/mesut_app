import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get small => const [
    BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static List<BoxShadow> get medium => const [
    BoxShadow(color: Color(0x12000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static List<BoxShadow> get large => const [
    BoxShadow(color: Color(0x18000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
}
