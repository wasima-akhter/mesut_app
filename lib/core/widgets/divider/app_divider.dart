import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.indent, this.endIndent});

  final double? indent;
  final double? endIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppColors.border,
      thickness: 1,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
