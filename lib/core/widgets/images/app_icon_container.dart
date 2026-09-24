import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_radii.dart';

class AppIconContainer extends StatelessWidget {
  const AppIconContainer({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.size,
  });

  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final containerSize = size ?? AppDimensions.iconContainerMedium;

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary100,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: containerSize * 0.5,
        color: iconColor ?? AppColors.primary600,
      ),
    );
  }
}
