import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';

class AppFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? icon;
  final IconData? iconData;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final String? tooltip;
  final ShapeBorder? shape;

  const AppFloatingActionButton({
    super.key,
    required this.onPressed,
    this.icon,
    this.iconData,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.tooltip,
    this.shape,
  }) : assert(icon != null || iconData != null, 'Either icon or iconData must be provided');

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primary;
    final fg = foregroundColor ?? AppColors.white;
    final iconWidget = icon ?? Icon(iconData, size: 22.sp, color: fg);

    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: elevation ?? 2,
        tooltip: tooltip,
        shape: shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        icon: iconWidget,
        label: Text(
          label!,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: elevation ?? 2,
      tooltip: tooltip,
      shape: shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: iconWidget,
    );
  }
}
