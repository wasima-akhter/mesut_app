import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.size,
  });

  final Widget icon;
  final VoidCallback? onPressed;

  final String? tooltip;

  final Color? backgroundColor;
  final Color? foregroundColor;

  final double? size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: icon,
      color: foregroundColor ?? AppColors.textPrimary,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.surface,
        minimumSize: Size(size ?? 44.r, size ?? 44.r),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.medium),
      ),
    );
  }
}
